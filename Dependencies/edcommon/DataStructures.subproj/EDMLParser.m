//---------------------------------------------------------------------------------------
//  EDMLParser.m created by erik
//  @(#)$Id: EDMLParser.m,v 2.15 2005-09-25 11:06:27 erik Exp $
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

#import <Foundation/Foundation.h>
#import "NSArray+Extensions.h"
#import "NSString+Extensions.h"
#import "EDBitmapCharset.h"
#import "EDObjectPair.h"
#import "EDMLToken.h"
#import "EDMLTagProcessorProtocol.h"
#import "EDMLParser.h"

#define EDML_MAX_ENTITY_LENGTH 50

@interface EDMLParser(PrivateAPI)
+ (void)_initializeCharacterSets;
- (id)_parseString:(NSString *)aString createDocument:(BOOL)docFlag;
- (void)_parserLoop;
- (EDMLToken *)_nextToken;
- (EDMLToken *)_peekedToken;
- (void)_shift:(EDMLToken *)aToken;
- (BOOL)_reduce;
- (void)_loadXMLEntityTable;
- (void)_reportClosingTagMismatch:(EDObjectPair *)tag;
- (void)_processNamespaceDefinitions:(NSArray *)attrList;
- (void)_processNamespaceContextEndings:(EDObjectPair *)tagName;
- (NSArray *)_normalizedAttributeList:(NSArray *)pAttrList;
- (EDObjectPair *)_normalizedAttributeName:(NSString *)name withDefaultNamespace:(NSString *)namespace;
- (NSString *)_qualifiedNameForTag:(EDObjectPair *)tag;
- (NSString *)_stringForTag:(NSArray *)attrList type:(int)type;
@end



enum
{
    EDMLPTextMode,
    EDMLPSpaceMode,
    EDMLPTagMode,
    EDMLPProcInstrMode,
    EDMLPCommentMode,
    EDMLPCommentBracketMode,
    EDMLPCDATAMode
};

enum
{
    EDMLPT_STRING = 1,
    EDMLPT_SPACE = 2,
    EDMLPT_LT = 3,
    EDMLPT_GT = 4,
    EDMLPT_SLASH = 5,
    EDMLPT_EQ =  6,
    EDMLPT_TSTRING =  7,
    EDMLPT_TATTR =  8,		
    EDMLPT_TATTRLIST =  9,
    EDMLPT_STAG = 10,
    EDMLPT_ETAG = 11,
    EDMLPT_ELEMENT = 12,
    EDMLPT_LIST = 13
};

#define DEFAULTNSKEY @"<DEFAULT>"
#define TAGKEY @"<TAG>"


//---------------------------------------------------------------------------------------
    @implementation EDMLParser
//---------------------------------------------------------------------------------------

/*" This parser was implemented before the widespread adoption of XML and today's abundance of corresponding parsers but it remains useful. It is probably even more useful today as more and more applications have to deal with XML files. Moreover, the parser can deal with fairly bad markup, as often found in HTML documents, but also handles more complex constructs such as XML namespaces. It is implemented as a shift/reduce parser which makes it efficient but not tolerant to missing end tags.

The parser needs a tag processor that implements the #EDMLTagProcessorProtocol and uses the callback methods at events during the parsing of a string/document. (Some few methods deal with configuration.) This mode of operation is very similar to the SAX API and provides great flexibility. Most applications, however, will use either the #{EDXMLDOMTagProcessor} or the #{EDAOMTagProcessor}. The former creates a DOM representation of the document using #{EDXMLNode} and derived classes. The latter also transforms the document into a tree in which the nodes are represented by objects but with one significant exception: #EDAOMTagProcessor uses node classes created by the application developer. This means, of course, that the resulting tree is directly meaningful in the application and the node classes can contain application specific behaviour. See the implementations in the EDSLProcessor framework for an example.

Typically, a parser with a custom tag processor is used as follows: !{
    
    id <EDMLTagProcessor>	myTagProcessor; // assume this exists
    NSString				*myDocument;  // assume this exists
    EDMLParser              *parser;
    id                      documentObject;

    parser = [EDMLParser parserWithTagProcessor:myTagProcessor];
    documentObject = [parser parseDocument:myDocument];
}


#EDXMLDocument and #EDXMLDocumentFragment provide convenience methods to initialise a parser with an XMLDOM processor, parse the input and return the corresponding object. For example:  !{

    NSData			*myDocumentData;  // assume this exists
    EDXMLDocument   *documentObject;
    
    documentObject = [EDXMLDocument documentWithData:myDocumentData];
}


#EDAOMTagProcessor provides a convenience method to initialise a parser with the AOM processor as follows: (See the class description of EDAOMTagProcessor for an explanation of the "tag definitions" dictionary.) !{
    
    NSDictionary 	*myTagDefinitions; // assume this exists
    NSString		*myDocument;  // assume this exists
    EDMLParser		*parser;
    id              documentObject;

    parser = [EDMLParser parserWithTagDefinitions:myTagDefinitions];
    documentObject = [parser parseDocument:myDocument];
}

If you just have a document fragment use parseString: instead. Note that there are convenience methods to parse XML. "*/


NSString *EDMLParserException = @"EDMLParserException";
EDBitmapCharset *idCharset, *spaceCharset = NULL, *textCharset, *attrStopCharset;
NSCharacterSet *colonNSCharset;


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)_initializeCharacterSets
{
    spaceCharset = EDBitmapCharsetFromCharacterSet([self spaceCharacterSet]);
    textCharset = EDBitmapCharsetFromCharacterSet([self textCharacterSet]);
    idCharset = EDBitmapCharsetFromCharacterSet([self idCharacterSet]);
    attrStopCharset = EDBitmapCharsetFromCharacterSet([self attrStopCharacterSet]);
    colonNSCharset = [[NSCharacterSet characterSetWithCharactersInString:@":"] retain];
}


/*" Returns the character set containing all characters that should be considered spaces. The default is the "whitespaceAndNewlineCharacterSet" set as returned by #NSCharacterSet. Override in sublcasses for further customisation. "*/

+ (NSCharacterSet *)spaceCharacterSet
{
    return [NSCharacterSet whitespaceAndNewlineCharacterSet];
}


/*" Returns the character set containing all characters that can legally appear tag and attribute names.  The default is the alphanumeric set plus !{{"-", ":", "."}}. Override in sublcasses for further customisation. "*/

+ (NSCharacterSet *)idCharacterSet
{
    NSMutableCharacterSet	*tempCharset;

    tempCharset = [[[NSCharacterSet alphanumericCharacterSet] mutableCopy] autorelease];
    [tempCharset addCharactersInString:@"-:."];
    return tempCharset;
}


/*" Returns the character set containing all characters that can legally appear between tags; minus whitespace. The default is "everything" minus whitespace minus the greater than and less than characters. Override in sublcasses for further customisation. "*/

+ (NSCharacterSet *)textCharacterSet
{
    NSMutableCharacterSet	*tempCharset;

    tempCharset = [[[NSCharacterSet illegalCharacterSet] mutableCopy] autorelease];
    [tempCharset addCharactersInString:@"<>&"];
    [tempCharset formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [tempCharset invert];
    return tempCharset;
}


/*" Returns the character set that definitely marks the end of an attribute. In an ideal world this would be the inverse of the idCharacterSet but in the real world it is simply !{{"=", ">"}}. Override in sublcasses for further customisation. "*/

+ (NSCharacterSet *)attrStopCharacterSet
{
    NSMutableCharacterSet *tempCharset;

    tempCharset = [[[NSCharacterSet whitespaceAndNewlineCharacterSet] mutableCopy] autorelease];
    [tempCharset addCharactersInString:@"=>"];
    return tempCharset;
}


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

/*" Creates and returns a parser which will use %aTagProcessor. "*/

+ (id)parserWithTagProcessor:(id <EDMLTagProcessor>)aTagProcessor
{
    return [[[self alloc] initWithTagProcessor:aTagProcessor] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated parser. "*/

- (id)init
{
    [super init];
    stack = [[NSMutableArray allocWithZone:[self zone]] init];
    namespaceStack = [[NSMutableArray allocWithZone:[self zone]] init];
    return self;
}


/*" Initialises a newly allocated parser and sets the tag processor to %aTagProcessor. "*/

- (id)initWithTagProcessor:(id <EDMLTagProcessor>)aTagProcessor
{
    [self init];
    [self setTagProcessor:aTagProcessor];
    return self;
}


- (void)dealloc
{
    [peekedToken release];
    [stack release];
    [tagProcessor release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Sets the tag processor to %aTagProcessor. The parser retains its tag processor. Note that it is probably not wise to change tag processors while parsing. "*/

- (void)setTagProcessor:(id <EDMLTagProcessor>)aTagProcessor
{
    [aTagProcessor retain];
    [tagProcessor release];
    tagProcessor = aTagProcessor;
}


/*" Returns the parser's tag processor. "*/

- (id <EDMLTagProcessor>)tagProcessor
{
    return tagProcessor;
}


/*" Controls whitespace handling. If set to YES, the parser will pass the exact whitespace sequence to its tag processor. If set to NO, it converts it to a simple !{@" "}. The default is not to preserve whitespace.

Note that the tag processor can specify that whitespace within text, i.e. between tags, should be treated as text. "*/

- (void)setPreservesWhitespace:(BOOL)flag
{
    preservesWhitespace = flag;
}


/*" Returns the parser's whitespace handling mode. See #{setPreservesWhitespace:} for details. "*/

- (BOOL)preservesWhitespace
{
    return preservesWhitespace;
}

/*" Controls tag case handling. If set to YES, the parser will convert all tag names and attributes to lowercase. "*/

- (void)setConvertsTagsToLowercase:(BOOL)flag
{
	convertsTagsToLowercase = flag;
}

/*" Returns the parser's tag case handling mode. See #{setConvertsTagNamesToLowercase:} for details. "*/

- (BOOL)convertsTagsToLowercase
{
	return convertsTagsToLowercase;
}

/*" Controls entity handling. If set to YES, the parser will ignore all entities. This is against the standards but helps with bad HTML. "*/

- (void)setIgnoresEntities:(BOOL)flag
{
	ignoresEntities = flag;
}

/*" Returns the parser's entity handling mode. See #{setIgnoresEntities:} for details. "*/

- (BOOL)ignoresEntities;
{
	return ignoresEntities;
}

/*" Set the "entity table" for the parser. This table maps entities of the form !{&ename;} to another string, usually a single characters. Entities are only replaced within text, not within tags.

Example table: !{
    {
        lt = "<";
        gt = ">";
        amp = "&";
        apos = "'";
        quot = "\"";
    }
    
}

Note that if you use the #{parseXML...} methods the standard XML entity table is automatically set if no other entity table was provided before.

"*/

- (void)setEntityTable:(NSDictionary *)aDictionary
{
    [aDictionary retain];
    [entityTable release];
    entityTable = aDictionary;
}


/*" Returns the parser's entity table. See #{setEntityTable:} for details. "*/

- (NSDictionary *)entityTable
{
    return entityTable;
}


//---------------------------------------------------------------------------------------
//	XML PARSING CONVENIENCES
//---------------------------------------------------------------------------------------

/*" Loads the file at #path and calls #{parseXMLDocument:} "*/

- (id)parseXMLDocumentAtPath:(NSString *)path
{
    NSData	*contents;

    if((contents = [NSData dataWithContentsOfFile:path]) == nil)
        [NSException raise:NSGenericException format:@"Cannot read XML document at %@", path];
    return [self parseXMLDocument:contents];
}


/*" Determines the string encoding of the %xmlData, converts it into a string and calls #{parseDocument:}. The class of the returned object depends on the tag processor.

This method automatically loads the standard XML entity table if no entity table is set. "*/

- (id)parseXMLDocument:(NSData *)xmlData
{
    if(entityTable == nil)
        [self _loadXMLEntityTable];
    return [self parseDocument:[NSString stringWithData:xmlData MIMEEncoding:[NSString MIMEEncodingOfXMLDocument:xmlData]]];
}


/*" Parses the XML fragment (which has to be passed as a string) and returns an array of all top-level elements found in the string.

Note that when you are using the EDXMLDOMTagProcessor this method does #{not} return an #{EDXMLDocumentFragment} but an array of #{EDXMLNode}s. Please use #{appendChildrenFromString:} in #{EDXMLDocumentFragment} for convenient construction of DOM document fragments.

This method automatically loads the standard XML entity table if no entity table is set. "*/

- (NSArray *)parseXMLFragment:(NSString *)xmlString
{
    if(entityTable == nil)
        [self _loadXMLEntityTable];
    return [self parseString:xmlString];
}


//---------------------------------------------------------------------------------------
//	PUBLIC ENTRY INTO PARSER
//---------------------------------------------------------------------------------------

/*" Parses, or tries to parse, the document contained in %aString using #{parseString:}. Then creates a document object using #{documentForElements:} in the tag processor. Consequently, the class of the returned object depends on the tag processor. Please refer to the respective class documentation. "*/

- (id)parseDocument:(NSString *)aString
{
    return [self _parseString:aString createDocument:YES];
}


/*" Parses, or tries to parse, the text contained in %aString. During the process methods from the #EDTagProcessorProtocol are sent to the current tag processor. #{parseString:} returns an array of all top-level elements found in the string as created by the tag processor. Exceptions are raised when syntax errors or mismatched container tags are encountered. (If the tag processor raises an exception, the parser shuts down properly, and re-raises it.) "*/

- (NSArray *)parseString:(NSString *)aString
{
    return [self _parseString:aString createDocument:NO];
}


//---------------------------------------------------------------------------------------
//	MAIN PARSER 
//---------------------------------------------------------------------------------------

- (id)_parseString:(NSString *)aString createDocument:(BOOL)docFlag
{
    unsigned int 	length;
    id				result;
    NSException		*parserException;

    if([tagProcessor respondsToSelector:@selector(parserWillBeginParsing:)])
        [(id)tagProcessor parserWillBeginParsing:self];
    
    if(textCharset == NULL)
        [[self class] _initializeCharacterSets];
    
    length = [aString length];
    source = NSZoneMalloc([self zone], sizeof(unichar) * (length + 1));
    [aString getCharacters:source];
    *(source + length) = (unichar)0;
    charp = source;

    [namespaceStack addObject:[NSDictionary dictionaryWithObjectsAndKeys:[tagProcessor defaultNamespace], DEFAULTNSKEY, nil]];
    lexmode = EDMLPTextMode;
    result = nil; // keep compiler happy
    parserException = nil;

    NS_DURING

    [self _parserLoop];
    if([stack count] > 1)
        [NSException raise:EDMLParserException format:@"Unexpected end of source."];
    result = [[[[stack lastObject] value] retain] autorelease];
    if(docFlag)
        result = [tagProcessor documentForElements:result];

    NS_HANDLER
        parserException = [[localException retain] autorelease];
    NS_ENDHANDLER
    
    NSZoneFree([self zone], source);
    source = NULL;
    [stack removeAllObjects];
    [namespaceStack removeAllObjects];
    [peekedToken release];
    peekedToken = nil;

    if([tagProcessor respondsToSelector:@selector(parserDidFinishParsing:)])
        [(id)tagProcessor parserDidFinishParsing:self];

    if(parserException != nil)
        [parserException raise];

    return result;
}


- (void)_parserLoop
{
    EDMLToken	*token;

    while((token = [self _nextToken]) != nil)
        {
        [self _shift:token];
        while([self _reduce])
            {}
        }
}


//---------------------------------------------------------------------------------------
//	TOKENIZER (LEXER)
//---------------------------------------------------------------------------------------

static __inline__ unichar *nextchar(unichar *charp, BOOL raiseOnEnd)
{
    charp += 1;
    if((raiseOnEnd == YES) && (*charp == (unichar)0))
        [NSException raise:EDMLParserException format:@"Unexpected end of source."];
    return charp;
}


static NSString *readentity(unichar *charp, NSDictionary *entityTable, int *len)
{
    NSString 	*entity;
    unichar		*start, c;

    NSCAssert((*charp == '&'), @"readentity called with charp not pointing to an & char.");
    charp = nextchar(charp, YES);
    start = charp;
    while((*charp != ';') && ((charp - start) < EDML_MAX_ENTITY_LENGTH))
        charp = nextchar(charp, YES);

    if(*start == '#')
        { // convert using unicode char code
        if((*(start + 1) == 'x') || (*(start + 1) == 'X'))
            c = [[NSString stringWithCharacters:(start + 2) length:(charp - (start + 2))] intValueForHex];
        else
            c = [[NSString stringWithCharacters:(start + 1) length:(charp - (start + 1))] intValue];
        entity = (c > 0) ? [NSString stringWithCharacters:&c length:1] : nil;
        }
    else if(entityTable != nil)
        { // convert using entity table
        entity = [entityTable objectForKey:[NSString stringWithCharacters:start length:(charp - start)]];
        }
    else
        {
        entity = nil;
        }

    charp = nextchar(charp, NO);
    if(charp - start >= EDML_MAX_ENTITY_LENGTH)
        [NSException raise:EDMLParserException format:@"Found invalid entity '%@'", [NSString stringWithCharacters:(start - 1) length:(charp - start + 1)]];

    if(entity == nil)
        entity = [NSString stringWithCharacters:(start - 1) length:(charp - start + 1)];

    *len = (charp - start + 1);

    return entity;
}


static NSString *readquotedstring(unichar *charp, NSDictionary *entityTable, BOOL ignoreEntities, int *len)
{
    NSMutableString	*string;
    unichar			*start, *chunkstart, endchar;
    int				entitylen;

    endchar = *charp;
    charp = nextchar(charp, YES);
    start = chunkstart = charp;
    string = nil;
    while(*charp != endchar)
        {
        if((*charp == '&') && (ignoreEntities == NO))
            {
            if(string == nil)
                string = [NSMutableString stringWithCharacters:chunkstart length:(charp - chunkstart)];
            else
                [string appendString:[NSString stringWithCharacters:chunkstart length:(charp - chunkstart)]];
            [string appendString:readentity(charp, entityTable, &entitylen)];
            charp += entitylen;
            chunkstart = charp;
            }
        else
            {
            charp = nextchar(charp, YES);
            }
        }
    if(string == nil)
        string = (id)[NSString stringWithCharacters:start length:(charp - chunkstart)];
    else
        [string appendString:[NSString stringWithCharacters:chunkstart length:(charp - chunkstart)]];
    charp = nextchar(charp, NO);

    *len = (charp - start + 1);

    return string;
}


- (EDMLToken *)_nextToken
{
    EDMLToken	*token;
    id			tvalue;
    unichar		*start;
    int			len;

    if(peekedToken != nil)
        {
        token = peekedToken;
        peekedToken = nil;
        return [token autorelease];
        }

    if(*charp == (unichar)0)
        return nil;

    NSAssert((lexmode == EDMLPTextMode) || (lexmode == EDMLPSpaceMode) || (lexmode == EDMLPTagMode) || (lexmode == EDMLPProcInstrMode) || (lexmode == EDMLPCommentMode) || (lexmode == EDMLPCDATAMode) || (lexmode == EDMLPCommentBracketMode), @"Invalid lexicalizer mode");

    switch(lexmode)
        {
        case EDMLPTextMode:
            if(*charp == '<')
                {
                charp = nextchar(charp, YES);
                if(*charp == '!')
                    {
                    lexmode = EDMLPCommentMode;
                    return [self _nextToken];
                    }
                else if(*charp == '?')
                    {
                    lexmode = EDMLPProcInstrMode;
                    return [self _nextToken];
                    }
                token = [EDMLToken tokenWithType:EDMLPT_LT];
                lexmode = EDMLPTagMode;
                break; // we're done and we have to skip the following ifs...
                }
            else if(*charp == '>')
                {
                [NSException raise:EDMLParserException format:@"Syntax Error at pos. %d; found stray `>'.", (charp - source)];
                token = nil;  // keep compiler happy
                }
            else if(EDBitmapCharsetContainsCharacter(spaceCharset, *charp))
                {
                lexmode = EDMLPSpaceMode;
                return [self _nextToken];
                }
            else if((*charp == '&') && (ignoresEntities == NO))
                {
                tvalue = readentity(charp, entityTable, &len);
                charp += len;
                token = [EDMLToken tokenWithType:EDMLPT_STRING];
                [token setValue:tvalue];
                }
            else
                {
                start = charp;
                while(EDBitmapCharsetContainsCharacter(textCharset, *charp) || (ignoresEntities && (*charp == '&')))
                    charp = nextchar(charp, NO);
                if(start == charp) // not at end and neither a text nor a switch char
                    [NSException raise:EDMLParserException format:@"Found invalid character \\u%x at pos %d.", (int)*charp, (charp - source)];
                token = [EDMLToken tokenWithType:EDMLPT_STRING];
                [token setValue:[NSString stringWithCharacters:start length:(charp - start)]];
                }
            break;

        case EDMLPSpaceMode:
            start = charp;
            while(EDBitmapCharsetContainsCharacter(spaceCharset, *charp))
                charp = nextchar(charp, NO);
            NSAssert(charp != start, @"Entered space mode when not located at a sequence of spaces.");
            token = [EDMLToken tokenWithType:[tagProcessor spaceIsString] ? EDMLPT_STRING : EDMLPT_SPACE];
            if(preservesWhitespace == YES)
                [token setValue:[NSString stringWithCharacters:start length:(charp - start)]];
            else
                [token setValue:@" "];
            lexmode = EDMLPTextMode;
            break;

        case EDMLPTagMode:
            while(EDBitmapCharsetContainsCharacter(spaceCharset, *charp))
                charp = nextchar(charp, YES);
            if(*charp == '<')
                {
                [NSException raise:EDMLParserException format:@"Syntax Error at pos. %d; found `<' in a tag.", (charp - source)];
                token = nil;  // keep compiler happy
                }
            else if(*charp == '>')
                {
                charp = nextchar(charp, NO);
                token = [EDMLToken tokenWithType:EDMLPT_GT];
                lexmode = EDMLPTextMode;
                }
            else if(*charp == '/' && *(charp - 1) != '=') // this handles corrupt HTML as in <body background=/path/to/image.jpg>
                {
                charp = nextchar(charp, YES);
                token = [EDMLToken tokenWithType:EDMLPT_SLASH];
                }
            else if(*charp == '=')
                {
                charp = nextchar(charp, YES);
                token = [EDMLToken tokenWithType:EDMLPT_EQ];
                }
            else
                {
                if(*charp == '"')
                    {
                    tvalue = readquotedstring(charp, entityTable, ignoresEntities, &len);
                    charp += len;
                    }
                else if(*charp == '\'')
                    {
                    tvalue = readquotedstring(charp, entityTable, ignoresEntities, &len);
                    charp += len;
                    }
                else
                    {
                    start = charp;
                    while(EDBitmapCharsetContainsCharacter(attrStopCharset, *charp) == NO)
                        charp = nextchar(charp, YES);
                    if(charp == start)
                        [NSException raise:EDMLParserException format:@"Syntax error at pos. %d; expected either `>' or a tag attribute/value. (Note that tag attribute values must be quoted if they contain anything other than alphanumeric characters.)", (charp - source)];
                    if(*(charp - 1) == '/')
                        charp -= 1;
                    tvalue = [NSString stringWithCharacters:start length:(charp - start)];
                    }
                token = [EDMLToken tokenWithType:EDMLPT_TSTRING];
				if(convertsTagsToLowercase)
					tvalue = [tvalue lowercaseString];
                [token setValue:tvalue];
                }
            break;
        
        case EDMLPCommentMode:
            while(*charp != '>')
                {
                if(*charp == '[')
                {
                    lexmode = EDMLPCommentBracketMode;
                    return [self _nextToken];
                }
                charp = nextchar(charp, YES);
                }
            charp = nextchar(charp, NO);
            // ignore comment directives
            lexmode = EDMLPTextMode;
            return [self _nextToken];
          
        case EDMLPProcInstrMode:
            while(*charp != '>')
                charp = nextchar(charp, YES);
            charp = nextchar(charp, NO);
            // ignore processing directives
            lexmode = EDMLPTextMode;
            return [self _nextToken];
                
        case EDMLPCDATAMode:
            start = charp;
            while((*charp != '>') || (*(charp - 1) != ']') || (*(charp - 2) != ']'))
                charp = nextchar(charp, YES);
            token = [EDMLToken tokenWithType:EDMLPT_STRING];
            [token setValue:[NSString stringWithCharacters:start length:charp - start - 3]];
            charp = nextchar(charp, NO);
            lexmode = EDMLPTextMode;
            break;

        case EDMLPCommentBracketMode:
            start = charp;
            while(*charp != ']')
            {
                if(*charp == '[')
                {
                    // check for <![CDATA[ ... ]]>
                    if((charp == start + 6) && ([[NSString stringWithCharacters:start length:7] isEqualToString:@"[CDATA["]))
                    {
                        lexmode = EDMLPCDATAMode;
                        return [self _nextToken];
                    }
                }
                charp = nextchar(charp, YES);
            }

                
            charp = nextchar(charp, NO);
            // ignore special processing directives
            lexmode = EDMLPCommentMode;
            return [self _nextToken];

        default: // keep compiler happy
            token = nil;
            break;
        }

    return token;
}


- (EDMLToken *)_peekedToken
{
    if(peekedToken == nil)
        peekedToken = [[self _nextToken] retain];
    return peekedToken;
}


//---------------------------------------------------------------------------------------
//	SHIFT/REDUCE
//---------------------------------------------------------------------------------------

- (void)_shift:(EDMLToken *)token
{
    [stack addObject:token];
}


static __inline__ int match(NSArray *stack, int t0, int t1, int t2, int t3, int t4)
{
    int	ti[] = { t4, t3, t2, t1, t0, 0 };
    int	i, sp;

    sp = [stack count] - 1;
    for(i = 0; ti[i] > 0; i++)
        {
        if((sp < 0) || ([(EDMLToken *)[stack objectAtIndex:sp--] type] != ti[i]))
            break;
        }
    return (ti[i] > 0) ? 0 : i;
}

#define SVAL(IDX) [[stack objectAtIndex:sc - ((IDX) + 1)] value]


- (BOOL)_reduce
{
    EDMLToken 		*rToken;
    int			   	mc, sc;

	rToken = nil;
    sc = [stack count];

    // LIST, ELEMENT --> LIST : add an element to an existing list
    if((mc = match(stack, 0, 0, 0, EDMLPT_LIST, EDMLPT_ELEMENT)) > 0)
        {
        rToken = [[[stack objectAtIndex:sc - 2] retain] autorelease];
        [[rToken value] addObject:SVAL(0)];
        }
    // ELEMENT --> LIST : create a list from an element
    else if((mc = match(stack, 0, 0, 0, 0, EDMLPT_ELEMENT)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_LIST];
        [rToken setValue:[NSMutableArray arrayWithObject:SVAL(0)]];
        }

    // STAG, LIST, ETAG --> ELEMENT : create container element from start/end tags
    // and an element list inbetween
    else if((mc = match(stack, 0, 0, EDMLPT_STAG, EDMLPT_LIST, EDMLPT_ETAG)) > 0)
        {
        EDObjectPair	*qualifiedTagName;

        qualifiedTagName = [[SVAL(2) objectAtIndex:0] firstObject];  // attr-pair: first is name, second value
        if([qualifiedTagName isEqual:SVAL(0)] == NO)
            [self _reportClosingTagMismatch:SVAL(0)];
        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:[tagProcessor elementForTag:qualifiedTagName attributeList:[SVAL(2) subarrayFromIndex:1] containedElements:SVAL(1)]];

        }
    // STAG, ETAG --> ELEMENT : create container element from start/end tags
    // with no elements inbetween
    else if((mc = match(stack, 0, 0, 0, EDMLPT_STAG, EDMLPT_ETAG)) > 0)
        {
        EDObjectPair	*qualifiedTagName;

        qualifiedTagName = [[SVAL(1) objectAtIndex:0] firstObject];  // attr-pair: first is name, second value
        if([qualifiedTagName isEqual:SVAL(0)] == NO)
            [self _reportClosingTagMismatch:SVAL(0)];
        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:[tagProcessor elementForTag:qualifiedTagName attributeList:[SVAL(1) subarrayFromIndex:1] containedElements:nil]];
        }

    // LT, TATTRLIST, SLASH, GT --> ELEMENT : create an emty container element
    else if((mc = match(stack, 0, EDMLPT_LT, EDMLPT_TATTRLIST, EDMLPT_SLASH, EDMLPT_GT)) > 0)
        {
        EDObjectPair	*qualifiedTagName;
        NSArray			*attrList;
        EDMLElementType	type;

        [self _processNamespaceDefinitions:SVAL(2)];
        attrList = [self _normalizedAttributeList:SVAL(2)];
        qualifiedTagName = [[[[attrList objectAtIndex:0] firstObject] retain] autorelease];
        attrList = [attrList subarrayFromIndex:1];

        if((type = [tagProcessor typeOfElementForTag:qualifiedTagName attributeList:attrList]) == EDMLContainerElement)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
            [rToken setValue:[tagProcessor elementForTag:qualifiedTagName attributeList:attrList]];
            }
        else if(type == EDMLSingleElement)
            {
            [NSException raise:EDMLParserException format:@"%@ is not a container element.", qualifiedTagName];
            }
        else // (type == EDMLUnknownTag)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_STRING];
            [rToken setValue:[self _stringForTag:SVAL(2) type:EDMLPT_SLASH]];
            }
        }
    // LT, SLASH, TATTRLIST, GT --> ETAG : create an end tag from its constituents
    else if((mc = match(stack, 0, EDMLPT_LT, EDMLPT_SLASH, EDMLPT_TATTRLIST, EDMLPT_GT)) > 0)
        {
        EDObjectPair	*qualifiedTagName;
        EDMLElementType	type;

        if([SVAL(1) count] != 1)
            [NSException raise:EDMLParserException format:@"Syntax error; found end tag with attributes."];
        qualifiedTagName = [[[self _normalizedAttributeList:SVAL(1)] objectAtIndex:0] firstObject];
        [self _processNamespaceContextEndings:qualifiedTagName];

        if((type = [tagProcessor typeOfElementForTag:qualifiedTagName attributeList:nil]) == EDMLContainerElement)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_ETAG];
            [rToken setValue:qualifiedTagName];
            }
        else if(type == EDMLSingleElement)
            {
            [NSException raise:EDMLParserException format:@"%@ is not a container element.", qualifiedTagName];
            }
        else // (type == EDMLUnknownTag)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_STRING];
            [rToken setValue:[self _stringForTag:SVAL(1) type:EDMLPT_ETAG]];
            }
        }
    // LT, TATTRLIST, GT --> STAG : create a start tag or a "single" element from its constituents
    else if((mc = match(stack, 0, 0, EDMLPT_LT, EDMLPT_TATTRLIST, EDMLPT_GT)) > 0)
        {
        EDObjectPair	*qualifiedTagName;
        NSArray			*normalizedList, *attrList;
        EDMLElementType	type;

        [self _processNamespaceDefinitions:SVAL(1)];
        attrList = normalizedList = [self _normalizedAttributeList:SVAL(1)];
        qualifiedTagName = [[[[attrList objectAtIndex:0] firstObject] retain] autorelease];
        attrList = [attrList subarrayFromIndex:1];

        if((type = [tagProcessor typeOfElementForTag:qualifiedTagName attributeList:attrList]) == EDMLContainerElement)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_STAG];
            [rToken setValue:normalizedList];
            }
        else if(type == EDMLSingleElement)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
            [rToken setValue:[tagProcessor elementForTag:qualifiedTagName attributeList:attrList]];
            }
        else // (type == EDMLUnknownTag)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_STRING];
            [rToken setValue:[self _stringForTag:SVAL(1) type:EDMLPT_STAG]];
            }
        }

    // TATTRLIST, TATTR --> TATTRLIST : add a tag attribute to an existing list
    else if((mc = match(stack, 0, 0, 0, EDMLPT_TATTRLIST, EDMLPT_TATTR)) > 0)
        {
        rToken = [[[stack objectAtIndex:sc - 2] retain] autorelease];
        [[rToken value] addObject:SVAL(0)];
        }
    // TATTR --> TATTRLIST : create a list from a tag attribute
    else if((mc = match(stack, 0, 0, 0, 0, EDMLPT_TATTR)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_TATTRLIST];
        [rToken setValue:[NSMutableArray arrayWithObject:SVAL(0)]];
        }

    // TSTRING, EQ, TSTRING --> TATTR : create an attribute from its constituents
    else if((mc = match(stack, 0, 0, EDMLPT_TSTRING, EDMLPT_EQ, EDMLPT_TSTRING)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_TATTR];
        [rToken setValue:[EDObjectPair pairWithObjects:[SVAL(2) lowercaseString]:SVAL(0)]];
        }
    // TSTRING, (!EQ) --> TATTR : create an attribute without value from a tag string 
    // not followed by an equal sign
    else if(((mc = match(stack, 0, 0, 0, 0, EDMLPT_TSTRING)) > 0) &&
            ([[self _peekedToken] type] != EDMLPT_EQ))
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_TATTR];
        [rToken setValue:[EDObjectPair pairWithObjects:SVAL(0):nil]];
        }

    // STRING, STRING --> STRING : concatenate to strings
    else if((mc = match(stack, 0, 0, 0, EDMLPT_STRING, EDMLPT_STRING)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_STRING];
        [rToken setValue:[SVAL(1) stringByAppendingString:SVAL(0)]];
        }        
    // STRING, (!STRING) --> ELEMENT : create an object from a string not followed by
    // another string
    else if(((mc = match(stack, 0, 0, 0, 0, EDMLPT_STRING)) > 0) &&
            ([[self _peekedToken] type] != EDMLPT_STRING))
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:[tagProcessor objectForText:SVAL(0)]];
        }
    // SPACE --> ELEMENT : create an object from a space
    else if((mc = match(stack, 0, 0, 0, 0, EDMLPT_SPACE)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:[tagProcessor objectForSpace:SVAL(0)]];
        }
    else
        {
        return NO;
        }
        
    [stack removeObjectsInRange:NSMakeRange(sc - mc, mc)];
    if(rToken != nil)
        [stack addObject:rToken];
    
    return YES;
}


//---------------------------------------------------------------------------------------
//	PARSER HELPER METHODS
//---------------------------------------------------------------------------------------

- (void)_loadXMLEntityTable
{
    NSString 	 *path;
    NSDictionary *xmlEntities;
    NSBundle *bundle;

    bundle = [NSBundle bundleForClass:NSClassFromString(@"EDCommonFramework")];
    if((path = [bundle pathForResource:@"XMLEntities" ofType:@"plist"]) == nil)
        [NSException raise:NSGenericException format:@"Missing resource XMLEntities.plist in EDCommon.framework"];
    xmlEntities = [[NSString stringWithContentsOfFile:path] propertyList];
    [self setEntityTable:xmlEntities];
}


- (void)_reportClosingTagMismatch:(EDObjectPair *)tag
{
    NSEnumerator	*tokenEnum;
    EDMLToken		*token;

    tokenEnum = [stack reverseObjectEnumerator];
    while((token = [tokenEnum nextObject]) != nil)
        {
        if([token type] == EDMLPT_STAG)
            break;
        }

    if(token != nil)
    {
        EDObjectPair *missingTag;

        missingTag = [[[token value] objectAtIndex:0] firstObject];
        [NSException raise:EDMLParserException format:@"Syntax error; found </%@> without matching start tag. It looks like a </%@> is missing somewhere.", [self _qualifiedNameForTag:tag], [self _qualifiedNameForTag:missingTag]];
    }
    else
    {
        [NSException raise:EDMLParserException format:@"Syntax error; found <%@> without matching start tag.", [self _qualifiedNameForTag:tag]];
    }

}


- (void)_processNamespaceDefinitions:(NSArray *)attrList
{
    NSEnumerator		*attrEnum;
    EDObjectPair		*attr;
    NSMutableDictionary	*newNamespaceContext;
    NSRange				colonPos;
    NSString			*name, *prefix;

    newNamespaceContext = nil;
    attrEnum = [attrList objectEnumerator];
    while((attr = [attrEnum nextObject]) != nil)
        {
        name = [attr firstObject];
        if([name hasPrefix:@"xmlns:"] || [name isEqualToString:@"xmlns"])
            {
            colonPos = [name rangeOfCharacterFromSet:colonNSCharset];
            prefix = (colonPos.length > 0) ? [name substringFromIndex:NSMaxRange(colonPos)] : DEFAULTNSKEY;
            if(newNamespaceContext == nil)
                newNamespaceContext = [[[namespaceStack lastObject] mutableCopy] autorelease];
            [newNamespaceContext setObject:[attr secondObject] forKey:prefix];
            }
        }

    if(newNamespaceContext != nil)
        {
        // first add the new context
        [namespaceStack addObject:newNamespaceContext];
        // an now use it to normalise our tag name
        [newNamespaceContext setObject:[self _normalizedAttributeName:[[attrList objectAtIndex:0] firstObject] withDefaultNamespace:[newNamespaceContext objectForKey:DEFAULTNSKEY]] forKey:TAGKEY];
        }
}


- (void)_processNamespaceContextEndings:(EDObjectPair *)tagName
{
    if([tagName isEqual:[[namespaceStack lastObject] objectForKey:TAGKEY]])
        [namespaceStack removeLastObject];
}


- (NSArray *)_normalizedAttributeList:(NSArray *)pAttrList
{
    NSMutableArray	*nAttrList;
    NSEnumerator	*attrEnum;
    NSString		*namespace;
    EDObjectPair	*attr, *name;

    nAttrList = [NSMutableArray arrayWithCapacity:[pAttrList count]];
    namespace = [[namespaceStack lastObject] objectForKey:DEFAULTNSKEY];
    attrEnum = [pAttrList objectEnumerator];
    while((attr = [attrEnum nextObject]) != nil)
        {
        name = [self _normalizedAttributeName:[attr firstObject] withDefaultNamespace:namespace];
        [nAttrList addObject:[EDObjectPair pairWithObjects:name:[attr secondObject]]];
        // default namespace for (next) attribute is namespace of element!
        namespace = [[[nAttrList objectAtIndex:0] firstObject] firstObject];
        }
    return nAttrList;
}


- (EDObjectPair *)_normalizedAttributeName:(NSString *)name withDefaultNamespace:(NSString *)namespace
{
    NSString	*prefix;
    NSRange		colonPos;
    
    if((colonPos = [name rangeOfCharacterFromSet:colonNSCharset]).length > 0)
        {
        prefix = [name substringToIndex:colonPos.location];
        if(((namespace = [[namespaceStack lastObject] objectForKey:prefix]) == nil) && ([prefix isEqualToString:@"xmlns"] == NO))
            [NSException raise:EDMLParserException format:@"Syntax error; found undefined namespace prefix `%@'", prefix];
        // name = [name substringFromIndex:NSMaxRange(colonPos)];
        }
    else
        {
        if([name isEqualToString:@"xmlns"])
            namespace = nil;
        }
    return [EDObjectPair pairWithObjects:namespace:name];
}


- (NSString *)_qualifiedNameForTag:(EDObjectPair *)tag
{
    NSDictionary *namespaces;
    NSEnumerator *nsEnum;
    NSString 	 *prefix;

    namespaces = [namespaceStack lastObject];

    if([[namespaces objectForKey:DEFAULTNSKEY] isEqualToString:[tag firstObject]])
        return [tag firstObject];
    
    nsEnum = [namespaces keyEnumerator];
    while((prefix = [nsEnum nextObject]) != nil)
        {
        if(([prefix isEqualToString:DEFAULTNSKEY] == NO) && ([prefix isEqualToString:TAGKEY] == NO))
            if([[namespaces objectForKey:prefix] isEqualToString:[tag firstObject]])
                break;
        }

    if(prefix == nil)
        prefix = @"(invalid namespace)";

    return [NSString stringWithFormat:@"%@:%@", prefix, [tag secondObject]];
}


- (NSString *)_stringForTag:(NSArray *)attrList type:(int)type
{
    NSMutableString	*buffer;
    NSEnumerator	*attrEnum;
    EDObjectPair	*attr;
    id				value;

    buffer = [NSMutableString stringWithString:@"<"];
    if(type == EDMLPT_ETAG)
        [buffer appendString:@"/"];
    attrEnum = [attrList objectEnumerator];
    [buffer appendString:[[attrEnum nextObject] firstObject]];
    while((attr = [attrEnum nextObject]) != nil)
        {
        [buffer appendString:@" "];
        [buffer appendString:[attr firstObject]];
        if((value = [attr secondObject]) != nil)
            {
            [buffer appendString:@"=\""];
            [buffer appendString:value];
            [buffer appendString:@"\""];
            }
        }
    if(type == EDMLPT_SLASH)
        [buffer appendString:@"/"];
    [buffer appendString:@">"];

    return buffer;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


