//---------------------------------------------------------------------------------------
//  EDIPSocket.h created by erik
//  @(#)$Id: EDIPSocket.h,v 2.1 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 1997-2001 by Erik Doernenburg. All rights reserved.
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

#import "EDCommonDefines.h"
#import "EDSocket.h"


struct _EDIPSFlags {
    unsigned int 	listening:1;
    unsigned int 	connectState:2;
    unsigned int 	userAbort:1;
};


@interface EDIPSocket : EDSocket
{
    struct _EDIPSFlags flags;	/*" All instance variables are private. "*/
}

/*" Setting socket options "*/
- (void)setAllowsTransmittingBroadcastMessages:(BOOL)flag;
- (void)setAllowsAddressReuse:(BOOL)flag;
- (void)setAllowsPortReuse:(BOOL)flag;
- (void)setSendTimeout:(NSTimeInterval)aTimeoutVal;
- (void)setReceiveTimeout:(NSTimeInterval)aTimeoutVal;

/*" Set local endpoint "*/
- (void)setLocalPort:(unsigned short)port;
- (void)setLocalPort:(unsigned short)port andAddress:(NSString *)addressString;

// If you are looking for info on addresses/ports, check methods in NSFileHandle+NetExt

/*" Set remote endpoint "*/
- (void)connectToHost:(NSHost *)host port:(unsigned short)port;
- (void)connectToAddress:(NSString *)addressString port:(unsigned short)port;

/*" Status "*/
- (BOOL)isConnected;

@end

/*" Name of an exception which occurs when the connection to a remote port fails due to a timeout. "*/
EDCOMMON_EXTERN NSString *EDSocketTemporaryConnectionFailureException;
/*" Name of an exception which occurs when the connection to a remote port is refused. "*/
EDCOMMON_EXTERN NSString *EDSocketConnectionRefusedException;

