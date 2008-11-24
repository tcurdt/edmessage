//---------------------------------------------------------------------------------------
//  EDMultimediaContentCoder.h created by erik on Mon 08-May-2000
//  $Id: EDMultimediaContentCoder.h,v 2.1 2003-04-08 17:06:03 znek Exp $
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


#ifndef	__EDMultimediaContentCoder_h_INCLUDE
#define	__EDMultimediaContentCoder_h_INCLUDE


#import "EDContentCoder.h"


@interface EDMultimediaContentCoder : EDContentCoder
{
    NSData 		*data;
    NSString	*filename;
    short		shouldBeDisplayedInline;
}

- (id)initWithData:(NSData *)someData filename:(NSString *)filename;
- (id)initWithData:(NSData *)someData filename:(NSString *)filename inlineFlag:(BOOL)inlineFlag;

- (NSData *)data;
- (NSString *)filename;
- (BOOL)shouldBeDisplayedInline;


@end

#endif	/* __EDMultimediaContentCoder_h_INCLUDE */
