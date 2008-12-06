//---------------------------------------------------------------------------------------
//  EDKeyValuePair.m created by erik on Sat 29-Aug-1998
//  @(#)$Id: EDObjectPair.m,v 2.1 2003-04-08 16:51:34 znek Exp $
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
#import "EDMutableObjectPair.h" // need to know subclass for mutable copying
#import "EDObjectPair.h"


//---------------------------------------------------------------------------------------
    @implementation EDObjectPair
//---------------------------------------------------------------------------------------

/*" From a purely functional point EDObjectPair does not add anything to NSArray. However, EDObjectPair can be used when a design explicitly deals with a relationship between two objects, typically an association of a value or an object with another object. An array of EDObjectPairs can be used instead of an NSDictionary when the order of key/value pairs is relevant and lookups of values by key do not need to be fast. EDObjectPairs also use less memory than NSArray and have a better hash function. (If you know LISP you probably use pairs for all sorts of other structures.) "*/


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:1];
}


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

/*" Creates and returns a pair containing !{nil} for both first and second object. "*/

+ (id)pair
{
    return [[[self alloc] init] autorelease];
}


/*" Creates and returns a pair containing the objects in aPair. "*/

+ (id)pairWithObjectPair:(EDObjectPair *)aPair
{
    return [[[self alloc] initWithObjects:[aPair firstObject]:[aPair secondObject]] autorelease];
}


/*" Creates and returns a pair containing anObject and anotherObject. "*/

+ (id)pairWithObjects:(id)anObject:(id)anotherObject
{
    return [[[self alloc] initWithObjects:anObject:anotherObject] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated pair by adding the objects from %aPair to it. Objects are, of course, retained. "*/

- (id)initWithObjectPair:(EDObjectPair *)aPair
{
    return [self initWithObjects:[aPair firstObject]:[aPair secondObject]];
}


/*" Initialises a newly allocated pair by adding anObject and anotherObject to it. Objects are, of course, retained. "*/

- (id)initWithObjects:(id)anObject:(id)anotherObject
{
    [super init];
    firstObject = [anObject retain];
    secondObject = [anotherObject retain];
    return self;
}


- (void)dealloc
{
    [firstObject release];
    [secondObject release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:firstObject];
    [encoder encodeObject:secondObject];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super init];
    version = [decoder versionForClassName:@"EDObjectPair"];
    if(version > 0)
        {
        firstObject = [[decoder decodeObject] retain];
        secondObject = [[decoder decodeObject] retain];
        }
    return self;
}


//---------------------------------------------------------------------------------------
//	NSCOPYING
//---------------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
    if(NSShouldRetainWithZone(self, zone))
        return [self retain];
    return [[EDObjectPair allocWithZone:zone] initWithObjects:firstObject:secondObject];
}


- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[EDMutableObjectPair allocWithZone:zone] initWithObjects:firstObject:secondObject];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION & COMPARISONS
//---------------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ 0x%x: (%@, %@)>", NSStringFromClass(isa), (void *)self, firstObject, secondObject];
}


- (NSUInteger)hash
{
    return [firstObject hash] ^ [secondObject hash];
}


- (BOOL)isEqual:(id)otherObject
{
    id otherFirstObject, otherSecondObject;

    if(otherObject == nil)
        return NO;
    else if((isa != ((EDObjectPair *)otherObject)->isa) && ([otherObject isKindOfClass:[EDObjectPair class]] == NO))
        return NO;

    otherFirstObject = ((EDObjectPair *)otherObject)->firstObject;
    otherSecondObject = ((EDObjectPair *)otherObject)->secondObject;

    return ( (((firstObject == nil) && (otherFirstObject == nil)) || [firstObject isEqual:otherFirstObject]) &&
             (((secondObject == nil) && (otherSecondObject == nil)) || [secondObject isEqual:otherSecondObject]) );
}


//---------------------------------------------------------------------------------------
//	ATTRIBUTES
//---------------------------------------------------------------------------------------

/*" Returns the first object. Note that this can be !{nil}. "*/

- (id)firstObject
{
    return firstObject;
}


/*" Returns the second object. Note that this can be !{nil}. "*/

- (id)secondObject
{
    return secondObject;
}


//---------------------------------------------------------------------------------------
//	CONVENIENCE
//---------------------------------------------------------------------------------------

/*" Returns an array containing all objects in the pair. Because a pair can contain !{nil} references, this array can have zero, one or two objects. If both objects in the pair are not !{nil} the first object preceedes the second in the array."*/

- (NSArray *)allObjects
{
    if(firstObject == nil)
        return [NSArray arrayWithObjects:secondObject, nil];
    return [NSArray arrayWithObjects:firstObject, secondObject, nil];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
