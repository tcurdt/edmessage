//---------------------------------------------------------------------------------------
//  EDDateFieldCoder.m created by erik
//  @(#)$Id: EDDateFieldCoder.m,v 2.2 2003/04/21 03:04:15 erik Exp $
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

#import <Foundation/Foundation.h>
#import <EDCommon/EDCommon.h>
#import "NSCalendarDate+NetExt.h"
#import "EDMConstants.h"
#import "EDDateFieldCoder.h"

@interface EDDateFieldCoder(PrivateAPI)
- (void)_takeDateFromString:(NSString *)string;
- (NSTimeZone *)_canonicalTimeZone;
@end


//---------------------------------------------------------------------------------------
    @implementation EDDateFieldCoder
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CLASS ATTRIBUTES
//---------------------------------------------------------------------------------------

+ (NSString *)dateFormat
{
    return @"%a, %d %b %Y %H:%M:%S %z";
}


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)encoderWithDate:(NSCalendarDate *)value
{
    return [[[self alloc] initWithDate:value] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithFieldBody:(NSString *)body
{
    [self init];
    [self _takeDateFromString:body];
    return self;
}


- (id)initWithDate:(NSCalendarDate *)value
{
    [self init];
    date = [value retain];
    return self;
}


- (void)dealloc
{
    [date release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (NSCalendarDate *)date
{
    return date;
}


- (NSString *)stringValue
{
    NSString *format = [[NSUserDefaults standardUserDefaults] stringForKey:@"NSDateFormatString"];
    return [date descriptionWithCalendarFormat:format];
}


- (NSString *)fieldBody
{
    NSCalendarDate	*canonicalDate;

    canonicalDate = [[date copy] autorelease];
    [canonicalDate setTimeZone:[self _canonicalTimeZone]];

    return [canonicalDate descriptionWithCalendarFormat:[[self class] dateFormat]];
}


//---------------------------------------------------------------------------------------
//	CODING HELPER METHODS
//---------------------------------------------------------------------------------------

#ifndef CLASSIC_VERSION

// Use a new parser written by Axel in Objective-C.     

- (void)_takeDateFromString:(NSString *)string
{
    string = [string stringByRemovingSurroundingWhitespace];
    date = [[NSCalendarDate dateWithMessageTimeSpecification:string] retain];
    if(date == nil)
        EDLog1(EDLogCoder, @"Invalid date spec; found \"%@\"\n", string);
}

#else

// Use classic yacc grammer for dates. Needs yacc (configured to use bison in postamble)
// and a locking mechanism. This is "proven technology" but looses the timezone and
// will not recognize new style timezones such as Europe/Rome. The choice is yours...


extern time_t parsedate(const char *datespec);

- (void)_takeDateFromString:(NSString *)string
{
    static char buffer[128];
    static EDLightWeightLock retainLock;
    static BOOL lockInitialized = NO;
    time_t t;

    if(lockInitialized == NO)
        {
        lockInitialized = YES;
        EDLWLInit(&retainLock);
        }
      
    EDLWLLock(&retainLock);
    [string getCString:buffer maxLength:127];
    if((t = parsedate(buffer)) == -1)
        {
        EDLog1(EDLogCoder, @"Invalid date spec; found \"%@\"\n", string);
        }
    else
        {
        t += -978307200; // Convert from Unix reference date to Foundation reference date
        date = [[NSCalendarDate allocWithZone:[self zone]] initWithTimeIntervalSinceReferenceDate:t];
        [date setTimeZone:[self _canonicalTimeZone]];
        }
    EDLWLUnlock(&retainLock);
}

#endif

//---------------------------------------------------------------------------------------
//	OTHER HELPER METHODS
//---------------------------------------------------------------------------------------

- (NSTimeZone *)_canonicalTimeZone
{
    static NSTimeZone *canonicalTimeZone = nil;

    if(canonicalTimeZone == nil)
        {
        canonicalTimeZone = [[NSTimeZone alloc] initWithName:@"GMT"];
        NSAssert(canonicalTimeZone != nil, @"System does not know time zone GMT.");
        }
    return canonicalTimeZone;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
