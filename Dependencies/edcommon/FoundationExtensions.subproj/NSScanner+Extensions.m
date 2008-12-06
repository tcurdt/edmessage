//---------------------------------------------------------------------------------------
//  NSScanner+Extensions.m created by erik
//  @(#)$Id: NSScanner+Extensions.m,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 1998-2000 by Erik Doernenburg. All rights reserved.
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
#import "NSScanner+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSScanner(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSScanner. "*/


/*" Copies the remainder of the scanner's string into a string which is returned indirectly through %stringRef. The latter can be !{NULL} in which case the string is discarded. Returns NO if the scanner is at the end when the method is called. "*/

- (BOOL)scanUpToEndIntoString:(NSString **)stringRef
{
    if([self isAtEnd])
        return NO;
    if(stringRef != NULL)
        *stringRef = [[self string] substringFromIndex:[self scanLocation]];
    [self setScanLocation:[[self string] length]];
    return YES;
}


//---------------------------------------------------------------------------------------
//	BRACKET STUFF
//---------------------------------------------------------------------------------------

/*" Assumes that the scanner is located just behind an opening bracket, ie. round, angle, curly or square brackets, and scans up to the matching closing bracket. Nested bracket pairs are ignored in this process. Returns YES if the bracket was found and if %stringRef is not !{NULL} indirectly returns the string between the brackets. "*/


- (BOOL)scanUpToClosingBracketIntoString:(NSString **)stringRef
{
    static unichar  brackets[] = {'(', ')', '[', ']', '{', '}', '<', '>', '\0' };
    NSCharacterSet	*bset;
    NSMutableString	*result;
    NSString		*literal;
    unichar    		oBracket, cBracket;
    int		   		nestingLevel = 1, location, i;

    if((location = [self scanLocation]) == 0)
        [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to scan up to a closing bracket even though no bracket has been scanned.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];

    oBracket = [[self string] characterAtIndex:location - 1];
    for(i = 0; brackets[i] != '\0'; i += 2)
        if(oBracket == brackets[i])
            break;
    if(brackets[i] == 0)
        return NO; // or should we raise an exception?
    cBracket = brackets[i + 1];
    bset = [NSCharacterSet characterSetWithCharactersInString:[NSString stringWithCharacters:&brackets[i] length:2]];

    result = [[[NSMutableString alloc] init] autorelease];
    while(([self isAtEnd] == NO) && (nestingLevel > 0))
        {
        if([self scanUpToCharactersFromSet:bset intoString:&literal])
            [result appendString:literal];
        if([self isAtEnd])
            break;	

        location = [self scanLocation];	
        if([[self string] characterAtIndex:location] == oBracket)
            {
            nestingLevel += 1;
            [self setScanLocation:location + 1];
            [result appendString:[NSString stringWithCharacters:&oBracket length:1]];
            }
        else
            {
            nestingLevel -= 1;
            if(nestingLevel > 0)
                {
                [self setScanLocation:location + 1];
                [result appendString:[NSString stringWithCharacters:&cBracket length:1]];
                }
            }
        }
    if(stringRef != NULL)
        *stringRef = result;	
    return (nestingLevel == 0);	
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
