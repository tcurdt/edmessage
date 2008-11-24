//---------------------------------------------------------------------------------------
//  EDHeaderFieldCoder.m created by erik on Sun 24-Oct-1999
//  @(#)$Id: EDHeaderFieldCoder.m,v 2.1 2003/04/08 17:06:05 znek Exp $
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
#import <EDCommon/EDCommon.h>
#import "EDHeaderFieldCoder.h"


//---------------------------------------------------------------------------------------
    @implementation EDHeaderFieldCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)decoderWithFieldBody:(NSString *)fieldBody
{
    return [[[self alloc] initWithFieldBody:fieldBody] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithFieldBody:(NSString *)body
{
    [self methodIsAbstract:_cmd];
    return self;
}


- (void)dealloc
{
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	CODING
//---------------------------------------------------------------------------------------

- (NSString *)stringValue
{
    [self methodIsAbstract:_cmd];
    return nil; // keep compiler happy...
}


- (NSString *)fieldBody
{
   [self methodIsAbstract:_cmd];
    return nil; // keep compiler happy...
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
