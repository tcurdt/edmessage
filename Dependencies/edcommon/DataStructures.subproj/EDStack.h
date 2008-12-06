//---------------------------------------------------------------------------------------
//  EDStack.h created by erik on Sat 19-Jul-1997
//  @(#)$Id: EDStack.h,v 2.0 2002-08-16 18:12:46 erik Exp $
//
//  Copyright (c) 1997 by Erik Doernenburg. All rights reserved.
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


@interface EDStack : NSObject
{
    NSMutableArray	*storage; /*" All instance variables are private. "*/
}

/*" Creating stacks "*/
+ (EDStack *)stack;
+ (EDStack *)stackWithObject:(id)anObject;

- (id)init;
- (id)initWithObject:(id)anObject;

/*" Adding/removing objects "*/
- (void)pushObject:(id)anObject;
- (id)popObject;
- (void)clear;

/*" Querying the stack "*/
- (id)topObject;
- (NSArray *)topObjects:(int)count;
- (NSUInteger)count;


@end
