//---------------------------------------------------------------------------------------
//  EDMessage.h created by erik on Wed 12-Apr-2000
//  $Id: EDMessage.h,v 2.2 2003/04/08 17:06:02 znek Exp $
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "EDMessageDefines.h"

#import "NSCalendarDate+NetExt.h"
#import "NSCharacterSet+MIME.h"
#import "NSData+MIME.h"
#import "NSImage+XFace.h"
#import "NSString+MessageUtils.h"
#import "NSString+PlainTextFlowedExtensions.h"

#import "EDMConstants.h"
#import "EDHeaderBearingObject.h"
#import "EDMessagePart.h"
#import "EDInternetMessage.h"

#import "EDHeaderFieldCoder.h"
#import "EDTextFieldCoder.h"
#import "EDDateFieldCoder.h"
#import "EDIdListFieldCoder.h"
#import "EDEntityFieldCoder.h"
#import "EDFaceFieldCoder.h"

#import "EDContentCoder.h"
#import "EDCompositeContentCoder.h"
#import "EDPlainTextContentCoder.h"
#import "EDHTMLTextContentCoder.h"
#import "EDMultimediaContentCoder.h"
#import "EDTextContentCoder.h"

#import "EDSMTPStream.h"
#import "EDMailAgent.h"
