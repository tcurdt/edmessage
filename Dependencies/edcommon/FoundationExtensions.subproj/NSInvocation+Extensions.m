//---------------------------------------------------------------------------------------
//  NSInvocation+Extensions.m created by erik on Sun 27-May-2001
//  @(#)$Id: NSInvocation+Extensions.m,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 1999 by Erik Doernenburg. All rights reserved.
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
#import "NSInvocation+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSInvocation(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSInvocation. "*/

/*" Returns an invocation the can be used to send %selector to the %object. The method is assumed to have no argument. "*/
+ (NSInvocation *)invocationWithTarget:(id)object method:(SEL)selector
{
    NSInvocation 		*invocation;
    NSMethodSignature	*methodSignature;
    
    methodSignature = [object methodSignatureForSelector:selector];
    invocation = [self invocationWithMethodSignature:methodSignature];
    [invocation setSelector:selector];
    [invocation setTarget:object];

    return invocation;
}


/*" Returns an invocation the can be used to send %selector to the %object. The method is assumed to have one argument. "*/

+ (NSInvocation *)invocationWithTarget:(id)object method:(SEL)selector argument:(void *)argument
{
    NSInvocation *invocation;

    invocation = [self invocationWithTarget:object method:selector];
    [invocation setArgument:&argument atIndex:2];
    
    return invocation;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
