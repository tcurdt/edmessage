//---------------------------------------------------------------------------------------
//  functions.m created by erik
//  @(#)$Id: functions.m,v 2.1 2003-04-08 16:51:35 znek Exp $
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
#import "osdep.h"
#import "functions.h"


NSString *EDStringFromInAddr(struct in_addr address)
{
    const unsigned char *bytes = (void *)&address;
    return [NSString stringWithFormat:@"%d.%d.%d.%d", bytes[0], bytes[1], bytes[2], bytes[3]];
}


struct in_addr EDInAddrFromString(NSString *string)
{
    NSScanner		*scanner;
    int				byte, i;
    unsigned int	numaddr;
    struct in_addr	inaddr;

    scanner = [NSScanner scannerWithString:string];
    numaddr = 0;
    for(i = 0; i < 4; i++)
        {
        if(([scanner scanInt:&byte] == NO) || (byte < 0) || (byte > 255))
            [NSException raise:NSInvalidArgumentException format:@"Cannot interpret \"%@\" as an internet address.", string];
        if((i < 3) && ([scanner scanString:@"." intoString:NULL] == NO))
            [NSException raise:NSInvalidArgumentException format:@"Cannot interpret \"%@\" as an internet address.", string];
        numaddr *= 256;
        numaddr += byte;
        }
    inaddr.s_addr = NSSwapHostIntToBig(numaddr);

    return inaddr;
}

