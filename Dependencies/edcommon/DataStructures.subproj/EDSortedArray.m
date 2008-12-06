//---------------------------------------------------------------------------------------
//  EDSortedArray.m created by erik on Sun 13-Sep-1998
//  @(#)$Id: EDSortedArray.m,v 2.2 2003-04-08 16:51:34 znek Exp $
//
//  Copyright (c) 1997-1999 by Erik Doernenburg. All rights reserved.
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
#import "EDSortedArray.h"
#import "EDSortedArray+Private.h"

#define RED 1
#define BLACK 0

//=======================================================================================
    @implementation EDSortedArray
//=======================================================================================

/*" Binary search trees can be considered as "always sorted" arrays. Whenever an object is added to the tree it automagically ends up at the "correct" index; as defined by the comparison selector.

This behaviour can be emulated, of course, using NSMutableArrays and (binary) search but EDSortedArray, which is based on red-black trees, has better performance characteristics. When objects are inserted into ordered collections, O(lg %n) instead of O(%n). Contains and index-of tests can also be carried out in O(lg %n) instead of O(%n). Inserting/removing at the end and retrieving objects by index is marginally slower, O(lg %n) instead of O(1). NSSets are even faster at contains tests, O(1), but they do no support ordered collections. The main disadvantage of binary search trees is their memory usage, 20 bytes per object rather than 4 to 8 in an array.

A final note: NSArrays are implemented extremely well and in collections with less than at least about 3000 objects performance gains are negligible; NSArray might even be faster! However, beyond a certain size the performance difference is more than noticeable. In the end, you might still want to use the tree based sorted arrays unless you already have the binary search insert written somewhere else.

This datastructure does not implement the copying and coding protocols as binary search trees are usually required in the context of algorithms, rather than data storage.
"*/


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated red-black tree with #{compare:} as comparison selector. "*/

- (id)init
{
    [super init];
    sentinel = [self _allocNodeForObject:nil];
    ((EDRedBlackTreeNode *)sentinel)->f.size = 0;
    rootNode = minimumNode = sentinel;
    comparator = @selector(compare:);
    return self;
}


/*" Initialises a newly allocated red-black tree with %aSelector as comparison selector. "*/

- (id)initWithComparisonSelector:(SEL)aSelector
{
    [self init];
    comparator = aSelector;
    return self;
}


- (void)dealloc
{
    if(NIL(rootNode) == NO)
        [self _deallocAllNodesBelowNode:rootNode];
    [self _deallocNode:sentinel];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS FOR IMMUTABLE ATTRIBUTES
//---------------------------------------------------------------------------------------

/*" Returns the selector that is used to compare objects in the tree. "*/

- (SEL)comparisonSelector
{
    return comparator;
}


- (EDRedBlackTreeNode *)_sentinel;
{
    return sentinel;
}


//---------------------------------------------------------------------------------------
//	NODE CREATION/DESTRUCTION
//---------------------------------------------------------------------------------------

- (EDRedBlackTreeNode *)_allocNodeForObject:(id)object
{
    EDRedBlackTreeNode *new;

    new = NSZoneMalloc([self zone], sizeof(EDRedBlackTreeNode));
    new->parent = sentinel;
    new->left = sentinel;
    new->right = sentinel;
    new->object = [object retain];
    new->f.color = BLACK;
    new->f.size = 1;

    return new;
}


- (void)_deallocNode:(EDRedBlackTreeNode *)node
{
    [node->object release];
    NSZoneFree([self zone], node);
}


- (void)_deallocAllNodesBelowNode:(EDRedBlackTreeNode *)x
{
    if(NIL(x->left) == NO)
        [self _deallocAllNodesBelowNode:x->left];
    if(NIL(x->right) == NO)
        [self _deallocAllNodesBelowNode:x->right];
    [self _deallocNode:x];
}


- (void)_swapValuesBetweenNodes:(EDRedBlackTreeNode *)a:(EDRedBlackTreeNode *)b
{
    id d = b->object;
    b->object = a->object;
    a->object = d;
}


//---------------------------------------------------------------------------------------
//	QUERIES (PRIVATE)
//---------------------------------------------------------------------------------------

- (EDRedBlackTreeNode *)_nodeForObject:(id)k
{
    EDRedBlackTreeNode *x;
    NSComparisonResult r;

    x = rootNode;
    while(NIL(x) == NO)
        {
        r = (NSComparisonResult)[k performSelector:comparator withObject:x->object];
        if(r == NSOrderedSame)
            break;
        else if(r == NSOrderedAscending)
            x = x->left;
        else
            x = x->right;
        }

    return x;
}


- (EDRedBlackTreeNode *)_nodeForObjectOrPredecessorOfObject:(id)k
{
    EDRedBlackTreeNode *x, *y;
    NSComparisonResult r;

    x = rootNode;
    y = sentinel;
    while(NIL(x) == NO)
        {
        r = (NSComparisonResult)[k performSelector:comparator withObject:x->object];
        if(r == NSOrderedSame)
            {
            y = x;
            break;
            }
        else if(r == NSOrderedAscending)
            {
            x = x->left;
            }
        else
            {
            y = x;
            x = x->right;
            }
        }

    return y;
}


- (EDRedBlackTreeNode *)_rootNode
{
    return rootNode;
}


- (EDRedBlackTreeNode *)_minimumNode
{
    return NIL(rootNode) ? rootNode : minimumNode;
}


- (EDRedBlackTreeNode *)_minimumBelowNode:(EDRedBlackTreeNode *)x
{
    while(NIL(x->left) == NO)
        x = x->left;
    return x;
}


- (EDRedBlackTreeNode *)_maximumBelowNode:(EDRedBlackTreeNode *)x
{
    while(NIL(x->right) == NO)
        x = x->right;
    return x;
}


- (EDRedBlackTreeNode *)_successorForNode:(EDRedBlackTreeNode *)x
{
   EDRedBlackTreeNode *y;

   if(NIL(x->right) == NO)
       return [self _minimumBelowNode:x->right];
   ((EDRedBlackTreeNode *)sentinel)->right = NULL; // to make sure
   y = x->parent;
   while(x == y->right)
       {
       x = y;
       y = y->parent;
       }
   return y;
}


- (EDRedBlackTreeNode *)_nodeWithRank:(unsigned int)i
{
    EDRedBlackTreeNode 	*x;
    unsigned int 		r;

    x = rootNode;
    r = x->left->f.size + 1;
    while(r != i)
        {
        if(i < r)
            {
            x = x->left;
            }
        else
            {
            x = x->right;
            i -= r;
            }
        r = x->left->f.size + 1;
        }
    return x;
}


- (unsigned int)_rankOfNode:(EDRedBlackTreeNode *)x
{
    EDRedBlackTreeNode 	*y;
    unsigned int 		r;

    r = x->left->f.size + 1;
    y = x;
    while(y != rootNode)
        {
        if(y == y->parent->right)
            r += y->parent->left->f.size + 1;
        y = y->parent;
        }
    return r;
}


//---------------------------------------------------------------------------------------
//	MUTATORS (PRIVATE)
//---------------------------------------------------------------------------------------

- (void)_leftRotateFromNode:(EDRedBlackTreeNode *)x
{
    EDRedBlackTreeNode *y;

    y = x->right;
    x->right = y->left;
    if(NIL(y->left) == NO)
        y->left->parent = x;
    y->parent = x->parent;
    if(NIL(x->parent) == YES)
        {
        rootNode = (EDRedBlackTreeNode *)y;
        }
    else
        {
        if(x == x->parent->left)
            x->parent->left = y;
        else
            x->parent->right = y;
        }
    y->left = x;
    x->parent = y;
    y->f.size = x->f.size;
    x->f.size = x->left->f.size + x->right->f.size + 1;
}


- (void)_rightRotateFromNode:(EDRedBlackTreeNode *)y
{
    EDRedBlackTreeNode *x;

    x = y->left;
    y->left = x->right;
    if(NIL(x->right) == NO)
        x->right->parent = y;
    x->parent = y->parent;
    if(NIL(y->parent) == YES)
        {
        rootNode = (EDRedBlackTreeNode *)x;
        }
    else
        {
        if(y == y->parent->left)
            y->parent->left = x;
        else
            y->parent->right = x;
        }
    x->right = y;
    y->parent = x;
    x->f.size = y->f.size;
    y->f.size = y->left->f.size + y->right->f.size + 1;
}


- (void)_insertNodeUnbalanced:(EDRedBlackTreeNode *)z
{
    EDRedBlackTreeNode *x, *y;

    if(NIL(rootNode))
        {
        minimumNode = z;
        }
    else
        {
        if(IS_SMALLER(z, minimumNode))
            minimumNode = z;
        }

    y = sentinel;
    x = rootNode;
    while(NIL(x) == NO)
        {
        x->f.size += 1;
        y = x;
        if(IS_SMALLER(z, x))
            x = x->left;
        else
            x = x->right;
        }

    z->parent = y;
    if(NIL(y) == YES)
        {
        rootNode = z;
        }
    else
        {
        if(IS_SMALLER(z, y))
            y->left = z;
        else
            y->right = z;
        }
}


- (void)_insertNode:(EDRedBlackTreeNode *)x
{
    EDRedBlackTreeNode *y;

    [self _insertNodeUnbalanced:(EDRedBlackTreeNode *)x];
    x->f.color = RED;

    while((x != rootNode) && (x->parent->f.color == RED))
        {
        if(x->parent == x->parent->parent->left)
            {
            y = x->parent->parent->right;
            if(y->f.color == RED)
                {
                x->parent->f.color = BLACK;
                y->f.color = BLACK;
                x->parent->parent->f.color = RED;
                x = x->parent->parent;
                }
            else 
                {
                if(x == x->parent->right)
                    {
                    x = x->parent;
                    [self _leftRotateFromNode:x];
                    }
                x->parent->f.color = BLACK;
                x->parent->parent->f.color = RED;
                [self _rightRotateFromNode:x->parent->parent];
                }
            }
        else 	/* same as above with 'left' and 'right' exchanged */
            {
            y = x->parent->parent->left;
            if(y->f.color == RED)
                {
                x->parent->f.color = BLACK;
                y->f.color = BLACK;
                x->parent->parent->f.color = RED;
                x = x->parent->parent;
                }
            else
                {
                if(x == x->parent->left)
                    {
                    x = x->parent;
                    [self _rightRotateFromNode:x];
                    }
                x->parent->f.color = BLACK;
                x->parent->parent->f.color = RED;
                [self _leftRotateFromNode:x->parent->parent];
                }
            }
        }
    ((EDRedBlackTreeNode *)rootNode)->f.color = BLACK;
}



- (void)_deleteFixup:(EDRedBlackTreeNode *)x
{
    EDRedBlackTreeNode *w;
    
    while((x != rootNode) && (x->f.color == BLACK))
        {
        if(x == x->parent->left)
            {
            w = x->parent->right;
            if(w->f.color == RED)
                {
                w->f.color = BLACK;
                x->parent->f.color = RED;
                [self _leftRotateFromNode:x->parent];
                w = x->parent->right;
                }
            if((w->left->f.color == BLACK) && (w->right->f.color == BLACK))
                {
                w->f.color = RED;
                x = x->parent;
                }
            else
                {
                if(w->right->f.color == BLACK)
                    {
                    w->left->f.color = BLACK;
                    w->f.color = RED;
                    [self _rightRotateFromNode:w];
                    w = x->parent->right;
                    }
                w->f.color = x->parent->f.color;
                x->parent->f.color = BLACK;
                w->right->f.color = BLACK;
                [self _leftRotateFromNode:x->parent];
                x = rootNode;
                }
            }
        else /* same as above with 'left' and 'right' exchanged */
            {
            w = x->parent->left;
            if(w->f.color == RED)
                {
                w->f.color = BLACK;
                x->parent->f.color = RED;
                [self _rightRotateFromNode:x->parent];
                w = x->parent->left;
                }
            if((w->right->f.color == BLACK) && (w->left->f.color == BLACK))
                {
                w->f.color = RED;
                x = x->parent;
                }
            else
                {
                if(w->left->f.color == BLACK)
                    {
                    w->right->f.color = BLACK;
                    w->f.color = RED;
                    [self _leftRotateFromNode:w];
                    w = x->parent->left;
                    }
                w->f.color = x->parent->f.color;
                x->parent->f.color = BLACK;
                w->left->f.color = BLACK;
                [self _rightRotateFromNode:x->parent];
                x = rootNode;
                }
            }
        }
    x->f.color = BLACK;
}



- (EDRedBlackTreeNode *)_deleteNode:(EDRedBlackTreeNode *)z
{
    EDRedBlackTreeNode *x, *y, *w;

    if(z == minimumNode)
        minimumNode = sentinel;

    if(NIL(z->left) || NIL(z->right))
        y = z;
    else
        y = [self _successorForNode:z];
    if(NIL(y->left) == NO)
        x = y->left;
    else
        x = y->right;
    x->parent = y->parent;
    if(NIL(y->parent))
        {
        rootNode = x;
        }
    else
        {
        if(y == y->parent->left)
            y->parent->left = x;
        else
            y->parent->right = x;
        }

    if(y != z)
        [self _swapValuesBetweenNodes:y:z];

    w = y;
    while(NIL(w) == NO)
        {
        w->f.size -= 1;
        w = w->parent;
        }

    if(y->f.color == BLACK)
        [self _deleteFixup:x];

    if(minimumNode == sentinel)
        if(NIL(rootNode) == NO)
            minimumNode = [self _minimumBelowNode:rootNode];
    
    return y;
}


//---------------------------------------------------------------------------------------
//	QUERIES (PUBLIC API)
//---------------------------------------------------------------------------------------

/*" Returns YES if %anObject is present in the receiver, NO otherwise. "*/

- (BOOL)containsObject:(id)anObject
{
    return NIL([self _nodeForObject:anObject]) == NO;
}


/*" If %anObject is present in the receiver (as determined by the comparison selector), the instance in the receiver is returned. Otherwise, returns !{nil}. "*/

- (id)member:(id)anObject
{
    EDRedBlackTreeNode *x;

    x = [self _nodeForObject:anObject];
    if(NIL(x) == YES)
        return nil;
    
    return x->object;
}


/*" If %anObject is present in the receiver (as determined by the comparison selector), the instance in the receiver is returned. Otherwise, returns the greatest object smaller than %anObject, or !{nil} if no such object exists. "*/

- (id)smallerOrEqualMember:(id)anObject
{
    EDRedBlackTreeNode *x;

    x = [self _nodeForObjectOrPredecessorOfObject:anObject];
    if(NIL(x) == YES)
        return nil;

    return x->object;
}


/*" Returns the object directly following %anObject in the order defined by the comparison selector or !{nil} if %anObject is the largest object. "*/

- (id)successorForObject:(id)anObject
{
    EDRedBlackTreeNode *x, *y;

    x = [self _nodeForObject:anObject];
    if(NIL(x) == YES)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to retrieve successor for an object that is not in the tree.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];

    y = [self _successorForNode:x];

    return y->object;
}


/*" Returns the smallest object (as defined by the comparison selector) in the receiver. "*/

- (id)minimumObject
{
    if(NIL(rootNode) == YES)
        return nil;
    return ((EDRedBlackTreeNode *)minimumNode)->object;
}


/*" Returns the largest object (as defined by the comparison selector) in the receiver. "*/

- (id)maximumObject
{
    if(NIL(rootNode) == YES)
        return nil;
    return [self _maximumBelowNode:rootNode]->object;
}


/*" Returns the number of objects in the receiver. "*/

- (NSUInteger)count
{
    return ((EDRedBlackTreeNode *)rootNode)->f.size;
}


/*" Returns the object located at index. If index is too large, i.e. if index is greater than or equal to the value returned by count, an NSInvalidArgumentException is raised. "*/

- (id)objectAtIndex:(NSUInteger)index
{
    if((NIL(rootNode) == YES) || (index >= ((EDRedBlackTreeNode *)rootNode)->f.size))
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Index (%d) is greater than number of objects in tree (%d)", NSStringFromClass(isa), NSStringFromSelector(_cmd), index, ((EDRedBlackTreeNode *)rootNode)->f.size];

    return [self _nodeWithRank:index + 1]->object;
}


/*" Returns the lowest index whose corresponding object is equal to %anObject. Objects are considered equal if invoking the comparison method in one with the other as parameter returns !{NSOrderedSame}. If none of the objects in the receiver are equal to anObject, #{indexOfObject:} returns !{NSNotFound}. "*/

- (NSUInteger)indexOfObject:(id)anObject
{
    EDRedBlackTreeNode *x;

    x = [self _nodeForObject:anObject];
    if(NIL(x) == YES)
        return NSNotFound;

    return [self _rankOfNode:x] - 1;
}


//---------------------------------------------------------------------------------------
//	ALL OBJECTS
//---------------------------------------------------------------------------------------

/*"  Returns an enumerator object that lets you access each object in the receiver, in order, starting with the element at index 0. You should not modify the receiver while using the enumerator. For a more detailed explanation and sample code see the description of the same method in #NSArray. "*/

- (NSEnumerator *)objectEnumerator
{
    return [[[_EDSortedArrayEnumerator alloc] initWithSortedArray:self] autorelease];
}


/*" Returns an array containing the receiver's objects, or an empty array if the receiver has no objects. The order of the objects in the array is the same as in the receiver. "*/

- (NSArray *)allObjects
{
    EDRedBlackTreeNode	*x;
    NSMutableArray		*a;

    if(rootNode == nil)
        return [NSArray array];

    x = minimumNode;
    a = [NSMutableArray arrayWithCapacity:((EDRedBlackTreeNode *)rootNode)->f.size];
    while(NIL(x) == NO)
        {
        [a addObject:x->object];
        x = [self _successorForNode:x];
        }
    return a;
}


//---------------------------------------------------------------------------------------
//	MUTATORS
//---------------------------------------------------------------------------------------

/*" Adds the specified object to the receiver. anObject is sent a #retain message as it is added to the receiver. "*/

- (void)addObject:(id)anObject
{
    EDRedBlackTreeNode *z;

    z = [self _allocNodeForObject:anObject];
    [self _insertNode:z];
}


/*" Adds each object contained in someObjects to the receiver. The objects are sent a #retain message. "*/

- (void)addObjectsFromArray:(NSArray *)someObjects
{
    unsigned int 	i, n;

    for(i = 0, n = [someObjects count]; i < n; i++)
        [self addObject:[someObjects objectAtIndex:i]];
}


/*" Removes %anObject from the receiver. The removed object is sent a #release message. This method raises an exception if anObject was not in the tree before.

Note that it is possible to have several objects that compare as equal in the tree. This method will remove any one of them."*/

- (void)removeObject:(id)anObject
{
    EDRedBlackTreeNode *z;

    z = [self _nodeForObject:anObject];
    if(NIL(z) == YES)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to delete an object that is not in the tree.", NSStringFromClass(isa), NSStringFromSelector(_cmd)];
    z = [self _deleteNode:z];
    [self _deallocNode:z];
}


/*" Removes the object at index. The removed object receives a #release message. If index is too large, i.e. if index is greater than or equal to the value returned by count, an NSInvalidArgumentException is raised. "*/

- (void)removeObjectAtIndex:(NSUInteger)index
{
    EDRedBlackTreeNode *x;
    
    if((NIL(rootNode) == YES) || (index >= ((EDRedBlackTreeNode *)rootNode)->f.size))
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Index (%d) is greater than number of objects in tree (%d).", NSStringFromClass(isa), NSStringFromSelector(_cmd), index, ((EDRedBlackTreeNode *)rootNode)->f.size];

    x =  [self _nodeWithRank:index + 1];
    [self _deleteNode:x];
    [self _deallocNode:x];
}


//=======================================================================================
    @end
//=======================================================================================



//=======================================================================================
    @implementation _EDSortedArrayEnumerator
//=======================================================================================

- (id)initWithSortedArray:(EDSortedArray *)anArray
{
    [super init];
    array = [anArray retain];
    sentinel = [anArray _sentinel];
    node = [anArray _minimumNode];
    return self;
}


- (void)dealloc
{
    [array release];
    [super dealloc];
}


- (id)nextObject
{
    id object;

    if(NIL(node) == YES)
        return nil;
    object = node->object;
    node = [array _successorForNode:node];

    return object;
}


//=======================================================================================
   @end
//=======================================================================================

