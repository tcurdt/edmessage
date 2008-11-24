/* 
     $Id: NSString+PlainTextFlowedExtensions.m,v 2.2 2003/05/20 22:39:14 erik Exp $

     Copyright (c) 2001 by Axel Katerbau. All rights reserved.

     Permission to use, copy, modify and distribute this software and its documentation
     is hereby granted, provided that both the copyright notice and this permission
     notice appear in all copies of the software, derivative works or modified versions,
     and any portions thereof, and that both notices appear in supporting documentation,
     and that credit is given to Axel Katerbau in all documents and publicity
     pertaining to direct or indirect use of this code or its derivatives.

     THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
     SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
     "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
     DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
     OR OF ANY DERIVATIVE WORK.
*/

#import "NSString+PlainTextFlowedExtensions.h"
#import "NSString+MessageUtils.h"

@implementation NSString (PlainTextFlowedExtensions)

- (NSString *)stringByEncodingFlowedFormat
{
    NSMutableString *flowedText;
    NSArray *paragraphs;
    NSString *paragraph, *lineBreakSeq;
    NSEnumerator *paragraphEnumerator;

    lineBreakSeq = @"\r\n";
    if([self rangeOfString:lineBreakSeq].location == NSNotFound)
        lineBreakSeq = @"\n";

    flowedText = [[[NSMutableString allocWithZone:[self zone]] initWithCapacity:[self length]] autorelease];

    paragraphs = [self componentsSeparatedByString:lineBreakSeq];

    paragraphEnumerator = [paragraphs objectEnumerator];

    while ((paragraph = [paragraphEnumerator nextObject]) != nil)
    {
        NSAutoreleasePool *pool;

        pool = [[NSAutoreleasePool alloc] init];

        /*
        1.  Ensure all lines (fixed and flowed) are 79 characters or
            fewer in length, counting the trailing space but not
            counting the CRLF, unless a word by itself exceeds 79
            characters.
        */

        /*
        2.  Trim spaces before user-inserted hard line breaks.
        */
        while ([paragraph hasSuffix:@" "])
            paragraph = [paragraph substringToIndex:[paragraph length] - 1]; // chop the last character

        if ([paragraph length] > 79)
        {
            NSString *wrappedParagraph;
            NSArray *paragraphLines;
            NSInteger i, count;
            /*
            When creating flowed text, the generating agent wraps, that is,
            inserts 'soft' line breaks as needed.  Soft line breaks are added
            between words.  Because a soft line break is a SP CRLF sequence, the
            generating agent creates one by inserting a CRLF after the occurance
            of a space.
            */
            wrappedParagraph = [[paragraph stringByAppendingString:lineBreakSeq] stringByWrappingToLineLength:72];

            // chop lineBreakSeq at the end
            wrappedParagraph = [wrappedParagraph substringToIndex:[wrappedParagraph length] - [lineBreakSeq length]];
            paragraphLines = [wrappedParagraph componentsSeparatedByString:lineBreakSeq];

            count = [paragraphLines count];

            for (i = 0; i < count; i++)
            {	
                NSString *line;

                line = [paragraphLines objectAtIndex:i];

                /*
                3.  Space-stuff lines which start with a space, "From ", or ">".
                */  
                line = [line stringBySpaceStuffing];

                if (i < (count-1) ) // ensure soft-break
                {
                    if (! [line hasSuffix:@" "])
                    {
                        line = [line stringByAppendingString:@" "];
                    }
                }
                else
                {
                    while ([line hasSuffix:@" "])
                    {
                        line = [line substringToIndex:[line length] - 1]; // chop the last character (space)
                    }
                }
                [flowedText appendString:line];
                [flowedText appendString:lineBreakSeq];
            }
        }
        else
        {
            // add paragraph to flowedText
            /*
            3.  Space-stuff lines which start with a space, "From ", or ">".
            */  
            paragraph = [paragraph stringBySpaceStuffing];
            [flowedText appendString:paragraph];
            [flowedText appendString:lineBreakSeq];
        }

        [pool release];
    }

    // chop lineBreakSeq at the end
    return [flowedText substringToIndex:[flowedText length] - [lineBreakSeq length]];
}


- (NSString *)stringByDecodingFlowedFormat
{
    NSMutableString *flowedText, *paragraph;
    NSArray *lines;
    NSString *line, *lineBreakSeq;
    NSEnumerator *lineEnumerator;
    int paragraphQuoteDepth = 0;
    BOOL isFlowed;
    
    lineBreakSeq = @"\r\n";
    if([self rangeOfString:lineBreakSeq].location == NSNotFound)
        lineBreakSeq = @"\n";
            
    flowedText = [[NSMutableString allocWithZone:[self zone]] initWithCapacity:[self length]];
    
    paragraph = [NSMutableString string];
        
    if ([self hasSuffix:lineBreakSeq])
        lines = [[self substringToIndex:[self length] - [lineBreakSeq length]] componentsSeparatedByString:lineBreakSeq];
    else
        lines = [self componentsSeparatedByString:lineBreakSeq];
        
    lineEnumerator = [lines objectEnumerator];
    
    while ((line = [lineEnumerator nextObject]) != nil)
    {
        NSAutoreleasePool *pool;
        int quoteDepth = 0;
        /*
        4.2.  Interpreting Format=Flowed
        
        If the first character of a line is a quote mark (">"), the line is
        considered to be quoted (see section 4.5).  Logically, all quote
        marks are counted and deleted, resulting in a line with a non-zero
        quote depth, and content. (The agent is of course free to display the
        content with quote marks or excerpt bars or anything else.)
        Logically, this test for quoted lines is done before any other tests
        (that is, before checking for space-stuffed and flowed).     
        */
        
        pool = [[NSAutoreleasePool alloc] init];
        
        while ([line hasPrefix:@">"])
        {
            line = [line substringFromIndex:1]; // chop of the first character
            quoteDepth += 1;
        }
        
        if ((paragraphQuoteDepth == 0) && (quoteDepth != 0))
            paragraphQuoteDepth = quoteDepth;
            
        /*
        If the first character of a line is a space, the line has been
        space-stuffed (see section 4.4).  Logically, this leading space is
        deleted before examining the line further (that is, before checking
        for flowed).   
        */
        
        if ([line hasPrefix:@" "])
            line = [line substringFromIndex:1]; // chop of the first character
        
        /*
        If the line ends in one or more spaces, the line is flowed.
        Otherwise it is fixed.  Trailing spaces are part of the line's
        content, but the CRLF of a soft line break is not.
        */
        
        isFlowed = [line hasSuffix:@" "] 
            && (paragraphQuoteDepth == quoteDepth) 
            && ([line caseInsensitiveCompare:@"-- "] != NSOrderedSame);
        
        /*
        A series of one or more flowed lines followed by one fixed line is
        considered a paragraph, and MAY be flowed (wrapped and unwrapped) as
        appropriate on display and in the construction of new messages (see
        section 4.5).   
        */
        
        
        [paragraph appendString:line];
        if (! isFlowed)
        {
            if (paragraphQuoteDepth > 0) // add quote chars if needed
            {
                int i;
            
                for (i=0; i<paragraphQuoteDepth; i++)
                    [flowedText appendString:@">"];
                
                [flowedText appendString:@" "];
            }
            
            [flowedText appendString:paragraph];
            [flowedText appendString:lineBreakSeq];
            
            // reset values for next paragraph
            paragraphQuoteDepth = 0;
            [paragraph setString:@""];
        }
        
        [pool release];
    }
    
    // take care of the last paragraph
    if ([paragraph length] > 0)
    {
        if (paragraphQuoteDepth > 0) // add quote chars if needed
        {
            int i;
        
            for (i=0; i<paragraphQuoteDepth; i++)
                [flowedText appendString:@">"];
            
            [flowedText appendString:@" "];
        }
        
        [flowedText appendString:paragraph];
    }
    
    return [flowedText autorelease];
}

- (NSString *)stringBySpaceStuffing
{
    if (([self hasPrefix:@" "]) || ([self hasPrefix:@"From "]))
        return [NSString stringWithFormat:@" %@", self];
    
    return self;
}

@end
