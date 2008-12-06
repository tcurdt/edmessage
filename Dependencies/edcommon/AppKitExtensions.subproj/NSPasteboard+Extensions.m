//---------------------------------------------------------------------------------------
//  NSPasteboard+Extensions.m created by erik on Mon 28-Jun-1999
//  @(#)$Id: NSPasteboard+Extensions.m,v 2.1 2003-04-08 16:51:32 znek Exp $
//
//  Copyright (c) 1999-2000 by Erik Doernenburg. All rights reserved.
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
#import "NSPasteboard+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSPasteboard(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various useful extensions to #NSPasteboard. "*/


/*" Returns YES if %type is one of the types available on the pasteboard. "*/

- (BOOL)containsType:(NSString *)type
{
    return [[self types] indexOfObject:type] != NSNotFound;
}


/*" Archives the %object using the standard #NSArchiver and stores it with the type specified. "*/

- (void)setObject:(id)object forType:(NSString *)pboardType
{
    [self setData:[NSArchiver archivedDataWithRootObject:object] forType:pboardType];
}


/*" Unarchives the object stored with the type specified using the standard #NSUnarchiver. This effectively copies the original object. "*/

- (id)objectForType:(NSString *)pboardType
{
    NSData *data = [self dataForType:pboardType];
    return (data != nil) ? [NSUnarchiver unarchiveObjectWithData:data] : nil;
}


/*" Saves a reference to the object on the pasteboard. This is in form of a pointer and, hence, can only be used in the same process space. Note also, that the object must be retained externally until its reference is removed from the pasteboard. "*/

- (void)setObjectByReference:(id)object forType:(NSString *)pboardType
{
    [self setData:[NSData dataWithBytes:&object length:sizeof(id)] forType:pboardType];
}

/*" Returns the object stored by reference on the pasteboard. This method can return invalid object references as it does not (and cannot) ensure the corresponding object has not been deallocated while the reference was on the pasteboard. "*/

- (id)objectByReferenceForType:(NSString *)pboardType
{
    NSData *data = [self dataForType:pboardType];
    return (data != nil) ? (*((id *)[[self dataForType:pboardType] bytes])) : nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
