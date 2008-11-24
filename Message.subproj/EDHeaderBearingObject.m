//---------------------------------------------------------------------------------------
//  EDHeaderBearingObject.m created by erik on Wed 31-Mar-1999
//  @(#)$Id: EDHeaderBearingObject.m,v 2.1 2003/04/08 17:06:06 znek Exp $
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

#import <Foundation/Foundation.h>

#import "NSString+MessageUtils.h"
#import "EDHeaderFieldCoder.h"
#import "EDTextFieldCoder.h"
#import "EDEntityFieldCoder.h"
#import "EDDateFieldCoder.h"
#import "EDIdListFieldCoder.h"
#import "EDFaceFieldCoder.h"
#import "EDHeaderBearingObject.h"


//---------------------------------------------------------------------------------------
    @implementation EDHeaderBearingObject
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)init
{
    [super init];
    headerFields = [[NSMutableArray allocWithZone:[self zone]] init];
    headerDictionary = [[NSMutableDictionary allocWithZone:[self zone]] init];
    return self;
}


- (void)dealloc
{
    [headerFields release];
    [headerDictionary release];
    [messageId release];
    [date release];
    [subject release];
    [originalSubject release];
    [author release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)addToHeaderFields:(EDObjectPair *)headerField
{
    NSString	 *fieldName, *sharedName, *fieldBody;

    fieldName = [headerField firstObject];
    fieldBody = [headerField secondObject];
    if((sharedName = [fieldName sharedInstance]) != fieldName)
        headerField = [[[EDObjectPair allocWithZone:[self zone]] initWithObjects:sharedName:fieldBody] autorelease];
    [headerFields addObject:headerField];
    [headerDictionary setObject:fieldBody forKey:[[fieldName lowercaseString] sharedInstance]];
}


- (NSArray *)headerFields
{
    return headerFields;
}


- (void)setBody:(NSString *)fieldBody forHeaderField:(NSString *)fieldName
{
    EDObjectPair	*headerField;
    NSString 		*canonicalName;
    NSUInteger		i, n;
    
    fieldName = [fieldName sharedInstance];
    canonicalName = [[fieldName lowercaseString] sharedInstance];
    headerField = [[EDObjectPair allocWithZone:[self zone]] initWithObjects:fieldName:fieldBody];
    if([headerDictionary objectForKey:canonicalName] != nil)
        {
        for(i = 0, n = [headerFields count]; i < n; i++)
            if([[[headerFields objectAtIndex:i] firstObject] caseInsensitiveCompare:fieldName] == NSOrderedSame)
                break;
        NSAssert(i < n, @"header dictionary inconsistent with header fields");
        [headerFields replaceObjectAtIndex:i withObject:headerField];
        }
    else
        {
        [headerFields addObject:headerField];
        }
    [headerDictionary setObject:fieldBody forKey:canonicalName];
    [headerField release];
}


- (NSString *)bodyForHeaderField:(NSString *)fieldName
{
    NSString *fieldBody;

    if((fieldBody = [headerDictionary objectForKey:fieldName]) == nil)
        if((fieldBody = [headerDictionary objectForKey:[fieldName lowercaseString]]) == nil)
            return nil;
    return fieldBody;
}


//---------------------------------------------------------------------------------------
//	CONVENIENCE HEADER ACCESSORS (CACHED)
//---------------------------------------------------------------------------------------

- (void)setMessageId:(NSString *)value
{
    EDIdListFieldCoder *fCoder;

    [value retain];
    [messageId release];
    messageId = value;

    fCoder = [[EDIdListFieldCoder alloc] initWithIdList:[NSArray arrayWithObject:messageId]];
    [self setBody:[fCoder fieldBody] forHeaderField:@"Message-Id"];
    [fCoder release];
}


- (NSString *)messageId
{
    NSString *fBody;

    if((messageId == nil) && ((fBody = [self bodyForHeaderField:@"message-id"]) != nil))
        messageId = [[[[EDIdListFieldCoder decoderWithFieldBody:fBody] list] lastObject] retain];
    return messageId;
}


- (void)setDate:(NSCalendarDate *)value
{
    EDDateFieldCoder *fCoder;
    
    [value retain];
    [date release];
    date = value;

    fCoder = [[EDDateFieldCoder alloc] initWithDate:date];
    [self setBody:[fCoder fieldBody] forHeaderField:@"Date"];
    [fCoder release];
}


- (NSCalendarDate *)date
{
    NSString *fBody;

    if((date == nil) && ((fBody = [self bodyForHeaderField:@"date"]) != nil))
        date = [[[EDDateFieldCoder decoderWithFieldBody:fBody] date] retain];
    return date;
}	


- (void)setSubject:(NSString *)value
{
    EDTextFieldCoder *fCoder;

    [value retain];
    [subject release];
    subject = value;
    [originalSubject release];
    originalSubject = nil;

    fCoder = [[EDTextFieldCoder alloc] initWithText:value];
    [self setBody:[fCoder fieldBody] forHeaderField:@"Subject"];
    [fCoder release];

}


- (NSString *)subject
{
    NSString *fBody;

    if((subject == nil) && ((fBody = [self bodyForHeaderField:@"subject"]) != nil))
        subject = [[[EDTextFieldCoder decoderWithFieldBody:fBody] text] retain];
    return subject;
}


//---------------------------------------------------------------------------------------
//	ACCESSORS FOR ATTRIBUTES DERIVED FROM HEADER FIELDS
//---------------------------------------------------------------------------------------

- (NSString *)originalSubject
{
    if(originalSubject == nil)
        originalSubject = [[[self subject] stringByRemovingReplyPrefix] retain];
    return originalSubject;
}


- (NSString *)replySubject
{
    // I do not want to see this localized!
    if([[self subject] isEqualToString:[self originalSubject]])
        return [@"Re: " stringByAppendingString:[self subject]];
    return [self subject];
}


- (NSString *)forwardSubject
{
    // Maybe we should localize this.
    return [[@"[FWD: " stringByAppendingString:[self subject]] stringByAppendingString:@"]"];
}


- (NSString *)author
{
    NSString *fBody;

    // Actually, a message can have multiple authors, but this will not look too bad...
    if((author == nil) && ((fBody = [self bodyForHeaderField:@"from"]) != nil))
        author = [[[[EDTextFieldCoder decoderWithFieldBody:fBody] text] realnameFromEMailString] retain];
    return author;
}


//---------------------------------------------------------------------------------------
//	CODER CLASS CACHE
//---------------------------------------------------------------------------------------

static NSMutableDictionary *coderClassCache = nil;


+ (void)_setupCoderClassCache
{
    coderClassCache = [[NSMutableDictionary alloc] init];
    [coderClassCache setObject:[EDDateFieldCoder class] forKey:@"date"];
    [coderClassCache setObject:[EDDateFieldCoder class] forKey:@"expires"];
    [coderClassCache setObject:[EDIdListFieldCoder class] forKey:@"message-id"];
    [coderClassCache setObject:[EDIdListFieldCoder class] forKey:@"references"];
#ifndef EDMESSAGE_WOBUILD
    [coderClassCache setObject:[EDFaceFieldCoder class] forKey:@"x-face"];
#endif
}


+ (EDHeaderFieldCoder *)decoderForHeaderField:(EDObjectPair *)headerField
{
    NSString	*name;
    Class 		coderClass;

    if(coderClassCache == nil)
        [self _setupCoderClassCache];

    name = [[headerField firstObject] lowercaseString];
    if((coderClass = [coderClassCache objectForKey:name]) == nil)
        {
        if([name hasPrefix:@"content-"])
            coderClass = [EDEntityFieldCoder class];
        else
            coderClass = [EDTextFieldCoder class];
        }

    return [coderClass decoderWithFieldBody:[headerField secondObject]];
}


- (EDHeaderFieldCoder *)decoderForHeaderField:(NSString *)fieldName
{
    NSString	*body;

    if((body = [self bodyForHeaderField:fieldName]) == nil)
        return nil;
    return [[self class] decoderForHeaderField:[EDObjectPair pairWithObjects:fieldName:body]];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
