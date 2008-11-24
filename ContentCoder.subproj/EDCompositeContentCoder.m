//---------------------------------------------------------------------------------------
//  EDCompositeContentCoder.m created by erik on Sun 18-Apr-1999
//  @(#)$Id: EDCompositeContentCoder.m,v 2.3 2003-04-21 03:05:16 erik Exp $
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
#import "utilities.h"
#import "NSString+MessageUtils.h"
#import "NSData+MIME.h"
#import "EDInternetMessage.h"
#import "EDMConstants.h"
#import "EDEntityFieldCoder.h"
#import "EDCompositeContentCoder.h"

@interface EDCompositeContentCoder(PrivateAPI)
- (void)_takeSubpartsFromMultipartContent:(EDMessagePart *)mpart;
- (void)_takeSubpartsFromMessageContent:(EDMessagePart *)mpart;
- (id)_encodeSubpartsWithClass:(Class)targetClass subtype:(NSString *)subtype;
@end


//---------------------------------------------------------------------------------------
    @implementation EDCompositeContentCoder
//---------------------------------------------------------------------------------------

static short boundaryId = 0;


//---------------------------------------------------------------------------------------
//	CAPABILITIES
//---------------------------------------------------------------------------------------

+ (BOOL)canDecodeMessagePart:(EDMessagePart *)mpart
{
    if([[[mpart contentType] firstObject] isEqualToString:@"multipart"])
        return YES;
    if(([[[mpart contentType] firstObject] isEqualToString:@"message"]) &&
       ([[[mpart contentType] secondObject] isEqualToString:@"rfc822"]))
        return YES;
    return NO;
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithMessagePart:(EDMessagePart *)mpart
{
    [super init];

    if([[[mpart contentType] firstObject] isEqualToString:@"multipart"])
        {
        [self _takeSubpartsFromMultipartContent:mpart];
        }
    else if(([[[mpart contentType] firstObject] isEqualToString:@"message"]) &&
            ([[[mpart contentType] secondObject] isEqualToString:@"rfc822"]))
        {
        [self _takeSubpartsFromMessageContent:mpart];
        }
    else
        {
        [NSException raise:NSInvalidArgumentException format:@"%@: Invalid content type %@", NSStringFromClass([self class]), [mpart bodyForHeaderField:@"content-type"]];
        }	

    return self;
}


- (id)initWithSubparts:(NSArray *)someParts
{
    [super init];
    subparts = [someParts retain];
    return self;
}



- (void)dealloc
{
    [subparts release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ATTRIBUTES
//---------------------------------------------------------------------------------------

- (NSArray *)subparts
{
    return subparts;
}


- (EDMessagePart *)messagePart
{
    return [self _encodeSubpartsWithClass:[EDMessagePart class] subtype:@"mixed"];
}

- (EDMessagePart *)messagePartWithSubtype:(NSString *)subtype
{
    return [self _encodeSubpartsWithClass:[EDMessagePart class] subtype:subtype];
}


- (EDInternetMessage *)message
{
    return [self _encodeSubpartsWithClass:[EDInternetMessage class] subtype:@"mixed"];
}

- (EDInternetMessage *)messageWithSubtype:(NSString *)subtype
{
    return [self _encodeSubpartsWithClass:[EDInternetMessage class] subtype:subtype];
}


//---------------------------------------------------------------------------------------
//	CODING
//---------------------------------------------------------------------------------------

- (void)_takeSubpartsFromMultipartContent:(EDMessagePart *)mpart
{
    NSDictionary		*defaultHeadersFields;
    EDEntityFieldCoder	*fcoder;
    NSString			*charset, *boundary;
    const char			*btext, *startPtr, *possibleEndPtr, *p, *pmin, *pmax, *q;
    unsigned int		blen;
    NSRange				subpartRange;
    EDMessagePart 		*subpart;
    BOOL   				done = NO;

    if((boundary = [[mpart contentTypeParameters] objectForKey:@"boundary"]) == nil)
        [NSException raise:EDMessageFormatException format:@"no boundary for multipart"];
    btext = [boundary cStringUsingEncoding:NSASCIIStringEncoding];
    blen = (unsigned int)strlen(btext);
    if([[[mpart contentType] secondObject] isEqualToString:@"digest"])
        {
        fcoder = [[[EDEntityFieldCoder alloc] initWithValues:[NSArray arrayWithObjects:@"message", @"rfc822", nil] andParameters:[NSDictionary dictionary]] autorelease];
        defaultHeadersFields = [NSDictionary dictionaryWithObject:[fcoder fieldBody] forKey:@"content-type"];
        }
    else
        {
        charset = [NSString MIMEEncodingForStringEncoding:NSASCIIStringEncoding];
        fcoder = [[[EDEntityFieldCoder alloc] initWithValues:[NSArray arrayWithObjects:@"text", @"plain", nil] andParameters:[NSDictionary dictionaryWithObject:charset forKey:@"charset"]] autorelease];
        defaultHeadersFields = [NSDictionary dictionaryWithObject:[fcoder fieldBody] forKey:@"content-type"];
        }

    subparts = [[NSMutableArray allocWithZone:[self zone]] init];

    pmin = p = [[mpart contentData] bytes];
    pmax = p + [[mpart contentData] length];
    startPtr = possibleEndPtr = NULL;
    while(done == NO)
        {  // p == 0 can occur if part was empty, ie. had no body
        if((p == 0) || (p > pmax - 5 - blen)) // --boundary--\n
            [NSException raise:EDMessageFormatException format:@"final boundary not found"];
        if((*p == '-') && (*(p+1) == '-') && (strncmp(p+2, btext, blen) == 0))
            {
            q = p + 2 + blen;
            if((*q == '-') && (*(q+1) == '-'))
                {
                done = YES;
                q += 2;
                }
            if((q = skipspace(q, pmax)) == NULL)  // might have been added
                [NSException raise:EDMessageFormatException format:@"final boundary not found"];
            if(iscrlf(*q) == NO)
                {
                EDLog(EDLogCoder, @"ignoring junk after mime multipart boundary");
                if((q = skiptonewline(q, pmax)) == NULL)
                    [NSException raise:EDMessageFormatException format:@"final boundary not found"];
                }

            if(startPtr != NULL)
                {
                subpartRange.location = startPtr - (const char *)[[mpart contentData] bytes];
                subpartRange.length = possibleEndPtr - startPtr;
                subpart = [[[EDMessagePart allocWithZone:[self zone]] initWithTransferData:[[mpart contentData] subdataWithRange:subpartRange] fallbackHeaderFields:defaultHeadersFields] autorelease];
                [subparts addObject:subpart];
                }
            startPtr = p = skipnewline(q, pmax); // trailing crlf belongs to boundary
            }
        else
            {
            if((p = skiptonewline(p, pmax)) == NULL)
                [NSException raise:EDMessageFormatException format:@"final boundary not found"];
            possibleEndPtr = p;
            p = skipnewline(p, pmax);
            }
       }
}


- (void)_takeSubpartsFromMessageContent:(EDMessagePart *)mpart
{
    EDInternetMessage	*msg;

    msg = [[EDInternetMessage allocWithZone:[self zone]] initWithTransferData:[mpart contentData]];
    subparts = [[NSArray allocWithZone:[self zone]] initWithObjects:msg, nil];
    [msg release];
}


- (id)_encodeSubpartsWithClass:(Class)targetClass subtype:(NSString *)subtype
{
    EDMessagePart		*result, *subpart;
    NSString			*boundary, *cte, *rootPartType;
    NSMutableDictionary	*ctpDictionary;
    NSEnumerator		*subpartEnum;
    NSData				*boundaryData, *linebreakData;
    NSMutableData		*contentData;

    result = [[[targetClass alloc] init] autorelease];

    // Is it okay to use a time stamp? (Conveys information which might not be known otherwise...)
	// 978307200 is the difference between unix and foundation reference dates
    boundary = [NSString stringWithFormat:@"EDMessagePart-%ld%d", lrint([NSDate timeIntervalSinceReferenceDate]) + 978307200l, boundaryId]; 
    boundaryId = (boundaryId + 1) % 10000;
    ctpDictionary = [NSMutableDictionary dictionary];
    [ctpDictionary setObject:boundary forKey:@"boundary"];
    if([[subtype lowercaseString] isEqualToString:@"related"])
        {
        rootPartType = [[[[subparts objectAtIndex:0] contentType] allObjects] componentsJoinedByString:@"/"];
        [ctpDictionary setObject:rootPartType forKey:@"type"];
        }
    [result setContentType:[EDObjectPair pairWithObjects:@"multipart":subtype] withParameters:ctpDictionary];
    boundaryData = [[@"--" stringByAppendingString:boundary] dataUsingEncoding:NSASCIIStringEncoding];
    linebreakData = [@"\r\n" dataUsingEncoding:NSASCIIStringEncoding];

    cte = MIME7BitContentTransferEncoding;
    contentData = [NSMutableData data];
    [contentData appendData:[@"This is a MIME encoded message.\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    subpartEnum = [subparts objectEnumerator];
    while((subpart = [subpartEnum nextObject]) != nil)
        {
        if([[subpart contentTransferEncoding] isEqualToString:MIME8BitContentTransferEncoding])
            cte = MIME8BitContentTransferEncoding;
        [contentData appendData:linebreakData];
        [contentData appendData:boundaryData];
        [contentData appendData:linebreakData];
        [contentData appendData:[subpart transferData]];
        }
    [contentData appendData:linebreakData];
    [contentData appendData:boundaryData];
    [contentData appendData:[@"--\r\n" dataUsingEncoding:NSASCIIStringEncoding]];
    
    [result setContentData:contentData];
    [result setContentTransferEncoding:cte];

    return result;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
