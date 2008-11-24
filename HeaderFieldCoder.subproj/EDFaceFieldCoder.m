//---------------------------------------------------------------------------------------
//  EDFaceFieldCoder.m created by erik
//  @(#)$Id: EDFaceFieldCoder.m,v 2.1 2003/04/08 17:06:05 znek Exp $
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

#import <AppKit/AppKit.h>
#import <EDCommon/EDCommon.h>
#import "NSImage+XFace.h"
#import "EDFaceFieldCoder.h"


//---------------------------------------------------------------------------------------
    @implementation EDFaceFieldCoder
//---------------------------------------------------------------------------------------

+ (id)encoderWithImage:(NSImage *)anImage
{
    return [[[self alloc] initWithImage:anImage] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithFieldBody:(NSString *)body
{
    [self init];
    image = [[NSImage allocWithZone:[self zone]] initWithXFaceData:[body dataUsingEncoding:NSASCIIStringEncoding]];
    return self;
}


- (id)initWithImage:(NSImage *)anImage
{
    [self init];
    image = [anImage retain];
    return self;
}


- (void)dealloc
{
    [image release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (NSImage *)image
{
    return image;
}


- (NSString *)stringValue
{
    return @"[IMAGE]";
}


- (NSString *)fieldBody
{
    return [[[NSString alloc] initWithData:[image xFaceData] encoding:NSASCIIStringEncoding] autorelease];	
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
