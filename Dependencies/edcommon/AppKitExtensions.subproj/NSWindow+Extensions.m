//---------------------------------------------------------------------------------------
//  NSWindow+Extensions.m created by erik on Sun 11-Oct-1998
//  @(#)$Id: NSWindow+Extensions.m,v 2.1 2003-04-08 16:51:32 znek Exp $
//
//  Copyright (c) 1998 by Erik Doernenburg. All rights reserved.
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
#import "NSWindow+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSWindow(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various useful extensions to #NSWindow. "*/

/*" Takes the tag from the sender, or from the selected cell if the sender is a matrix, and stops the current modal session with this code. "*/

- (void)endModalSessionWithCodeFromSender:(id)sender
{
    if([sender isKindOfClass:[NSMatrix class]])
        [[NSApplication sharedApplication] stopModalWithCode:[[(NSMatrix *)sender selectedCell] tag]];
    else
        [[NSApplication sharedApplication] stopModalWithCode:[sender tag]];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
