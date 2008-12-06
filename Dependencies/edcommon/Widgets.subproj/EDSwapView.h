//---------------------------------------------------------------------------------------
//  EDSwapView.h created by erik
//  @(#)$Id: EDSwapView.h,v 2.0 2002-08-16 18:12:50 erik Exp $
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

#import <AppKit/NSView.h>


struct EDSVFlags
{
#ifdef __BIG_ENDIAN__
    unsigned delegateWantsSwapinNotif:1;
    unsigned delegateWantsSwapoutNotif:1;
    unsigned padding:30;
#else
    unsigned padding:30;
    unsigned delegateWantsSwapoutNotif:1;
    unsigned delegateWantsSwapinNotif:1;
#endif
};


@interface EDSwapView : NSView
{
    NSMutableSet		*views;			/*" These instance variables are private. "*/
    NSMutableSet		*visibleViews;	/*" "*/
    struct EDSVFlags   	flags;			/*" "*/
    id					delegate;		/*" "*/

    IBOutlet NSView 	*view0;			/*" Connect in Interface Builder. "*/
    IBOutlet NSView		*view1;			/*" "*/
    IBOutlet NSView		*view2;			/*" "*/
    IBOutlet NSView		*view3;			/*" "*/
    IBOutlet NSView		*view4;			/*" "*/
}

/*" Managing views by number "*/
- (void)setView0:(NSView *)aView;
- (NSView *)view0;
- (void)setView1:(NSView *)aView;
- (NSView *)view1;
- (void)setView2:(NSView *)aView;
- (NSView *)view2;
- (void)setView3:(NSView *)aView;
- (NSView *)view3;
- (void)setView4:(NSView *)aView;
- (NSView *)view4;

- (void)switchToViewNumber:(int)number;
- (IBAction)takeViewNumber:(id)sender;

/*" Managing views by object reference "*/
- (void)addView:(NSView *)aView;
- (void)addView:(NSView *)aView atPoint:(NSPoint)point;
- (void)removeView:(NSView *)aView;

- (void)showView:(NSView *)aView;
- (void)hideView:(NSView *)aView;

- (void)switchToView:(NSView *)aView;
- (void)hideAllViews;

- (BOOL)isShowingView:(NSView *)aView;
- (NSArray *)visibleViews;

/*" Assigning a delegate "*/
- (void)setDelegate:(id)anObject;
- (id)delegate;

@end


@interface NSObject(EDSwapViewDelegateInformalProtocol)
- (void)swapView:(EDSwapView *)swapView didSwapinView:(NSView *)view;
- (void)swapView:(EDSwapView *)swapView willSwapoutView:(NSView *)view;
@end
