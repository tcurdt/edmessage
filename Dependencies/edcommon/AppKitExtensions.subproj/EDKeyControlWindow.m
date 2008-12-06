//---------------------------------------------------------------------------------------
//  EDKeyControlWindow.m created by erik on Sat 14-Aug-1999
//  @(#)$Id: EDKeyControlWindow.m,v 2.2 2005-09-25 11:06:26 erik Exp $
//
//  Copyright (c) 1999 by Erik Doernenburg. All rights reserved.
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
#import "EDCommonDefines.h"
#import "NSApplication+Extensions.h"
#import "EDKeyControlWindow.h"

@interface EDKeyControlWindow(PrivateAPI)
- (void)_adjustPromptFieldOrigin;
- (void)_adjustPromptFieldSize;
- (void)_setCurrentKeyBindingDictionary:(NSDictionary *)dictionary;
- (void)_refViewFrameChanged:(NSNotification *)notification;
@end


//---------------------------------------------------------------------------------------
    @implementation EDKeyControlWindow
//---------------------------------------------------------------------------------------

/*" Allows selectors to be sent up the responder chain in response to keystrokes.

The exact behaviour is determined by a "key binding" dictionary which is loaded from a file named !{KeyBindings.dict} in the application's main bundle. This can be overriden by a file in any of the applications library directories.

The dictionary uses the keyboard key as key and the selector as value. A tilde character preceeding the key name is interpreted as !{ALT} modifier and a caret as !{CTRL} modifier. Alternatively, the value can be another dictionary in which case this sub dictionary becomes active after the corresponding key was pressed. When a key not defined in the sub dictionary is pressed, the main dictionary becomes active again. If a sub directory contains the key !{"prompt"} the corresponding value is displayed in the prompt field when the sub directory becomes active.

Example: Consider the following file: !{

    {
        n = "gotoNext:";
        "^x" = {
            prompt = "x-tras";
            s = "save:";
        }
    }
}

If the user presses !{n} the selector !{gotoNext:} is sent. If the user presses !{CTRL-x} the prompt field appears and shows the text "x-tras". Pressing !{s} now results in the selector !{save:} being sent.

"*/

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (void)dealloc
{
    [DNC removeObserver:self]; // just in case the ref view stays around...
    [promptField release];
    [toplevelKeyBindingDictionary release];
	[super dealloc];
}


//---------------------------------------------------------------------------------------
//	FURTHER INITIALISATION
//---------------------------------------------------------------------------------------

- (void)awakeFromNib
{
    NSString	*path, *fileContents;

    [promptField retain];
    
    path = [[[[NSApplication sharedApplication] libraryDirectory] stringByAppendingPathComponent:@"KeyBindings"] stringByAppendingPathExtension:@"dict"];
    if((fileContents = [NSString stringWithContentsOfFile:path]) == nil)
        {
        path = [[NSBundle mainBundle] pathForResource:@"KeyBindings" ofType:@"dict"];
        if((fileContents = [NSString stringWithContentsOfFile:path]) == nil)
            [NSException raise:NSGenericException format:@"Cannot read KeyBindings"];
        }

    NS_DURING
        toplevelKeyBindingDictionary = [[fileContents propertyList] retain];
        [self _setCurrentKeyBindingDictionary:toplevelKeyBindingDictionary];
    NS_HANDLER
        [NSException raise:NSGenericException format:@"Syntax error in KeyBindings"];
    NS_ENDHANDLER
}


//---------------------------------------------------------------------------------------
//	PRIVATE HELPER METHODS
//---------------------------------------------------------------------------------------

- (void)_adjustPromptFieldOrigin
{
    NSRect	rvFrame, pfFrame;

    NSAssert(referenceView != nil, @"do not invoke _adjustPromptFieldOrigin when no reference view is configured.");

    rvFrame = [referenceView frame];
    rvFrame = [[self contentView] convertRect:rvFrame fromView:[referenceView superview]];
    pfFrame = [promptField frame];
    pfFrame.origin.x = NSMaxX(rvFrame) - NSWidth(pfFrame) + 2;
    pfFrame.origin.y = NSMaxY(rvFrame) - NSHeight(pfFrame) + 1;
    [promptField setFrame:pfFrame];
}


- (void)_adjustPromptFieldSize
{
    NSRect oldFrame, newFrame;
    
    oldFrame = [promptField frame];
    [promptField sizeToFit];
    newFrame = [promptField frame];
    newFrame.origin.x -= newFrame.size.width - oldFrame.size.width;
    [promptField setFrame:newFrame];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)setReferenceView:(NSView *)aView
{
    if(referenceView != nil)
        {
        [DNC removeObserver:self name:NSViewFrameDidChangeNotification object:referenceView];
        referenceView = nil;
        }
    if(aView != nil)
        {
        referenceView = aView;
        [referenceView setPostsFrameChangedNotifications:YES];
        [DNC addObserver:self selector:@selector(_refViewFrameChanged:) name:NSViewFrameDidChangeNotification object:referenceView];
        [self _adjustPromptFieldOrigin];
        }
}


- (NSView *)referenceView
{
    return referenceView;
}


//---------------------------------------------------------------------------------------
//	PRIVATE ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)_setCurrentKeyBindingDictionary:(NSDictionary *)dictionary
{
    NSString *prompt;
    
    prompt = [dictionary objectForKey:@"prompt"];
    if((dictionary == toplevelKeyBindingDictionary) || (prompt == nil))
        {
        if([promptField superview] != nil)
            [promptField removeFromSuperview];
        }
    else
        {
        if([promptField superview] == nil)
            [[self contentView] addSubview:promptField];
        [promptField setStringValue:prompt];
        [self _adjustPromptFieldSize];
        }
    currentKeyBindingDictionary = dictionary;
}


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- (void)keyDown:(NSEvent *)theEvent
{
    NSString		*keyStringRep;
    unsigned int	modifierFlags;
    id				entry;
    SEL				selector;

    keyStringRep = [theEvent charactersIgnoringModifiers];
    modifierFlags = [theEvent modifierFlags];
    if((modifierFlags & NSAlternateKeyMask) != 0)
        keyStringRep = [@"~" stringByAppendingString:keyStringRep];
    if((modifierFlags & NSControlKeyMask) != 0)
        keyStringRep = [@"^" stringByAppendingString:keyStringRep];

    if((entry = [currentKeyBindingDictionary objectForKey:keyStringRep]) != nil)
        {
        if([entry isKindOfClass:[NSDictionary class]])
            {
            [self _setCurrentKeyBindingDictionary:entry];
            }
        else if([entry isKindOfClass:[NSString class]])
            {
            if((selector = NSSelectorFromString(entry)) == NULL)
                [NSException raise:NSGenericException format:@"Invalid selector name in KeyBindings; found \"%@\"", entry];
            if([[NSApplication sharedApplication] sendAction:selector to:nil from:self] == NO)
                NSBeep();
            [self _setCurrentKeyBindingDictionary:toplevelKeyBindingDictionary];
            }
        else
            {
            [NSException raise:NSGenericException format:@"Syntax error in KeyBindings"];
            }
        }
    else
        {
        if(currentKeyBindingDictionary != toplevelKeyBindingDictionary)
            {
            [self _setCurrentKeyBindingDictionary:toplevelKeyBindingDictionary];
            NSBeep();
            }
        else
            {
            [super keyDown:theEvent];
            }
        }
}


//---------------------------------------------------------------------------------------
//	NOTIFICATIONS
//---------------------------------------------------------------------------------------

- (void)_refViewFrameChanged:(NSNotification *)notification
{
    [self _adjustPromptFieldOrigin];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
