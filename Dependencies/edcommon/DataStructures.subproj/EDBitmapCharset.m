//---------------------------------------------------------------------------------------
// EDBitmapCharset.m created by erik on Fri 08-Oct-1999 */
//  @(#)$Id: EDBitmapCharset.m,v 2.1 2003-04-08 16:51:33 znek Exp $
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
#import "EDBitmapCharset.h"


EDBitmapCharset *EDBitmapCharsetFromCharacterSet(NSCharacterSet *charset)
{
    EDBitmapCharset  *bitmapCharsetStruct;

    bitmapCharsetStruct = NSZoneMalloc([charset zone], sizeof(EDBitmapCharset));
    bitmapCharsetStruct->bitmapRep = [[charset bitmapRepresentation] retain];
    bitmapCharsetStruct->bytes = [bitmapCharsetStruct->bitmapRep bytes];

    return bitmapCharsetStruct;
}


void EDReleaseBitmapCharset(EDBitmapCharset *charset)
{
    NSZone	*zone;

    zone = [charset->bitmapRep zone];
    [charset->bitmapRep release];
    NSZoneFree(zone, charset);
}

