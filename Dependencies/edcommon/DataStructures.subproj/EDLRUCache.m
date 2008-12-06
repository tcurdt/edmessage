//---------------------------------------------------------------------------------------
//  EDLRUCache.m created by erik on Fri 29-Oct-1999
//  @(#)$Id: EDLRUCache.m,v 2.1 2003-04-08 16:51:33 znek Exp $
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
#import "NSDate+Extensions.h"
#import "EDLRUCache.h"


//---------------------------------------------------------------------------------------
    @implementation EDLRUCache
//---------------------------------------------------------------------------------------

/*" A simple Last-Recently-Used cache. When the cache is full, as defined by by its size, and an object is added, the object that has not been accessed for the longest time is automatically removed. Currently, only very basic operations are supported but implementing additions should be straightforward when requried.

This datastructure does not implement the copying and coding protocols as caches are usually required in the context of algorithms, rather than data storage.

"*/


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated LRU cache to store count items. "*/

- (id)initWithCacheSize:(NSUInteger)count
{
    [super init];
    NSParameterAssert(count > 0);
    size = count;
    entries = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:size];
    timestamps = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:size];
    return self;
}


- (void)dealloc
{
    [entries release];
    [timestamps release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Adds an entry to the receiver, consisting of newKey and its corresponding value object newObject. For details on the operation please see the discussion in #NSDictionary. "*/

- (void)addObject:(id)newObject withKey:(id)newKey
{
    NSDate			*date, *earliestDate;
    NSEnumerator	*keyEnum;
    id				key, keyForEarliestDate;

    while([entries count] >= size)
        {
        earliestDate = nil;
        keyForEarliestDate = nil; // keep compiler happy
        keyEnum = [timestamps keyEnumerator];
        while((key = [keyEnum nextObject]) != nil)
            {
            date = [timestamps objectForKey:key];
            if((earliestDate == nil) || ([date precedesDate:earliestDate]))
                {
                earliestDate = date;
                keyForEarliestDate = key;
                }
            }
        [entries removeObjectForKey:keyForEarliestDate];
        [timestamps removeObjectForKey:keyForEarliestDate];
        }

    [entries setObject:newObject forKey:newKey];
    [timestamps setObject:[NSDate date] forKey:newKey];
}


/*" Returns an entry's value given its key, or !{nil} if no value is associated with %aKey. "*/

- (id)objectWithKey:(id)aKey
{
    id	object;

    if((object = [entries objectForKey:aKey]) != nil)
        [timestamps setObject:[NSDate date] forKey:aKey];
    return object;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
