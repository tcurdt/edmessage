//---------------------------------------------------------------------------------------
//  EDSMTPStream.m created by erik on Sun 12-Mar-2000
//  $Id: EDSMTPStream.m,v 2.1 2003/04/08 17:06:05 znek Exp $
//
//  Copyright (c) 2000,2008 by Erik Doernenburg. All rights reserved.
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
#import <EDCommon/EDCommon.h>
#import "EDSMTPStream.h"

@interface EDSMTPStream(PrivateAPI)
- (void)_assertServerIsReady;
- (void)_startProtocol;
- (void)_shutdown;
- (NSString *)_pathFromAddress:(NSString *)address;
@end


//---------------------------------------------------------------------------------------
    @implementation EDSMTPStream
//---------------------------------------------------------------------------------------

NSString *EDSMTPException = @"EDSMTPException";
NSString *EDBrokenSMPTServerHint = @"EDBrokenSMPTServerHint";
NSString *EDSMTPErrorDomain = @"EDSMTPErrorDomain";


//---------------------------------------------------------------------------------------
//	INITIALISER
//---------------------------------------------------------------------------------------

- (id)initWithFileHandle:(NSFileHandle *)aFileHandle
{
    [super initWithFileHandle:aFileHandle];
    [self setLinebreakStyle:EDCanonicalLinebreakStyle];
    [self setEnforcesCanonicalLinebreaks:YES];
    pendingResponses = [[NSMutableArray allocWithZone:[self zone]] init];
	[self resetCapabilities];
    state = MustReadServerGreeting;
    return self;
}

- (void)dealloc
{
    if(state != ConnectionClosed)
        {
        NS_DURING
        [self close];
        NS_HANDLER
        NS_ENDHANDLER
        }
    [super dealloc];
}

- (void)resetCapabilities
{
	[capabilities release];
    capabilities = [[NSMutableDictionary allocWithZone:[self zone]] init];
}

//---------------------------------------------------------------------------------------
//	STARTUP/SHUTDOWN
//---------------------------------------------------------------------------------------

- (void)_assertServerIsReady
{
    if(state < ServerReadyForCommand)
        {
		[self _startProtocol];
		// this hopefully leaves us with state == ServerReadyForCommand
		}

    if(state == ServerReadyForCommand)
	    {
	    if(([self allowsPipelining] == NO) && ([self hasPendingResponses]))
			{
			[NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to issue an SMTP command when a response is pending and server is not known to allow pipelining.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
			}
		}
    
	if(state > ServerReadyForCommand)
        {
        if(state == ServerReadingBody)
            {
            [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to issue an SMTP command within message body.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
            }
        else if(state == ConnectionClosed)
            {
            [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to issue an SMTP command on a closed stream.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
            }
        else
            {
            [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to issue an SMTP command on an unusable stream.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
            }

        }
}

- (void)_startProtocol
{
	if(state == MustReadServerGreeting)
		{
		[pendingResponses addObject:@"220"];
		[self assertServerAcceptedCommand];
		state = flags2.needExtensionCheck ? ShouldSayEHLO : ShouldSayHELO;
		}
	
	NS_DURING
	
	// Using while loop because we know that TLS requires double EHLO...	
	while(state == ShouldSayEHLO)
		{
		[self sayEHLO];
		}
	// Say EHLO can result in state == ShouldSayHELO
	if(state == ShouldSayHELO)  
		{
		[self sayHELO];
		}
	
	NS_HANDLER
	
		NSMutableDictionary	*amendedUserInfo;
		
		amendedUserInfo = [NSMutableDictionary dictionaryWithDictionary:[localException userInfo]];
		if((flags2.triedExtensionsCheck == YES) && (state != InitFailed))
			[amendedUserInfo setObject:@"YES" forKey:EDBrokenSMPTServerHint];
		state = InitFailed;
		[[NSException exceptionWithName:[localException name] reason:[localException reason] userInfo:amendedUserInfo] raise];
	
	NS_ENDHANDLER
}


- (void)sayEHLO
{
	NSArray	 *response;
	NSString *responseCode;

	[self writeFormat:@"EHLO %@\r\n", [[NSHost currentHost] name]];
	flags2.triedExtensionsCheck = YES;
	response = [self readResponse];
	responseCode = [[response objectAtIndex:0] substringToIndex:3];
	if([responseCode isEqualToString:@"250"]) // okay!
		{
		[self handleEHLOResponse250:response];
		}
	else if(([responseCode hasPrefix:@"5"])) // didn't like EHLO, now try HELO
		{
		state = ShouldSayHELO;
		}
	else // other error; most likely 421 - Service not available
		{
		state = InitFailed;
		[NSException raise:EDSMTPException format:@"Failed to initialize STMP connection; read \"%@\"", [response componentsJoinedByString:@" "]];
		}
}


- (void)handleEHLOResponse250:(NSArray *)response
{
    NSEnumerator *lineEnum;
    NSString	 *line;
    NSArray		 *words;

	lineEnum = [response objectEnumerator];
	while((line = [lineEnum nextObject]) != nil)
	    {
		words = [[line substringFromIndex:4] componentsSeparatedByString:@" "];
		[capabilities setObject:[words subarrayFromIndex:1] forKey:[[words objectAtIndex:0] uppercaseString]];
		}
	state = ServerReadyForCommand;
}


- (void)sayHELO
{
	NSArray	 *response;
	NSString *responseCode;
	
	[self writeFormat:@"HELO %@\r\n", [[NSHost currentHost] name]];
	response = [self readResponse];
	responseCode = [[response objectAtIndex:0] substringToIndex:3];
	if([responseCode isEqualToString:@"250"]) // okay!
		{
		[self handleHELOResponse250:response];
		}
	else if([responseCode hasPrefix:@"5"]) // didn't like HELO?!
		{
		// Not setting InitFailed yet, this can still be a follow on problem from a failed EHLO
		[NSException raise:EDSMTPException format:@"Failed to initialize STMP connection; read \"%@\"", [response componentsJoinedByString:@" "]];
		}
	else
		{
		state = InitFailed;
		[NSException raise:EDSMTPException format:@"Failed to initialize STMP connection; read \"%@\"", [response componentsJoinedByString:@" "]];
		}
}


- (void)handleHELOResponse250:(NSArray *)response
{
	state = ServerReadyForCommand;
}


- (BOOL)authenticatePlainWithUsername:(NSString *)aUsername andPassword:(NSString *)aPassword error:(NSError **)errorPtr
{        
	NSError				*error;
	NSMutableDictionary	*errorInfo;
	NSArray				*response;
	NSString			*responseCode;
    NSData				*token;
	
	error = nil;
	if([self supportsPlainAuthentication] == false)
		{
		errorInfo = [NSMutableDictionary dictionary];
		[errorInfo setObject:@"Server does not support 'plain' authentication." forKey:@"message"];
		if([self authenticationMethods] != nil)
			[errorInfo setObject:[self authenticationMethods] forKey:@"methods"];	
		error = [NSError errorWithDomain:EDSMTPErrorDomain code:0 userInfo:errorInfo];
		}
	else
		{
		token = [[[NSString stringWithFormat:@"\0%@\0%@", aUsername, aPassword] dataUsingEncoding:NSUTF8StringEncoding] encodeBase64];
		[self writeFormat:@"AUTH PLAIN %@", [NSString stringWithData:token encoding:NSASCIIStringEncoding]];
		response = [self readResponse];
		responseCode = [[response objectAtIndex:0] substringToIndex:3];
		if([responseCode isEqualToString:@"235"])
			{
			return YES;
			}
		else
			{
			errorInfo = [NSMutableDictionary dictionary];
			[errorInfo setObject:@"Authentication failed." forKey:@"message"];
			[errorInfo setObject:[response componentsJoinedByString:@" "] forKey:@"response"];	
			error = [NSError errorWithDomain:EDSMTPErrorDomain code:[responseCode intValue] userInfo:errorInfo];
			}
		}
	if((error != nil) && (errorPtr != NULL))
		*errorPtr = error;
	return NO;
}


- (void)_shutdown
{
    if(state == MustReadServerGreeting)
        [pendingResponses addObject:@"220"];
    else if(state == ServerReadingBody)
        [self finishBody];
    while([self hasPendingResponses])
        [self assertServerAcceptedCommand];
    [self writeString:@"QUIT\r\n"];
    [pendingResponses addObject:@"221"];
    [self assertServerAcceptedCommand];
    state = ConnectionClosed;
}


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- (void)close
{
    [self _shutdown];
    [super close];
}


//---------------------------------------------------------------------------------------
//	SMTP EXTENSIONS
//---------------------------------------------------------------------------------------

- (void)checkProtocolExtensions
{
    flags2.needExtensionCheck = YES;
    [self _assertServerIsReady];
}


- (BOOL)handles8BitBodies
{
    return [capabilities objectForKey:@"8BITMIME"] != nil;
}


- (BOOL)allowsPipelining
{
    return [capabilities objectForKey:@"PIPELINING"] != nil;
}

- (BOOL)supportsPlainAuthentication
{
	return [[self authenticationMethods] indexOfObject:@"PLAIN"] != NSNotFound;
}

- (NSArray *)authenticationMethods
{
	return [[capabilities objectForKey:@"AUTH"] arrayByMappingWithSelector:@selector(uppercaseString)];
}
				   

//---------------------------------------------------------------------------------------
//	WRITE WRAPPER
//---------------------------------------------------------------------------------------

- (void)writeSender:(NSString *)sender
{
    [self _assertServerIsReady];
    if([self handles8BitBodies])
        [self writeFormat:@"MAIL FROM:%@ BODY=8BITMIME\r\n", [self _pathFromAddress:sender]];
    else
        [self writeFormat:@"MAIL FROM:%@\r\n", [self _pathFromAddress:sender]];
    [pendingResponses addObject:@"250"];
}


- (void)writeRecipient:(NSString *)recipient
{
    [self _assertServerIsReady];
    [self writeFormat:@"RCPT TO:%@\r\n", [self _pathFromAddress:recipient]];
    [pendingResponses addObject:@"250"];
}


- (void)beginBody
{
    [self _assertServerIsReady];
    [self writeString:@"DATA\r\n"];
    [pendingResponses addObject:@"354"];
    state = ServerReadingBody;
}


- (void)finishBody
{
    if(state != ServerReadingBody)
        [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to finish a message body that was not begun.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
    [self writeString:@"\r\n.\r\n"];
    [pendingResponses addObject:@"250"];
    state = ServerReadyForCommand;
}

- (BOOL)hasPendingResponses
{
    return [pendingResponses count] > 0;
}


- (void)assertServerAcceptedCommand
{
    NSString	*expectedCode;
    NSArray		*response;

    if([pendingResponses count] == 0)
        [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: No pending responses.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];

    expectedCode = [[[pendingResponses objectAtIndex:0] retain] autorelease];
    [pendingResponses removeObjectAtIndex:0];
    response = [self readResponse];
    if([[response objectAtIndex:0] hasPrefix:expectedCode] == NO)
        [NSException raise:EDSMTPException format:@"Unexpected SMTP response code; expected %@, read \"%@\"", expectedCode, [response componentsJoinedByString:@" "]];
}



//-------------------------------------------------------------------------------------------
//	HELPER
//-------------------------------------------------------------------------------------------

- (NSString *)_pathFromAddress:(NSString *)address
{
    NSString	*path;

    if([address hasPrefix:@"<"] == NO)
        path = [NSString stringWithFormat:@"<%@>", address];
    else
        path = address;

    return path;
}


- (NSArray *)readResponse
{
    NSString		*partialResponse;
    NSMutableArray	*response;

    response = [NSMutableArray array];
    do
        {
        partialResponse = [self availableLine];
        [response addObject:partialResponse];
        }
    while([partialResponse characterAtIndex:3] == '-');

    return response;
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
