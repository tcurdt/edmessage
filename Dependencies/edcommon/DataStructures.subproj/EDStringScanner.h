//---------------------------------------------------------------------------------------
//  EDStringScanner.h created by erik on Mon 24-Apr-2000
//  $Id: EDStringScanner.h,v 2.1 2003-04-08 16:51:34 znek Exp $
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

#import "EDCommonDefines.h"

@interface EDStringScanner : NSObject
{
    NSString	*string;		/*" All instance variables are private. "*/
    unichar	 	*buffer;		/*" "*/
    unichar		*charPointer;	/*" "*/
    unichar  	*endOfBuffer;	/*" "*/
    unsigned int bufferOffset;	/*" "*/
}

/*" Creating string scanners "*/
+ (id)scannerWithString:(NSString *)aString;

- (id)initWithString:(NSString *)aString;

/*" Querying the scanner "*/
- (unichar)getCharacter;
- (unichar)peekCharacter;

- (unsigned int)scanLocation;

@end


/*" Returned by #getCharacter and #peekCharacter when the scanner has reached the end of the string. "*/
EDCOMMON_EXTERN unichar EDStringScannerEndOfDataCharacter;

