//---------------------------------------------------------------------------------------
//  NSCharacterSet+MIME.h created by erik on Sun 23-Mar-1997
//  @(#)$Id: NSCharacterSet+MIME.h,v 2.0 2002/08/16 18:24:13 erik Exp $
//
//  Copyright (c) 1997,98 by Erik Doernenburg. All rights reserved.
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

@interface NSCharacterSet(EDMessageExtensions)

/* This category caches all returned character sets. This will in effect leak some
memory but saves the overhead of repeatedly constructing the sets. One could shift
the burden of caching to the clients of this class but as they are in the same
framework this wouldn't make much sense... */

+ (NSCharacterSet *)standardASCIICharacterSet;
+ (NSCharacterSet *)linebreakCharacterSet;

+ (NSCharacterSet *)MIMETokenCharacterSet;
+ (NSCharacterSet *)MIMENonTokenCharacterSet;
+ (NSCharacterSet *)MIMETSpecialsCharacterSet;
+ (NSCharacterSet *)MIMEHeaderDefaultLiteralCharacterSet;

@end
