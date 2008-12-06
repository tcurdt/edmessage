//---------------------------------------------------------------------------------------
//  NSAttributedString+Extensions.m created by erik on Tue 05-Oct-1999
//  @(#)$Id: NSAttributedString+AppKitExtensions.m,v 2.2 2003-10-20 16:54:24 znek Exp $
//
//  Copyright (c) 1999-2000 by Erik Doernenburg. All rights reserved.
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

#import <AppKit/AppKit.h>
#import "NSAttributedString+Extensions.h"
#import "NSAttributedString+AppKitExtensions.h"


//=======================================================================================
    @implementation NSAttributedString(EDAppKitExtensions)
//=======================================================================================

/*" Various common extensions to #NSAttributedString. "*/

//---------------------------------------------------------------------------------------
//	CLASS ATTRIBUTES
//---------------------------------------------------------------------------------------

/*" Returns a dark blue, 0.1 0.1 0.5 (calibrated). "*/

+ (NSColor *)defaultLinkColor
{
    return [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.5 alpha:1.0];
}


//=======================================================================================
    @end
//=======================================================================================


//=======================================================================================
    @implementation NSMutableAttributedString(EDAppKitExtensions)
//=======================================================================================

/*" Various common extensions to #NSMutableAttributedString. "*/

//---------------------------------------------------------------------------------------
//	APPENDING CONVENIENCE METHODS
//---------------------------------------------------------------------------------------

/*" Appends the string %aURL as a clickable, underlined URL in the default link color. "*/

- (void)appendURL:(NSString *)aURL
{
    [self appendURL:aURL linkColor:[[self class] defaultLinkColor]];
}


/*" Appends the string %aURL as a clickable, underlined URL in the link color specified. "*/

- (void)appendURL:(NSString *)aURL linkColor:(NSColor *)linkColor
{
    NSRange	urlRange;

    urlRange.location = [self length];
    [self appendString:aURL];
    urlRange.length = [self length] - urlRange.location;
    [self addAttribute:NSLinkAttributeName value:aURL range:urlRange];
    [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:urlRange];
    if(linkColor != nil)
        [self addAttribute:NSForegroundColorAttributeName value:linkColor range:urlRange];
}


/*" Appends the image represented by %data with the filename %name to the string. The image is displayed inline if possible. "*/

- (void)appendImage:(NSData *)data name:(NSString *)name
{
    NSFileWrapper	 	*wrapper;
    NSTextAttachment 	*attachment;
    NSAttributedString	*attchString;

    wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
    if(name != nil)
       [wrapper setPreferredFilename:name];
    // standard text attachment displays everything possible inline
    attachment = [[[NSTextAttachment alloc] initWithFileWrapper:wrapper] autorelease];
    attchString = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:attchString];
}


/*" Appends the attachments represented by %data with the filename %name to the string. "*/

- (void)appendAttachment:(NSData *)data name:(NSString *)name
{
    NSFileWrapper		*wrapper;
    NSTextAttachment 	*attachment;
    NSCell			 	*cell;
    NSAttributedString	*attchString;

    wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
    if(name != nil)
        [wrapper setPreferredFilename:name];
    attachment = [[[NSTextAttachment alloc] initWithFileWrapper:wrapper] autorelease];
    cell = (NSCell *)[attachment attachmentCell];
    NSAssert([cell isKindOfClass:[NSCell class]], @"AttachmentCell must inherit from NSCell.");
    [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:[name pathExtension]]];
    attchString = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:attchString];
}


//---------------------------------------------------------------------------------------
//	URLIFIER
//---------------------------------------------------------------------------------------

/*" Invokes #urlifyWithLinkColor with the default link color. "*/

- (void)urlify
{
    [self urlifyWithLinkColor:[[self class] defaultLinkColor] range:NSMakeRange(0, [self length])];
}


/*" Invokes #{urlifyWithLinkColor:range:} with a range covering the entire string. "*/

- (void)urlifyWithLinkColor:(NSColor *)linkColor
{
    [self urlifyWithLinkColor:linkColor range:NSMakeRange(0, [self length])];
}


/*" Searches the section of the reciever defined by %range for URLs. All those found are reformatted to be underlined and clickable and have the link color specified. Schemes recognized are http, ftp, mailto, gopher, news. "*/

- (void)urlifyWithLinkColor:(NSColor *)linkColor range:(NSRange)range
{
    static NSCharacterSet *colon = nil, *alpha, *urlstop;
    static NSString		  *scheme[] = { @"http", @"ftp", @"mailto", @"gopher", @"news", nil };
    static unsigned int   maxServLength = 6;
    NSString			  *string, *url;
    NSRange				  r, remainingRange, possSchemeRange, schemeRange, urlRange;
    NSUInteger			  nextLocation, endLocation, i;

    if(colon == nil)
        {
        colon = [[NSCharacterSet characterSetWithCharactersInString:@":"] retain];
        alpha = [[NSCharacterSet alphanumericCharacterSet] retain];
        urlstop = [[NSCharacterSet characterSetWithCharactersInString:@"\"<>()[]',; \t\n\r"] retain];
        }

    string = [self string];
    nextLocation = range.location;
    endLocation = NSMaxRange(range);
    while(1)
        {
        remainingRange = NSMakeRange(nextLocation, endLocation - nextLocation);
        r = [string rangeOfCharacterFromSet:colon options:0 range:remainingRange];
        if(r.length == 0)
            break;
        nextLocation = NSMaxRange(r);

        if(r.location < maxServLength)
            possSchemeRange = NSMakeRange(0,  r.location);
        else
            possSchemeRange = NSMakeRange(r.location - 6,  6);
        // no need to clean up composed chars becasue they are not allowed in URLs anyway
        for(i = 0; scheme[i] != nil; i++)
            {
            schemeRange = [string rangeOfString:scheme[i] options:(NSBackwardsSearch|NSAnchoredSearch|NSLiteralSearch) range:possSchemeRange];
            if(schemeRange.length != 0)
                {
                r.length = endLocation - r.location;
                r = [string rangeOfCharacterFromSet:urlstop options:0 range:r];
                if(r.length == 0) // not found, assume URL extends to end of string
                    r.location = [string length];
                urlRange = NSMakeRange(schemeRange.location, r.location - schemeRange.location);
                if([string characterAtIndex:NSMaxRange(urlRange) - 1] == (unichar)'.')
                    urlRange.length -= 1;
                url = [string substringWithRange:urlRange];
                [self addAttribute:NSLinkAttributeName value:url range:urlRange];
                [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:urlRange];
                if(linkColor != nil)
                    [self addAttribute:NSForegroundColorAttributeName value:linkColor range:urlRange];
                nextLocation = urlRange.location + urlRange.length;
                break;
                }
            }
        }

}


//=======================================================================================
    @end
//=======================================================================================
