//---------------------------------------------------------------------------------------
//  EDCanvas.m created by erik on Sat 31-Oct-1998
//  @(#)$Id: EDCanvas.m,v 2.1 2003-04-08 16:51:36 znek Exp $
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
#import "EDCanvas.h"

//---------------------------------------------------------------------------------------
    @implementation EDCanvas
//---------------------------------------------------------------------------------------

/*" This view simply fills its entire bounds with the color specified. It can also draw a bezel but this functionality is obsoleted by the Aqua design guidelines."*/

//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:1];
}


+ (Class)cellClass
{
    return [NSCell class];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- initWithFrame:(NSRect)frame
{
    [super initWithFrame:frame];
    color = [NSColor whiteColor];
    return self;
}


- (void)dealloc
{
    [color release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:color];
    [encoder encodeValueOfObjCType:@encode(BOOL) at:&drawsBezel];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super initWithCoder:decoder];
    version = [decoder versionForClassName:@"EDCanvas"];
    // Version is -1 when loading a NIB file in which we were set as a custom subclass.
    // The unsigned representation of this is INT_MAX on a 2-bytes-complement machine...
    if(version == INT_MAX)
        {
        color = [NSColor whiteColor];
        }
    else
        {
        color = [[decoder decodeObject] copyWithZone:[self zone]];
        [decoder decodeValueOfObjCType:@encode(BOOL) at:&drawsBezel];
        }

    return self;
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Sets the receiver's color to %aColor and redraws it if neccessary. "*/

- (void)setColor:(NSColor *)aColor
{
    id old = color;
    color = [aColor copyWithZone:[self zone]];
    [old release];
    [self setNeedsDisplay:YES];
}


/*" Returns the receiver's color. "*/

- (NSColor *)color
{
    return color;
}


/*" If set to YES the receiver draws a gray bezel along its bounds, if NO it just fills its bounds with the color. "*/

- (void)setDrawsBezel:(BOOL)flag
{
    drawsBezel = flag;
}


/*" Returns whether the receiver draws a gray bezel along its bounds. "*/

- (BOOL)drawsBezel
{
    return drawsBezel;
}


//---------------------------------------------------------------------------------------
// VIEW ATTRIBUTES
//---------------------------------------------------------------------------------------

- (BOOL)isOpaque
{
    return [color alphaComponent] == 1.0;
}


//---------------------------------------------------------------------------------------
//	DRAWING
//---------------------------------------------------------------------------------------

- (void)drawRect:(NSRect)rect
{
    NSRectEdge	sides[8] = {NSMinYEdge, NSMaxXEdge, NSMaxYEdge, NSMinXEdge, NSMinYEdge, NSMaxXEdge, NSMaxYEdge, NSMinXEdge};
    NSColor		*colors[8];

    [color set];
    NSRectFill(rect);
    if(drawsBezel)
        {
        colors[0] = colors[1] = [NSColor controlLightHighlightColor];
        colors[2] = colors[3] = [NSColor controlShadowColor];
        // colors[4] = colors[5] = [NSColor controlHighlightColor];
        colors[4] = colors[5] = [NSColor controlDarkShadowColor];
        colors[6] = colors[7] = [NSColor controlDarkShadowColor];

        NSDrawColorTiledRects(rect, rect, sides, colors, 8);
        }
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

