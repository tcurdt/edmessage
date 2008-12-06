//---------------------------------------------------------------------------------------
//  NSString+printf.m created by erik on Sat 27-Sep-1997
//  @(#)$Id: NSString+Extensions.m,v 2.1 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 1997-2000,2008 by Erik Doernenburg. All rights reserved.
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

#import "NSString+Extensions.h"
#import "EDObjectPair.h"


@interface NSString(EDExtensionsPrivateAPI)
+ (NSDictionary *)_contentTypeExtensionMapping;
@end



//=======================================================================================
    @implementation NSString(EDExtensions)
//=======================================================================================

/*" Various common extensions to #NSString. "*/

NSString *MIMEAsciiStringEncoding = @"us-ascii";
NSString *MIMELatin1StringEncoding = @"iso-8859-1";
NSString *MIMELatin2StringEncoding = @"iso-8859-2";
NSString *MIME2022JPStringEncoding = @"iso-2022";
NSString *MIMEUTF8StringEncoding = @"utf-8";

NSString *MIMEApplicationContentType = @"application";
NSString *MIMEImageContentType		 = @"image";
NSString *MIMEAudioContentType		 = @"audio";
NSString *MIMEMessageContentType 	 = @"message";
NSString *MIMEMultipartContentType 	 = @"multipart";
NSString *MIMETextContentType 		 = @"text";
NSString *MIMEVideoContentType       = @"video";

NSString *MIMEAlternativeMPSubtype 	 = @"alternative";
NSString *MIMEMixedMPSubtype 		 = @"mixed";
NSString *MIMEParallelMPSubtype 	 = @"parallel";
NSString *MIMEDigestMPSubtype 		 = @"digest";
NSString *MIMERelatedMPSubtype 		 = @"related";

NSString *MIMEInlineContentDisposition = @"inline";
NSString *MIMEAttachmentContentDisposition = @"attachment";


static NSFileHandle *stdoutFileHandle = nil;
static NSLock *printfLock = nil;
static NSCharacterSet *iwsSet = nil;


//---------------------------------------------------------------------------------------
//	CONVENIENCE CONSTRUCTORS
//---------------------------------------------------------------------------------------

/*" Convenience factory method. "*/

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
}


//---------------------------------------------------------------------------------------
//	VARIOUS EXTENSIONS
//---------------------------------------------------------------------------------------

/*" Returns a copy of the receiver with all whitespace left of the first non-whitespace character and right of the last whitespace character removed. "*/

- (NSString *)stringByRemovingSurroundingWhitespace
{
    NSRange		start, end, result;

    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    start = [self rangeOfCharacterFromSet:iwsSet];
    if(start.length == 0)
        return @""; // string is empty or consists of whitespace only

    end = [self rangeOfCharacterFromSet:iwsSet options:NSBackwardsSearch];
    if((start.location == 0) && (end.location == [self length] - 1))
        return self;

    result = NSMakeRange(start.location, end.location + end.length - start.location);

    return [self substringWithRange:result];	
}


/*" Returns YES if the receiver consists of whitespace only. "*/

- (BOOL)isWhitespace
{
    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    return ([self rangeOfCharacterFromSet:iwsSet].length == 0);

}


/*" Returns a copy of the receiver with all whitespace removed. "*/

- (NSString *)stringByRemovingWhitespace
{
    return [self stringByRemovingCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]];
}


/*" Returns a copy of the receiver with all characters from %set removed. "*/

- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set
{
    NSMutableString	*temp;

    if([self rangeOfCharacterFromSet:set options:NSLiteralSearch].length == 0)
        return self;
    temp = [[self mutableCopyWithZone:[self zone]] autorelease];
    [temp removeCharactersInSet:set];

    return temp;
}


/*" Returns a string that is not wider than %maxWidths pixels. "*/

- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forFont:(NSFont *)font
{
    return [self stringByAbbreviatingPathToWidth:maxWidth forAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
}

/*" Returns a string that is not wider than %maxWidths pixels. "*/

- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forAttributes:(NSDictionary *)attributes
{
    NSString		*result;
    NSMutableArray	*components;
    int 			i;

    if([self sizeWithAttributes:attributes].width <= maxWidth)
        return self;

    result = [self stringByAbbreviatingWithTildeInPath];
    if([result sizeWithAttributes:attributes].width <= maxWidth)
        return result;

    components = [[[result pathComponents] mutableCopy] autorelease];
    if([[components objectAtIndex:0] isEqualToString:@"/"])
        [components removeObjectAtIndex:0];
    if([components count] < 2)
        return nil;
    [components replaceObjectAtIndex:0 withObject:@"..."];

    for(i = 1; i < [components count] - 1; i++)
        {
        [components removeObjectAtIndex:i];
        result = [NSString pathWithComponents:components];
        if([result sizeWithAttributes:attributes].width <= maxWidth)
            return result;
        }

    return nil;
}


/*" Returns YES if the receiver's prefix is equal to %string, comparing case insensitive. "*/

- (BOOL)hasPrefixCaseInsensitive:(NSString *)string
{
    return (([string length] <= [self length]) && ([self compare:string options:(NSCaseInsensitiveSearch|NSAnchoredSearch) range:NSMakeRange(0, [string length])] == NSOrderedSame));
}


/*" Returns YES if the receiver is equal to string "yes", comparing case insensitive. "*/

- (BOOL)boolValue
{
    if([self intValue] > 0)
        return YES;
    return [self caseInsensitiveCompare:@"yes"] == NSOrderedSame;
}


/*" Assumes the string contains an integer written in hexadecimal notation and returns its value. Uses #scanHexInt in #NSScanner. "*/

- (unsigned int)intValueForHex
{
    unsigned int	value;

    if([[NSScanner scannerWithString:self] scanHexInt:&value] == NO)
        return 0;
    return value;
}


/*" Returns yes if the string contains no text characters. Note that its length can still be non-zero. "*/

- (BOOL)isEmpty
{
  return [self isEqualToString:@""];
}


//---------------------------------------------------------------------------------------
//	FACTORY METHODS
//---------------------------------------------------------------------------------------

/*" Creates and returns a string by converting the bytes in data using the string encoding described by %charsetName. If no NSStringEncoding corresponds to %charsetName this method returns !{nil}. "*/

+ (NSString *)stringWithData:(NSData *)data MIMEEncoding:(NSString *)charsetName
{
    return [[[NSString alloc] initWithData:data MIMEEncoding:charsetName] autorelease];
}


/*" Creates and returns a string by copying %length characters from %buffer and coverting these into a string using the string encoding described by %charsetName. If no NSStringEncoding corresponds to %charsetName this method returns !{nil}. "*/

+ (NSString *)stringWithBytes:(const void *)buffer length:(unsigned int)length MIMEEncoding:(NSString *)charsetName
{
    return [[[NSString alloc] initWithData:[NSData dataWithBytes:buffer length:length] MIMEEncoding:charsetName] autorelease];
}


//---------------------------------------------------------------------------------------
//	Converting to/from byte representations
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated string by converting the bytes in buffer using the string encoding described by %charsetName. If no NSStringEncoding corresponds to %charsetName this method returns !{nil}. "*/

- (id)initWithData:(NSData *)buffer MIMEEncoding:(NSString *)charsetName
{
    NSStringEncoding encoding;

    if((encoding = [NSString stringEncodingForMIMEEncoding:charsetName]) == 0)
        return nil; // Behaviour has changed (2001/08/03).
    return [self initWithData:buffer encoding:encoding];
}


/*" Returns an NSData object containing a representation of the receiver in the encoding described by %charsetName. If no NSStringEncoding corresponds to %charsetName this method returns !{nil}. "*/

- (NSData *)dataUsingMIMEEncoding:(NSString *)charsetName
{
    NSStringEncoding encoding;

    if((encoding = [NSString stringEncodingForMIMEEncoding:charsetName]) == 0)
        return nil;
    return [self dataUsingEncoding:encoding];
}


//---------------------------------------------------------------------------------------
//	NSStringEncoding vs. MIME Encoding
//---------------------------------------------------------------------------------------

+ (NSStringEncoding)stringEncodingForMIMEEncoding:(NSString *)charsetName
{
    CFStringEncoding cfEncoding;

    if(charsetName == nil)
        return 0;

    charsetName = [charsetName lowercaseString];
    cfEncoding = CFStringConvertIANACharSetNameToEncoding((CFStringRef)charsetName);
    if(cfEncoding == kCFStringEncodingInvalidId)
        return 0;
    return CFStringConvertEncodingToNSStringEncoding(cfEncoding);
}


+ (NSString *)MIMEEncodingForStringEncoding:(NSStringEncoding)nsEncoding
{
    CFStringEncoding cfEncoding;

    cfEncoding = CFStringConvertNSStringEncodingToEncoding(nsEncoding);
    return (NSString *)CFStringConvertEncodingToIANACharSetName(cfEncoding);
}


- (NSString *)recommendedMIMEEncoding
{
    static NSStringEncoding preferredEncodings[] = {
        NSASCIIStringEncoding, NSISOLatin1StringEncoding, NSISOLatin2StringEncoding,
        // no constants available for ISO8859-3 through ISO8859-15
        2147484163U, 2147484164U, 2147484165U, 2147484166U, 2147484167U,
        2147484168U, 2147484169U, 2147484170U, 2147484171U, 2147484173U,
        2147484174U, 2147484175U, 0 };
    NSStringEncoding *encodingPtr;

    for(encodingPtr = preferredEncodings; *encodingPtr != 0; encodingPtr++)
        {
        if([self canBeConvertedToEncoding:*encodingPtr])
            return [NSString MIMEEncodingForStringEncoding:*encodingPtr];
        }

    return [NSString MIMEEncodingForStringEncoding:[self smallestEncoding]];
}


//---------------------------------------------------------------------------------------
//	TYPE / FILENAME EXTENSION MAPPING
//---------------------------------------------------------------------------------------

static NSMutableDictionary *teTable = nil;


+ (NSDictionary *)_contentTypeExtensionMapping
{
    NSString *path;

    if(teTable == nil)
        {
        path = [[NSBundle bundleForClass:NSClassFromString(@"EDCommonFramework")] pathForResource:@"MIME" ofType:@"plist"];
        teTable = [[[NSString stringWithContentsOfFile:path] propertyList] retain];
        NSAssert([teTable isKindOfClass:[NSDictionary class]], @"Problem with MIME.plist");
        }
    return teTable;
}


/*" Adds a mapping between a MIME content type/subtype and a file extension to the internal table; the MIME type/subtype being the first object and the file extension the second object in the pair. Note that one MIME type might be represented by several file extensions but a file extension must always map to exactly one MIME type; for example "image/jpeg" maps to "jpg" and "jpeg." A fairly extensive table is available by default. "*/

+ (void)addContentTypePathExtensionPair:(EDObjectPair *)tePair
{
    [self _contentTypeExtensionMapping];
    if([teTable isKindOfClass:[NSMutableDictionary class]] == NO)
        {
        [teTable autorelease];
        teTable = [[NSMutableDictionary alloc] initWithDictionary:teTable];
        }
    [teTable setObject:[tePair secondObject] forKey:[tePair firstObject]];
}


/*" Returns a file extension that is used for files of the MIME content type/subtype. Note that one MIME type might be represented by several file extensions. "*/

+ (NSString *)pathExtensionForContentType:(NSString *)contentType
{
    NSDictionary   	*table;
    NSEnumerator	*extensionEnum;
    NSString		*extension;

    contentType = [contentType lowercaseString];
    table = [self _contentTypeExtensionMapping];
    extensionEnum = [table keyEnumerator];
    while((extension = [extensionEnum nextObject]) != nil)
        {
        if([[table objectForKey:extension] isEqualToString:contentType])
            break;
        }
    return extension;
}


/*" Returns the MIME content type/subtype for extension "*/

+ (NSString *)contentTypeForPathExtension:(NSString *)extension
{
    return [[self _contentTypeExtensionMapping] objectForKey:[extension lowercaseString]];
}


//---------------------------------------------------------------------------------------
//	XML DOCUMENT ENCODING
//---------------------------------------------------------------------------------------

/*" Examines %xmlData and searches for an XML processing directive that specifies the document's encoding. If found returns the encoding, specified as a MIME character set, otherwise returns !{nil}. "*/

+ (NSString *)MIMEEncodingOfXMLDocument:(NSData *)xmlData
{
    NSScanner			*scanner;
    NSString			*pd, *encoding;
    NSRange				pdRange;
    const char 			*p, *pmax, *pdStart;
    short				inQuotes;

    p = [xmlData bytes];
    pmax = p + [xmlData length];

    // skip initial whitespace, return *nil* if document is completely empty
    while((p < pmax) && (isspace(*p)))
        p += 1;
    if(p == pmax)
        return nil;

    // grab processing directive
    if((p + 6 >= pmax) || (*p != '<') || (*p == '?'))
        [NSException raise:NSGenericException format:@"Could not find processing directive in XML doc."];
    pdStart = p + 2;
    inQuotes = 0;
    for(p = pdStart;p < pmax; p++)
        {
        if(*p == '"')
            inQuotes ^= 1;
        else if((*p == '>') && (inQuotes == 0))
            break;
        }
    if((p == pmax) || (*(p - 1) != '?'))
        [NSException raise:NSGenericException format:@"Malformed processing directive in XML doc."];
    pdRange = NSMakeRange((NSUInteger)pdStart - (NSUInteger)[xmlData bytes], (NSUInteger)p - 1 - (NSUInteger)pdStart);
    pd = [NSString stringWithData:[xmlData subdataWithRange:pdRange] encoding:NSASCIIStringEncoding];

    // analyse and find encoding value
    scanner = [NSScanner scannerWithString:pd];
    if([scanner scanString:@"xml" intoString:NULL] == NO)
        [NSException raise:NSGenericException format:@"Could not find processing directive in XML doc."];
    if([scanner scanUpToString:@"encoding" intoString:NULL] == NO || [scanner isAtEnd])
        {
        encoding = MIMEUTF8StringEncoding;
        }
    else
        {
        [scanner scanString:@"encoding" intoString:NULL];
        if(([scanner scanString:@"=" intoString:NULL] == NO) ||
           ([scanner scanString:@"\"" intoString:NULL] == NO) ||
           ([scanner scanUpToString:@"\"" intoString:&encoding] == NO))
            [NSException raise:NSGenericException format:@"Malformed processing directive in XML doc."];
        }
    return encoding;
}


/*" Examines %xmlData and searches for an XML processing directive that specifies the document's encoding. If found returns the encoding, specified as an NSStringEncoding, otherwise returns 0. "*/

+ (NSStringEncoding)encodingOfXMLDocument:(NSData *)xmlData
{
    return [self stringEncodingForMIMEEncoding:[self MIMEEncodingOfXMLDocument:xmlData]];
}


//---------------------------------------------------------------------------------------
//	CRYPTING
//---------------------------------------------------------------------------------------

/*" Returns an encrypted version of the receiver using a random "salt."

This method is thread-safe. "*/

- (NSString *)encryptedString
{
    char 	salt[3];

    salt[0] = 'A' + random() % 26;
    salt[1] = 'A' + random() % 26;
    salt[2] = '\0';

    return [self encryptedStringWithSalt:salt];
}


/*" Returns an encrypted version of the receiver using %salt as randomizer. %Salt must be a C String containing excatly two characters.

This method is thread-safe. "*/

- (NSString *)encryptedStringWithSalt:(const char *)salt
{
    static NSLock	*encryptLock = nil;
    NSMutableData 	*sdata;
    char 			*encryptedCString;
    NSString 		*encryptedString;
    char 			terminator = '\0';

    NSParameterAssert((salt != NULL) && (strlen(salt) == 2));

    if(encryptLock == nil)
        encryptLock = [[NSLock alloc] init]; // intentional leak

    sdata = [[self dataUsingEncoding:NSNonLossyASCIIStringEncoding] mutableCopy];
    [sdata appendBytes:&terminator length:1];

    [encryptLock lock];
    encryptedCString = crypt((const char *)[sdata bytes], (const char *)salt);
    encryptedString = [[[NSString allocWithZone:[self zone]] initWithCString:encryptedCString] autorelease];
    [encryptLock unlock];

    [sdata release];
    
    return encryptedString;
}


/*" Returns YES if the receiver is a encryption of %aString. Assume you have the encrypted password in !{pwd} and the user's input in !{input}. Call !{[pwd isValidEncryptionOfString:input]} to verify the passwrd.

This method is thread-safe. "*/

- (BOOL)isValidEncryptionOfString:(NSString *)aString
{
	char salt[3];

	[self getCString:salt maxLength:2 encoding:NSASCIIStringEncoding];
	salt[2] = '\0';
	return [self isEqualToString:[aString encryptedStringWithSalt:salt]];
}


//---------------------------------------------------------------------------------------
//	SHARING STRING INSTANCES
//---------------------------------------------------------------------------------------

/*" Maintains a global pool of string instances. Returns the instance stored in the pool or adds the receiver if no such string was in the pool before. This can be used to allow for equality tests using #{==} instead of #{isEqual:} but this "leaks" all string instances that are ever shared and, hence, should be used with caution. "*/

- (NSString *)sharedInstance
{
    static NSMutableSet *stringPool;
    NSString *sharedInstance;

    if(stringPool == nil)
        stringPool = [[NSMutableSet alloc] init];

    if((sharedInstance = [stringPool member:self]) != nil)
        return sharedInstance;
    [stringPool addObject:self];
    return self;
}


//---------------------------------------------------------------------------------------
//	PRINTING
//---------------------------------------------------------------------------------------

/*" Writes the %printf format string to %stdout using the default C String encoding. "*/

+ (void)printf:(NSString *)format, ...
{
    va_list   	args;
    NSString	*buffer;

    va_start(args, format);
    buffer = [[NSString alloc] initWithFormat:format arguments:args];
    [buffer printf];
    [buffer release];
    va_end(args);
}


/*" Writes the %printf format string to %fileHandle using the default C String encoding. "*/

+ (void)fprintf:(NSFileHandle *)fileHandle:(NSString *)format, ...
{
    va_list   	args;
    NSString	*buffer;

    va_start(args, format);
    buffer = [[NSString alloc] initWithFormat:format arguments:args];
    [buffer fprintf:fileHandle];
    [buffer release];
    va_end(args);
}


/*" Writes the contents of the reciever to %stdout using the default C String encoding. "*/

- (void)printf
{
    if(printfLock == nil)
        printfLock = [[NSLock alloc] init];

    [printfLock lock];
    if(stdoutFileHandle == nil)
        stdoutFileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];
    [stdoutFileHandle writeData:[self dataUsingEncoding:[NSString defaultCStringEncoding]]];
    [printfLock unlock];
}


/*" Writes the contents of the reciever to %fileHandle using the default C String encoding. "*/

- (void)fprintf:(NSFileHandle *)fileHandle
{
    if(printfLock == nil)
        printfLock = [[NSLock alloc] init];

    [printfLock lock];
    [fileHandle writeData:[self dataUsingEncoding:[NSString defaultCStringEncoding]]];
    [printfLock unlock];
}


//=======================================================================================
    @end
//=======================================================================================


//=======================================================================================
    @implementation NSMutableString(EDExtensions)
//=======================================================================================

/*" Various common extensions to #NSMutableString. "*/

/*" Removes all whitespace left of the first non-whitespace character and right of the last whitespace character. "*/

- (void)removeSurroundingWhitespace
{
    NSRange		start, end;

    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    start = [self rangeOfCharacterFromSet:iwsSet];
    if(start.length == 0)
        {
        [self setString:@""];  // string is empty or consists of whitespace only
        return;
        }

    if(start.location > 0)
        [self deleteCharactersInRange:NSMakeRange(0, start.location)];
    
    end = [self rangeOfCharacterFromSet:iwsSet options:NSBackwardsSearch];
    if(end.location < [self length] - 1)
        [self deleteCharactersInRange:NSMakeRange(NSMaxRange(end), [self length] - NSMaxRange(end))];
}


/*" Removes all whitespace from the string. "*/

- (void)removeWhitespace
{
    [self removeCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


/*" Removes all characters in %set from the string. "*/

- (void)removeCharactersInSet:(NSCharacterSet *)set
{
    NSRange			matchRange, searchRange, replaceRange;
    unsigned int    length;

    length = [self length];
    matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:NSMakeRange(0, length)];
    while(matchRange.length > 0)
        {
        replaceRange = matchRange;
        searchRange.location = NSMaxRange(replaceRange);
        searchRange.length = length - searchRange.location;
        for(;;)
            {
            matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:searchRange];
            if((matchRange.length == 0) || (matchRange.location != searchRange.location))
                break;
            replaceRange.length += matchRange.length;
            searchRange.length -= matchRange.length;
            searchRange.location += matchRange.length;
            }
        [self deleteCharactersInRange:replaceRange];
        matchRange.location -= replaceRange.length;
        length -= replaceRange.length;
        }
}


//=======================================================================================
    @end
//=======================================================================================

