//---------------------------------------------------------------------------------------
//  NSObject+Extensions.m created by erik on Sun 06-Sep-1998
//  @(#)$Id: NSObject+Extensions.m,v 2.5 2005-09-25 11:06:36 erik Exp $
//
//  Copyright (c) 1998-2000,2008 by Erik Doernenburg. All rights reserved.
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
#import <objc/objc-class.h>
#import "EDObjcRuntime.h"
#import "NSObject+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSObject(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various extensions to #NSObject. "*/

//---------------------------------------------------------------------------------------
//	RUNTIME CONVENIENCES
//---------------------------------------------------------------------------------------

/*" Raises an #NSInternalInconsistencyException stating that the method must be overriden. "*/

- (volatile void)methodIsAbstract:(SEL)selector
{
    [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: Abstract definition must be overriden.", NSStringFromClass([self class]), NSStringFromSelector(selector)];
}


/*" Prints a warning that the method is obsolete. This warning is only printed once per method. "*/

- (void)methodIsObsolete:(SEL)selector
{
    [self methodIsObsolete:selector hint:nil];
}


/*" Prints a warning that the method is obsolete including the %hint supplied. This warning is only printed once per method. "*/

- (void)methodIsObsolete:(SEL)selector hint:(NSString *)hint
{
    static NSMutableSet *methodList = nil;
    EDObjcMethodInfo method;
    NSValue *methodKey;

    if(methodList == nil)
        methodList = [[NSMutableSet alloc] init];

   if((method = EDObjcClassGetInstanceMethod(isa, selector)) == NULL)
       method = EDObjcClassGetClassMethod(isa, selector);

   methodKey = [NSValue valueWithBytes:&method objCType:@encode(Method)];
   if([methodList containsObject:methodKey] == NO)
       {
       [methodList addObject:methodKey];
       if(hint == nil)
           NSLog(@"*** Warning: Compatibility method '%@' in class %@ has been invoked at least once.", NSStringFromSelector(selector), NSStringFromClass([self class]));
       else
           NSLog(@"*** Warning: Compatibility method '%@' in class %@ has been invoked at least once. %@", NSStringFromSelector(selector), NSStringFromClass([self class]), hint);
        }
}


- (NSString *)className
{
    return NSStringFromClass([self class]);
}


//---------------------------------------------------------------------------------------
//	EXTENDED INTROSPECTION 
//---------------------------------------------------------------------------------------
#if 0
IMP EDGetFirstUnusedIMPForSelector(Class aClass, SEL aSelector, BOOL isClassMethod)
{
#ifndef GNU_RUNTIME
    IMP						activeIMP;
    struct objc_method_list	*mlist;
    void					*iterator;
    int						i;

    if(isClassMethod)
        aClass = aClass->isa;
    iterator = 0;
    activeIMP = [aClass instanceMethodForSelector:aSelector];
    while((mlist = class_nextMethodList(aClass, &iterator)) != NULL)
        {
        for(i = 0; i < mlist->method_count; i++)
            {
            if((mlist->method_list[i].method_name == aSelector) && (mlist->method_list[i].method_imp != activeIMP))
                return mlist->method_list[i].method_imp;
            }
        }
    return NULL;
#else /* GNU_RUNTIME */
#warning ** implementation missing for GNU runtime
    return NULL;
#endif
}
#endif

BOOL EDClassIsSuperclassOfClass(Class aClass, Class subClass)
{
    Class class;

    class = class_getSuperclass(subClass);
    while(class != nil)
        {
        if(class == aClass)
            return YES;
		class = class_getSuperclass(subClass);
        }
    return NO;
}


NSArray *EDSubclassesOfClass(Class aClass)
{
    NSMutableArray *subclasses;
    Class          *classes;
    int            numClasses, newNumClasses, i;

    // cf. /System/Library/Frameworks/System.framework/Headers/objc/objc-runtime.h
    numClasses = 0, newNumClasses = objc_getClassList(NULL, 0);
    classes = NULL;
    while (numClasses < newNumClasses)
        {
        numClasses = newNumClasses;
        classes = realloc(classes, sizeof(Class) * numClasses);
        newNumClasses = objc_getClassList(classes, numClasses);
        }

    subclasses = [NSMutableArray array];
    for(i = 0; i < numClasses; i++)
        {
        if(EDClassIsSuperclassOfClass(aClass, classes[i]) == YES)
            [subclasses addObject:classes[i]];
        }
    free(classes);

    return subclasses;
}

/*" Returns all subclasses of the receiving class "*/

+ (NSArray *)subclasses
{
    return EDSubclassesOfClass(self);
}


//---------------------------------------------------------------------------------------
//  MAPPING
//---------------------------------------------------------------------------------------

/*" Invokes the method described by %selector in the receiver once for each object in %anArray and collects the return values in another array that is returned. Note that the selector is assumed to take one argument, the current object from the array, and return the corresponding object.

Example: Assume you have an array !{a} which contains names and an object !{phoneBook} implementing a method !{lookupPhoneNumber:} which returns a phone number for a name. In this case you can use !{[phoneBook mapArray:a withSelector:@selector(lookupPhoneNumber:)]} to get the corresponding array of phone numbers."*/

- (NSArray *)mapArray:(NSArray *)anArray withSelector:(SEL)selector
{
    NSMutableArray	*mappedArray;
    unsigned int	i, n = [anArray count];

    mappedArray = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:n] autorelease];
    for(i = 0; i < n; i++)
        [mappedArray addObject:EDObjcMsgSend1(self, selector, [anArray objectAtIndex:i])];

    return mappedArray;
}


//---------------------------------------------------------------------------------------
//  REPEATED PERFORM
//---------------------------------------------------------------------------------------

/*" Invokes the method described by %selector in the receiver once for each object in %array, passing the respective object as an argument. "*/

- (void)performSelector:(SEL)selector withObjects:(NSArray *)array
{
    unsigned int	i, n = [array count];

    for(i = 0; i < n; i++)
        EDObjcMsgSend1(self, selector, [array objectAtIndex:i]);
}


/*" Invokes the method described by %selector in the receiver once for each object enumerated by %enumerator, passing the respective object as an argument. "*/

- (void)performSelector:(SEL)selector withObjectsEnumeratedBy:(NSEnumerator *)enumerator
{
    id object;

    while((object = [enumerator nextObject]) != nil)
        EDObjcMsgSend1(self, selector, object);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

