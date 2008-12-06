//---------------------------------------------------------------------------------------
//  EDUDPSocket.m created by erik
//  @(#)$Id: EDUDPSocket.m,v 2.2 2005-09-25 11:06:35 erik Exp $
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
#import "osdep.h"
#import "functions.h"
#import "EDUDPSocket.h"

#define EDUDPSOCK_BUFFERSIZE 4096


//---------------------------------------------------------------------------------------
    @implementation EDUDPSocket
//---------------------------------------------------------------------------------------

/*" This class implementes UDP sockets. Most of the commonly used functionality is in its superclasses #EDIPSocket and #NSFileHandle as well as in the NSFileHandle category defined in this framework.

For unconnected UDP sockets  #remoteHost returns the last host a package was received from. "*/

//---------------------------------------------------------------------------------------
//	CLASS ATTRIBUTES
//---------------------------------------------------------------------------------------

+ (int)socketProtocol
{
    return IPPROTO_UDP;
}


+ (int)socketType
{
    return SOCK_DGRAM;
}


//-------------------------------------------------------------------------------------------
//	INIT & DEALLOC
//-------------------------------------------------------------------------------------------

- (id)init
{
    [super init];
    remoteAddress = NULL;
    return self;
}

- (void)dealloc
{
    if(remoteAddress != NULL)
        NSZoneFree([self zone], remoteAddress);
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	CONNECTION SETUP AND SHUTDOWN
//---------------------------------------------------------------------------------------

- (void)connectToHost:(NSHost *)host port:(unsigned short)port
{
    flags.connectState = 0;
    [super connectToHost:host port:port];
}


//---------------------------------------------------------------------------------------
//	RECEIVING
//---------------------------------------------------------------------------------------

- (NSData *)availableData
{
    int		bytesRead;
    char	buffer[EDUDPSOCK_BUFFERSIZE];

    if(flags.connectState > 0)
        {
        bytesRead = recv([self fileDescriptor], buffer, EDUDPSOCK_BUFFERSIZE, 0);
        }
    else
        {
        unsigned int remoteAddressLength;

        remoteAddressLength = sizeof(struct sockaddr_in);
        if(remoteAddress == NULL)
            remoteAddress = NSZoneMalloc([self zone], remoteAddressLength);
        bytesRead = recvfrom([self fileDescriptor], buffer, EDUDPSOCK_BUFFERSIZE, 0, (struct sockaddr *)remoteAddress, &remoteAddressLength);
        }
    if(bytesRead == -1)
        [NSException raise:NSFileHandleOperationException format:@"Unable to read from socket: %s", strerror(ED_ERRNO)];

    return [NSData dataWithBytes:&buffer length:bytesRead];
}


//---------------------------------------------------------------------------------------
//	REMOTE HOST OVERRIDE
//---------------------------------------------------------------------------------------

- (NSHost *)remoteHost
{
    NSString 	*address;

    if(remoteAddress == NULL)
        return nil;
    
    address = EDStringFromInAddr(((struct sockaddr_in *)remoteAddress)->sin_addr);
    return [NSHost hostWithAddress:address];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
