//---------------------------------------------------------------------------------------
//  NSMatrix+Extensions.m created by erik on Sat 04-Nov-2000
//  $Id: NSMatrix+Extensions.m,v 2.1 2003-04-08 16:51:32 znek Exp $
//
//  Copyright (c) 2000 by Erik Doernenburg. All rights reserved.
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
#import "NSMatrix+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSMatrix(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSMatrix. "*/

/*" Selects the %cell if it is anywhere in the matrix. "*/

- (void)selectCell:(NSCell *)cell
{
    int	 	i, j, n, m;

    for(i = 0, n = [self numberOfColumns]; i < n; i++)
        for(j = 0, m = [self numberOfRows]; j < m; j++)
            {
            if([self cellAtRow:j column:i] == cell)
                {
                [self selectCellAtRow:j column:i];
                break;
                }
            }
}


/*" Selects the/a cell that has %object as the represented object. "*/

- (void)selectCellForObject:(id)object
{
    int	 	i, j, n, m;

    for(i = 0, n = [self numberOfColumns]; i < n; i++)
        for(j = 0, m = [self numberOfRows]; j < m; j++)
            {
            if([[[self cellAtRow:j column:i] representedObject] isEqual:object])
                {
                [self selectCellAtRow:j column:i];
                break;
                }
            }
}


/*" Returns the/a cell that has %object as the represented object. "*/

- (NSCell *)cellForObject:(id)object
{
    NSEnumerator *cellEnum;
    NSCell		 *cell;

    cellEnum = [[self cells] objectEnumerator];
    while((cell = [cellEnum nextObject]) != nil)
        {
        if([[cell representedObject] isEqual:object])
            break;
        }

    return cell;
  
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
