//---------------------------------------------------------------------------------------
//  EDSwapView.m created by erik
//  @(#)$Id: EDSwapView.m,v 2.1 2003-04-08 16:51:36 znek Exp $
//
//  Copyright (c) 1997-1998 by Erik Doernenburg. All rights reserved.
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

#import <AppKit/AppKit.h>
#include "EDSwapView.h"

@interface EDSwapView(PrivateAPI)
- (void)_setViewVar:(NSView **)viewVar toView:(NSView *)aView;
@end


//---------------------------------------------------------------------------------------
    @implementation EDSwapView
//---------------------------------------------------------------------------------------

/*" Swap views are very similar to #NSTabViews in that they allow to switch between several views in one place. They differ in that EDSwapView never contains the widget to switch between views and it allows more than one view to be visible; usually with different positions in the swap view. This is useful in inspectors that have multiple switching areas.

The main advantage of EDSwapView are the instance variables and methods dealing with view numbers, allowing the developer to wire up the entire interface in IB. (Zero code approach.) "*/


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:1];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frameRect
{
    [super initWithFrame:frameRect];

    views = [[NSMutableSet allocWithZone:[self zone]] init];
    visibleViews = [[NSMutableSet allocWithZone:[self zone]] init];

    return self;
}


- (void)dealloc
{
    [views release];
    [visibleViews release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];

    [encoder encodeObject:views];
    [encoder encodeObject:visibleViews];
    [encoder encodeValueOfObjCType:@encode(int) at:&flags];
    [encoder encodeObject:delegate];

    [encoder encodeObject:view0];
    [encoder encodeObject:view1];
    [encoder encodeObject:view2];
    [encoder encodeObject:view3];
    [encoder encodeObject:view4];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super initWithCoder:decoder];
    version = [decoder versionForClassName:@"EDSwapView"];
    // Version is -1 when loading a NIB file in which we were set as a custom subclass.
    // The unsigned representation of this is INT_MAX on a 2-bytes-complement machine...
    if(version == INT_MAX)
        {
        views = [[NSMutableSet allocWithZone:[self zone]] init];
        visibleViews = [[NSMutableSet allocWithZone:[self zone]] init];
        }
    else
        {
        views = [[decoder decodeObject] retain];
        visibleViews = [[decoder decodeObject] retain];
        [decoder decodeValueOfObjCType:@encode(int) at:&flags];
        delegate = [[decoder decodeObject] retain];

        view0 = [[decoder decodeObject] retain];
        view1 = [[decoder decodeObject] retain];
        view2 = [[decoder decodeObject] retain];
        view3 = [[decoder decodeObject] retain];
        view4 = [[decoder decodeObject] retain];
        }

    return self;
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Sets view0 to %aView and adds it to the receiver's list of views. If aView is an #NSBox its contents are used instead. "*/

- (void)setView0:(NSView *)aView
{
    [self _setViewVar:&view0 toView:aView];
}

/*" Returns view0, or !{nil} if this has not been set. "*/

- (NSView *)view0
{
    return view0;
}


/*" Sets view1 to %aView and adds it to the receiver's list of views. If aView is an #NSBox its contents are used instead. "*/

- (void)setView1:(NSView *)aView
{
    [self _setViewVar:&view1 toView:aView];
}


/*" Returns view1, or !{nil} if this has not been set. "*/

- (NSView *)view1
{
    return view1;
}


/*" Sets view2 to %aView and adds it to the receiver's list of views. If aView is an #NSBox its contents are used instead. "*/

- (void)setView2:(NSView *)aView
{
    [self _setViewVar:&view2 toView:aView];
}


/*" Returns view2, or !{nil} if this has not been set. "*/

- (NSView *)view2
{
    return view2;
}


/*" Sets view3 to %aView and adds it to the receiver's list of views. If aView is an #NSBox its contents are used instead. "*/

- (void)setView3:(NSView *)aView
{
    [self _setViewVar:&view3 toView:aView];
}


/*" Returns view3, or !{nil} if this has not been set. "*/

- (NSView *)view3
{
    return view3;
}


/*" Sets view4 to %aView and adds it to the receiver's list of views. If aView is an #NSBox its contents are used instead. "*/

- (void)setView4:(NSView *)aView
{
    [self _setViewVar:&view4 toView:aView];
}


/*" Returns view4, or !{nil} if this has not been set. "*/

- (NSView *)view4
{
    return view4;
}


- (void)_setViewVar:(NSView **)viewVar toView:(NSView *)aView
{
    if(*viewVar != nil)
        {
        [self removeView:*viewVar];
        }
    if([aView isKindOfClass:[NSBox class]])
        {
        NSBox *box = (NSBox *)aView;
        aView = [box contentView];
        [aView setAutoresizingMask:[box autoresizingMask]];
        }
    *viewVar = aView;
    [self addView:aView];
}


/*" Sets the receiver's delegate to anObject. "*/

- (void)setDelegate:(id)anObject
{
    delegate = anObject;
    flags.delegateWantsSwapinNotif = NO;
    flags.delegateWantsSwapoutNotif = NO;
    if(delegate != nil)
        {
        if([delegate respondsToSelector:@selector(swapView:didSwapinView:)])
            flags.delegateWantsSwapinNotif = YES;
        if([delegate respondsToSelector:@selector(swapView:didSwapoutView:)])
            flags.delegateWantsSwapoutNotif = YES;
        }
}


/*" Returns the receiver's delegate. "*/

- (id)delegate
{
    return delegate;
}


//---------------------------------------------------------------------------------------
//	ADDING AND REMOVING VIEWS
//---------------------------------------------------------------------------------------

/*" Calls #{addView:atPoint:} with !{NSZeroPoint}. "*/

- (void)addView:(NSView *)aView
{
    [self addView:aView atPoint:NSZeroPoint];
}


/*" Adds %aView to the receiver's list of views to be displayed at %point. This does not make the view visible. It does remove the view from it's superview; provided it had one before. None if the %viewX variables are affected. "*/

- (void)addView:(NSView *)aView atPoint:(NSPoint)point
{
    if([views containsObject:aView])
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to add view <%@ 0x%x> more than once.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [aView class], aView];
    [views addObject:aView];
    [aView setFrameOrigin:point];
    [aView removeFromSuperview];
}


/*" Removes %aView from the receiver's list of views. If the view was visible it is hidden first. "*/

- (void)removeView:(NSView *)aView
{
    if([views containsObject:aView] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to remove unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [aView class], aView];
    if([self isShowingView:aView])
        [self hideView:aView];
    [views removeObject:aView];
}


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- (void)resizeSubviewsWithOldSize:(NSSize)oldFrameSize
{
   NSMutableSet *invisibleViews;
   NSEnumerator *viewEnum;
   NSView		 *view;

   invisibleViews = [[views mutableCopy] autorelease];
   [invisibleViews minusSet:visibleViews];

   viewEnum = [invisibleViews objectEnumerator];
   while((view = [viewEnum nextObject]) != nil)
       [self addSubview:view];

   [super resizeSubviewsWithOldSize:oldFrameSize];

   viewEnum = [invisibleViews objectEnumerator];
   while((view = [viewEnum nextObject]) != nil)
       [view removeFromSuperview];
}


- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if([visibleViews count] == 0)
        {
        [[NSColor colorWithCalibratedWhite:0.5 alpha:0.5] set];
        [NSBezierPath fillRect:[self bounds]];
        }
}


//---------------------------------------------------------------------------------------
//	ACTIONS: SHOW AND HIDE INDIVIDUAL VIEWS
//---------------------------------------------------------------------------------------

/*" Ensures that %aView is visible. If the view needs to be swapped in and a delegate exists and implements #{swapView:didSwapinView:} this method is called after the view is swapped in but before the window is flushed. "*/

- (void)showView:(NSView *)aView
{
    if([views containsObject:aView] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to show unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [aView class], aView];

    if([visibleViews containsObject:aView])
        return;

    [[self window] disableFlushWindow];

    [self addSubview:aView];
    [visibleViews addObject:aView];
    [aView display];
    
    if(flags.delegateWantsSwapinNotif)
        [delegate swapView:self didSwapinView:aView];

    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


/*" Ensures that %aView is not visible. If the view needs to be swapped out and a delegate exists and implements #{swapView:willSwapoutView:} this method is called before the view is swapped out but after window flushing is disabled. "*/

- (void)hideView:(NSView *)aView
{
    if([views containsObject:aView] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to hide unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [aView class], aView];

    if([visibleViews containsObject:aView] == NO)
        return;

    [[self window] disableFlushWindow];

    if(flags.delegateWantsSwapoutNotif)
        [delegate swapView:self willSwapoutView:aView];
    
    [aView removeFromSuperview];
    [visibleViews removeObject:aView];
    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


//---------------------------------------------------------------------------------------
//	ACTIONS: SHOW AND HIDE ALL VIEWS
//---------------------------------------------------------------------------------------

/*" Ensures that only %aView is visible. If any view needs to be swapped in or out the corresponding delegate methods are called. "*/

- (void)switchToView:(NSView *)aView
{
    NSView 	*visView;
    BOOL	wasVisible = NO;
    
    if([views containsObject:aView] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to switch to unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [aView class], aView];

    if([visibleViews containsObject:aView])
        {
        if([visibleViews count] == 1)
           return;
        wasVisible = YES;
        [visibleViews removeObject:aView];
        }	

    [[self window] disableFlushWindow];
    while((visView = [visibleViews anyObject]) != nil)
        [self hideView:visView];
    if(wasVisible == YES)
        [visibleViews addObject:aView];
    else
        [self showView:aView];
    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


/*" Ensures that no views are visible. If any view needs to be swapped out the corresponding delegate method is called. "*/

- (void)hideAllViews
{
    NSView *visView;

    [[self window] disableFlushWindow];
    while((visView = [visibleViews anyObject]) != nil)
        [self hideView:visView];
    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


//---------------------------------------------------------------------------------------
//	ACTIONS: SHOW VIEWS BY NUMBER
//---------------------------------------------------------------------------------------

/*" Calls #{switchToView:} with the corresponding view from the %viewX instance variables. "*/

- (void)switchToViewNumber:(int)viewnum
{
   switch(viewnum)
       {
   case 0: [self switchToView:view0]; break;
   case 1: [self switchToView:view1]; break;
   case 2: [self switchToView:view2]; break;
   case 3: [self switchToView:view3]; break;
   case 4: [self switchToView:view4]; break;
   default:
       [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to switch to invalid view #%d.", NSStringFromClass(isa), NSStringFromSelector(_cmd), viewnum];
       }
}


/*" Calls #{switchToViewNumber:} with the view number taken from the sender. If this is an #NSPopUpButton or #NSMatrix the tag of the selected item/cell is used, if it is an NSButton this method returns 1 if the button's state is !{NSOnState} and zero otherwise, and in all other cases it returns the tag of the sender. "*/

- (void)takeViewNumber:(id)sender
{
   int viewnum;

   if([sender isKindOfClass:[NSPopUpButton class]])
       viewnum = [[sender selectedItem] tag];
   else if([sender isKindOfClass:[NSButton class]])
       viewnum = ([sender state] == NSOnState) ? 1 : 0;
   else if([sender isKindOfClass:[NSMatrix class]])
       viewnum = [[sender selectedCell] tag];
   else
       viewnum = [sender tag];

   [self switchToViewNumber:viewnum];
}


//---------------------------------------------------------------------------------------
//	QUERIES
//---------------------------------------------------------------------------------------

/*" Returns YES if %aView is currently visible. "*/

- (BOOL)isShowingView:(NSView *)aView
{
    return [visibleViews containsObject:aView];
}


/*" Returns an array containing all views that are currently visible. "*/

- (NSArray *)visibleViews
{
    return [visibleViews allObjects];
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
