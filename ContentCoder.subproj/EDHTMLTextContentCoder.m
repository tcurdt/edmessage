//---------------------------------------------------------------------------------------
//  EDHTMLTextContentCoder.m created by erik on Sat Jan 04 2003
//  @(#)$Id: EDHTMLTextContentCoder.m,v 2.2 2003-04-08 17:06:03 znek Exp $
//
//  Copyright (c) 2002 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Mulle Kybernetik in all documents and publicity
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
#import "NSData+MIME.h"
#import "EDMessagePart.h"
#import "EDInternetMessage.h"
#import "EDHTMLTextContentCoder.h"


//---------------------------------------------------------------------------------------
    @implementation EDHTMLTextContentCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CAPABILITIES
//---------------------------------------------------------------------------------------

+ (BOOL)canDecodeMessagePart:(EDMessagePart *)mpart
{
    NSString	*charset;

    if(([[[mpart contentType] firstObject] isEqualToString:@"text"] == NO) ||
       ([[[mpart contentType] secondObject] isEqualToString:@"html"] == NO))
        return NO;

    charset = [[mpart contentTypeParameters] objectForKey:@"charset"];
    if((charset != nil) && ([NSString stringEncodingForMIMEEncoding:charset] == 0))
        return NO;

    return YES;
}


//---------------------------------------------------------------------------------------
//	CODING
//---------------------------------------------------------------------------------------

// This method is not declared 'public' in the superclass. We know that it is
// called, though. Maybe just think of them as being 'protected' in Java terms...

- (id)_encodeTextWithClass:(Class)targetClass
{
    EDMessagePart		*result;
    NSString			*charset;
    NSDictionary		*parameters;
    NSData				*contentData;

    result = [[[targetClass alloc] init] autorelease];
    charset = [text recommendedMIMEEncoding];
    parameters = [NSDictionary dictionaryWithObjectsAndKeys:charset ,@"charset", nil];
    [result setContentType:[EDObjectPair pairWithObjects:@"text":@"html"] withParameters:parameters];
    if([charset caseInsensitiveCompare:MIMEAsciiStringEncoding] == NSOrderedSame)
        [result setContentTransferEncoding:MIME7BitContentTransferEncoding];
    else if(dataMustBe7Bit)
        [result setContentTransferEncoding:MIMEQuotedPrintableContentTransferEncoding];
    else
        [result setContentTransferEncoding:MIME8BitContentTransferEncoding];
    contentData = [text dataUsingMIMEEncoding:charset];
    [result setContentData:contentData];

    return result;
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
