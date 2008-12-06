//---------------------------------------------------------------------------------------
//  EDStringWriter.m created by erik on Mon Mar 31 2003
//  @(#)$Id: EDStringWriter.m,v 1.1 2003-05-26 19:43:31 erik Exp $
//
//  Copyright (c) 2003 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Mulle Kybernetik in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#import "EDStringWriter.h"


//---------------------------------------------------------------------------------------
    @implementation EDStringWriter
//---------------------------------------------------------------------------------------

/*" This class is a simple implementation of the #EDTextWriter protocol. It appends all text to its internal buffer. "*/


/*" Initialises a newly allocated string writer with an empty buffer. "*/

- (id)init
{
    return [self initWithBuffer: [NSMutableString string]];
}


/*" Initialises a newly allocated string writer with aBuffer as buffer. "*/

- (id)initWithBuffer:(NSMutableString *)aBuffer
{
    [super init];
    buffer = [aBuffer retain];
    return self;
}


- (void)dealloc
{
    [buffer release];
    [super dealloc];
}


/*" Returns the contents of the internal buffer. Note that this is %live and you must copy the returned string if you want to write to the stream without modifying the string you retrieved. "*/

- (NSString *)string
{
    return buffer;
}


/*" Does nothing. "*/

- (void)flush
{
}


/*" Appends string to the buffer. "*/

- (void)writeString:(NSString *)string
{
    [buffer appendString:string];
}


/*" Appends string and a newline sequence to the buffer "*/

- (void)writeLine:(NSString *)string
{
    [buffer appendString:string];
    [buffer appendString:@"\n"];
}


/*" Creates a string from the !{printf} style format and arguments and appends it to the buffer. "*/

- (void)writeFormat:(NSString *)format, ...
{
    NSString	*temp;
    va_list 	args;

    va_start(args, format);
    temp = [[NSString alloc] initWithFormat:format arguments:args];
    [buffer appendString:temp];
    [temp release];
    va_end(args);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
