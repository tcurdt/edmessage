//
//  $Id: NSString+OPOSErrors.h,v 1.1 2003/01/18 02:23:30 westheide Exp $
//  OPMessageServices
//
//  Created by Jšrg Westheide on Mon Jan 13 2003.
//  Copyright (c) 2003 objectpark.org. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSString (OPOSErrors)

+ (NSString*) stringForErrorCode:(OSStatus) error;


@end
