//---------------------------------------------------------------------------------------
//  EDStream.m created by erik
//  @(#)$Id: EDStream.m,v 2.2 2003-04-21 23:25:11 erik Exp $
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
#import "EDTCPSocket.h"
#import "EDStream.h"

#define LF ((char)'\x0A')
#define CR ((char)'\x0D')


@interface EDStream(PrivateAPI)
- (void)_writeRawData:(NSData *)data;
@end


//---------------------------------------------------------------------------------------
    @implementation EDStream
//---------------------------------------------------------------------------------------

/*" This class is meant to be used with sockets but it can work with all kinds of NSFileHandle. The main concept in EDStream is the conversion from raw data, chopped up into chunks of arbitrary size and delivered as NSData objects, into a stream of NSString objects representing meaningful units, lines for example. EDStream also contains functionality to simplify the implementation of common text-based internet protocols such as SMTP and NNTP. "*/

static NSData	*linebreakSequences[3];


//---------------------------------------------------------------------------------------
//	CLASS INITS
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    if(linebreakSequences[0] != nil)
        return;
    linebreakSequences[0] = [[NSData alloc] initWithBytes:&"\r\n" length:2];
    linebreakSequences[1] = [[NSData alloc] initWithBytes:&"\n" length:1];
    linebreakSequences[2] = [[NSData alloc] initWithBytes:&"\r" length:1];
}
    

//---------------------------------------------------------------------------------------
//	FACTORY METHODS
//---------------------------------------------------------------------------------------

/*" Creates and returns a stream for %aFileHandle. "*/

+ (id)streamWithFileHandle:(NSFileHandle *)aFileHandle
{
    return [[[self alloc] initWithFileHandle:aFileHandle] autorelease];
}


/*" Creates and returns a stream initialised for reading at path. The file pointer is set to the beginning of the file. If no file exists at path the method returns !{nil}. "*/

+ (id)streamForReadingAtPath:(NSString *)path
{
    NSFileHandle *handle;

    if((handle = [NSFileHandle fileHandleForReadingAtPath:path]) == nil)
        return nil;
    return [[[self alloc] initWithFileHandle:handle] autorelease];
}

/*" Creates and returns a stream initialised for writing at path. The file pointer is set to the beginning of the file. If no file exists at path the method returns !{nil}. "*/

+ (id)streamForWritingAtPath:(NSString *)path
{
    NSFileHandle *handle;

    if((handle = [NSFileHandle fileHandleForWritingAtPath:path]) == nil)
        return nil;
    return [[[self alloc] initWithFileHandle:handle] autorelease];
}

/*" Creates and returns a stream initialised for reading and writing at path. The file pointer is set to the beginning of the file. If no file exists at path the method returns !{nil}. "*/

+ (id)streamForUpdatingAtPath:(NSString *)path
{
    NSFileHandle *handle;

    if((handle = [NSFileHandle fileHandleForUpdatingAtPath:path]) == nil)
        return nil;
    return [[[self alloc] initWithFileHandle:handle] autorelease];
}


/*" Creates and returns a stream for an EDTCPSocket connected to port on host. "*/

+ (id)streamConnectedToHost:(NSHost *)host port:(unsigned short)port
{
    EDTCPSocket *socket;

    socket = [EDTCPSocket socket];
    [socket connectToHost:host port:port];
    return [self streamWithFileHandle:socket];
}


/*" Creates and returns a stream for an EDTCPSocket connected to port on the host with the name hostname. "*/

+ (id)streamConnectedToHostWithName:(NSString *)hostname port:(unsigned short)port
{
    return [self streamConnectedToHost:[NSHost hostWithName:hostname] port:port];
}


/*" Creates and returns a stream for an EDTCPSocket connected to port on host. %SendTimeout and %receiveTimout are set on this socket. "*/

+ (id)streamConnectedToHost:(NSHost *)host port:(unsigned short)port sendTimeout:(NSTimeInterval)sendTimeout receiveTimeout:(NSTimeInterval)receiveTimeout
{
    EDTCPSocket *socket;

    socket = [EDTCPSocket socket];
    [socket setSendTimeout:sendTimeout];
    [socket setReceiveTimeout:receiveTimeout];
    [socket connectToHost:host port:port];
    return [self streamWithFileHandle:socket];
}


/*" Creates and returns a stream for an EDTCPSocket connected to port on the host with the name hostname. %SendTimeout and %receiveTimout are set on this socket. "*/

+ (id)streamConnectedToHostWithName:(NSString *)hostname port:(unsigned short)port sendTimeout:(NSTimeInterval)sendTimeout receiveTimeout:(NSTimeInterval)receiveTimeout
{
    return [self streamConnectedToHost:[NSHost hostWithName:hostname] port:port sendTimeout:sendTimeout receiveTimeout:receiveTimeout];
}


//---------------------------------------------------------------------------------------
//	INITIALIZATION & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated stream by setting its file handle to aFileHandle. "*/

- (id)initWithFileHandle:(NSFileHandle *)aFileHandle
{    
    [super init];
    fileHandle = [aFileHandle retain];
    recordBuffer = [[NSMutableData allocWithZone:[self zone]] init];
    stringEncoding = [NSString defaultCStringEncoding];
    return self;
}


- (void)dealloc
{
    [recordBuffer release];
    [fileHandle release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ATTRIBUTES
//---------------------------------------------------------------------------------------

/*" Returns the file handle the stream uses for reading and writing. "*/

- (NSFileHandle *)fileHandle
{
    return fileHandle;
}


/*" Sets %aFileHandle as "dump" file handle. All data read from or written to the real file handle is copied (written) to this file handle. "*/

- (void)setDumpFileHandle:(NSFileHandle *)aFileHandle
{
    id old = dumpHandle;
    dumpHandle = [aFileHandle retain];
    [old release];
}


/*" Returns the "dump" file handle. All data read from or written to the real file handle is copied (written) to this file handle. "*/

- (NSFileHandle *)dumpFileHandle
{
    return dumpHandle;
}


/*" Sets the string encoding used to convert to and from the data objects used on the network. The default is !{[NSString defaultCStringEncoding]}.

Note that for some string encodings sequences of bytes exist that cannot be transformed into a string. (An example is UTF-8 and a byte sequence ending with a byte that has bit 8 set.) #EDStream uses the #{NSString}'s conversion methods and these nullify the entire sequence which means that an undefined number of characters around the "offending" one can be affected. This can also affect #availableString if for some reason only part of a multibyte sequence becomes available. (Highly unlikely but possible.) An obvious workaround is to use #availableLine when reading such character encodings. "*/

- (void)setStringEncoding:(NSStringEncoding)encoding
{
    stringEncoding = encoding;
}


/*" Returns the string encoding used to convert to and from the data objects used on the network. "*/

- (NSStringEncoding)stringEncoding
{
    return stringEncoding;
}


/*" Sets the linebreak style used for communication. The following table lists all styles:

_{EDCanonicalLinebreakStyle CR+LF, most commonly used style} _{EDUnixLinebreakStyle LF only, common on UNIX and hence Mac OS X text files} _{EDMacintoshLinebreakStyle CR only, common for older Mac OS 9 text files}

The linebreak style can be change during normal operation if required. "*/

- (void)setLinebreakStyle:(int)aStyle
{
    NSParameterAssert((aStyle >= 0) && (aStyle <= 2));
    flags.linebreakStyle = aStyle;
}


/*" Returns the linebreak style used for communication. See #{setLinebreakStyle:} for more details. "*/

- (int)linebreakStyle
{
    return flags.linebreakStyle;
}


/*" If set to YES all linebreaks written to the stream, as strings or data objects, that are not canonical are automatically replaced by a canonical linebreak, i.e. CR+LF. Note that this only works if #linebreakStyle is !{EDCanonicalLinebreakStyle} and only affects data/strings written to the stream; no conversions take place while reading. The default is not to enforce canonical linebreaks.  "*/

- (void)setEnforcesCanonicalLinebreaks:(BOOL)flag
{
    if((flag == YES) && (flags.linebreakStyle != EDCanonicalLinebreakStyle))
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Can only enforce canonical linebreaks if linebreak style is EDCanonicalLinebreakStyle.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
    flags.enforcesCanonicalLinebreaks = flag;
}

/*" Returns whether linebreak sequences are converted to canonical linebreak sequences when writing. See #{setEnforcesCanonicalLinebreaks:} for details. "*/

- (BOOL)enforcesCanonicalLinebreaks
{
    return flags.enforcesCanonicalLinebreaks;
}


/*" If set to YES all dots '.' at the beginning of a line are doubled. This is required for protocols such as SMTP and NNTP when transmitting message bodies. The default is not to double leading dots. "*/

- (void)setEscapesLeadingDots:(BOOL)flag
{
    // the following is not really true. we could also escape dots if linebreak style is unix....
    if((flag == YES) && (flags.linebreakStyle != EDCanonicalLinebreakStyle))
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Can only escape leading dots if linebreak style is EDCanonicalLinebreakStyle.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
    flags.escapesLeadingDots = flag;
}


/*" Returns whether dots '.' at the beginning of a line are doubled. See #{setEscapesLeadingDots:} for details. "*/

- (BOOL)escapesLeadingDots
{
    return flags.escapesLeadingDots;
}


//---------------------------------------------------------------------------------------
//	PRIMITIVES
//---------------------------------------------------------------------------------------

/*" Closes the stream and its file handle; disallowing further communication. This does not automatically release the stream. "*/

- (void)close
{
    [fileHandle closeFile];
}


/*" Causes all in-memory data to be written to permanent storage. This method should be invoked by programs that require a file to always be in a known state. An invocation of this method does not return until memory is flushed. "*/

- (void)flush
{
    [fileHandle synchronizeFile];
}


/*" Returns the data available through the stream. If the stream's file handle represents a file, it returns all data between the current file pointer and the end of the file. If it represents a communication channel, e.g. a socket, this method returns the contents of the communication buffer; blocking until some data is available if neccessary. (See #availableData in #NSFileHandle for further details.)

Note that if you used #{getRecordWithDelimiter:} data might still be available in the record buffer; see #getRecordBuffer for details. This method does not (by design) touch the record buffer. It is best not to mix #availableData and #{getRecordWithDelimiter:} calls. "*/

- (NSData *)availableData
{
    NSData	*newData;

    newData = [fileHandle availableData];
    if(dumpHandle != nil)
        [dumpHandle writeData:newData];
    
    return newData;
}


/*" Synchronously writes data to the stream's file handle. (See #{writeData:} in #NSFileHandle for further details.) If #enforcesCanonicalLinebreaks and/or #escapesLeadingDots are set the appropriate conversions are carried out. "*/ 
- (void)writeData:(NSData *)data
{
    const byte 		*source;
    byte			c;
    unsigned int   	chunk, pos, length;

    if((flags.enforcesCanonicalLinebreaks == NO) && (flags.escapesLeadingDots == NO))
        {
        [self _writeRawData:data];
        return;
        }

    source = [data bytes];
    length = [data length];
    chunk = 0;

    for(pos = 0; pos < length; pos++)
        {
        c = source[pos];
        if((flags.enforcesCanonicalLinebreaks) && (c == LF) && ((pos == 0) || (source[pos - 1] != CR)))
            {
            [self _writeRawData:[data subdataWithRange:NSMakeRange(chunk, (pos - chunk))]];
            [self _writeRawData:linebreakSequences[EDCanonicalLinebreakStyle]];
            chunk = pos + 1;
            }
        if((flags.escapesLeadingDots == YES) && ((c == LF) || (pos == 0)) && (pos + 1 < length) && (source[pos + 1] == '.'))
            {
            if(pos >= chunk)
                [self _writeRawData:[data subdataWithRange:NSMakeRange(chunk, (pos - chunk + 1))]];
            [self _writeRawData:[NSData dataWithBytes:&"." length:1]];
            chunk = pos + 1;
            }
        }

    if(pos >= chunk)
        [self _writeRawData:[data subdataWithRange:NSMakeRange(chunk, (pos - chunk))]];
}


- (void)_writeRawData:(NSData *)data
{   
    if(dumpHandle != nil)
        [dumpHandle writeData:data];
    [fileHandle writeData:data];
}


//---------------------------------------------------------------------------------------
//	READING STRUCTURED DATA
//---------------------------------------------------------------------------------------

/*" Reads and returns data up to (and not including) delimiter. If not enough data is available this method blocks until more data is received. Returns !{nil} if delimeter cannot be found in the remainder of the stream. In this case the remaining data is available through #getRecordBuffer. "*/

- (NSData *)getRecordWithDelimiter:(NSData *)delimiter
{
    NSData				*newData, *record;
    unsigned int 		newLength, oldLength, nextRecordPos;
    const char 			*bp, *dp, *dmp, *bpMax, *dmpMax;

    bp = [recordBuffer bytes];
    bpMax = bp + [recordBuffer length];
    dp = dmp = [delimiter bytes];
    dmpMax = dp + [delimiter length];

    do
        {
        if(bp == bpMax)
            {
            newData = [self availableData];
            //[NSThread sleepUntilDate:[NSDate dateWithTimeIntervalSinceNow:1]];
            if((newLength = [newData length]) == 0)
                return nil;
            oldLength = [recordBuffer length];
            [recordBuffer appendData:newData];
            bp = [recordBuffer bytes] + oldLength;
            bpMax = bp + newLength;
          }
        while(bp < bpMax)
            {
            if(*bp == *dmp) 			// start/continue pattern match
                {
                dmp += 1;
                if(dmp == dmpMax)
                    break;
                }
            else						// no match with pattern
                {
                if(dmp != dp) 			// we were in a match before, go back. this
                    {					// is naive, cf. Knuth-Morris-Pratt algorithm	
                    bp -= (dmp - dp);
                    dmp = dp;
                    }
                }
            bp += 1;
            }
        }
    while(bp == bpMax);

    nextRecordPos = bp - (const char *)[recordBuffer bytes] + 1;
    record = [recordBuffer subdataWithRange:NSMakeRange(0, nextRecordPos - (dmp - dp))];
    if(nextRecordPos < [recordBuffer length])
        {
        [recordBuffer setData:[recordBuffer subdataWithRange:NSMakeRange(nextRecordPos, [recordBuffer length] - nextRecordPos)]];
        }
    else
        {
        [recordBuffer setLength:0];
        }

    return record;
}


/*" Returns the contents of the record buffer and empties it. The record buffer contains all data that has been read from the stream but not requested through #{getRecordWithDelimiter:} yet. "*/

- (NSData *)getRecordBuffer
{
    NSData	*copyOfBuffer;

    copyOfBuffer = [[recordBuffer copy] autorelease];
    [recordBuffer setLength:0];

    return copyOfBuffer;
}	



//---------------------------------------------------------------------------------------
//	READING STRINGS
//---------------------------------------------------------------------------------------

/*" Returns the data available through the stream converted into a string. If the stream's file handle represents a file, it returns all data between the current file pointer and the end of the file. If it represents a communication channel, e.g. a socket, this method returns the contents of the communication buffer; blocking until some data is available if neccessary. (See #availableData in #NSFileHandle for further details.)

Please read the description of #{setStringEncoding:} before using this with multibyte character encodings.

You can mix #availableString and #availableLine without loosing data. However, #availableString might block even if some data was available in the record buffer. "*/

- (NSString *)availableString
{
    NSString	  *string;

    string = [[[NSString allocWithZone:[self zone]] initWithData:[self availableData] encoding:stringEncoding] autorelease];
    if([recordBuffer length] > 0)
        string = [[[[NSString allocWithZone:[self zone]] initWithData:[self getRecordBuffer] encoding:stringEncoding] autorelease] stringByAppendingString:string];
    return string;
}


/*" Reads and returns a string up to (and not including) the current linebreak sequence. If not enough data is available this method blocks until more data is received. Returns !{nil} if no more data is available on the stream. "*/

- (NSString *)availableLine
{
    NSData 		  *lineData;
    NSString	  *string;

    if((lineData = [self getRecordWithDelimiter:linebreakSequences[flags.linebreakStyle]]) != nil)
        {
        string = [[[NSString allocWithZone:[self zone]] initWithData:lineData encoding:stringEncoding] autorelease];
        }
    else if([recordBuffer length] > 0)
        {
        string = [[[NSString allocWithZone:[self zone]] initWithData:[self getRecordBuffer] encoding:stringEncoding] autorelease];
        }
    else
        {
        string = nil;
        }
    return string;
}


//---------------------------------------------------------------------------------------
//	WRITING STRINGS
//---------------------------------------------------------------------------------------

/*" Converts string into a data object with the current string encoding and writes it using #{writeData:} "*/

- (void)writeString:(NSString *)string
{
    [self writeData:[string dataUsingEncoding:stringEncoding]];
}


/*" Converts string into a data object with the current string encoding and writes it using #{writeData:} followed by a linebreak sequence determined by #linebreakStyle. "*/

- (void)writeLine:(NSString *)string
{
    [self writeData:[string dataUsingEncoding:stringEncoding]];
    [self writeData:linebreakSequences[flags.linebreakStyle]];
}


/*" Creates a string from the !{printf} style format and arguments, converts this into a data object with the current string encoding and writes it using #{writeData:}. "*/

- (void)writeFormat:(NSString *)format, ...
{
    va_list 	args;

    va_start(args, format);
    [self writeString:[[[NSString alloc] initWithFormat:format arguments:args] autorelease]];
    va_end(args);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
