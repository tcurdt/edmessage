//---------------------------------------------------------------------------------------
//  EDPlainTextContentCoder.h created by erik on Sun 18-Apr-1999
//  @(#)$Id: EDPlainTextContentCoder.h,v 2.1 2003-04-08 17:06:03 znek Exp $
//
//  This file is part of the Alexandra Newsreader Project. ED3000 and the supporting
//  ED frameworks are free software; you can redistribute and/or modify them under
//  the terms of the GNU General Public License, version 2 as published by the Free
//  Software Foundation.
//---------------------------------------------------------------------------------------


#ifndef	__EDPlainTextContentCoder_h_INCLUDE
#define	__EDPlainTextContentCoder_h_INCLUDE


#import "EDContentCoder.h"


@interface EDPlainTextContentCoder : EDContentCoder 
{
    NSString *text;
    BOOL	 dataMustBe7Bit;
}

- (id)initWithText:(NSString *)text;
- (NSString *)text;

- (void)setDataMustBe7Bit:(BOOL)flag;
- (BOOL)dataMustBe7Bit;

@end

#endif	/* __EDPlainTextContentCoder_h_INCLUDE */
