//---------------------------------------------------------------------------------------
//  EDSparseClusterArray.h created by erik on Fri 28-May-1999
//  @(#)$Id: EDSparseClusterArray.h,v 2.0 2002-08-16 18:12:46 erik Exp $
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


@interface EDSparseClusterArray : NSObject
{
    NSMapTable		*pageTable;		/*" All instance variables are private. "*/
    unsigned int	pageSize;		/*" "*/
}

/*" Creating sparse cluster arrays "*/
- (id)init;

/*" Adding and removing objects "*/
- (void)setObject:(id)anObject atIndex:(NSUInteger)index;
- (void)removeObjectAtIndex:(NSUInteger)index;
- (id)objectAtIndex:(NSUInteger)index;

/*" Querying the array "*/
- (NSUInteger)count;
- (NSEnumerator *)indexEnumerator;
- (NSArray *)allObjects;

@end
