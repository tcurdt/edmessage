//---------------------------------------------------------------------------------------
//  EDIdListFieldCoder.m created by erik
//  @(#)$Id: EDIdListFieldCoder.m,v 2.1 2003/04/08 17:06:05 znek Exp $
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
#import <EDCommon/EDCommon.h>
#import "NSString+MessageUtils.h"
#import "EDIdListFieldCoder.h"

@interface EDIdListFieldCoder(PrivateAPI)
- (void)_takeListFromString:(NSString *)string;
- (NSString *)_getStringForList;
@end


//---------------------------------------------------------------------------------------
    @implementation EDIdListFieldCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)encoderWithIdList:(NSArray *)value
{
    return [[[self alloc] initWithIdList:value] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithFieldBody:(NSString *)body
{
   [self init];
   [self _takeListFromString:body];
   return self;
}


- (id)initWithIdList:(NSArray *)value
{
   [self init];
   list = [[NSArray allocWithZone:[self zone]] initWithArray:value];
   return self;
}


- (void)dealloc
{
   [list release];
   [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (NSArray *)list
{
    return list;
}


- (NSString *)stringValue
{
    return [list componentsJoinedByString:@" "];
}


- (NSString *)fieldBody
{
    return [self _getStringForList];
}


//---------------------------------------------------------------------------------------
//	CODING HELPER METHODS
//---------------------------------------------------------------------------------------

- (void)_takeListFromString:(NSString *)body
{
    static NSCharacterSet *bracketSet = nil, *nonWhitespaceSet;

    NSRange		msgIdRange, searchRange, bracketPos;
    NSInteger	start;

    if(bracketSet == nil)
        {
        bracketSet = [[NSCharacterSet characterSetWithCharactersInString:@"<>"] retain];
        nonWhitespaceSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];
        }

    list = [[NSMutableArray allocWithZone:[self zone]] init];

    start = -1;
    searchRange = NSMakeRange(0, [body length]);
    while(searchRange.length > 0)
        {
        bracketPos = [body rangeOfCharacterFromSet:bracketSet options:0 range:searchRange];
        if(bracketPos.length == 0)
            break;
        
        NSAssert(bracketPos.length < 2, @"Cannot handle composed delimiter characters");
        if([body characterAtIndex:bracketPos.location] == '<')
            {
            start = bracketPos.location;
            }
        else
            {
            if(start >= 0)
                {
                msgIdRange = NSMakeRange(start, NSMaxRange(bracketPos) - start);
                [list addObject:[[body substringWithRange:msgIdRange] stringByRemovingWhitespace]];
                start = -1;
                }
            }

        searchRange.location = NSMaxRange(bracketPos);
        searchRange.length = [body length] - searchRange.location;
        }

}

- (NSString *)_getStringForList
{
    NSMutableArray	*newList;
    NSUInteger		newLength;
    NSUInteger		i;
	NSInteger		n;
    
    if((n = [list count]) == 0)
        return @"";

    newList = [NSMutableArray arrayWithArray:list];
    newLength = -1; // first id doesn't have a leading space...
    for(i = 0; i < [list count]; i++)
        newLength += [(NSString *)[list objectAtIndex:i] length] + 1; // one for space

    // we remove ids until the resulting string is short enough. note that
    // the first and the last three ids are not deleted even if the string
    // remains too long. (cf. son-of-1036)
    while(newLength > 1000 - 12 - 2)
        {
        if([newList count] < 5)
            return nil;
        newLength -= [(NSString *)[newList objectAtIndex:1] length] + 1;	
        [newList removeObjectAtIndex:1];
        }

    return [newList componentsJoinedByString:@" "];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
