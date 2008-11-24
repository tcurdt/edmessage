//---------------------------------------------------------------------------------------
//  EDInternetMessage.m created by erik on Mon 20-Jan-1997
//  @(#)$Id: EDInternetMessage.m,v 2.3 2003/12/03 20:42:17 erik Exp $
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
#import <EDCommon/EDCommon.h>
#import "NSString+MessageUtils.h"
#import "EDMConstants.h"
#import "EDInternetMessage.h"

//---------------------------------------------------------------------------------------
    @implementation EDInternetMessage
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithTransferData:(NSData *)data fallbackHeaderFields:(NSDictionary *)fields
{
    NSString *version;
    
    [super initWithTransferData:data fallbackHeaderFields:fields];

    // a bit late maybe...
    if(((version = [self bodyForHeaderField:@"mime-version"]) != nil) && ([version length] > 0))
        if([[version stringByRemovingBracketComments] floatValue] > 1.0)
            EDLog1(EDLogCoder, @"MIME Decoder: decoded version %@ as 1.0.", version);

    return self;
}


//---------------------------------------------------------------------------------------
//	TRANSFER LEVEL ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (NSData *)transferData
{
    // If we don't have a cached version we'll be constructing the transfer data. In this
    // case tag with our version.
    if((originalTransferData == nil) && ([self bodyForHeaderField:@"mime-version"] == nil))
        {
        NSString *desig = [NSString stringWithFormat:@"EDMessage Framework v%@", EDMessageVersion];
        [self setBody:[NSString stringWithFormat:@"1.0 (%@)", desig] forHeaderField:@"MIME-Version"];
        }
    return [super transferData];
}


//---------------------------------------------------------------------------------------
//	IS EQUAL
//---------------------------------------------------------------------------------------

- (BOOL)isEqual:(id)other
{
    if((isa != ((EDInternetMessage *)other)->isa) && ([other isKindOfClass:[EDInternetMessage class]] == NO))
        return NO;
    return [[self messageId] isEqualToString:[other messageId]];
}


- (BOOL)isEqualToMessage:(EDInternetMessage *)other
{
    return [[self messageId] isEqualToString:[other messageId]];
}


//---------------------------------------------------------------------------------------
//	CONVENIENCE METHODS FOR ATTACHMENTS
//---------------------------------------------------------------------------------------

// later maybe...

- (void)addAttachment:(NSData *)data withName:(NSString *)name
{
    
}

- (void)addAttachment:(NSData *)data withName:(NSString *)name setInlineFlag:(BOOL)inlineFlag
{
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
