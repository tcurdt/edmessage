//---------------------------------------------------------------------------------------
//  EDTableView.h created by erik on Mon 28-Jun-1999
//  @(#)$Id: EDTableView.h,v 2.1 2003-04-08 16:51:36 znek Exp $
//
//  Copyright (c) 1999-2001 by Erik Doernenburg. All rights reserved.
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

#import <AppKit/NSTableView.h>
#import "EDCommonDefines.h"


struct _EDTVFlags {
#ifdef __BIG_ENDIAN__
    unsigned isManagingClick : 1;
    unsigned padding : 31;
#else
    unsigned padding : 31;
    unsigned isManagingClick : 1;
#endif
};


@interface EDTableView : NSTableView
{
    struct _EDTVFlags	flags;
    NSMutableSet		*clickThroughColumns;
    int					clickedRowIdx, clickedColumnIdx;
}

/*" Managing "click-through" columns "*/
- (void)addToClickThroughColumns:(NSTableColumn *)aColumn;
- (void)removeFromClickThroughColumns:(NSTableColumn *)aColumn;
- (NSArray *)clickThroughColumns;

@end
