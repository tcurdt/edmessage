//---------------------------------------------------------------------------------------
//  NSFileHandle+NetExt.m created by erik
//  @(#)$Id: NSFileHandle+Extensions.m,v 2.2 2005-09-25 11:06:35 erik Exp $
//
//  Copyright (c) 1997,1999,2008 by Erik Doernenburg. All rights reserved.
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
#import "osdep.h"
#import "functions.h"
#import "NSFileHandle+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSFileHandle(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various useful extensions to #NSFileHandle. Most only work with file handles that represent sockets but this is in a category on NSFileHandle, and not in its subclass #EDIPSocket, because this functionality is also useful for plain NSFileHandles that represent sockets. The latter are often created through invocations such as #acceptConnectionInBackgroundAndNotify. "*/


/*" Returns the port of the local endpoint of the socket. "*/

- (unsigned short)localPort
{
    unsigned int		sockaddrLength;
    struct sockaddr_in	sockaddr;
    
    sockaddrLength = sizeof(struct sockaddr_in);
    if(getsockname([self fileDescriptor], (struct sockaddr *)&sockaddr, &sockaddrLength) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Cannot get local port number for socket: %s", strerror(ED_ERRNO)];
    return sockaddr.sin_port;
}


/*" Returns the address of the local endpoint of the socket in the "typical" dotted numerical notation. "*/

- (NSString *)localAddress
{
    unsigned int		sockaddrLength;
    struct sockaddr_in	sockaddr;
    
    sockaddrLength = sizeof(struct sockaddr_in);
    if(getsockname([self fileDescriptor], (struct sockaddr *)&sockaddr, &sockaddrLength) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Cannot get local port number for socket: %s", strerror(ED_ERRNO)];
    return EDStringFromInAddr(sockaddr.sin_addr);
}


/*" Returns the port of the remote endpoint of the socket. "*/

- (unsigned short)remotePort
{
    unsigned int		sockaddrLength;
    struct sockaddr_in	sockaddr;

    sockaddrLength = sizeof(struct sockaddr_in);
    if(getpeername([self fileDescriptor], (struct sockaddr *)&sockaddr, &sockaddrLength) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Failed to get peer: %s", strerror(ED_ERRNO)];
    return sockaddr.sin_port;
}


/*" Returns the address of the remote endpoint of the socket in the "typical" dotted numerical notation. "*/

- (NSString *)remoteAddress
{
    unsigned int		sockaddrLength;
    struct sockaddr_in	sockaddr;

    sockaddrLength = sizeof(struct sockaddr_in);
    if(getpeername([self fileDescriptor], (struct sockaddr *)&sockaddr, &sockaddrLength) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Failed to get peer: %s", strerror(ED_ERRNO)];
    return EDStringFromInAddr(sockaddr.sin_addr);
}


/*" Returns the host for the remote endpoint of the socket. "*/

- (NSHost *)remoteHost
{
    return [NSHost hostWithAddress:[self remoteAddress]];
}


/*" Causes the full-duplex connection on the socket to be shut down. "*/

- (void)shutdown
{
    if(shutdown([self fileDescriptor], 2) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Failed to shutdown socket: %s", strerror(ED_ERRNO)];
}


/*" Causes part of the full-duplex connection on the socket to be shut down; further receives will be disallowed. "*/

- (void)shutdownInput
{
    if(shutdown([self fileDescriptor], 0) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Failed to shutdown input of socket: %s", strerror(ED_ERRNO)];
}


/*" Causes part of the full-duplex connection on the socket to be shut down; further sends will be disallowed. "*/

- (void)shutdownOutput
{
    if(shutdown([self fileDescriptor], 1) == -1)
        [NSException raise:NSFileHandleOperationException format:@"Failed to shutdown output of socket: %s", strerror(ED_ERRNO)];
}


- (unsigned int)_availableByteCountNonBlocking
{
    int numBytes;

    if(ioctl([self fileDescriptor], FIONREAD, (char *) &numBytes) == -1)
        [NSException raise: NSFileHandleOperationException format: @"ioctl() error # %d", errno];
    return numBytes;
}


/*" Calls #{readDataOfLengthNonBlocking:} with a length of !{UINT_MAX}, effectively reading as much data as is available. "*/

- (NSData *)availableDataNonBlocking
{
    return [self readDataOfLengthNonBlocking:UINT_MAX];
}

/*" Calls #{readDataOfLengthNonBlocking:} with a length of !{UINT_MAX}, effectively reading as far towards the end of the file as possible. "*/

- (NSData *)readDataToEndOfFileNonBlocking
{
    return [self readDataOfLengthNonBlocking:UINT_MAX];
}


/*" Tries to read length bytes of data. If less data is available it does not block to wait for more but returns whatever is available. If no data is available this method returns !{nil} and not an empty instance of #NSData. "*/

- (NSData *)readDataOfLengthNonBlocking:(unsigned int)length
{
    unsigned int available;

    available = [self _availableByteCountNonBlocking];
    if(available == 0)
        return nil;

    return [self readDataOfLength:((available < length) ? available : length)];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
