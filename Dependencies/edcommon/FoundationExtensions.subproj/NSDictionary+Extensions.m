//---------------------------------------------------------------------------------------
//  NSDictionary+Extensions.m created by znek on Sun 02-Jan-2000
//  @(#)$Id: NSDictionary+Extensions.m,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 2000 by Erik Doernenburg. All rights reserved.
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
#import "NSDictionary+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSDictionary(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSDictionary. "*/

/*" Based on the assumption that all keys are instances of #NSString returns the object for a key that is equal to %searchKey when compared case insensitively. Note that the dictionary might contain multiple keys that fullfill this criterion and no assumptions should be made regarding the key chosen. In fact, different keys might be chosen in subsequent invocations of this method. "*/

- (id)objectForStringKeyCaseInsensitive:(NSString *)searchKey
{
    NSEnumerator	*keyEnum;
    NSString		*key;
    id				object;

    if((object = [self objectForKey:searchKey]) != nil)
        return object;

    if([self count] > 50) // what's the right constant here?
        {
        if((object = [self objectForKey:[searchKey uppercaseString]]) != nil)
            return object;
        if((object = [self objectForKey:[searchKey lowercaseString]]) != nil)
            return object;
        if((object = [self objectForKey:[searchKey capitalizedString]]) != nil)
            return object;
        }

    keyEnum = [self keyEnumerator];
    while((key = [keyEnum nextObject]) != nil)
        {
        if([key caseInsensitiveCompare:searchKey] == NSOrderedSame)
            return [self objectForKey:key];
        }
    
    return nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
    @implementation NSMutableDictionary(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSMutableDictionary. "*/

/*" Assumes that all values are instances of #NSMutableArray. Creates a dictionary instance if required and adds the %object to the array. "*/

- (void)addObject:(id)object toArrayForKey:(id)key
{
    NSMutableArray *entry;

    if((entry = [self objectForKey:key]) == nil)
    {
        entry = [[NSMutableArray allocWithZone:[self zone]] init];
        [self setObject:entry forKey:key];
        [entry release];
    }
    [entry addObject:object];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
