//---------------------------------------------------------------------------------------
//  EDSortedArray.h created by erik on Sun 13-Sep-1998
//  @(#)$Id: EDSortedArray.h,v 2.1 2003-01-19 22:47:27 erik Exp $
//
//  Copyright (c) 1998-1999 by Erik Doernenburg. All rights reserved.
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

@interface EDSortedArray : NSObject
{
    SEL		comparator;		/*" All instance variables are private. "*/
    void	*sentinel;		 /*" "*/
    void 	*rootNode;		/*" "*/
    void 	*minimumNode;	/*" "*/
}

/*" Creating sorted arrays "*/
- (id)init;
- (id)initWithComparisonSelector:(SEL)aSelector;

/*" Adding and removing objects "*/
- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)someObjects;
- (void)removeObject:(id)anObject;
- (void)removeObjectAtIndex:(NSUInteger)index;

/*" Querying the array "*/
- (NSUInteger)count;
- (id)minimumObject;
- (id)maximumObject;
- (BOOL)containsObject:(id)anObject;
- (id)member:(id)anObject;
- (id)smallerOrEqualMember:(id)anObject;
- (id)successorForObject:(id)anObject;
- (id)objectAtIndex:(NSUInteger)index;
- (NSUInteger)indexOfObject:(id)anObject;
- (NSEnumerator *)objectEnumerator;
- (NSArray *)allObjects;

/*" Retrieving the comparison selector "*/
- (SEL)comparisonSelector;


@end
