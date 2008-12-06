//---------------------------------------------------------------------------------------
//  EDStack.m created by erik on Sat 19-Jul-1997
//  @(#)$Id: EDStack.m,v 2.2 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 1997 by Erik Doernenburg. All rights reserved.
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
#import "EDStack.h"


//---------------------------------------------------------------------------------------
    @implementation EDStack
//---------------------------------------------------------------------------------------

/*" From a purely functional point EDStack does not add anything to NSArray. However, EDStack clarifies the indended use of the datastructure. Note that it is not a subclass of NSMutableArray; something you might expect if you are familiar with Java. (See Martin Fowler "Refactoring" p. 352 for a good explanation why the Java way is "wrong.")

This datastructure does not implement the copying and coding protocols as stacks are usually required in the context of algorithms, rather than data storage. "*/


/*" Creates and returns an empty stack. "*/

+ (EDStack *)stack
{
    return [[[self alloc] init] autorelease];
}


/*" Creates and returns a stack with a single object on it. "*/

+ (EDStack *)stackWithObject:(id)anObject
{
    return [[[self alloc] initWithObject:anObject] autorelease];
}


//---------------------------------------------------------------------------------------
//	constructors / destructors
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated stack. "*/

- (id)init
{
    [super init];
    storage = [[NSMutableArray allocWithZone:[self zone]] init];
    return self;
}


/*" Initialises a newly allocated stack by adding anObject to it. The object receives a #retain message. "*/

- (id)initWithObject:(id)anObject
{
    [self init];
    [storage addObject:anObject];
    return self;
}

- (void)dealloc
{
    [storage release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	push / pop
//---------------------------------------------------------------------------------------

/*" Pushes %anObject onto the stack. The object receives a #retain message. "*/

- (void)pushObject:(id)anObject
{
    [storage addObject:anObject];
}

/*" Removes and returns the topmost object from the stack. The object receives a #release message. If the stack is empty this method returns !{nil}."*/

- (id)popObject
{
    id object;

    if((object = [storage lastObject]) != nil)
        {
        [[object retain] autorelease];
        [storage removeLastObject];
        }
    return object;
}


/*" Removes all objects from the stack. Each removed object is sent a #release message. "*/

- (void)clear
{
    [storage removeAllObjects];
}


//---------------------------------------------------------------------------------------
//	peeking around
//---------------------------------------------------------------------------------------

/*" Returns the topmost object on the stack, or !{nil} if the stack is empty. "*/

- (id)topObject
{
    return [storage lastObject];
}


/*" Returns an array containing the %n topmost object on the stack. Raises an exception if %n is greater than the value returned by #count."*/

- (NSArray *)topObjects:(int)count
{
    return [storage subarrayWithRange:NSMakeRange([storage count] - count , count)];
}


/*" Returns the number of objects on the stack."*/

- (NSUInteger)count
{
    return [storage count];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
