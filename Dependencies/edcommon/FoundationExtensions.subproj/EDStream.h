//---------------------------------------------------------------------------------------
//  EDStream.h created by erik
//  @(#)$Id: EDStream.h,v 2.3 2003-07-01 08:24:15 znek Exp $
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

#import <Foundation/Foundation.h>
#import "EDTextWriter.h"


struct _EDSFlags {
    unsigned int 	enforcesCanonicalLinebreaks:1;
    unsigned int 	escapesLeadingDots:1;		
    unsigned int 	linebreakStyle:2;
};


@interface EDStream : NSObject <EDTextWriter>
{
    struct _EDSFlags	 flags;								/*" All instance variables are private. "*/
    NSFileHandle		*fileHandle;						/*" "*/
    NSFileHandle		*dumpHandle;						/*" "*/
    NSStringEncoding	stringEncoding;						/*" "*/
    NSMutableData		*recordBuffer;						/*" "*/
}

/*" Creating streams "*/
+ (id)streamWithFileHandle:(NSFileHandle *)aFileHandle;
+ (id)streamForReadingAtPath:(NSString *)path;
+ (id)streamForWritingAtPath:(NSString *)path;
+ (id)streamForUpdatingAtPath:(NSString *)path;
+ (id)streamConnectedToHost:(NSHost *)host port:(unsigned short)port;
+ (id)streamConnectedToHost:(NSHost *)host port:(unsigned short)port sendTimeout:(NSTimeInterval)sendTimeout receiveTimeout:(NSTimeInterval)receiveTimeout;
+ (id)streamConnectedToHostWithName:(NSString *)hostname port:(unsigned short)port;
+ (id)streamConnectedToHostWithName:(NSString *)hostname port:(unsigned short)port sendTimeout:(NSTimeInterval)sendTimeout receiveTimeout:(NSTimeInterval)receiveTimeout;

- (id)initWithFileHandle:(NSFileHandle *)aFileHandle;

/*" Managing the stream "*/
- (NSFileHandle *)fileHandle;
- (void)close;

/*" Configuring the stream "*/
- (void)setStringEncoding:(NSStringEncoding)encoding;
- (NSStringEncoding)stringEncoding;

- (void)setLinebreakStyle:(int)aStyle;
- (int)linebreakStyle;

- (void)setEnforcesCanonicalLinebreaks:(BOOL)flag;
- (BOOL)enforcesCanonicalLinebreaks;

- (void)setEscapesLeadingDots:(BOOL)flag;
- (BOOL)escapesLeadingDots;

- (void)setDumpFileHandle:(NSFileHandle *)aFileHandle;
- (NSFileHandle *)dumpFileHandle;

/*" Reading/writing data "*/
- (NSData *)availableData;
- (NSData *)getRecordWithDelimiter:(NSData *)delimiter;
- (NSData *)getRecordBuffer;
- (void)writeData:(NSData *)data;

/*" Reading/writing strings "*/
- (NSString *)availableString;
- (NSString *)availableLine;
- (void)writeString:(NSString *)string;
- (void)writeLine:(NSString *)string;
- (void)writeFormat:(NSString *)format, ...;

@end


enum
{
    EDCanonicalLinebreakStyle = 0,
    EDUnixLinebreakStyle = 1,
    EDMacintoshLinebreakStyle = 2
};

