//---------------------------------------------------------------------------------------
//  EDMultimediaContentCoder.m created by erik on Mon 08-May-2000
//  $Id: EDMultimediaContentCoder.m,v 2.1 2003-04-08 17:06:03 znek Exp $
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

#import <Foundation/Foundation.h>
#import "NSData+MIME.h"
#import "EDInternetMessage.h"
#import "EDMultimediaContentCoder.h"

@interface EDMultimediaContentCoder(PrivateAPI)
- (id)_encodeDataWithClass:(Class)targetClass;
@end


//---------------------------------------------------------------------------------------
    @implementation EDMultimediaContentCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CAPABILITIES
//---------------------------------------------------------------------------------------

+ (BOOL)canDecodeMessagePart:(EDMessagePart *)mpart
{
    NSString *ct = [[mpart contentType] firstObject];
    if([ct isEqualToString:@"image"] || [ct isEqualToString:@"audio"] || [ct isEqualToString:@"video"] || [ct isEqualToString:@"application"])
        return YES;
    return NO;
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithMessagePart:(EDMessagePart *)mpart
{
    [super init];

    if((filename = [[mpart contentDispositionParameters] objectForKey:@"filename"]) != nil)
        filename = [[filename lastPathComponent] retain];
    else if((filename = [[mpart contentTypeParameters] objectForKey:@"name"]) != nil)
        filename = [[filename lastPathComponent] retain];
    else
        filename = nil;
    data = [[mpart contentData] retain];
    if([mpart contentDisposition] == nil)
        {
        NSString *ct = [[mpart contentType] firstObject];
        if([ct isEqualToString:@"image"] || [ct isEqualToString:@"video"])
            shouldBeDisplayedInline = [data length] < (512 * 1024);
        else
            shouldBeDisplayedInline = NO; 
        }
    else
        {
        shouldBeDisplayedInline = [[mpart contentDisposition] isEqualToString:MIMEInlineContentDisposition];
        }
        
    return self;
}


- (id)initWithData:(NSData *)someData filename:(NSString *)aFilename
{
    return [self initWithData:someData filename:aFilename inlineFlag:UNKNOWN];
}


- (id)initWithData:(NSData *)someData filename:(NSString *)aFilename inlineFlag:(BOOL)inlineFlag
{
    [super init];
    data = [someData retain];
    filename = [aFilename retain];
    shouldBeDisplayedInline = inlineFlag;
    return self;
}


- (void)dealloc
{
    [data release];
    [filename release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	CONTENT ATTRIBUTES
//---------------------------------------------------------------------------------------

- (NSData *)data
{
    return data;
}


- (NSString *)filename
{
    return filename;
}


- (BOOL)shouldBeDisplayedInline
{
    return (shouldBeDisplayedInline != NO);
}


- (EDMessagePart *)messagePart
{
    return [self _encodeDataWithClass:[EDMessagePart class]];
}


- (EDInternetMessage *)message
{
    return [self _encodeDataWithClass:[EDInternetMessage class]];
}


//---------------------------------------------------------------------------------------
//	CODING
//---------------------------------------------------------------------------------------

- (id)_encodeDataWithClass:(Class)targetClass
{
    EDMessagePart		*result;
    NSString			*ctString, *cdString;
    NSArray				*ctValues;
    EDObjectPair		*contentType;
    NSDictionary 		*parameters;
    
    result = [[[targetClass alloc] init] autorelease];
    
    if((filename != nil) && ((ctString = [NSString contentTypeForPathExtension:[filename pathExtension]]) != nil))
        {
        ctValues = [ctString componentsSeparatedByString:@"/"];
        NSAssert1([ctValues count] == 2, @"invalid entry in content type table; found %@", ctString);
        contentType = [EDObjectPair pairWithObjects:[ctValues objectAtIndex:0]:[ctValues objectAtIndex:1]];
        parameters = [NSDictionary dictionaryWithObject:filename forKey:@"name"];
        [result setContentType:contentType withParameters:parameters];
        }
    else if(filename != nil)
        {
        contentType = [EDObjectPair pairWithObjects:@"application":@"octet-stream"];
        parameters = [NSDictionary dictionaryWithObject:filename forKey:@"name"];
        [result setContentType:contentType withParameters:parameters];
        }
    else
        {
        [result setContentType:[EDObjectPair pairWithObjects:@"application":@"octet-stream"]];
        }
    
    if(shouldBeDisplayedInline != UNKNOWN)
        {
        cdString = (shouldBeDisplayedInline) ? MIMEInlineContentDisposition : MIMEAttachmentContentDisposition;
        if(filename != nil)
            [result setContentDisposition:cdString withParameters:[NSDictionary dictionaryWithObject:filename forKey:@"filename"]];
        else
            [result setContentDisposition:cdString];
       }
    
    [result setContentTransferEncoding:MIMEBase64ContentTransferEncoding];

    [result setContentData:data];

    return result;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
