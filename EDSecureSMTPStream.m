//---------------------------------------------------------------------------------------
//  EDSMTPSStream.m created by erik on Wed 08-Oct-2008
//  $Id$
//
//  Copyright (c) 2008 by Erik Doernenburg. All rights reserved.
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

#import "EDSecureSMTPStream.h"
#import "OPSSLSocket.h"

//---------------------------------------------------------------------------------------
    @implementation EDSecureSMTPStream
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)streamConnectedToHost:(NSHost *)host port:(unsigned short)port
{
    OPSSLSocket *socket;
	
    socket = [OPSSLSocket socket];
    [socket connectToHost:host port:port];
    return [self streamWithFileHandle:socket];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (OPSSLSocket *)socket
{
	return (OPSSLSocket *)[self fileHandle];
}


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- (void)handleHELOResponse250:(NSArray *)response
{
	if(![[self socket] isEncrypted])
		{
		state = InitFailed;
		[NSException raise:EDSMTPException format:@"Failed to initialize STMP connection; requested TLS but server does not support it."];
		}
	[super handleHELOResponse250:response];
}


- (void)handleEHLOResponse250:(NSArray *)response
{
	NSString *responseCode;
	
	[super handleEHLOResponse250:response];
	
	if([[self socket] isEncrypted])
		return;

	if([self supportsTLS] == false)
		{
		state = InitFailed;
		[NSException raise:EDSMTPException format:@"Failed to initialize STMP connection; requested TLS but server does not support it."];
		}
	[self writeFormat:@"STARTTLS\r\n"];
	response = [self readResponse];
	responseCode = [[response objectAtIndex:0] substringToIndex:3];
	if([responseCode isEqualToString:@"220"])  
		{
		[[self socket] negotiateEncryption];
		[self resetCapabilities]; 
		state = ShouldSayEHLO;
		}
	else
		{
		state = InitFailed;
		[NSException raise:EDSMTPException format:@"Failed to initialize STMP connection; read \"%@\"", [response componentsJoinedByString:@" "]];
		}
}


//---------------------------------------------------------------------------------------
//	SMTP EXTENSIONS
//---------------------------------------------------------------------------------------

- (BOOL)supportsTLS
{
	return [capabilities objectForKey:@"STARTTLS"] != nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
