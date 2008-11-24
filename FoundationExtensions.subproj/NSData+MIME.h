//---------------------------------------------------------------------------------------
//  NSData+MIME.h created by erik on Sun 12-Jan-1997
//  @(#)$Id: NSData+MIME.h,v 2.3 2003/09/08 21:01:49 erik Exp $
//
//  Copyright (c) 1997-1999 by Erik Doernenburg. All rights reserved.
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

#import "EDMessageDefines.h"

@interface NSData(EDMIMEExtensions)

- (BOOL)isValidTransferEncoding:(NSString *)encodingName;

- (NSData *)decodeContentWithTransferEncoding:(NSString *)encodingName;
- (NSData *)encodeContentWithTransferEncoding:(NSString *)encodingName;

- (NSData *)decodeQuotedPrintable;
- (NSData *)encodeQuotedPrintable;

- (NSData *)decodeHeaderQuotedPrintable;
- (NSData *)encodeHeaderQuotedPrintable;
- (NSData *)encodeHeaderQuotedPrintableMustEscapeCharactersInString:(NSString *)escChars;

// base64 encoding is handled in a category in EDCommon

@end


EDMESSAGE_EXTERN NSString *MIME7BitContentTransferEncoding;
EDMESSAGE_EXTERN NSString *MIME8BitContentTransferEncoding;
EDMESSAGE_EXTERN NSString *MIMEBinaryContentTransferEncoding;
EDMESSAGE_EXTERN NSString *MIMEQuotedPrintableContentTransferEncoding;
EDMESSAGE_EXTERN NSString *MIMEBase64ContentTransferEncoding;
