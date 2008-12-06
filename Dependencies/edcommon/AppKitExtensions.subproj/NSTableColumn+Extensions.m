//---------------------------------------------------------------------------------------
//  NSTableColumn+Extensions.m created by erik on Fri 10-Sep-1999
//  @(#)$Id: NSTableColumn+Extensions.m,v 2.1 2003-04-08 16:51:32 znek Exp $
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
#import "NSTableColumn+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSTableColumn(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various useful extensions to #NSTableColumn. "*/


/*" Returns the string value as it is displayed in row. "*/

- (NSString *)stringValueAtRow:(int)row
{
    NSFormatter	*formatter;
    NSString 	*stringValue;
    id 			myTableView, dataSource, value;

    myTableView = [self tableView];
    dataSource = [myTableView dataSource];
    NSAssert(dataSource != nil, @"table views without data source are not supported");

    if([[self tableView] isKindOfClass:[NSOutlineView class]])
        {
        value = [dataSource outlineView:myTableView objectValueForTableColumn:self byItem:[myTableView itemAtRow:row]];
        }
    else
        {
        value = [dataSource tableView:myTableView objectValueForTableColumn:self row:row];
        }

    if((formatter = [[self dataCell] formatter]) != nil)
        stringValue = [formatter stringForObjectValue:value];
    else if([value isKindOfClass:[NSString class]] == NO)
        stringValue = [value description];
    else
        stringValue = value;

    return stringValue;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
