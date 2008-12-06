//---------------------------------------------------------------------------------------
//  EDObjectWell.h created by erik on Sun 11-Oct-1998
//  @(#)$Id: EDObjectWell.h,v 2.0 2002-08-16 18:12:50 erik Exp $
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


struct _EDOWFlags {
#ifdef __BIG_ENDIAN__
    unsigned drawsBezel : 1;
    unsigned delaysRequestingData : 1;
    unsigned delegateRespondsToOpMask: 1;
    unsigned delegateRespondsToShouldAccept : 1;
    unsigned delegateRespondsToDidAccept : 1;
    unsigned padding : 27;
#else
    unsigned padding : 27;
    unsigned delegateRespondsToDidAccept : 1;
    unsigned delegateRespondsToShouldAccept : 1;
    unsigned delegateRespondsToOpMask: 1;
    unsigned delaysRequestingData : 1;
    unsigned drawsBezel : 1;
#endif
};


@interface EDObjectWell : NSControl
{
    struct _EDOWFlags	flags;				/*" These instance variables are private. "*/ 
    NSDictionary		*imageDictionary;	/*" "*/
    NSArray		 		*currentTypes;		/*" "*/
    NSArray		 		*acceptableTypes;	/*" "*/
    IBOutlet id  		delegate;			/*" Connect in Interface Builder. "*/
}

/*" Changing the well's appearance "*/
- (void)setDrawsBezel:(BOOL)flag;
- (BOOL)drawsBezel;

- (void)setImageDictionary:(NSDictionary *)someImages;
- (NSDictionary *)imageDictionary;

/*" Setting and getting the well's attributes "*/
- (void)setDelaysRequestingData:(BOOL)flag;
- (BOOL)delaysRequestingData;

/*" Assigning a delegate "*/
- (void)setDelegate:(id)anObject;
- (id)delegate;

/*" Setting and getting object types "*/
- (void)setCurrentTypes:(NSArray *)types;
- (NSArray *)currentTypes;
- (void)setAcceptableTypes:(NSArray *)types;
- (NSArray *)acceptableTypes;

/*" Setting the image displayed "*/
- (void)setImage:(NSImage *)anImage;
- (NSImage *)image;

@end


@interface NSObject(EDObjectWellDelegateInformalProtocol)
- (void)objectWell:(EDObjectWell *)anObjectWell writeType:(NSString *)type ontoPasteboard:(NSPasteboard *)pboard;
- (BOOL)objectWell:(EDObjectWell *)anObjectWell shouldAcceptPasteboard:(NSPasteboard *)pboard;
- (void)objectWell:(EDObjectWell *)anObjectWell didAcceptPasteboard:(NSPasteboard *)pboard;
@end
