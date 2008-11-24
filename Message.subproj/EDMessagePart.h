//---------------------------------------------------------------------------------------
//  EDMessagePart.h created by erik on Mon 20-Jan-1997
//  @(#)$Id: EDMessagePart.h,v 2.2 2003/09/08 21:01:51 erik Exp $
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

#import "EDHeaderBearingObject.h"

@interface EDMessagePart : EDHeaderBearingObject
{
    NSDictionary	*fallbackFields;
    EDObjectPair  	*contentType;
    NSDictionary	*contentTypeParameters;
    NSString		*contentDisposition;
    NSDictionary	*contentDispositionParameters;
    NSData			*contentData;
    NSData			*originalTransferData;
    NSRange		 	bodyRange;
}

- (id)initWithTransferData:(NSData *)data;
- (id)initWithTransferData:(NSData *)data fallbackStringEncoding:(NSStringEncoding)encoding;
- (id)initWithTransferData:(NSData *)data fallbackHeaderFields:(NSDictionary *)fields;

- (NSData *)transferData;

- (void)setContentType:(EDObjectPair *)aType;
- (void)setContentType:(EDObjectPair *)aType withParameters:(NSDictionary *)someParameters;
- (EDObjectPair *)contentType;
- (NSDictionary *)contentTypeParameters;

- (void)setContentDisposition:(NSString *)aDispositionDirective;
- (void)setContentDisposition:(NSString *)aDispositionDirective withParameters:(NSDictionary *)someParameters;
- (NSString *)contentDisposition;
- (NSDictionary *)contentDispositionParameters;

- (void)setContentTransferEncoding:(NSString *)anEncoding;
- (NSString *)contentTransferEncoding;

- (void)setContentData:(NSData *)data;
- (NSData *)contentData;

- (NSString *)pathExtensionForContentType;

@end
