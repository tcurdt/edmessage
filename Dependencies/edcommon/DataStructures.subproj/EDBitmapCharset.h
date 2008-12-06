//---------------------------------------------------------------------------------------
//  EDBitmapCharset.h created by erik on Fri 08-Oct-1999
//  @(#)$Id: EDBitmapCharset.h,v 2.1 2003-04-08 16:51:33 znek Exp $
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

#import "EDCommonDefines.h"

/*" The datastructure behind EDBitmapCharsets. Use these instead of NSCharacterSet objects when you need a lot of contains tests; and you want them to be as fast as possible. "*/

typedef struct
{
    const byte 	*bytes;
    NSData		*bitmapRep;
} EDBitmapCharset;


/*" Returns YES if the character is in the charset. To be more precise, YES means any value greater than 0. In fact, this method returns the exact bit that was tested against.  This is the only operation currently supported on EDBitmapCharsets. "*/

static __inline__ BOOL EDBitmapCharsetContainsCharacter(EDBitmapCharset *charset, unichar character)
{
    return ((charset->bytes)[character >> 3] & (((unsigned int)1) << (character & 0x7)));
}


/*" Create and release (dealloc) an EDBitmapCharset. "*/

EDCOMMON_EXTERN EDBitmapCharset *EDBitmapCharsetFromCharacterSet(NSCharacterSet *charset);
EDCOMMON_EXTERN void EDReleaseBitmapCharset(EDBitmapCharset *charset);

