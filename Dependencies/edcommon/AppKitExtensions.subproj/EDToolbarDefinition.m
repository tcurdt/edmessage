//---------------------------------------------------------------------------------------
//  EDToolbarDefinition.h created by erik on Sat 06-Jun-2001
//  @(#)$Id: EDToolbarDefinition.m,v 2.1 2003-04-08 16:51:31 znek Exp $
//
//  Copyright (c) 2001 by Erik Doernenburg. All rights reserved.
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
#import "EDToolbarDefinition.h"


//---------------------------------------------------------------------------------------
    @implementation EDToolbarDefinition
//---------------------------------------------------------------------------------------

/*" #EDToolbarDefinitions provide a convenient way to define window toolbars in external text files.

The following code fragment shows how a toolbar can be created and assigned to a window: !{

    toolbarDefinition = [EDToolbarDefinition toolbarDefinitionWithName: ... ];
    [toolbarDefinition setTargetForActions:self];
    [[self window] setToolbar:[toolbarDefinition toolbar]];
}

Toolbars request their items lazily from their delegate, the toolbar definition by default. If the window controller wants to receive other delegate methods it must set itself as the delegate and then forward the appropriate methods! "*/

/*" Creates and returns a toolbar by reading the file named %aName with the extension !{toolbar} in the main bundle. See class description for an explanation of the file format.
"*/

+ (id)toolbarDefinitionWithName:(NSString *)aName
{
    return [[[self alloc] initWithName:aName] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly created toolbar definition by reading the file named %aName with the extension !{toolbar} in the main bundle. See class description for an explanation of the file format.
"*/

- (id)initWithName:(NSString *)aName
{
    NSString *path;

    [super init];

    name = [aName copyWithZone:[self zone]];
    if((path = [[NSBundle mainBundle] pathForResource:name ofType:@"toolbar"]) == nil)
        {
        [self autorelease];
        return nil;
        }
    toolbarDefinition = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    
    return self;
}



- (void)dealloc
{
    [name release];
    [toolbarDefinition release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Returns the name of the toolbar definition. "*/

- (NSString *)name
{
    return name;
}


/*" Sets %anObject as the target that will be used for the toolbar items. The selector is set in the text file but this cannot be done in the text file as there is no way to reference an instance. "*/

- (void)setTargetForActions:(id)anObject
{
    targetForActions = anObject;
}


/*" Returns the target that will be used for the toolbar items. "*/

- (id)targetForActions
{
    return targetForActions;
}


//---------------------------------------------------------------------------------------
//	CREATING TOOLBAR OBJECTS
//---------------------------------------------------------------------------------------

/*" Returns an #NSToolbar instance for the definition. Note that #{setTargetForActions:} should be called before. The toolbar's delegate is set to the receive but this is not neccessarily required and can be changed afterwards. "*/

- (NSToolbar *)toolbar
{
    NSToolbar *toolbar;
    
    toolbar = [[[NSToolbar allocWithZone:[self zone]] initWithIdentifier:name] autorelease];
    if([[toolbarDefinition objectForKey:@"autosavesConfiguration"] boolValue])
        [toolbar setAutosavesConfiguration:YES];
    if([[toolbarDefinition objectForKey:@"allowsUserCustomization"] boolValue])
        [toolbar setAllowsUserCustomization:YES];
    [toolbar setDelegate:self];
    
    return toolbar;    
}


/*" Returns the identifiers of all items that are part of the default toolbar. "*/

- (NSArray *)defaultItemIdentifiers
{
    return [toolbarDefinition objectForKey:@"defaultItemIdentifiers"];
}


/*" Returns the identifiers of all items that can be part of the toolbar. "*/

- (NSArray *)allowedItemIdentifiers
{
    return [toolbarDefinition objectForKey:@"allowedItemIdentifiers"];
}


/*" Returns the #NSToolbarItem for the given identifier. "*/

- (NSToolbarItem *)itemWithIdentifier:(NSString *)identifier
{
    NSToolbarItem 	*item;
    NSDictionary	*definition;
    NSString		*value;
    
    definition = [[toolbarDefinition objectForKey:@"itemInfoByIdentifier"] objectForKey:identifier];
    item = [[[NSToolbarItem allocWithZone:[self zone]] initWithItemIdentifier:identifier] autorelease];

    if((value = [definition objectForKey:@"action"]) != nil)
        {
        [item setTarget:targetForActions];
        [item setAction:NSSelectorFromString(value)];
        }
    if((value = [definition objectForKey:@"imageName"]) != nil)
        [item setImage:[NSImage imageNamed:value]];
    if((value = [definition objectForKey:@"label"]) != nil)
        [item setLabel:value];
    if((value = [definition objectForKey:@"paletteLabel"]) != nil)
        [item setPaletteLabel:value];
    if((value = [definition objectForKey:@"toolTip"]) != nil)
        [item setToolTip:value];
        
    return item;
}


//---------------------------------------------------------------------------------------
//	TOOLBAR DELEGATE
//---------------------------------------------------------------------------------------

/*" NSToolbar delegate method. Returns !{[self allowedItemIdentifiers]} "*/
- (NSArray *)toolbarAllowedItemIdentifiers:(NSToolbar *)toolbar
{
    return [self allowedItemIdentifiers];
}


/*" NSToolbar delegate method. Returns !{[self defaultItemIdentifiers]} "*/
- (NSArray *)toolbarDefaultItemIdentifiers:(NSToolbar *)toolbar
{
    return [self defaultItemIdentifiers];
}

/*" NSToolbar delegate method. Returns !{[self itemWithIdentifier:itemIdentifier]} "*/
- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag;
{
    return [self itemWithIdentifier:itemIdentifier];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
