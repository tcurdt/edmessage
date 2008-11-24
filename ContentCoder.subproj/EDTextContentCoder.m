//---------------------------------------------------------------------------------------
//  EDTextContentCoder.m created by erik on Fri 12-Nov-1999
//  @(#)$Id: EDTextContentCoder.m,v 2.1 2003-04-08 17:06:03 znek Exp $
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

#ifndef EDMESSAGE_WOBUILD

#import <AppKit/AppKit.h>
#import <EDCommon/EDCommon.h>
#import "NSString+MessageUtils.h"
#import "EDMessagePart.h"
#import "EDMConstants.h"
#import "EDTextContentCoder.h"

@interface EDTextContentCoder(PrivateAPI)
- (NSString *)_stringFromMessagePart:(EDMessagePart *)mpart;
- (void)_takeTextFromPlainTextMessagePart:(EDMessagePart *)mpart;
- (void)_takeTextFromEnrichedTextMessagePart:(EDMessagePart *)mpart;
- (void)_takeTextFromHTMLMessagePart:(EDMessagePart *)mpart;
@end


//---------------------------------------------------------------------------------------
    @implementation EDTextContentCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CAPABILITIES
//---------------------------------------------------------------------------------------

+ (BOOL)canDecodeMessagePart:(EDMessagePart *)mpart
{
    NSString	*subtype, *charset;

    if([[[mpart contentType] firstObject] isEqualToString:@"text"] == NO)
       return NO;

    charset = [[mpart contentTypeParameters] objectForKey:@"charset"];
    if((charset != nil) && ([NSString stringEncodingForMIMEEncoding:charset] == 0))
        return NO;

    subtype = [[mpart contentType] secondObject];
    if([subtype isEqualToString:@"plain"] || [subtype isEqualToString:@"enriched"] || [subtype isEqualToString:@"html"])
        return YES;

    return NO;
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithMessagePart:(EDMessagePart *)mpart
{
    [super init];
    if([[[mpart contentType] firstObject] isEqualToString:@"text"])
        {
        if([[[mpart contentType] secondObject] isEqualToString:@"plain"])
            [self _takeTextFromPlainTextMessagePart:mpart];
        else if([[[mpart contentType] secondObject] isEqualToString:@"enriched"])
            [self _takeTextFromEnrichedTextMessagePart:mpart];
        else if([[[mpart contentType] secondObject] isEqualToString:@"html"])
            [self _takeTextFromHTMLMessagePart:mpart];
        }
    return self;
}


- (void)dealloc
{
    [text release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ATTRIBUTES
//---------------------------------------------------------------------------------------

- (NSAttributedString *)text
{
    return text;
}


//---------------------------------------------------------------------------------------
//	DECODING
//---------------------------------------------------------------------------------------

- (NSString *)_stringFromMessagePart:(EDMessagePart *)mpart
{
    NSString			*charset;
    NSStringEncoding	textEncoding;

    if((charset = [[mpart contentTypeParameters] objectForKey:@"charset"]) == nil)
        charset = MIMEAsciiStringEncoding;
    if((textEncoding = [NSString stringEncodingForMIMEEncoding:charset]) > 0)
        return [NSString stringWithData:[mpart contentData] encoding:textEncoding];
    return nil;
}


- (void)_takeTextFromPlainTextMessagePart:(EDMessagePart *)mpart
{
    NSString *string;
    
    if((string = [self _stringFromMessagePart:mpart]) != nil)
        text = [[NSAttributedString allocWithZone:[self zone]] initWithString:string];
}


- (void)_takeTextFromEnrichedTextMessagePart:(EDMessagePart *)mpart
{
    static NSCharacterSet 	  *etSpecialSet = nil, *newlineSet;
    NSScanner				  *scanner;
    NSMutableAttributedString *output;
    EDStack					  *markerStack;
    EDObjectPair			  *marker;
    NSString			  	  *string, *tag;
    int					  	  nofillct, paramct, pos1;
	unsigned int			  nlSeqLength;

    if(etSpecialSet == nil)
        {
        etSpecialSet = [[NSCharacterSet characterSetWithCharactersInString:@"\n\r<"] retain];
        newlineSet = [[NSCharacterSet characterSetWithCharactersInString:@"\n\r"] retain];
        }

    if((string = [self _stringFromMessagePart:mpart]) == nil)
        return;
    scanner = [NSScanner scannerWithString:string];
    [scanner setCharactersToBeSkipped:nil];
    markerStack = [EDStack stack];
    text = [[NSMutableAttributedString alloc] init];
    nofillct = paramct = 0;

    while([scanner isAtEnd] == NO)
        {
        output = (paramct > 0) ? nil : text;
        if([scanner scanUpToCharactersFromSet:etSpecialSet intoString:&string])
            {
            [output appendString:string];
            }
        else if([scanner scanString:@"<" intoString:NULL])
            {
            if([scanner scanString:@"<" intoString:NULL])
                {
                [output appendString:@"<"];
                }
            else
                {
                if([scanner scanUpToString:@">" intoString:&string] == NO)
                    [NSException raise:EDMessageFormatException format:@"Missing `>' in text/enriched body."];
                [scanner scanString:@">" intoString:NULL];
                tag = [string lowercaseString];
                if([tag isEqualToString:@"param"])
                    {
                    paramct += 1;
                    }
                else if([tag isEqualToString:@"/param"])
                    {
                    paramct -= 1;
                    }
                else if([tag isEqualToString:@"nofill"])
                    {
                    nofillct += 1;
                    }
                else if([tag isEqualToString:@"/nofill"])
                    {
                    nofillct -= 1;
                    }
                else if([tag isEqualToString:@"bold"])
                    {
                    marker = [EDObjectPair pairWithObjects:string:[NSNumber numberWithUnsignedInteger:[text length]]];
                    [markerStack pushObject:marker];
                    }
                else if([tag isEqualToString:@"/bold"])
                    {
                    marker = [markerStack popObject];
                    NSAssert([[marker firstObject] isEqualToString:@"bold"], @"unbalanced tags...");
                    pos1 = [[marker secondObject] intValue];
                    [text applyFontTraits:NSBoldFontMask range:NSMakeRange(pos1, [text length] - pos1)];
                    }
                else if([tag isEqualToString:@"italic"])
                    {
                    marker = [EDObjectPair pairWithObjects:string:[NSNumber numberWithUnsignedInteger:[text length]]];
                    [markerStack pushObject:marker];
                    }
                else if([tag isEqualToString:@"/italic"])
                    {
                    marker = [markerStack popObject];
                    NSAssert([[marker firstObject] isEqualToString:@"italic"], @"unbalanced tags...");
                    pos1 = [[marker secondObject] intValue];
                    [text applyFontTraits:NSItalicFontMask range:NSMakeRange(pos1, [text length] - pos1)];
                    }
#warning * a lot of tags are missing and bug with bold and italic
                /* If you add more tags please take note that the current attribute handling model is extremely simple and applies the changes when the endmarker is reached, i.e. in reverse order. As bold and italic are not exclusive this works for the moment... Actually, it doesn't work at all because the attributes of the last character are applied to appended strings. Hence, we do need a two-pass approach!  */
                }
            }
        else if([scanner scanCharactersFromSet:newlineSet intoString:&string])
            {
            if(nofillct > 0)
                {
                [output appendString:string];
                }
            else
                {
                nlSeqLength = [string hasPrefix:@"\r\n"] ? 2 : 1;
                if([string length] == nlSeqLength)
                    [output appendString:@" "];
                else
                    [output appendString:[string substringFromIndex:nlSeqLength]];
                }
            }
        }
}


- (void)_takeTextFromHTMLMessagePart:(EDMessagePart *)mpart
{
    NSString			*charset;
    NSStringEncoding	textEncoding;
    NSData				*data;

    if((charset = [[mpart contentTypeParameters] objectForKey:@"charset"]) == nil)
        charset = MIMEAsciiStringEncoding;
    if((textEncoding = [NSString stringEncodingForMIMEEncoding:charset]) == 0)
        [NSException raise:EDMessageFormatException format:@"Invalid charset in message part; found '%@'", charset];
    data = [[NSString stringWithData:[mpart contentData] encoding:textEncoding] dataUsingEncoding:NSUnicodeStringEncoding];
    text = [[NSAttributedString allocWithZone:[self zone]] initWithHTML:data documentAttributes:NULL];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

#endif
