//---------------------------------------------------------------------------------------
//  NSSet+Extensions.m created by erik on Sat 10-Mar-2001
//  $Id: NSSet+Extensions.m,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 2000 by Erik Doernenburg. All rights reserved.
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
#import "EDObjcRuntime.h"
#import "NSSet+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSSet(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSSet. "*/

/*" Adds all objects from %otherSet to the receiver. "*/

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)otherSet
{
    NSMutableSet	*temp;

    temp = [[[NSMutableSet allocWithZone:[self zone]] initWithSet:self] autorelease];
    [temp unionSet:otherSet];

    return temp;
}


/*" Adds all objects from %anArray to the receiver. "*/

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)anArray
{
    NSMutableSet	*temp;

    temp = [[[NSMutableSet allocWithZone:[self zone]] initWithSet:self] autorelease];
    [temp addObjectsFromArray:anArray];

    return temp;
}


//---------------------------------------------------------------------------------------

/*" Uses each object in the receiver as a key and looks up the corresponding value in %mapping. All these values are added to the set returned. Note that this method raises an exception if any of the objects in the receiver is not found as a key in %mapping. Note also, that the returned set can be smaller than the receiver. "*/

- (NSSet *)setByMappingWithDictionary:(NSDictionary *)mapping
{
    NSMutableSet	*mappedSet;
    NSEnumerator	*objectEnum;
    id				object;

    mappedSet = [[[NSMutableSet allocWithZone:[self zone]] initWithCapacity:[self count]] autorelease];
    objectEnum = [self objectEnumerator];
    while((object = [objectEnum nextObject]) != nil)
        [mappedSet addObject:[mapping objectForKey:object]];

    return mappedSet;
}


/*" Invokes the method described by %selector in each object in the receiver. All returned values are added to the set returned. Note that the returned set can be smaller than the receiver. "*/

- (NSSet *)setByMappingWithSelector:(SEL)selector
{
    NSMutableSet	*mappedSet;
    NSEnumerator	*objectEnum;
    id				object;

    mappedSet = [[[NSMutableSet allocWithZone:[self zone]] initWithCapacity:[self count]] autorelease];
    objectEnum = [self objectEnumerator];
    while((object = [objectEnum nextObject]) != nil)
        [mappedSet addObject:EDObjcMsgSend(object, selector)];

    return mappedSet;
}


/*" Invokes the method described by %selector in each object in the receiver passing %object as an argument. All returned values are added to the set returned. Note that the returned set can be smaller than the receiver. "*/

- (NSSet *)setByMappingWithSelector:(SEL)selector withObject:(id)otherObject
{
    NSMutableSet	*mappedSet;
    NSEnumerator	*objectEnum;
    id				object;

    mappedSet = [[[NSMutableSet allocWithZone:[self zone]] initWithCapacity:[self count]] autorelease];
    objectEnum = [self objectEnumerator];
    while((object = [objectEnum nextObject]) != nil)
        [mappedSet addObject:EDObjcMsgSend1(object, selector, otherObject)];

    return mappedSet;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
