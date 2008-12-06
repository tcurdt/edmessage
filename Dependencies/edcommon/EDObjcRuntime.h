//---------------------------------------------------------------------------------------
//  EDObjcRuntime.h created by znek on Mon 18-Mar-2002
//  @(#)$Id: EDObjcRuntime.h,v 2.2 2003-04-08 16:49:49 znek Exp $
//
//  Copyright (c) 1997-2002 by Erik Doernenburg. All rights reserved.
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

#ifndef GNU_RUNTIME /* NeXT RUNTIME */

#import <objc/objc.h>
#import <objc/objc-runtime.h>
#import <objc/objc-api.h>
#import <objc/objc-class.h>

/*" Portable runtime functions. Should be used instead of the corresponding NeXT or GNUStep runtime functions. "*/
#define EDObjcMsgSend(obj, sel) objc_msgSend((obj), (sel))
#define EDObjcMsgSend1(obj, sel, obj1) objc_msgSend((obj), (sel), (obj1))
#define EDObjcMsgSend2(obj, sel, obj1, obj2) objc_msgSend((obj), (sel), (obj1), (obj2))
#define EDObjcMsgSend3(obj, sel, obj1, obj2, obj3) objc_msgSend((obj), (sel), (obj1), (obj2), (obj3))
/*" Defines for runtime types and functions. Should be used instead of the corresponding NeXT and GNUStep runtime functions. (First set is for NeXT, second set for GNU runtimes.)"*/
#define EDObjcMethodInfo Method
#define EDObjcClassGetInstanceMethod class_getInstanceMethod
#define EDObjcClassGetClassMethod class_getClassMethod
#define EDObjcSelectorsAreEqual(sel1, sel2) ((sel1)) == ((sel2))

#else /* GNU_RUNTIME */

#import <objc/objc.h>
#import <objc/objc-api.h>

#define EDObjcMsgSend(obj, sel) objc_msg_lookup((obj), (sel))((obj), (sel))
#define EDObjcMsgSend1(obj, sel, obj1) objc_msg_lookup((obj), (sel))((obj), (sel), (obj1))
#define EDObjcMsgSend2(obj, sel, obj1, obj2) objc_msg_lookup((obj), (sel))((obj), (sel), (obj1), (obj2))
#define EDObjcMsgSend3(obj, sel, obj1, obj2, obj3) objc_msg_lookup((obj), (sel))((obj), (sel), (obj1), (obj2), (obj3))
#define EDObjcMethodInfo Method_t
#define EDObjcClassGetInstanceMethod class_get_instance_method
#define EDObjcClassGetClassMethod class_get_class_method
#define EDObjcSelectorsAreEqual(sel1, sel2) sel_eq(((sel1)),((sel2)))

#endif
