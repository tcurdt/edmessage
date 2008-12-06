//---------------------------------------------------------------------------------------
//  EDSparseClusterArray.m created by erik on Fri 28-May-1999
//  @(#)$Id: EDSparseClusterArray.m,v 2.1 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 1999 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "EDSparseClusterArray.h"


@interface EDSparseClusterArray(PrivateAPI)
- (NSMapTable *)_pageTable;
- (unsigned int)_pageSize;
@end


@interface _EDSCAEnumerator : NSEnumerator
{
    EDSparseClusterArray *array;
    uintptr_t			 *pnumList;
    unsigned int		 pnlCount, pageSize;
    unsigned int		 pnlidx, eidx;
}
- (id)initWithSparseClusterArray:(EDSparseClusterArray *)anArray;
@end


void EDSCARetain(NSMapTable *table, const void *page);
void EDSCARelease(NSMapTable *table, void *page);
NSString *EDSCADescribe(NSMapTable *table, const void *page);
int EDSCACompare(const void *a, const void *b); 


typedef struct
{
    unsigned int active;
    unsigned int retainCount;
    id 		 	 entries[0];
} EDSCAPage;



//---------------------------------------------------------------------------------------
    @implementation EDSparseClusterArray
//---------------------------------------------------------------------------------------

/*" NSArrays do not allow "gaps" between the objects. This can be worked around with a dedicated marker object for empty positions but when these gaps become large storage and the count operation become inefficient. #EDSparseClusterArray solves these problems to a certain extent. It works well when larger groups of objects, i.e. a few hundred objects, are separated by few small gaps and these groups (or clusters) are separated by arbitrarily large gaps. Hence the name EDSparse%{Cluster}Array. "*/

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated sparse cluster array. "*/

- init
{
    [super init];

    pageTable = NSCreateMapTableWithZone(NSNonOwnedPointerOrNullMapKeyCallBacks, (NSMapTableValueCallBacks) { EDSCARetain, EDSCARelease, EDSCADescribe }, 0, [self zone]);
    pageSize = (NSPageSize() - sizeof(EDSCAPage)) / sizeof(id);
    
    return self;
}


- (void)dealloc
{
    NSFreeMapTable(pageTable);
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION & COMPARISONS
//---------------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ 0x%x: %@>", NSStringFromClass(isa), (void *)self, [self allObjects]];
}


//---------------------------------------------------------------------------------------
//	PRIVATE ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (NSMapTable *)_pageTable
{
    return pageTable;
}


- (unsigned int)_pageSize
{
    return pageSize;
}


//---------------------------------------------------------------------------------------
//	STORING/RETRIEVING OBJECTS BY INDEX
//---------------------------------------------------------------------------------------

/*" Stores anObject in the slot %index of the receiver. Index can be arbitrarily large without affecting performance. The object receives a #retain message. 

If the slot is already occupied, the object at the index is removed and receives a #release message.

This method raises an NSInvalidArgumentException if anObject is !{nil}."*/

- (void)setObject:(id)anObject atIndex:(NSUInteger)index
{
    NSUInteger	pnum, eidx;
    EDSCAPage	*page;
    id			previousObject;

    if(anObject == nil)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to insert *nil* at index %d.", NSStringFromClass(isa), NSStringFromSelector(_cmd), index];
    
    pnum = index / pageSize;
    eidx = index % pageSize;

    if((page = NSMapGet(pageTable, (void *)pnum)) == NULL)
        {
        page = NSAllocateMemoryPages(1); // rounded up to page size...
        NSMapInsertKnownAbsent(pageTable, (void *)pnum, page);
        }

    if((previousObject = page->entries[eidx]) != nil)
        [previousObject release];
    else
        page->active += 1;

    page->entries[eidx] = [anObject retain];
}


/*" Removes the object stored in  slot %index from the receiver. The object receives a #release message.

This method raises an NSInvalidArgumentException if the slot was empty."*/

- (void)removeObjectAtIndex:(NSUInteger)index
{
    NSUInteger	pnum, eidx;
    EDSCAPage	*page;

    pnum = index / pageSize;
    eidx = index % pageSize;

    if(((page = NSMapGet(pageTable, (void *)pnum)) == NULL) || ((page->entries[eidx]) == nil))
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to remove an object that is not in the array (index %d).", NSStringFromClass(isa), NSStringFromSelector(_cmd), index];

    [page->entries[eidx] release];
    page->entries[eidx] = nil;
    page->active -= 1;

    if(page->active == 0)
        NSMapRemove(pageTable, (void *)pnum);
}


/*" Returns the object located at index, or !{nil} if the slot was empty. "*/

- (id)objectAtIndex:(NSUInteger)index
{
    NSUInteger	pnum, eidx;
    EDSCAPage	*page;

    pnum = index / pageSize;
    eidx = index % pageSize;

    if(((page = NSMapGet(pageTable, (void *)pnum)) == NULL) || ((page->entries[eidx]) == nil))
        return nil;

    return page->entries[eidx];
}


//---------------------------------------------------------------------------------------
//	ACCESSING THE OBJECT SET
//---------------------------------------------------------------------------------------

/*" Returns the number of objects in the receiver. "*/

- (NSUInteger)count
{
    NSMapEnumerator	mapEnum;
    unsigned int	count, pnum;
    EDSCAPage		*page;
    
    count = 0;
    mapEnum = NSEnumerateMapTable(pageTable);
    while(NSNextMapEnumeratorPair(&mapEnum, (void **)&pnum, (void **)&page))
        count += page->active;

    return count;
}


/*"  Returns an enumerator object that lets you access all indeces for occupied slots in the receiver, in order, starting with the smallest index. You should not modify the receiver while using the enumerator. For a more detailed explanation and sample code see the description of #keyEnumerator in #NSDictionary. "*/

- (NSEnumerator *)indexEnumerator
{
    return [[[_EDSCAEnumerator allocWithZone:[self zone]] initWithSparseClusterArray:self] autorelease];
}


/*" Returns an array containing the receiver's objects, or an empty array if the receiver has no objects. The order of the objects in the array is the same as in the receiver. "*/

- (NSArray *)allObjects
{
    
    NSMutableArray	*allObjects;
    EDSCAPage		*page;
    NSMapEnumerator	mapEnum;
    id				entry;
    NSUInteger		*pnumList, pnlCount, pnum, pnlidx, eidx;
    
    pnlCount = NSCountMapTable(pageTable);
    pnumList = NSZoneMalloc([self zone], pnlCount * sizeof(int));
    mapEnum = NSEnumerateMapTable(pageTable);
    pnlidx = 0;
    while(NSNextMapEnumeratorPair(&mapEnum, (void **)&pnum, (void **)&page))
        pnumList[pnlidx++] = pnum;
    qsort(pnumList, pnlCount, sizeof(int), EDSCACompare);

    pnlidx = 0;
    allObjects = [[[NSMutableArray allocWithZone:[self zone]] init] autorelease];
    while(pnlidx < pnlCount)
        {
        page = NSMapGet(pageTable, (void *)pnumList[pnlidx++]);
        eidx = 0;
        while(eidx < pageSize)
            {
            if((entry = page->entries[eidx++]) != nil)
                [allObjects addObject:entry];
            }
        }

    NSZoneFree([self zone], pnumList);

    return allObjects;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation _EDSCAEnumerator
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithSparseClusterArray:(EDSparseClusterArray *)anArray
{
    EDSCAPage		*page;
    NSMapEnumerator mapEnum;
    unsigned int	pnum;
    
    [super init];
    
    array = [anArray retain];
    pageSize = [array _pageSize];
    pnlCount = NSCountMapTable([array _pageTable]);
    pnumList = NSZoneMalloc([self zone], pnlCount * sizeof(int));
    mapEnum = NSEnumerateMapTable([array _pageTable]);
    pnlidx = 0;
    while(NSNextMapEnumeratorPair(&mapEnum, (void **)&pnum, (void **)&page))
        pnumList[pnlidx++] = pnum;
    qsort(pnumList, pnlCount, sizeof(int), EDSCACompare);
    pnlidx = 0;
    eidx = 0;
    
    return self;
}


- (void)dealloc
{
    NSZoneFree([self zone], pnumList);
    [array release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ENUMERATOR INTERFACE IMPLEMENTATION
//---------------------------------------------------------------------------------------

- (id)nextObject
{
    EDSCAPage	 *page;
    id 			 entry;
    NSUInteger	 index;

    entry = nil; index = 0;
    while((entry == nil) && (pnlidx < pnlCount))
        {
        page = NSMapGet([array _pageTable], (void *)pnumList[pnlidx]);
        while((entry == nil) && (eidx < pageSize))
            entry = page->entries[eidx++];

        index = pnumList[pnlidx] * pageSize + eidx - 1;

        if(eidx >= pageSize)
            {
            pnlidx += 1;
            eidx = 0;
            }
        }

    return (entry != nil) ? [NSNumber numberWithUnsignedInt:index] : nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
//	VALUE CALL BACK FUNCTIONS
//---------------------------------------------------------------------------------------

void EDSCARetain(NSMapTable *table, const void *page)
{
    //NSLog(@"#p# retain %@", EDSCADescribe(table, page));
    ((EDSCAPage *)page)->retainCount += 1;
}


void EDSCARelease(NSMapTable *table, void *page)
{
    //NSLog(@"#p# release %@", EDSCADescribe(table, page));
    ((EDSCAPage *)page)->retainCount -= 1;
    if(((EDSCAPage *)page)->retainCount < 1)
        NSDeallocateMemoryPages(page, 1);
}


NSString *EDSCADescribe(NSMapTable *table, const void *page)
{
    const EDSCAPage *p = page;
    return [NSString stringWithFormat:@"{ rcount = %d; active = %d }", p->retainCount, p->active];
}


//---------------------------------------------------------------------------------------
//	SORT CALLBACK FUNCTION
//---------------------------------------------------------------------------------------

int EDSCACompare(const void *a, const void *b)
{
    // okay, they are unsigned ints, but this way it's easy and
    // the numbers cannot be that large anyway.
    return *(int *)a - *(int *)b;
}



