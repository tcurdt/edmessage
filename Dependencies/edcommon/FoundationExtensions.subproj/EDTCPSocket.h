//---------------------------------------------------------------------------------------
//  EDTCPSocket.h created by erik
//  @(#)$Id: EDTCPSocket.h,v 2.1 2003-04-08 16:51:35 znek Exp $
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

#import "EDIPSocket.h"

@interface EDTCPSocket : EDIPSocket
{
}

/*" Setting socket options "*/
- (void)setSendsDataImmediately:(BOOL)flag;

/*" Server sockets "*/
- (void)startListening;
- (void)startListeningOnLocalPort:(unsigned short)aPort;
- (void)startListeningOnLocalPort:(unsigned short)aPort andAddress:(NSString *)addressString;

@end
