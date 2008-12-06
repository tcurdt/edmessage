//---------------------------------------------------------------------------------------
//  EDMutableObjectPair.m created by erik on Tue Jul 23 2002
//  @(#)$Id: EDMutableObjectPair.m,v 2.1 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 2002 by Erik Doernenburg. All rights reserved.
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
#import "EDMutableObjectPair.h"


//---------------------------------------------------------------------------------------
    @implementation EDMutableObjectPair
//---------------------------------------------------------------------------------------

/*" Mutable variant of object pair allows objects to be changed. "*/


//---------------------------------------------------------------------------------------
//	NSCOPYING
//---------------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
    return [[EDObjectPair allocWithZone:zone] initWithObjects:firstObject:secondObject];
}


- (id)mutableCopyWithZone:(NSZone *)zone
{
    return [[EDMutableObjectPair allocWithZone:zone] initWithObjects:firstObject:secondObject];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Sets the firstObject of the receiver to %anObject. "*/

- (void)setFirstObject:(id)anObject
{
    [anObject retain];
    [firstObject release];
    firstObject = anObject;
}


/*" Sets the secondObject of the receiver to %anObject. "*/

- (void)setSecondObject:(id)anObject
{
    [anObject retain];
    [secondObject release];
    secondObject = anObject;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
