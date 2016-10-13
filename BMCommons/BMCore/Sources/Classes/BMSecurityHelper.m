//
//  BMKeychainUtil.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/10/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMSecurityHelper.h"

#import <Security/Security.h>
#import <CoreFoundation/CoreFoundation.h>

#import "BMErrorCodes.h"
#import "BMErrorHelper.h"
#import "BMLogging.h"
#import "NSData+BMEncryption.h"

@interface BMSecurityHelper(Private)

OSStatus ExtractIdentityAndTrust(CFDataRef inPKCS12Data,        // 5
                                 SecIdentityRef *outIdentity,
                                 SecTrustRef *outTrust,
                                 CFArrayRef *outCerts,
                                 CFStringRef password);
CFDataRef CreatePersistentRefForIdentity(SecIdentityRef identity);
SecIdentityRef CreateIdentityForPersistentRef(CFDataRef persistent_ref);

@end

@implementation BMSecurityHelper

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

#pragma mark - Public methods

+ (void)wipeKeychain {
    
    const void *classes[] = {kSecClassGenericPassword, kSecClassInternetPassword, kSecClassCertificate, kSecClassKey, kSecClassIdentity};
    
    for (int i = 0; i < 5; ++i) {
        CFTypeRef classRef = classes[i];
    
        /* delete custom data */
        NSMutableDictionary *searchData = [NSMutableDictionary new];
        [searchData setObject:(__bridge id)classRef forKey:(__bridge id)kSecClass];
        
        OSStatus status = SecItemDelete((__bridge CFDictionaryRef)searchData);
        
        if (status != 0) {
            LogWarn(@"Could not delete keychain items, error code=%d", (int)status);
        }
        
    }
}

+ (SecIdentityRef) newIdentityForPersistentRef:(NSData *)ref {
    return CreateIdentityForPersistentRef((__bridge CFDataRef)ref);
}

+ (SecCertificateRef) copyCertificateFromIdentity:(SecIdentityRef)identity {
    if (!identity) {
        return NULL;
    }
    // Get the certificate from the identity.
    SecCertificateRef myReturnedCertificate = NULL;
    SecIdentityCopyCertificate (identity,
                                         &myReturnedCertificate);  // 1
    
    return myReturnedCertificate;
}

+ (SecCertificateRef)newCertificateByImportingFromFile:(NSString *)thePath withError:(NSError **)error {
    
    NSData *certData = [[NSData alloc]
                        initWithContentsOfFile:thePath];
    CFDataRef myCertData = (__bridge CFDataRef)certData;                 // 1
    
    SecCertificateRef myCert = SecCertificateCreateWithData(NULL, myCertData);  
    
    
    const void *keys[] =   { kSecClass, kSecValueRef };
    const void *values[] = { kSecClassCertificate, myCert };
    CFDictionaryRef dict = CFDictionaryCreate(NULL, keys, values,
                                              sizeof(keys) / sizeof(*keys), NULL, NULL);
    
    OSStatus status;
    
    if ((status = SecItemCopyMatching(dict, NULL)) != 0) {
        status = SecItemAdd(dict, NULL);
    }
    
    CFRelease(dict);
    
    if (status != 0) {
        if (myCert) CFRelease(myCert);
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:status description:@"Could not import certificate"];
        }
        return NULL;
    } else {
        return myCert;
    }
}

+ (NSData *)importP12DataFromFile:(NSString *)thePath usingPassword:(NSString *)password withError:(NSError **)error {

    NSData *PKCS12Data = [[NSData alloc] initWithContentsOfFile:thePath];
    CFDataRef inPKCS12Data = (__bridge CFDataRef)PKCS12Data;             // 1
    
    OSStatus status = noErr;
    SecIdentityRef myIdentity;
    SecTrustRef myTrust;
    CFArrayRef myCerts;
    status = ExtractIdentityAndTrust(inPKCS12Data,
                                     &myIdentity,
                                     &myTrust,
                                     &myCerts,
                                     (__bridge CFStringRef)password);                 // 2
    if (status != 0) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:status description:@"Could not extract identity and trust"];
        }
        
        if (myIdentity) CFRelease(myIdentity);
        if (myTrust) CFRelease(myTrust);
        if (myCerts) CFRelease(myCerts);
        
        return nil;
    }
    
    //Allow self-signed certificates
    SecTrustSetAnchorCertificates(myTrust, myCerts);
    SecTrustSetAnchorCertificatesOnly (myTrust, NO);
        
    SecTrustResultType trustResult;
    status = SecTrustEvaluate(myTrust, &trustResult);
    
    if (status != 0) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_DATA code:status description:@"Could not evaluate trust"];
        }
        
        if (myIdentity) CFRelease(myIdentity);
        if (myTrust) CFRelease(myTrust);
        if (myCerts) CFRelease(myCerts);
        
        return nil;
    }
    
    //Get time used to verify trust
    if (trustResult == kSecTrustResultRecoverableTrustFailure) {
        CFAbsoluteTime trustTime,currentTime,timeIncrement,newTime;
        CFDateRef newDate;
        
        trustTime = SecTrustGetVerifyTime(myTrust);             // 3
        timeIncrement = 31536000;                               // 4
        currentTime = CFAbsoluteTimeGetCurrent();               // 5
        newTime = currentTime - timeIncrement;                  // 6
        if (trustTime - newTime){                               // 7
            newDate = CFDateCreate(NULL, newTime);              // 8
            SecTrustSetVerifyDate(myTrust, newDate);            // 9
            status = SecTrustEvaluate(myTrust, &trustResult);   // 10
            if (status != 0) {
                LogWarn(@"Could not evaluate trust, error=%d", (int)status);
            }
            CFRelease(newDate);
        }
    }
    
    if (trustResult == kSecTrustResultRecoverableTrustFailure || trustResult == kSecTrustResultDeny || trustResult == kSecTrustResultInvalid ||
        trustResult == kSecTrustResultFatalTrustFailure) {
        if (error) {
            *error = [BMErrorHelper errorForDomain:BM_ERROR_DOMAIN_CLIENT code:BM_ERROR_SECURITY description:[NSString stringWithFormat:@"Certificate is not trusted, trustResult=%d", (int)trustResult]];
        }
        
        if (myIdentity) CFRelease(myIdentity);
        if (myTrust) CFRelease(myTrust);
        if (myCerts) CFRelease(myCerts);
        
        return nil;
    }
    
    //Create a persistent reference and return it
    
    CFDataRef persistentRef = CreatePersistentRefForIdentity(myIdentity);
    
    if (myIdentity) CFRelease(myIdentity);
    if (myTrust) CFRelease(myTrust);
    if (myCerts) CFRelease(myCerts);
    
    NSData *ret = (__bridge_transfer NSData *)persistentRef;
    
    return ret;
}

#if TARGET_OS_IPHONE
+ (OSStatus)generateKeyPairWithKeySize:(NSUInteger)keySize publicKeyTag:(NSString *)publicKeyTag privateKeyTag:(NSString *)privateKeyTag newPublicKey:(SecKeyRef *)publicKey newPrivateKey:(SecKeyRef *)privateKey {
    
    NSData *publicTag = [publicKeyTag dataUsingEncoding:NSUTF8StringEncoding];
    NSData *privateTag = [privateKeyTag dataUsingEncoding:NSUTF8StringEncoding];
    
    OSStatus sanityCheck = noErr;
    
    if ( keySize != 512 && keySize != 1024 && keySize != 2048) {
        NSString *reason = [NSString stringWithFormat:@"%d is an invalid and unsupported key size", (int)keySize];
        NSException *ex = [NSException exceptionWithName:@"BMInvalidArgumentException" reason:reason userInfo:nil];
        @throw ex;
    }
    
    // Container dictionaries.
    NSMutableDictionary * privateKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * publicKeyAttr = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * keyPairAttr = [[NSMutableDictionary alloc] init];
    
    // Set top level dictionary for the keypair.
    [keyPairAttr setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [keyPairAttr setObject:[NSNumber numberWithUnsignedInteger:keySize] forKey:(__bridge id)kSecAttrKeySizeInBits];
    
    // Set the private key dictionary.
    [privateKeyAttr setObject:[NSNumber numberWithBool:NO] forKey:(__bridge id)kSecAttrIsPermanent];
    [privateKeyAttr setObject:privateTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set the public key dictionary.
    [publicKeyAttr setObject:[NSNumber numberWithBool:NO] forKey:(__bridge id)kSecAttrIsPermanent];
    [publicKeyAttr setObject:publicTag forKey:(__bridge id)kSecAttrApplicationTag];
    // See SecKey.h to set other flag values.
    
    // Set attributes to top level dictionary.
    [keyPairAttr setObject:privateKeyAttr forKey:(__bridge id)kSecPrivateKeyAttrs];
    [keyPairAttr setObject:publicKeyAttr forKey:(__bridge id)kSecPublicKeyAttrs];
    
    // SecKeyGeneratePair returns the SecKeyRefs just for educational purposes.
    sanityCheck = SecKeyGeneratePair((__bridge CFDictionaryRef)keyPairAttr, publicKey, privateKey);
    
    
    return sanityCheck;
}
#endif

+ (SecKeyRef)newPublicKeyRefFromData:(NSData *)data {
    
    SecCertificateRef cert = SecCertificateCreateWithData(NULL, (__bridge CFDataRef)data);
    SecKeyRef key = NULL;
    SecTrustRef trust = NULL;
    SecPolicyRef policy = NULL;
    
    if (cert != NULL) {
        policy = SecPolicyCreateBasicX509();
        if (policy) {
            if (SecTrustCreateWithCertificates((CFTypeRef)cert, policy, &trust) == noErr) {
                SecTrustResultType result;
                if (SecTrustEvaluate(trust, &result) == noErr) {
                    //if (result == kSecTrustResultProceed || result == kSecTrustResultUnspecified) {
                    key = SecTrustCopyPublicKey(trust);
                    //}
                }
            }
        }
    }
    if (policy) CFRelease(policy);
    if (trust) CFRelease(trust);
    if (cert) CFRelease(cert);
    return key;
}

+ (SecKeyRef)newPrivateKeyRefWithPassword:(NSString *)password fromData:(NSData *)data {
    NSMutableDictionary * options = [[NSMutableDictionary alloc] init];
    
    SecKeyRef privateKeyRef = NULL;
    
    // Set the public key query dictionary
    //change to your .pfx  password here
    [options setObject:password forKey:(__bridge id)kSecImportExportPassphrase];
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    
    OSStatus securityError = SecPKCS12Import((__bridge CFDataRef)data,
                                             (__bridge CFDictionaryRef)options, &items);
    
    if (securityError == noErr && CFArrayGetCount(items) > 0) {
        CFDictionaryRef identityDict = CFArrayGetValueAtIndex(items, 0);
        SecIdentityRef identityApp =
        (SecIdentityRef)CFDictionaryGetValue(identityDict,
                                             kSecImportItemIdentity);
        
        securityError = SecIdentityCopyPrivateKey(identityApp, &privateKeyRef);
        if (securityError != noErr) {
            privateKeyRef = NULL;
        }
    }
    if (items) CFRelease(items);
    return privateKeyRef;
}


@end

@implementation BMSecurityHelper(Private)

#pragma mark - C Methods

OSStatus ExtractIdentityAndTrust(CFDataRef inPKCS12Data,        // 5
                                 SecIdentityRef *outIdentity,
                                 SecTrustRef *outTrust,
                                 CFArrayRef *outCerts,
                                 CFStringRef password) {
    
    OSStatus securityError = errSecSuccess;
    
    const void *keys[] =   { kSecImportExportPassphrase };
    const void *values[] = { password };
    
    CFDictionaryRef optionsDictionary = CFDictionaryCreate(
                                                           NULL, keys,
                                                           values, sizeof(keys) / sizeof(*keys),
                                                           NULL, NULL);  // 6
    
    
    CFArrayRef items = CFArrayCreate(NULL, 0, 0, NULL);
    securityError = SecPKCS12Import(inPKCS12Data,
                                    optionsDictionary,
                                    &items);                    // 7
    
    
    //
    if (securityError == 0) {                                   // 8
        CFDictionaryRef myIdentityAndTrust = CFArrayGetValueAtIndex (items, 0);
        const void *tempIdentity = NULL;
        tempIdentity = CFRetain(CFDictionaryGetValue (myIdentityAndTrust,
                                                      kSecImportItemIdentity));
        *outIdentity = (SecIdentityRef)tempIdentity;
        const void *tempTrust = NULL;
        tempTrust = CFRetain(CFDictionaryGetValue (myIdentityAndTrust, kSecImportItemTrust));
        *outTrust = (SecTrustRef)tempTrust;
        
        const void *tempCertArray = NULL;
        tempCertArray = CFRetain(CFDictionaryGetValue(myIdentityAndTrust, kSecImportItemCertChain));
        *outCerts = (CFArrayRef)tempCertArray;
    } else {
        *outIdentity = NULL;
        *outTrust = NULL;
        *outCerts = NULL;
    }
    
    if (items)
        CFRelease(items);
    
    if (optionsDictionary)
        CFRelease(optionsDictionary);                           // 9
    
    return securityError;
}

CFDataRef CreatePersistentRefForIdentity(SecIdentityRef identity)
{
    CFTypeRef  persistent_ref = NULL;
    const void *keys[] =   { kSecReturnPersistentRef, kSecValueRef };
    const void *values[] = { kCFBooleanTrue,          identity };
    CFDictionaryRef dict = CFDictionaryCreate(NULL, keys, values,
                                              sizeof(keys) / sizeof(*keys), NULL, NULL);
    
    
    if (SecItemCopyMatching(dict, &persistent_ref) != 0) {
        SecItemAdd(dict, &persistent_ref);
    }
    
    if (dict)
        CFRelease(dict);
    
    return (CFDataRef)persistent_ref;
}

SecIdentityRef CreateIdentityForPersistentRef(CFDataRef persistent_ref)
{
    CFTypeRef   identity_ref     = NULL;
    const void *keys[] =   { kSecReturnRef,  kSecValuePersistentRef };
    const void *values[] = { kCFBooleanTrue, persistent_ref };
    CFDictionaryRef dict = CFDictionaryCreate(NULL, keys, values,
                                              sizeof(keys) / sizeof(*keys), NULL, NULL);
    SecItemCopyMatching(dict, &identity_ref);
    
    if (dict)
        CFRelease(dict);
    
    return (SecIdentityRef)identity_ref;
}

@end
