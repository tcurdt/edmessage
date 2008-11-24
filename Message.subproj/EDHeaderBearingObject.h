//---------------------------------------------------------------------------------------
//  EDHeaderBearingObject.h created by erik on Wed 31-Mar-1999
//  @(#)$Id: EDHeaderBearingObject.h,v 2.1 2003/04/08 17:06:06 znek Exp $
//
//  Copyright (c) 1999 by Erik Doernenburg. All rights reserved.
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

/* This class would be a real candidate for multiple inheritance. Fortunately, the classes that want to adopt its behaviour so far do not need to inherit from some other base class... */

#import <EDCommon/EDCommon.h>

@class EDHeaderFieldCoder;

@interface EDHeaderBearingObject : EDIRCObject
{
    NSMutableArray		 *headerFields;
    NSMutableDictionary  *headerDictionary;
    NSString			 *messageId;
    NSCalendarDate		 *date;
    NSString			 *subject;
    NSString			 *originalSubject;
    NSString			 *author;
}

- (void)addToHeaderFields:(EDObjectPair *)headerField;
- (NSArray *)headerFields;
+ (EDHeaderFieldCoder *)decoderForHeaderField:(EDObjectPair *)headerField;
- (EDHeaderFieldCoder *)decoderForHeaderField:(NSString *)headerField;

- (void)setBody:(NSString *)fieldBody forHeaderField:(NSString *)fieldName;
- (NSString *)bodyForHeaderField:(NSString *)fieldName;

- (void)setMessageId:(NSString *)value;
- (NSString *)messageId;

- (void)setDate:(NSCalendarDate *)value;
- (NSCalendarDate *)date;

- (void)setSubject:(NSString *)value;
- (NSString *)subject;

- (NSString *)originalSubject;
- (NSString *)replySubject;
- (NSString *)forwardSubject;
- (NSString *)author;

@end
