//---------------------------------------------------------------------------------------
//  NSTableView+Extensions.m created by erik on Sun 12-Sep-1999
//  @(#)$Id: NSTableView+Extensions.m,v 2.1 2003-04-08 16:51:32 znek Exp $
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

#import <AppKit/AppKit.h>
#import "NSTableView+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSTableView(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various useful extensions to #NSTableView. "*/

/*" Ensures that the row with %rowIndex is in the top-third of the tableview. Scrolls as little as possible. "*/

- (void)scrollRowToTop:(int)rowIndex
{
    NSClipView	*myClipView;
    NSRect		cvbounds;
    float		rowFactor, targetY;

    myClipView = (NSClipView *)[self superview];
    cvbounds = [myClipView bounds];
    rowFactor = [self rowHeight] + [self intercellSpacing].height;
    targetY = rowIndex * rowFactor;
    if((targetY < NSMinY(cvbounds)) || (targetY > NSMinY(cvbounds) + 0.3 * NSHeight(cvbounds)))
        {
        if(NSHeight(cvbounds) / rowFactor > 12)
            targetY -= 2 * rowFactor;
        else if(NSHeight(cvbounds) / rowFactor > 5)
            targetY -= rowFactor;
        if(targetY < 0)
            targetY = 0;
        else if(targetY + rowFactor > NSHeight([self bounds]) - NSHeight(cvbounds))
            targetY = NSHeight([self bounds]) - NSHeight(cvbounds);
        [myClipView scrollToPoint:NSMakePoint(NSMinX(cvbounds), targetY)];
        [[myClipView superview] reflectScrolledClipView:myClipView];
        }
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
