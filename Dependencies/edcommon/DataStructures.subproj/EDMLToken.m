//---------------------------------------------------------------------------------------
//  EDMLToken.m created by erik
//  @(#)$Id: EDMLToken.m,v 2.1 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 1999-2000 by Erik Doernenburg. All rights reserved.
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
#import "EDMLToken.h"


//---------------------------------------------------------------------------------------
    @implementation EDMLToken
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (EDMLToken *)tokenWithType:(int)aType
{
    return [[[self alloc] initWithType:aType] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithType:(int)aType
{
    [super init];
    type = aType;
    return self;
}

- (void)dealloc
{
    [value release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION
//---------------------------------------------------------------------------------------

- (NSString *)description
{
    if([value isKindOfClass:[NSString class]])
        return [NSString stringWithFormat:@"[%d \"%@\"]", type, value];
    return [NSString stringWithFormat:@"[%d %@]", type, value];
}


//---------------------------------------------------------------------------------------
//  ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (int)type
{
    return type;
}


- (void)setValue:(id)aValue
{
    [aValue retain];
    [value release];
    value = aValue;
}

- (id)value
{
    return value;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
