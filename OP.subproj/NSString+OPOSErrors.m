//
//  $Id: NSString+OPOSErrors.m,v 1.2 2003/01/18 21:22:24 westheide Exp $
//  OPMessageServices
//
//  Created by Jörg Westheide on Mon Jan 13 2003.
//  Copyright (c) 2003 objectpark.org. All rights reserved.
//

#import "NSString+OPOSErrors.h"
#import <Security/Security.h>


@implementation NSString (OPOSErrors)

/*"This method converts the error numbers to an error message."*/
+ (NSString*) stringForErrorCode:(OSStatus)error
    {
    // if it's a CSSM error code...
    if ((unsigned int)(error & 0xFFFF0000) == (unsigned int)CSSM_BASE_ERROR)
        {
        NSString *module, *errStr;
        
        switch ((CSSM_ERRBASE(error) & 0xFFFF) >> 11)
            {
            case 0:  module = @"CSSM Base (CSSM)";
                     break;
            case 1:  module = @"Cryptographic Services (CSP)";
                     break;
            case 2:  module = @"Data Store (DL)";
                     break;
            case 3:  module = @"Certificate Library (CL)";
                     break;
            case 4:  module = @"Trust Policy (TP)";
                     break;
            case 5:  module = @"Key Recovery (KR)";
                     break;
            case 6:  module = @"Access Control (AC)";
                     break;
            default: module = @"unknown";
            }
            
        switch (CSSM_ERRCODE(error))
            {
            case CSSM_ERRCODE_INTERNAL_ERROR:                 errStr = @"INTERNAL_ERROR";                   break;
            case CSSM_ERRCODE_MEMORY_ERROR:                   errStr = @"MEMORY_ERROR";                     break;
            case CSSM_ERRCODE_MDS_ERROR:                      errStr = @"MDS_ERROR";                        break;
            case CSSM_ERRCODE_INVALID_POINTER:                errStr = @"INVALID_POINTER";                  break;
            case CSSM_ERRCODE_INVALID_INPUT_POINTER:          errStr = @"INVALID_INPUT_POINTER";            break;
            case CSSM_ERRCODE_INVALID_OUTPUT_POINTER:         errStr = @"INVALID_OUTPUT_POINTER";           break;
            case CSSM_ERRCODE_FUNCTION_NOT_IMPLEMENTED:       errStr = @"FUNCTION_NOT_IMPLEMENTED";         break;
            case CSSM_ERRCODE_SELF_CHECK_FAILED:              errStr = @"SELF_CHECK_FAILED";                break;
            case CSSM_ERRCODE_OS_ACCESS_DENIED:               errStr = @"OS_ACCESS_DENIED";                 break;
            case CSSM_ERRCODE_FUNCTION_FAILED:                errStr = @"FUNCTION_FAILED";                  break;
            case CSSM_ERRCODE_MODULE_MANIFEST_VERIFY_FAILED:  errStr = @"MODULE_MANIFEST_VERIFY_FAILED";    break;
            case CSSM_ERRCODE_INVALID_GUID:                   errStr = @"INVALID_GUID";                     break;
                                                              
            /* Common Error Codes for ACLs */                             
            case CSSM_ERRCODE_OPERATION_AUTH_DENIED:          errStr = @"OPERATION_AUTH_DENIED";            break;
            case CSSM_ERRCODE_OBJECT_USE_AUTH_DENIED:         errStr = @"OBJECT_USE_AUTH_DENIED";           break;
            case CSSM_ERRCODE_OBJECT_MANIP_AUTH_DENIED:       errStr = @"MANIP_AUTH_DENIED";                break;
            case CSSM_ERRCODE_OBJECT_ACL_NOT_SUPPORTED:       errStr = @"OBJECT_ACL_NOT_SUPPORTED";         break;
            case CSSM_ERRCODE_OBJECT_ACL_REQUIRED:            errStr = @"OBJECT_ACL_REQUIRED";              break;
            case CSSM_ERRCODE_INVALID_ACCESS_CREDENTIALS:     errStr = @"INVALID_ACCESS_CREDENTIALS";       break;
            case CSSM_ERRCODE_INVALID_ACL_BASE_CERTS:         errStr = @"INVALID_ACL_BASE_CERTS";           break;
            case CSSM_ERRCODE_ACL_BASE_CERTS_NOT_SUPPORTED:   errStr = @"ACL_BASE_CERTS_NOT_SUPPORTED";     break;
            case CSSM_ERRCODE_INVALID_SAMPLE_VALUE:           errStr = @"INVALID_SAMPLE_VALUE";             break;
            case CSSM_ERRCODE_SAMPLE_VALUE_NOT_SUPPORTED:     errStr = @"SAMPLE_VALUE_NOT_SUPPORTED";       break;
            case CSSM_ERRCODE_INVALID_ACL_SUBJECT_VALUE:      errStr = @"INVALID_ACL_SUBJECT_VALUE";        break;
            case CSSM_ERRCODE_ACL_SUBJECT_TYPE_NOT_SUPPORTED: errStr = @"ACL_SUBJECT_TYPE_NOT_SUPPORTED";   break;
            case CSSM_ERRCODE_INVALID_ACL_CHALLENGE_CALLBACK: errStr = @"INVALID_ACL_CHALLENGE_CALLBACK";   break;
            case CSSM_ERRCODE_ACL_CHALLENGE_CALLBACK_FAILED:  errStr = @"ACL_CHALLENGE_CALLBACK_FAILED";    break;
            case CSSM_ERRCODE_INVALID_ACL_ENTRY_TAG:          errStr = @"INVALID_ACL_ENTRY_TAG";            break;
            case CSSM_ERRCODE_ACL_ENTRY_TAG_NOT_FOUND:        errStr = @"ACL_ENTRY_TAG_NOT_FOUND";          break;
            case CSSM_ERRCODE_INVALID_ACL_EDIT_MODE:          errStr = @"INVALID_ACL_EDIT_MODE";            break;
            case CSSM_ERRCODE_ACL_CHANGE_FAILED:              errStr = @"ACL_CHANGE_FAILED";                break;
            case CSSM_ERRCODE_INVALID_NEW_ACL_ENTRY:          errStr = @"INVALID_NEW_ACL_ENTRY";            break;
            case CSSM_ERRCODE_INVALID_NEW_ACL_OWNER:          errStr = @"INVALID_NEW_ACL_OWNER";            break;
            case CSSM_ERRCODE_ACL_DELETE_FAILED:              errStr = @"ACL_DELETE_FAILED";                break;
            case CSSM_ERRCODE_ACL_REPLACE_FAILED:             errStr = @"ACL_REPLACE_FAILED";               break;
            case CSSM_ERRCODE_ACL_ADD_FAILED:                 errStr = @"ACL_ADD_FAILED";                   break;
                                                              
            /* Common Error Codes for Specific Data Types */              
            case CSSM_ERRCODE_INVALID_CONTEXT_HANDLE:         errStr = @"INVALID_CONTEXT_HANDLE";           break;
            case CSSM_ERRCODE_INCOMPATIBLE_VERSION:           errStr = @"INCOMPATIBLE_VERSION";             break;
            case CSSM_ERRCODE_INVALID_CERTGROUP_POINTER:      errStr = @"INVALID_CERTGROUP_POINTER";        break;
            case CSSM_ERRCODE_INVALID_CERT_POINTER:           errStr = @"INVALID_CERT_POINTER";             break;
            case CSSM_ERRCODE_INVALID_CRL_POINTER:            errStr = @"INVALID_CRL_POINTER";              break;
            case CSSM_ERRCODE_INVALID_FIELD_POINTER:          errStr = @"INVALID_FIELD_POINTER";            break;
            case CSSM_ERRCODE_INVALID_DATA:                   errStr = @"INVALID_DATA";                     break;
            case CSSM_ERRCODE_CRL_ALREADY_SIGNED:             errStr = @"CRL_ALREADY_SIGNED";               break;
            case CSSM_ERRCODE_INVALID_NUMBER_OF_FIELDS:       errStr = @"INVALID_NUMBER_OF_FIELDS";         break;
            case CSSM_ERRCODE_VERIFICATION_FAILURE:           errStr = @"VERIFICATION_FAILURE";             break;
            case CSSM_ERRCODE_INVALID_DB_HANDLE:              errStr = @"INVALID_DB_HANDLE";                break;
            case CSSM_ERRCODE_PRIVILEGE_NOT_GRANTED:          errStr = @"PRIVILEGE_NOT_GRANTED";            break;
            case CSSM_ERRCODE_INVALID_DB_LIST:                errStr = @"INVALID_DB_LIST";                  break;
            case CSSM_ERRCODE_INVALID_DB_LIST_POINTER:        errStr = @"INVALID_DB_LIST_POINTER";          break;
            case CSSM_ERRCODE_UNKNOWN_FORMAT:                 errStr = @"UNKNOWN_FORMAT";                   break;
            case CSSM_ERRCODE_UNKNOWN_TAG:                    errStr = @"UNKNOWN_TAG";                      break;
            case CSSM_ERRCODE_INVALID_CSP_HANDLE:             errStr = @"INVALID_CSP_HANDLE";               break;
            case CSSM_ERRCODE_INVALID_DL_HANDLE:              errStr = @"INVALID_DL_HANDLE";                break;
            case CSSM_ERRCODE_INVALID_CL_HANDLE:              errStr = @"INVALID_CL_HANDLE";                break;
            case CSSM_ERRCODE_INVALID_TP_HANDLE:              errStr = @"INVALID_TP_HANDLE";                break;
            case CSSM_ERRCODE_INVALID_KR_HANDLE:              errStr = @"INVALID_KR_HANDLE";                break;
            case CSSM_ERRCODE_INVALID_AC_HANDLE:              errStr = @"INVALID_AC_HANDLE";                break;
            case CSSM_ERRCODE_INVALID_PASSTHROUGH_ID:         errStr = @"INVALID_PASSTHROUGH_ID";           break;
            case CSSM_ERRCODE_INVALID_NETWORK_ADDR:           errStr = @"INVALID_NETWORK_ADDR";             break;
            case CSSM_ERRCODE_INVALID_CRYPTO_DATA:            errStr = @"INVALID_CRYPTO_DATA";              break;
            default:                                          errStr = [NSString stringWithFormat:@"Unknown error %d", CSSM_ERRCODE(error)];
            }
            
        return [NSString stringWithFormat:@"Error %@ in %@ module", errStr, module];
        }
        
    // "normal" error codes
    switch (error)
        {
        case noErr:                        return @"OK (no error)";
        
        // from MacError.h
        // -1..-61, 
        case qErr:                 return @"queue element not found during deletion";
        case vTypErr:              return @"invalid queue element";
        case corErr:               return @"core routine number out of range";
        case unimpErr:             return @"unimplemented core routine";
        case SlpTypeErr:           return @"invalid queue element";
        case seNoDB:               return @"no debugger installed to handle debugger command";
        case controlErr:           return @"I/O System Error (controlErr)";
        case statusErr:            return @"I/O System Error (statusErr)";
        case readErr:              return @"I/O System Error (readErr)";
        case writErr:              return @"I/O System Error (writErr)";
        case badUnitErr:           return @"I/O System Error (badUnitErr)";
        case unitEmptyErr:         return @"I/O System Error (unitEmptyErr)";
        case openErr:              return @"I/O System Error (openErr)";
        case closErr:              return @"I/O System Error (closErr)";
        case dRemovErr:            return @"tried to remove an open driver";
        case dInstErr:             return @"DrvrInstall couldn't find driver in resources";
        case abortErr:             return @"IO aborted";
        case notOpenErr:           return @"Couldn't rd/wr/ctl/sts cause driver not opened";
        case unitTblFullErr:       return @"unit table has no more entries";
        case dceExtErr:            return @"dce extension error";
        case dirFulErr:            return @"Directory full";
        case dskFulErr:            return @"disk full";
        case nsvErr:               return @"no such volume";
        case ioErr:                return @"I/O error (bummer)";
        case bdNamErr:             return @"there may be no bad names in the final system!";
        case fnOpnErr:             return @"File not open";
        case eofErr:               return @"End of file";
        case posErr:               return @"tried to position to before start of file (r/w)";
        case mFulErr:              return @"memory full (open) or file won't fit (load)";
        case tmfoErr:              return @"too many files open";
        case fnfErr:               return @"File not found";
        case wPrErr:               return @"diskette is write protected.";
        case fLckdErr:             return @"file is locked";
        case vLckdErr:             return @"volume is locked";
        case fBsyErr:              return @"File is busy (delete)";
        case dupFNErr:             return @"duplicate filename (rename)";
        case opWrErr:              return @"file already open with with write permission";
        case paramErr:             return @"error in user parameter list";
        case rfNumErr:             return @"refnum error";
        case gfpErr:               return @"get file position error";
        case volOffLinErr:         return @"volume not on line error (was Ejected)";
        case permErr:              return @"permissions error (on file open)";
        case volOnLinErr:          return @"drive volume already on-line at MountVol";
        case nsDrvErr:             return @"no such drive (tried to mount a bad drive num)";
        case noMacDskErr:          return @"not a mac diskette (sig bytes are wrong)";
        case extFSErr:             return @"volume in question belongs to an external fs";
        case fsRnErr:              return @"file system internal error:during rename the old entry was deleted but could not be restored.";
        case badMDBErr:            return @"bad master directory block";
        case wrPermErr:            return @"write permissions error";
        // -120..-124
        case dirNFErr:             return @"Directory not found";
        case tmwdoErr:             return @"No free WDCB available";
        case badMovErr:            return @"Move into offspring error";
        case wrgVolTypErr:         return @"Wrong volume type error [operation not supported for MFS]";
        case volGoneErr:           return @"Server volume has been disconnected.";
        // -128
        case userCanceledErr:      return @"User canceled";
        // -200..-201
        case noHardwareErr:        return @"Sound Manager Error Returns";
        case notEnoughHardwareErr: return @"Sound Manager Error Returns";
        // -360,-400
        case slotNumErr:           return @"invalid slot # error";
        case gcrOnMFMErr:          return @"gcr format on high density media error";
        
        // PPC errors, from MacError.h
        // -900..-932
        case notInitErr:           return @"PPCToolBox not initialized";
        case nameTypeErr:          return @"Invalid or inappropriate locationKindSelector in locationName";
        case noPortErr:            return @"Unable to open port or bad portRefNum";
        case noGlobalsErr:         return @"The system is hosed, better re-boot";
        case localOnlyErr:         return @"Network activity is currently disabled";
        case destPortErr:          return @"Port does not exist at destination";
        case sessTableErr:         return @"Out of session tables, try again later";
        case noSessionErr:         return @"Invalid session reference number";
        case badReqErr:            return @"bad parameter or invalid state for operation";
        case portNameExistsErr:    return @"port is already open (perhaps in another app)";
        case noUserNameErr:        return @"user name unknown on destination machine";
        case userRejectErr:        return @"Destination rejected the session request";
        case noMachineNameErr:     return @"user hasn't named his Macintosh in the Network Setup Control Panel";
        case noToolboxNameErr:     return @"A system resource is missing, not too likely";
        case noResponseErr:        return @"unable to contact destination";
        case portClosedErr:        return @"port was closed";
        case sessClosedErr:        return @"session was closed";
        case badPortNameErr:       return @"PPCPortRec malformed";
        case noDefaultUserErr:     return @"user hasn't typed in owners name in Network Setup Control Pannel";
        case notLoggedInErr:       return @"The default userRefNum does not yet exist";
        case noUserRefErr:         return @"unable to create a new userRefNum";
        case networkErr:           return @"An error has occurred in the network, not too likely";
        case noInformErr:          return @"PPCStart failed because destination did not have inform pending";
        case authFailErr:          return @"unable to authenticate user at destination";
        case noUserRecErr:         return @"Invalid user reference number";
        case badServiceMethodErr:  return @"illegal service type, or not supported";
        case badLocNameErr:        return @"location name malformed";
        case guestNotAllowedErr:   return @"destination port requires authentication";
        
        // from SecureTransport.h
        // -9800..-9849
        case errSSLProtocol:               return @"SSL protocol error";
        case errSSLNegotiation:            return @"Cipher Suite negotiation failure";
        case errSSLFatalAlert:             return @"Fatal alert";
        case errSSLWouldBlock:             return @"I/O would block (not fatal)";
        case errSSLSessionNotFound:        return @"Attempt to restore an unknown session";
        case errSSLClosedGraceful:         return @"Connection closed gracefully";
        case errSSLClosedAbort:            return @"Connection closed via error";
        case errSSLXCertChainInvalid:      return @"Invalid certificate chain";
        case errSSLBadCert:                return @"Bad certificate format";
        case errSSLCrypto:                 return @"Underlying cryptographic error";
        case errSSLInternal:               return @"Internal error";
        case errSSLModuleAttach:           return @"Module attach failure";
        case errSSLUnknownRootCert:        return @"Valid cert chain, but untrusted root";
        case errSSLNoRootCert:             return @"Cert chain not verified by root";
        case errSSLCertExpired:            return @"Chain had an expired cert";
        case errSSLCertNotYetValid:        return @"Chain had a cert not yet valid";
        case errSSLClosedNoNotify:         return @"Server closed session with no notification";
        case errSSLBufferOverflow:         return @"Insufficient buffer provided";
        case errSSLBadCipherSuite:         return @"Bad SSLCipherSuite";
        
        // from SecBase.h
        // -25240..-25279
        case errSecACLNotSimple:           return @"The access control list is not in standard simple form.";
        case errSecPolicyNotFound:         return @"The policy specified cannot be found.";
        case errSecInvalidTrustSetting:    return @"The trust setting is invalid.";
        case errSecNoAccessForItem:        return @"The specified item has no access control.";        
        case errSecInvalidOwnerEdit:       return @"Invalid owner edit";
        
        //from SecBase.h
        // -25290..-25329
        // these errSec... errors are also known as errKC...
        case errSecNotAvailable:           return @"Keychain manager or trust results not available.";
        case errSecReadOnly:               return @"Read only error.";
        case errSecAuthFailed:             return @"Authorization/Authentication failed.";
        case errSecNoSuchKeychain:         return @"The keychain does not exist.";
        case errSecInvalidKeychain:        return @"The keychain is not valid.";
        case errSecDuplicateKeychain:      return @"A keychain with the same name already exists.";
        case errSecDuplicateCallback:      return @"More than one callback of the same name exists.";
        case errSecInvalidCallback:        return @"The callback is not valid.";
        case errSecDuplicateItem:          return @"The item already exists.";
        case errSecItemNotFound:           return @"The item cannot be found.";
        case errSecBufferTooSmall:         return @"The buffer is too small.";
        case errSecDataTooLarge:           return @"The data is too large.";
        case errSecNoSuchAttr:             return @"The attribute does not exist.";
        case errSecInvalidItemRef:         return @"The item reference is invalid.";
        case errSecInvalidSearchRef:       return @"The search reference is invalid.";
        case errSecNoSuchClass:            return @"The keychain item class does not exist.";
        case errSecNoDefaultKeychain:      return @"A default keychain does not exist.";
        case errSecInteractionNotAllowed:  return @"Interaction is not allowed with the Security Server.";
        case errSecReadOnlyAttr:           return @"The attribute is read only.";
        case errSecWrongSecVersion:        return @"The version is incorrect.";
        case errSecKeySizeNotAllowed:      return @"The key size is not allowed.";
        case errSecNoStorageModule:        return @"There is no storage module available.";
        case errSecNoCertificateModule:    return @"There is no certificate module available.";
        case errSecNoPolicyModule:         return @"There is no policy module available.";
        case errSecInteractionRequired:    return @"User interaction is required.";
        case errSecDataNotAvailable:       return @"The data is not available.";
        case errSecDataNotModifiable:      return @"The data is not modifiable.";
        case errSecCreateChainFailed:      return @"The attempt to create a certificate chain failed.";
        
        // from Authorization.h
        // -60001..-60032
        case errAuthorizationInvalidSet:              return @"The authorization set parameter is invalid.";
        case errAuthorizationInvalidRef:              return @"The authorization parameter is invalid.";
        case errAuthorizationInvalidTag:              return @"The authorization tag parameter is invalid.";
        case errAuthorizationInvalidPointer:          return @"The authorizedRights parameter is invalid.";
        case errAuthorizationDenied:                  return @"The authorization was denied.";
        case errAuthorizationCanceled:                return @"The authorization was cancled by the user.";
        case errAuthorizationInteractionNotAllowed:   return @"The authorization was denied since no user interaction was possible.";
        case errAuthorizationInternal:                return @"something else went wrong (authorization internal error)";
        case errAuthorizationExternalizeNotAllowed:   return @"authorization externalization denied";
        case errAuthorizationInternalizeNotAllowed:   return @"authorization internalization denied";
        case errAuthorizationInvalidFlags:            return @"invalid authorization option flag(s)";
        case errAuthorizationToolExecuteFailure:      return @"cannot execute privileged tool";
        case errAuthorizationToolEnvironmentError:    return @"privileged tool environment error";
        
        // an error code we still have to add...
        default:                                      return [NSString stringWithFormat:@"Unknown error %d", error];
        }
    }
    
@end
