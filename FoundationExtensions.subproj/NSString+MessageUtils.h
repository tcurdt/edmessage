//---------------------------------------------------------------------------------------
//  NSString+MessageUtils.h created by erik on Sun 23-Mar-1997
//  @(#)$Id: NSString+MessageUtils.h,v 2.1 2003/09/08 21:01:50 erik Exp $
//
//  Copyright (c) 1997-2000 by Erik Doernenburg. All rights reserved.
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

@interface NSString(EDMessageUtilities) 

- (BOOL)isValidMessageID;
- (NSString *)getURLFromArticleID;

- (NSString *)stringByRemovingBracketComments;

- (NSString *)realnameFromEMailString;
- (NSString *)addressFromEMailString;
- (NSArray *)addressListFromEMailString;

- (NSString *)stringByRemovingReplyPrefix;

- (NSString *)stringByApplyingROT13;
- (NSString *)stringWithCanonicalLinebreaks;

- (NSString *)stringByUnwrappingParagraphs;
- (NSString *)stringByWrappingToLineLength:(unsigned int)length;
- (NSString *)stringByPrefixingLinesWithString:(NSString *)prefix;

- (NSString *)stringByFoldingToLimit:(unsigned int)limit;
- (NSString *)stringByUnfoldingString;
@end


@interface NSMutableString(EDMessageUtilities)

- (void)appendAsLine:(NSString *)line withPrefix:(NSString *)prefix;

@end
