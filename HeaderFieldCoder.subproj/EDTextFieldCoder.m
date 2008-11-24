//---------------------------------------------------------------------------------------
//  EDTextFieldCoder.m created by erik
//  @(#)$Id: EDTextFieldCoder.m,v 2.2 2003/04/08 17:06:05 znek Exp $
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
#import "NSString+MessageUtils.h"
#import "NSData+MIME.h"
#import "EDMConstants.h"
#import "EDTextFieldCoder.h"

@interface EDTextFieldCoder(PrivateAPI)
+ (NSString *)_wrappedWord:(NSString *)aString encoding:(NSString *)encoding;
@end

#define EDLS_MALFORMED_MIME_HEADER_WORD \
NSLocalizedString(@"Syntax error in MIME header word \"%@\"", "Reason for exception which is raised when a MIME header word is encountered that is syntactically malformed.")

#define EDLS_UNKNOWN_ENCODING_SPEC \
NSLocalizedString(@"Unknown encoding specifier in header field; found \"%@\"", "Reason for exception which is raised when an unknown encoding specifier is found.")


//---------------------------------------------------------------------------------------
    @implementation EDTextFieldCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)encoderWithText:(NSString *)value
{
    return [[[self alloc] initWithText:value] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithFieldBody:(NSString *)body
{
    [self init];
    text = [[[self class] stringByDecodingMIMEWordsInString:body] retain];
    return self;
}


- (id)initWithText:(NSString *)value
{
    [self init];
    text = [value copyWithZone:[self zone]];
    return self;
}


- (void)dealloc
{
    [text release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	CODING
//---------------------------------------------------------------------------------------

- (NSString *)text
{
    return text;
}


- (NSString *)stringValue
{
    return text;
}


- (NSString *)fieldBody
{
    return [[self class] stringByEncodingString:text];
}


//---------------------------------------------------------------------------------------
//	HELPER METHODS
//---------------------------------------------------------------------------------------

+ (NSString *)stringByDecodingMIMEWordsInString:(NSString *)fieldBody
{
    NSMutableString		*result;
    NSScanner			*scanner;
    NSString			*chunk, *charset, *transferEncoding, *previousChunk, *decodedWord;
    NSStringEncoding	stringEncoding;
    NSData				*wContents;
    BOOL				hasSeenEncodedWord;

    result = [NSMutableString string];
    hasSeenEncodedWord = NO;
    scanner = [NSScanner scannerWithString:fieldBody];
    [scanner setCharactersToBeSkipped:nil];
    while([scanner isAtEnd] == NO)
        {
        if([scanner scanUpToString:@"=?" intoString:&chunk] == YES)
            {
            if((hasSeenEncodedWord == NO) || ([chunk isWhitespace] == NO))
                [result appendString:chunk];
            }
        if([scanner scanString:@"=?" intoString:NULL] == YES)
            {
            previousChunk = chunk;
            if(([scanner scanUpToString:@"?" intoString:&charset] == NO) ||
               ([scanner scanString:@"?" intoString:NULL] == NO) ||
               ([scanner scanUpToString:@"?" intoString:&transferEncoding] == NO) ||
               ([scanner scanString:@"?" intoString:NULL] == NO) ||
               ([scanner scanUpToString:@"?=" intoString:&chunk] == NO) ||
               ([scanner scanString:@"?=" intoString:NULL] == NO))
                {
                [NSException raise:EDMessageFormatException format:EDLS_MALFORMED_MIME_HEADER_WORD, fieldBody];
                if([previousChunk isWhitespace])
                    [result appendString:previousChunk];
                hasSeenEncodedWord = NO;
               }
            else
                {
                wContents = [chunk dataUsingEncoding:NSASCIIStringEncoding];
                if([transferEncoding caseInsensitiveCompare:@"Q"] == NSOrderedSame)
                    wContents = [wContents decodeHeaderQuotedPrintable];
                else if([transferEncoding caseInsensitiveCompare:@"B"] == NSOrderedSame)
                    wContents = [wContents decodeBase64];
                else
                    [NSException raise:EDMessageFormatException format:EDLS_UNKNOWN_ENCODING_SPEC, transferEncoding];
                charset = [charset lowercaseString];
                if((stringEncoding = [NSString stringEncodingForMIMEEncoding:charset]) == 0)
                    stringEncoding = NSASCIIStringEncoding;
                // Only very few string encodings make malformed words possible but of course,
                // if there is something to break a user agent will. In this case stringWithData
                // returns nil by the way.
                if((decodedWord = [NSString stringWithData:wContents encoding:stringEncoding]) != nil)
                    [result appendString:decodedWord];
                hasSeenEncodedWord = YES;
                }
            }
        }
    return result;
}


+ (NSString *)stringByEncodingString:(NSString *)string
{
    NSCharacterSet	*spaceCharacterSet;
    NSScanner		*scanner;
    NSMutableString	*buffer, *chunk;
    NSString		*currentEncoding, *nextEncoding, *word, *spaces;

    spaceCharacterSet = [NSCharacterSet characterSetWithCharactersInString:@" "];
    buffer = [[[NSMutableString allocWithZone:[(NSObject *)self zone]] init] autorelease];
    scanner = [NSScanner scannerWithString:string];
    [scanner setCharactersToBeSkipped:nil];

    chunk = [NSMutableString string];
    currentEncoding = nil;
    do
        {
        if([scanner scanCharactersFromSet:spaceCharacterSet intoString:&spaces] == NO)
            spaces = @"";
        if([scanner scanUpToCharactersFromSet:spaceCharacterSet intoString:&word] == NO)
            word = nil;

        nextEncoding = [word recommendedMIMEEncoding];
        if((nextEncoding != currentEncoding) || ([chunk length] + [word length] + 7 + [currentEncoding length] > 75) || (word == nil))
            {
            if([chunk length] > 0)
                {
                if([currentEncoding caseInsensitiveCompare:MIMEAsciiStringEncoding] != NSOrderedSame)
                    [buffer appendString:[self _wrappedWord:chunk encoding:currentEncoding]];
                else
                    [buffer appendString:chunk];
                }
            [buffer appendString:spaces];
            currentEncoding = nextEncoding;
            chunk = [[word mutableCopy] autorelease];
            }
        else
            {
            [chunk appendString:spaces];
            [chunk appendString:word];
            }
        }
    while([chunk length] > 0);

    return buffer;
}

#ifndef UINT_MAX
// doesn't really matter, 4 Gig should be enough for everybody.... ;-)
#define UINT_MAX 0xffffffff 
#endif

+ (NSString *)_wrappedWord:(NSString *)aString encoding:(NSString *)encoding
{
    NSData			*stringData, *b64Rep, *qpRep, *transferRep;
    NSString		*result;
    NSUInteger		b64Length, qpLength, length;

    stringData = [aString dataUsingMIMEEncoding:encoding];
    b64Rep = [stringData encodeBase64WithLineLength:(UINT_MAX - 3) andNewlineAtEnd:NO];
    qpRep = [stringData encodeHeaderQuotedPrintable];
    b64Length = [b64Rep length]; qpLength = [qpRep length];
    if((qpLength < 6) || (qpLength < [stringData length] * 3/2) || (qpLength <= b64Length))
        transferRep = qpRep;
    else
        transferRep = b64Rep;

    // Note, that this might be wrong if QP was chosen even though it was longer than B64!
    if((length = [transferRep length] + 7 + [encoding length]) > 75)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Encoding of this header field body results in a MIME word which exceeds the maximum length of 75 characters. Try to split it into components that are separated by whitespaces.", NSStringFromClass(self), NSStringFromSelector(_cmd)];

    result = [[[NSString allocWithZone:[(NSObject *)self zone]] initWithFormat:@"=?%@?%@?%@?=", encoding, (transferRep == qpRep) ? @"Q" : @"B", [NSString stringWithData:transferRep encoding:NSASCIIStringEncoding]] autorelease];

    return result;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
