//---------------------------------------------------------------------------------------
//  EDSortedArray+Private.h created by erik on Tue 15-Sep-1998
//  @(#)$Id: EDSortedArray+Private.h,v 2.2 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 1998-1999 by Erik Doernenburg. All rights reserved.
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

#import "EDSortedArray.h"


/*" This structure is used to represent nodes. It's a struct and not an object because latter would use yet another 4 bytes for the isa pointer. "*/

typedef struct _EDRedBlackTreeNode
{
    struct _EDRedBlackTreeNode 	*left, *right, *parent;
    id 						   	object;
    struct {
        unsigned 				color : 1;
        unsigned				size : 31;
    } f;
} EDRedBlackTreeNode;


/*" Some private methods made available for the benefit of subclassers. "*/

@interface EDSortedArray(Private)

- (EDRedBlackTreeNode *)_allocNodeForObject:(id)object;
- (void)_deallocNode:(EDRedBlackTreeNode *)node;
- (void)_deallocAllNodesBelowNode:(EDRedBlackTreeNode *)x; // doesn't restore r/b-property!
- (void)_swapValuesBetweenNodes:(EDRedBlackTreeNode *)a:(EDRedBlackTreeNode *)b;

- (EDRedBlackTreeNode *)_sentinel;
- (EDRedBlackTreeNode *)_rootNode;
- (EDRedBlackTreeNode *)_minimumNode;
- (EDRedBlackTreeNode *)_nodeForObject:(id)k;
- (EDRedBlackTreeNode *)_nodeForObjectOrPredecessorOfObject:(id)k;
- (EDRedBlackTreeNode *)_maximumBelowNode:(EDRedBlackTreeNode *)x;
- (EDRedBlackTreeNode *)_minimumBelowNode:(EDRedBlackTreeNode *)x;
- (EDRedBlackTreeNode *)_successorForNode:(EDRedBlackTreeNode *)x;
- (void)_leftRotateFromNode:(EDRedBlackTreeNode *)x;
- (void)_rightRotateFromNode:(EDRedBlackTreeNode *)y;
- (void)_insertNode:(EDRedBlackTreeNode *)z;
- (EDRedBlackTreeNode *)_deleteNode:(EDRedBlackTreeNode *)z;

- (unsigned int)_rankOfNode:(EDRedBlackTreeNode *)x;
- (EDRedBlackTreeNode *)_nodeWithRank:(unsigned int)i;

@end


/*" Private subclass of #NSEnumerator for use with #EDSortedArray. You never instantiate objects of this class directly. In fact, you don't even have the interface unless you specifically include it. "*/

@interface _EDSortedArrayEnumerator : NSEnumerator
{
    EDSortedArray 		*array;
    EDRedBlackTreeNode	*sentinel;
    EDRedBlackTreeNode 	*node;
}

- (id)initWithSortedArray:(EDSortedArray *)anArray;

@end


#define IS_SMALLER(A, B) (((NSComparisonResult)[((EDRedBlackTreeNode *)A)->object performSelector:comparator withObject:((EDRedBlackTreeNode *)B)->object]) == NSOrderedAscending)
#define IS_EQUAL(A, B) (((NSComparisonResult)[((EDRedBlackTreeNode *)A)->object performSelector:comparator withObject:((EDRedBlackTreeNode *)B)->object]) == NSOrderedSame)
#define NIL(X) (((EDRedBlackTreeNode *)X) == sentinel)

