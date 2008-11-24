//---------------------------------------------------------------------------------------
//  EDPlainTextContentCoder.m created by erik on Sun 18-Apr-1999
//  @(#)$Id: EDPlainTextContentCoder.m,v 2.2 2003-04-08 17:06:03 znek Exp $
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

#import <Foundation/Foundation.h>
#import <EDCommon/EDCommon.h>
#import "EDMConstants.h"
#import "NSString+PlainTextFlowedExtensions.h"
#import "NSData+MIME.h"
#import "EDMessagePart.h"
#import "EDInternetMessage.h"
#import "EDPlainTextContentCoder.h"

@interface EDPlainTextContentCoder(PrivateAPI)
- (void)_takeTextFromMessagePart:(EDMessagePart *)mpart;
- (id)_encodeTextWithClass:(Class)targetClass;
@end


//---------------------------------------------------------------------------------------
    @implementation EDPlainTextContentCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CAPABILITIES
//---------------------------------------------------------------------------------------

+ (BOOL)canDecodeMessagePart:(EDMessagePart *)mpart
{
    NSString	*charset;
    
    if(([[[mpart contentType] firstObject] isEqualToString:@"text"] == NO) ||
       ([[[mpart contentType] secondObject] isEqualToString:@"plain"] == NO))
        return NO;
#warning * maybe we should allow text/enriched and dump the formatting...    

    charset = [[mpart contentTypeParameters] objectForKey:@"charset"];
    if((charset != nil) && ([NSString stringEncodingForMIMEEncoding:charset] == 0))
        return NO;

    return YES;
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithMessagePart:(EDMessagePart *)mpart
{
    [super init];
    if([[[mpart contentType] firstObject] isEqualToString:@"text"])
        [self _takeTextFromMessagePart:mpart];
    return self;
}


- (id)initWithText:(NSString *)someText
{
    [super init];
    text = [someText retain];
    return self;
}


- (void)dealloc
{
    [text release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	CONTENT ATTRIBUTES
//---------------------------------------------------------------------------------------

- (NSString *)text
{
    return text;
}


- (EDMessagePart *)messagePart
{
    return [self _encodeTextWithClass:[EDMessagePart class]];
}


- (EDInternetMessage *)message
{
    return [self _encodeTextWithClass:[EDInternetMessage class]];
}


//---------------------------------------------------------------------------------------
//	CODING ATTRIBUTES
//---------------------------------------------------------------------------------------

- (void)setDataMustBe7Bit:(BOOL)flag
{
    dataMustBe7Bit = flag;
}


- (BOOL)dataMustBe7Bit
{
    return dataMustBe7Bit;
}


//---------------------------------------------------------------------------------------
//	CODING
//---------------------------------------------------------------------------------------

- (void)_takeTextFromMessagePart:(EDMessagePart *)mpart
{
    NSString *charset, *format;

    if((charset = [[mpart contentTypeParameters] objectForKey:@"charset"]) == nil)
        charset = MIMEAsciiStringEncoding;

    if((text = [NSString stringWithData:[mpart contentData] MIMEEncoding:charset]) == nil)
        {
        EDLog1(EDLogCoder, @"cannot decode charset %@", charset);
        return;
        }
    [text retain];

    format = [[mpart contentTypeParameters] objectForKey:@"format"];
    if((format != nil) && ([format caseInsensitiveCompare:@"flowed"] == NSOrderedSame))
        {
        NSString *deflowed;
        
        deflowed = [[text stringByDecodingFlowedFormat] retain];
        [text release];
        text = deflowed;
        }
}


- (id)_encodeTextWithClass:(Class)targetClass
{
    EDMessagePart		*result;
    NSString			*charset, *flowedText;
    NSDictionary		*parameters;
    NSData				*contentData;

    flowedText = [text stringByEncodingFlowedFormat];
    
    result = [[[targetClass alloc] init] autorelease];
    charset = [flowedText recommendedMIMEEncoding];
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:charset ,@"charset", @"flowed", @"format", nil];
    [result setContentType:[EDObjectPair pairWithObjects:@"text":@"plain"] withParameters:parameters];
    if([charset caseInsensitiveCompare:MIMEAsciiStringEncoding] == NSOrderedSame)
        [result setContentTransferEncoding:MIME7BitContentTransferEncoding];
    else if(dataMustBe7Bit)
        [result setContentTransferEncoding:MIMEQuotedPrintableContentTransferEncoding];
    else
        [result setContentTransferEncoding:MIME8BitContentTransferEncoding];
    contentData = [flowedText dataUsingMIMEEncoding:charset];
    [result setContentData:contentData];
    
    return result;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
