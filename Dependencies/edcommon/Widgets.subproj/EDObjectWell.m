//---------------------------------------------------------------------------------------
//  EDObjectWell.m created by erik on Sun 11-Oct-1998
//  @(#)$Id: EDObjectWell.m,v 2.1 2003-04-08 16:51:36 znek Exp $
//
//  Copyright (c) 1998-2000 by Erik Doernenburg. All rights reserved.
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
#import "EDObjectWell.h"

@interface EDObjectWell(PrivateAPI)
- (void)_setDefaultValues;
- (void)_writeType:(NSString *)type ontoPasteboard:(NSPasteboard *)pboard;
@end


//---------------------------------------------------------------------------------------
    @implementation EDObjectWell
//---------------------------------------------------------------------------------------

/*" Object wells are places that provide or accept objects. A delegate/datasource specifies, in terms of pasteboard types, what kind of object is available and fills the pasteboard when the user drags the graphical representation of the objects from the well. If an object of an acceptable type is deposited on the well (and the delegate approves) the object is accepted and the delegate notified. This does not neccessarily result in anything being displayed on the well. "*/


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:3];
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
    [self _setDefaultValues];
    return self;
}


- (void)dealloc
{
    [imageDictionary release];
    [currentTypes release];
    [acceptableTypes release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeValueOfObjCType:@encode(int) at:&flags];
    [encoder encodeObject:delegate];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super initWithCoder:decoder];
    version = [decoder versionForClassName:@"EDObjectWell"];
    // Version is -1 when loading a NIB file in which we were set as a custom subclass.
    // The unsigned representation of this is INT_MAX on a 2-bytes-complement machine...
    if(version == INT_MAX)  
        {
        [self _setDefaultValues];
        }
    else 
        {
        [decoder decodeValueOfObjCType:@encode(int) at:&flags];
        delegate = [decoder decodeObject];
        if(version == 2)
            [decoder decodeObject];
        }
    
    return self;
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)setDrawsBezel:(BOOL)flag
{
    flags.drawsBezel = flag;
    [self setNeedsDisplay:YES];
}

- (BOOL)drawsBezel
{
    return flags.drawsBezel;
}


- (void)setDelaysRequestingData:(BOOL)flag
{
    flags.delaysRequestingData = flag;
}

- (BOOL)delaysRequestingData
{
    return flags.delaysRequestingData;
}


- (void)setImageDictionary:(NSDictionary *)someImages
{
    [imageDictionary autorelease];
    imageDictionary = [someImages retain];
    [self setCurrentTypes:currentTypes]; // to update image
}

- (NSDictionary *)imageDictionary
{
    return imageDictionary;
}


- (void)setDelegate:(id)anObject
{
    flags.delegateRespondsToOpMask = [anObject respondsToSelector:@selector(objectWell:operationMaskForLocal:)];
    flags.delegateRespondsToShouldAccept = [anObject respondsToSelector:@selector(objectWell:shouldAcceptPasteboard:)];
    flags.delegateRespondsToDidAccept = [anObject respondsToSelector:@selector(objectWell:didAcceptPasteboard:)];
    delegate = anObject;
}

- (id)delegate
{
    return delegate;
}


- (void)setCurrentTypes:(NSArray *)types
{
    [currentTypes autorelease];
    currentTypes = [types retain];
    if((types == nil) || ([types count] == 0))
        [self setImage:nil];
    else if(imageDictionary != nil)
        [self setImage:[imageDictionary objectForKey:[types objectAtIndex:0]]];
}

- (NSArray *)currentTypes
{
    return currentTypes;
}


- (void)setAcceptableTypes:(NSArray *)types
{
    [acceptableTypes autorelease];
    acceptableTypes = [types retain];
    if((types == nil) || ([types count] == 0))
        [self unregisterDraggedTypes];
    else
        [self registerForDraggedTypes:types];
}

- (NSArray *)acceptableTypes
{
    return acceptableTypes;
}


- (void)setImage:(NSImage *)anImage
{
    [[self cell] setImage:anImage];
    [self setNeedsDisplay:YES];
}

- (NSImage *)image
{
    return [[self cell] image];
}


//---------------------------------------------------------------------------------------
//	PRIVATE STUFF
//---------------------------------------------------------------------------------------

- (void)_setDefaultValues
{
   flags.drawsBezel = YES;
   flags.delaysRequestingData = YES;
}


- (void)_writeType:(NSString *)type ontoPasteboard:(NSPasteboard *)pboard
{
   [delegate objectWell:self writeType:type ontoPasteboard:pboard];
}


//---------------------------------------------------------------------------------------
//	DRAWING
//---------------------------------------------------------------------------------------

- (void)drawRect:(NSRect)rect
{
    if(flags.drawsBezel)
        NSDrawLightBezel([self bounds], rect);
    [super drawRect:rect];
}


//---------------------------------------------------------------------------------------
//	EVENT HANDLING
//---------------------------------------------------------------------------------------

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}


- (BOOL)shouldDelayWindowOrderingForEvent:(NSEvent *)theEvent 
{
    return YES;
}


- (void)mouseDown:(NSEvent *)theEvent
{
    NSPasteboard	*dragPboard;
    NSEnumerator	*typeEnum;
    NSString		*type;
    NSPoint			imageLocation;

    if(currentTypes == nil)
        return;

    dragPboard = [NSPasteboard pasteboardWithName:NSDragPboard];
    if(flags.delaysRequestingData)
        {
        [dragPboard declareTypes:currentTypes owner:self];
        [self _writeType:[currentTypes objectAtIndex:0] ontoPasteboard:dragPboard];
        }
    else
        {
        [dragPboard declareTypes:currentTypes owner:nil];
        typeEnum = [currentTypes objectEnumerator];
        while((type = [typeEnum nextObject]) != nil)
            [self _writeType:type ontoPasteboard:dragPboard];
        }

    imageLocation = [[self cell] imageRectForBounds:[self bounds]].origin;
    [self dragImage:[[self cell] image] at:imageLocation offset:NSMakeSize(0, 0) event:theEvent pasteboard:dragPboard source:self slideBack:YES];
}


//---------------------------------------------------------------------------------------
//	PASTBOARD / DRAGGING SOURCE PROTOCOL IMPLEMENTATIONS
//---------------------------------------------------------------------------------------

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
    [self _writeType:type ontoPasteboard:sender];
}


- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return NSDragOperationGeneric;
}


- (BOOL)ignoreModifierKeysWhileDragging
{
    return YES;
}


- (void)draggedImage:(NSImage *)anImage endedAt:(NSPoint)aPoint deposited:(BOOL)flag
{
    // To make sure we don't receive requests when our object source might be gone.
    [[NSPasteboard pasteboardWithName:NSDragPboard] declareTypes:[NSArray array] owner:nil];
}


//---------------------------------------------------------------------------------------
//	DRAGGING DESTINATION PROTOCOL IMPLEMENTATION
//---------------------------------------------------------------------------------------

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
    NSPasteboard 	*pboard;
    unsigned int 	retMask;

    if(currentTypes != nil)
        return NSDragOperationNone;
    
    pboard = [sender draggingPasteboard];

    if((flags.delegateRespondsToShouldAccept == YES) && ([delegate objectWell:self shouldAcceptPasteboard:pboard] == NO))
        {
        retMask = NSDragOperationNone;
        }
    else
        {
        retMask = [sender draggingSourceOperationMask] & NSDragOperationGeneric;
        }
    
    return retMask;
}


- (void)draggingExited:(id <NSDraggingInfo>)sender
{
    [self setImage:nil];
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}


- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{ // this should probably be in perform but Mike Ferris says its better here...
    if(imageDictionary != nil)
        {
        [self setImage:[imageDictionary objectForKey:[[sender draggingPasteboard] availableTypeFromArray:acceptableTypes]]];
        }
    if(flags.delegateRespondsToDidAccept == YES)
        {
        [delegate objectWell:self didAcceptPasteboard:[sender draggingPasteboard]];
        }
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
