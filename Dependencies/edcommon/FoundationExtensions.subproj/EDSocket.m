//---------------------------------------------------------------------------------------
//  EDSocket.m created by erik
//  @(#)$Id: EDSocket.m,v 2.3 2003-10-20 16:55:08 znek Exp $
//
//  Copyright (c) 1997-2000,2008 by Erik Doernenburg. All rights reserved.
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
#import "NSObject+Extensions.h"
#import "osdep.h"
#import "EDSocket.h"

@interface EDSocket(PrivateAPI)
- (void)_realHandleNotification:(NSNotification *)notification;
@end


//---------------------------------------------------------------------------------------
    @implementation EDSocket
//---------------------------------------------------------------------------------------

/*" This class and its subclasses provide an object-oriented interface for socket programming. #EDSocket inherits from #NSFileHandle and acts as a common base class. This is a fairly natural choice as a socket is really a special file handle and NSFileHandle actually contains some useful methods to deal with socket functionality, #acceptConnectionInBackgroundAndNotify for example. However, NSFileHandle does not provide a means to create and connect sockets. The interesting part is that NSFileHandle (in Apple's implementation) is a class cluster and all the caveats of subclassing such a thing apply. Hence, most of the code in EDSocket is dealing with general infrastructure. At the moment there is only on subclass, namely #EDIPSocket representing the protocol family !{inet}. There are, however, a lot of other families that you might want to support; Unix domain sockets or Appletalk for example.

Note that some socket related functionality is implemented in a category on NSFileHandle. "*/


//---------------------------------------------------------------------------------------
//	CLASS ATTRIBUTES
//---------------------------------------------------------------------------------------

/*" Must be overriden to return the protocol family for the socket class; for example !{PF_INET} for IP sockets. "*/

+ (int)protocolFamily
{
    [self methodIsAbstract:_cmd];
    return -1; // keep compiler happy
}


/*" Must be overriden to return the protocol for the socket class; for example !{IPPROTO_TCP} for TCP sockets. "*/

+ (int)socketProtocol
{
    [self methodIsAbstract:_cmd];
    return -1; // keep compiler happy
}


/*" Must be overriden to return the type for the socket class; for example !{SOCK_STREAM} for TCP sockets. "*/

+ (int)socketType
{
    [self methodIsAbstract:_cmd];
    return -1; // keep compiler happy
}


//---------------------------------------------------------------------------------------
//	CONSTRUCTORS
//---------------------------------------------------------------------------------------

/*" Creates and returns a socket. Of course, subclasses inherit this method which means a TCP socket can be created as !{[EDTCPSocket socket]}. "*/

+ (id)socket
{
    return [[[self alloc] init] autorelease];
}


//---------------------------------------------------------------------------------------
//	INITIALIZATION & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated socket by creating a POSIX socket with the protocol family, protocol and type as defined by the corresponding class methods. "*/

- (id)init
{
    int socketDesc;

    self = [super init];
    if((socketDesc = socket([isa protocolFamily], [isa socketType], [isa socketProtocol])) < 0)
        {
        [self release];
        [NSException raise:NSFileHandleOperationException format:@"Failed to create a socket: %s", strerror(ED_ERRNO)];
        }
    realHandle = [[NSFileHandle allocWithZone:[self zone]] initWithFileDescriptor:socketDesc closeOnDealloc:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_realHandleNotification:) name:nil object:realHandle];

    return self;
}


/*" Initialises a newly allocated socket by wrapping %aFileHandle. The file handle's file descriptor must represent a  socket. "*/

- (id)initWithFileHandle:(NSFileHandle *)aFileHandle
{
    self = [super init];
    realHandle = [aFileHandle retain];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_realHandleNotification:) name:nil object:realHandle];
    return self;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self]; // to be sure
    [realHandle release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	SOCKET OPTIONS
//---------------------------------------------------------------------------------------

/*" Sets the socket option described by %anOption on protocol level %aLevel to %value. You should not call this method directly but use the "appropriatly" named methods in subclasses, e.g. #{setAllowsAddressReuse:} or #{setSendsDataImmediately:}. "*/

- (void)setSocketOption:(int)anOption level:(int)aLevel value:(int)value
{
    if(setsockopt([self fileDescriptor], aLevel, anOption, (char *)&value, sizeof(value)) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Failed to set option %d on socket: %s", anOption, strerror(ED_ERRNO)];
}

/*" Sets the socket option described by %anOption on protocol level %aLevel to %timeout. You should not call this method directly but use the "appropriatly" named methods in subclasses, e.g. #{setSendTimeout:}. "*/

- (void)setSocketOption:(int)anOption level:(int)aLevel timeValue:(NSTimeInterval)timeout
{
    struct timeval _timeout;

    _timeout.tv_sec  = (int)timeout;
    _timeout.tv_usec = (int)((timeout - (int)timeout) * (NSTimeInterval)1000000);

    if(setsockopt([self fileDescriptor], aLevel, anOption, (struct timeval *)&_timeout, sizeof(_timeout)) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Failed to set option %d on socket: %s", anOption, strerror(ED_ERRNO)];
}


//---------------------------------------------------------------------------------------
//	OVERRIDES 
//---------------------------------------------------------------------------------------

- (NSData *)availableData
{
    return [realHandle availableData];
}


- (NSData *)readDataToEndOfFile
{
    return [realHandle readDataToEndOfFile];
}


- (NSData *)readDataOfLength:(NSUInteger)length
{
    return [realHandle readDataOfLength:length];
}


- (void)writeData:(NSData *)data
{
    [realHandle writeData:data];
}


- (unsigned long long)offsetInFile
{
    [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Operation not allowed on sockets.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
    return 0;// keep Compiler happy
}


- (unsigned long long)seekToEndOfFile
{
    return [realHandle seekToEndOfFile];
}


- (void)seekToFileOffset:(unsigned long long)offset
{
    [realHandle seekToFileOffset:offset];
}


- (void)truncateFileAtOffset:(unsigned long long)offset
{
    [realHandle truncateFileAtOffset:offset];
}


- (void)synchronizeFile
{
    [realHandle synchronizeFile];
}


- (void)closeFile
{
    [realHandle closeFile];
}


- (int)fileDescriptor
{
    return [realHandle fileDescriptor];
}


//---------------------------------------------------------------------------------------
//	FORWARDS
//	We know that certain messages declared in our super class are, in fact, not
//  implemented in it. Hence, we don't need to override them and can use the
//	forwarding mechanism. 
//---------------------------------------------------------------------------------------

- (void)forwardInvocation:(NSInvocation *)invocation
{
    if([realHandle respondsToSelector:[invocation selector]])
        [invocation invokeWithTarget:realHandle];
    else
        [self doesNotRecognizeSelector:[invocation selector]];
}


- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    NSMethodSignature *s;

    if((s = [super methodSignatureForSelector:aSelector]) != nil)
        return s;
    return [realHandle methodSignatureForSelector:aSelector];
}


- (BOOL)respondsToSelector:(SEL)aSelector
{
    if([super respondsToSelector:aSelector] == YES)
        return YES;
    return [realHandle respondsToSelector:aSelector];
}


//---------------------------------------------------------------------------------------
//	NOTIFICATION RESENDING
//---------------------------------------------------------------------------------------

- (void)_realHandleNotification:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] postNotificationName:[notification name] object:self userInfo:[notification userInfo]];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
