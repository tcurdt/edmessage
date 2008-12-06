//---------------------------------------------------------------------------------------
//  EDTCPSocket.m created by erik
//  @(#)$Id: EDTCPSocket.m,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 1997-2001,2008 by Erik Doernenburg. All rights reserved.
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
#import "EDTCPSocket.h"


//---------------------------------------------------------------------------------------
    @implementation EDTCPSocket
//---------------------------------------------------------------------------------------

/*" This class implementes TCP sockets and some methods specific to such sockets. Most of the commonly used functionality is in its superclasses #EDIPSocket and #NSFileHandle as well as in the NSFileHandle category defined in this framework.

The following code example shows how to set up a client socket, and connect it to Apple's web server: !{

    EDTCPSocket *socket;

    socket = [EDTCPSocket socket];
    [socket connectToHost:[NSHost hostWithName:hostname] port:80]
}

The following code example shows how to set up a server socket, listening on the standard web port on all interfaces of this host. If we are debugging it sets the "re-use address" option so that we don't have to wait to set up the socket after restarting our application: !{

    EDTCPSocket *socket;

    socket = [EDTCPSocket socket];
\#if DEBUG
    [socket setAllowsAddressReuse:YES];
\#endif
    [socket startListeningOnLocalPort:80];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(newClientNotification:)
                                                 name:NSFileHandleConnectionAcceptedNotification
                                               object:socket];
    [socket acceptConnectionInBackgroundAndNotify];

}

Note that, generally, working with #EDStreams is a better choice than working directly with sockets.

"*/

//---------------------------------------------------------------------------------------
//	CLASS ATTRIBUTES
//---------------------------------------------------------------------------------------

+ (int)socketProtocol
{
    return IPPROTO_TCP;
}


+ (int)socketType
{
    return SOCK_STREAM;
}


//---------------------------------------------------------------------------------------
//	OPTIONS & PARAMETERS
//---------------------------------------------------------------------------------------

/*" Controls wether data written to the socket is sent immediatly or whether the operating system should try to accumulate some data before sending a packet to reduce overhead. This is commonly known as Nagle's algorithm (RFC 896) and corresponds to TCP_NODELAY. "*/

- (void)setSendsDataImmediately:(BOOL)flag
{
    [self setSocketOption:TCP_NODELAY level:IPPROTO_TCP value:flag];
}


//---------------------------------------------------------------------------------------
//	LISTENING
//---------------------------------------------------------------------------------------

/*" Starts listening for incoming connections. This requires that a local port has been set before. Note that #acceptConnectionInBackgroundAndNotify must be called afterwards so that incoming connections are handled. "*/

- (void)startListening
{
    if(listen([self fileDescriptor], 5) == -1)   // backlog length of 5 is maximum
        [NSException raise:NSFileHandleOperationException format:@"Unable start listening on local port: %s", strerror(ED_ERRNO)];
    flags.listening = YES;
}


/*" Starts listening for incoming connections on aPort on all local IP addresses (interfaces). Note that #acceptConnectionInBackgroundAndNotify must be called afterwards so that incoming connections are handled. "*/

- (void)startListeningOnLocalPort:(unsigned short)aPort
{	
    [self setLocalPort:aPort];
    [self startListening];
}


/*" Starts listening for incoming connections on the aPort on the specified local address; the latter being in the "typical" dotted numerical notation. Note that #acceptConnectionInBackgroundAndNotify must be called afterwards so that incoming connections are handled. "*/

- (void)startListeningOnLocalPort:(unsigned short)aPort andAddress:(NSString *)addressString
{
    [self setLocalPort:aPort andAddress:addressString];
    [self startListening];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
