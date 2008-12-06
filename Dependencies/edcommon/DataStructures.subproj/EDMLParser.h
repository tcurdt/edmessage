//---------------------------------------------------------------------------------------
//  EDMLParser.h created by erik
//  @(#)$Id: EDMLParser.h,v 2.4 2005-09-25 11:06:27 erik Exp $
//
//  Copyright (c) 1999-2002 by Erik Doernenburg. All rights reserved.
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
#import "EDMLTagProcessorProtocol.h"

@interface EDMLParser : NSObject
{
    BOOL					preservesWhitespace;	/*" All instance variables are private. "*/
	BOOL					convertsTagsToLowercase;/*" "*/
	BOOL					ignoresEntities;		/*" "*/
    id <EDMLTagProcessor>	tagProcessor;			/*" "*/
    NSDictionary			*entityTable;			/*" "*/
    unichar		 			*source;				/*" "*/
    unichar		 			*charp;					/*" "*/
    unsigned int 			lexmode;				/*" "*/
    id						peekedToken;			/*" "*/
    NSMutableArray			*stack;					/*" "*/
    NSMutableArray			*namespaceStack;		/*" "*/
}

/*" Creating parser instances "*/
+ (id)parserWithTagProcessor:(id <EDMLTagProcessor>)aTagProcessor;

- (id)init;
- (id)initWithTagProcessor:(id <EDMLTagProcessor>)aTagProcessor;

/*" Assigning a tag processor "*/
- (void)setTagProcessor:(id <EDMLTagProcessor>)aTagProcessor;
- (id <EDMLTagProcessor>)tagProcessor;

/*" Configuring the parser "*/
- (void)setPreservesWhitespace:(BOOL)flag;
- (BOOL)preservesWhitespace;
- (void)setConvertsTagsToLowercase:(BOOL)flag;
- (BOOL)convertsTagsToLowercase;
- (void)setIgnoresEntities:(BOOL)flag;
- (BOOL)ignoresEntities;
- (void)setEntityTable:(NSDictionary *)aDictionary;
- (NSDictionary *)entityTable;

/*" Parsing "*/
- (id)parseDocument:(NSString *)aString;
- (NSArray *)parseString:(NSString *)aString;
- (id)parseXMLDocumentAtPath:(NSString *)path;
- (id)parseXMLDocument:(NSData *)xmlData;
- (NSArray *)parseXMLFragment:(NSString *)xmlString;

/*" Relevant character sets "*/
+ (NSCharacterSet *)spaceCharacterSet;
+ (NSCharacterSet *)idCharacterSet;
+ (NSCharacterSet *)textCharacterSet;
+ (NSCharacterSet *)attrStopCharacterSet;

@end


/*" Exception thrown when the parser encounters an error; generally a syntax error. "*/

EDCOMMON_EXTERN NSString *EDMLParserException;
