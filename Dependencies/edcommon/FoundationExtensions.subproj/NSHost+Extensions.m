//---------------------------------------------------------------------------------------
//  NSHost+Extensions.m created by erik on Fri 15-Oct-1999
//  @(#)$Id: NSHost+Extensions.m,v 2.2 2003-04-21 23:23:56 erik Exp $
//
//  Copyright (c) 1999,2008 by Erik Doernenburg. All rights reserved.
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
#import "NSHost+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSHost(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSHost. "*/

/*" If string describes an internet address (in the "typical" dotted numerical notation) returns the host with that address. Otherwise returns the NSHost with the name %string. In both cases, if caching is turned on and the cache already contains an NSHost with address/name, this method returns that object. Otherwise, this method creates a new instance and returns it. "*/

+ (NSHost *)hostWithNameOrAddress:(NSString *)string
{
    NSHost	*host;

    if((host = [NSHost hostWithAddress:string]) == nil)
        host = [NSHost hostWithName:string];

    return host;
}


/*" Returns the NSHost corresponding to the loopback address of the machine the process is running on. "*/

+ (NSHost *)localhost
{
    return [NSHost hostWithAddress:[self loopbackAddress]];
}


/*" Returns the loopback address in the "typical" dotted numerical notation. "*/

+ (NSString *)loopbackAddress
{
    struct in_addr address;

    address.s_addr = htonl(INADDR_LOOPBACK);
    return EDStringFromInAddr(address);
}


/*" Returns the broadcast address in the "typical" dotted numerical notation. "*/

+ (NSString *)broadcastAddress
{
    struct in_addr address;

    address.s_addr = htonl(INADDR_BROADCAST);
    return EDStringFromInAddr(address);
}


/*" Returns local domain name. On Windows this is simply the domain of the #currentHost, on other platforms the system resolver is queried and the default domain name is returned. "*/

+ (NSString *)localDomain
{
    NSString *domain;
    
    if(!(_res.options & RES_INIT))
        res_init();
    domain = [[[NSString alloc] initWithCString:_res.defdname] autorelease];

    return domain;
}


/*" Returns a fully qualified name for the receiver, or !{nil} if none can be determined. "*/

- (NSString *)fullyQualifiedName
{
    NSEnumerator	*hostnameEnum;
    NSString		*hostname, *fqName;
    NSRange			dotRange;

    fqName = nil;
    hostnameEnum = [[self names] objectEnumerator];
    while((hostname = [hostnameEnum nextObject]) != nil)
        {
        if((dotRange = [hostname rangeOfString:@"."]).length != 0)
            break;
        }

    return fqName;
}


/*" Returns the domain part of a fully qualified name for the receiver, or !{nil} if none can be determined. "*/

- (NSString *)domain
{
    NSString		*fqName, *domain;
    NSRange			dotRange;

    /* If fqName is *nil* we could assume that the host must be local and hence return localDomain (at least on platforms that do not rely on this method to determine the local domain!) but I have consciously decided against that to avoid things like localhost.some.net */

    if((fqName = [self fullyQualifiedName]) == nil)
        return nil;

    dotRange = [fqName rangeOfString:@"."];
    NSAssert(dotRange.length > 0, @"fully qualified name does not contain a dot?!");
    domain = [fqName substringFromIndex:NSMaxRange(dotRange)];
    
    return domain;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
