//
//  $Id: OPSSLSocket.h,v 1.6 2003/03/26 23:15:16 westheide Exp $
//  OPMessageServices
//
//  Created by joerg on Mon Sep 17 2001.
//  Copyright (c) 2001 Jšrg Westheide. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <EDCommon/EDTCPSocket.h>
#import <Security/Security.h>

/*"Theses constants are the keys for the userinfo dictionary of the OPSSLExceptions."*/
#define OPEErrorCode       @"OPEErrorCode"
#define OPEFailedCall      @"OPEFailedCall"
#define OPECallingMethod   @"OPECallingMethod"
#define OPECallingObject   @"OPECallingObject"

@interface OPSSLSocket : EDTCPSocket
    {
    @private
    BOOL          _encrypted;         /*"These variables are private (and therefore not documented)."*/
    SSLContextRef _context;           /*""*/
    }

/*"Protcol and cipher names"*/
+ (NSString*) cipherToString:(SSLCipherSuite)cipher;
+ (NSString*) protocolToString:(SSLProtocol)protocol;

/*"Init methods"*/
- (OPSSLSocket*) init;
- (OPSSLSocket*) initAsServer;
- (OPSSLSocket*) initWithFileHandle:(NSFileHandle *)aFileHandle;
- (OPSSLSocket*) initAsServerWithFileHandle:(NSFileHandle *)aFileHandle;

/*"Reading data"*/
- (NSData*) availableData;

//- (NSData*) readDataToEndOfFile;
- (NSData*) readDataOfLength:(size_t)length;

/*"Writing data"*/
- (void) writeData:(NSData*)data;
/*
- (unsigned long long) offsetInFile;
- (unsigned long long) seekToEndOfFile;
- (void) seekToFileOffset:(unsigned long long)offset;

- (void) truncateFileAtOffset:(unsigned long long)offset;
- (void) synchronizeFile;
*/

/*"Maintaining connection"*/
- (void) closeFile;

/*"Maintaining encryption"*/
- (void) negotiateEncryption;
- (void) shutdownEncryption;
- (BOOL) isEncrypted;
- (BOOL) isNotEncrypted;

/*"Certificate verification parameters"*/
- (BOOL) allowsAnyRootCertificate;
- (void) setAllowsAnyRootCertificate:(BOOL)allowed;
- (BOOL) allowsExpiredCertificates;
- (void) setAllowsExpiredCertificates:(BOOL)allowed;

/*"Inquireing session parameters"*/
- (SSLProtocol)    negotiatedProtocol;
- (SSLCipherSuite) negotiatedCipher;

@end
