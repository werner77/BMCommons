//
//  BMLicenseKeyHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 6/24/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMLicenseKeyHelper_Private.h"
#import <BMCore/NSData+BMEncryption.h>
#import <BMCore/BMEncryptionHelper.h>
#import <BMCore/BMRegexKitLite.h>
#import <BMCore/BMEncodingHelper.h>
#import <BMCore/BMSecurityHelper.h>
#import <BMCore/BMLicenseKey_Private.h>
#import <BMCore/BMLicenseChecker_Private.h>
#import <BMCore/BMCore.h>

static unsigned char publicKey[] =
{48,-126,3,-96,48,-126,2,-120,2,9,0,-67,-101,-25,-41,103,95,-27,69,48,13,6,9,42,-122,72,-122,-9,13,1,1,5,5,0,48,-127,-111,49,11,48,9,6,3,85,4,6,19,2,78,76,49,11,48,9,6,3,85,4,8,19,2,78,72,49,18,48,16,6,3,85,4,7,19,9,65,109,115,116,101,114,100,97,109,49,21,48,19,6,3,85,4,10,19,12,66,101,104,105,110,100,32,77,101,100,105,97,49,11,48,9,6,3,85,4,11,19,2,73,84,49,24,48,22,6,3,85,4,3,19,15,98,101,104,105,110,100,109,101,100,105,97,46,99,111,109,49,35,48,33,6,9,42,-122,72,-122,-9,13,1,9,1,22,20,105,110,102,111,64,98,101,104,105,110,100,109,101,100,105,97,46,99,111,109,48,30,23,13,49,51,48,54,50,52,50,49,53,51,49,54,90,23,13,50,51,48,54,50,50,50,49,53,51,49,54,90,48,-127,-111,49,11,48,9,6,3,85,4,6,19,2,78,76,49,11,48,9,6,3,85,4,8,19,2,78,72,49,18,48,16,6,3,85,4,7,19,9,65,109,115,116,101,114,100,97,109,49,21,48,19,6,3,85,4,10,19,12,66,101,104,105,110,100,32,77,101,100,105,97,49,11,48,9,6,3,85,4,11,19,2,73,84,49,24,48,22,6,3,85,4,3,19,15,98,101,104,105,110,100,109,101,100,105,97,46,99,111,109,49,35,48,33,6,9,42,-122,72,-122,-9,13,1,9,1,22,20,105,110,102,111,64,98,101,104,105,110,100,109,101,100,105,97,46,99,111,109,48,-126,1,34,48,13,6,9,42,-122,72,-122,-9,13,1,1,1,5,0,3,-126,1,15,0,48,-126,1,10,2,-126,1,1,0,-34,-54,52,-3,-85,-30,-93,-117,-25,-70,44,25,-52,100,10,-75,-64,-56,-48,-106,-46,81,76,-107,-87,125,-128,109,10,4,-98,-89,-23,-107,96,-48,32,-44,-101,81,-69,-43,-80,-5,-50,-30,110,-9,-63,-48,-102,-100,-53,24,-63,30,-64,-10,61,-113,-75,-62,-29,-26,-120,-106,-100,19,50,-45,-61,9,67,-63,40,120,-105,-4,72,67,24,-102,-44,25,80,66,-81,87,110,-35,-69,82,4,-90,-19,-51,14,-114,-99,-78,42,41,-102,-94,99,-96,44,4,14,-60,-35,-82,53,74,-7,21,112,6,-18,88,-110,-89,-128,55,-87,-30,99,-55,81,-85,77,27,21,-89,67,-43,-55,85,-27,86,119,-56,-55,-106,62,58,107,-6,36,48,41,-123,48,-114,-107,15,99,-34,66,70,127,29,-18,98,-115,-119,-85,53,62,25,-23,-8,-69,117,-10,-30,4,53,-72,-5,5,-39,-84,16,40,-112,-78,38,117,-16,91,-74,-118,-102,-12,74,-6,23,-116,96,-27,71,55,-47,94,16,68,71,81,101,89,13,18,-107,19,21,-2,26,99,113,102,40,-19,88,92,-77,80,91,21,83,-18,67,16,-48,22,-102,40,-21,-50,-70,-34,122,50,125,30,95,33,86,27,25,-95,124,-89,-84,-125,-19,2,3,1,0,1,48,13,6,9,42,-122,72,-122,-9,13,1,1,5,5,0,3,-126,1,1,0,93,-9,33,-122,64,80,-32,-43,-80,-29,100,-57,-59,-22,-32,-14,-92,58,-120,-81,20,63,104,-57,81,-67,83,29,73,124,111,-29,-50,-116,58,-32,44,108,-76,-72,-20,50,-85,8,5,100,12,66,-45,-22,-95,123,-50,-123,48,-86,90,24,-35,53,106,41,97,90,-74,61,20,-39,-41,117,127,127,29,122,-116,102,-89,-65,34,58,19,-85,31,10,62,-63,-88,-116,-44,78,105,121,31,104,-29,50,-59,48,26,-15,-128,-18,-28,-121,83,61,-44,125,50,99,-113,-28,-120,115,-94,-33,-51,-96,78,2,2,53,113,-20,17,-73,108,-32,105,-98,68,34,-125,-86,-99,12,52,87,-104,19,-12,92,-46,23,-9,-65,-116,102,13,-58,-36,-71,61,40,-69,-23,-34,23,-29,111,99,-50,-31,95,-9,-10,-83,63,26,105,-93,-122,-120,64,-62,-7,42,-60,-54,117,38,113,-61,39,-19,-93,125,35,-36,-120,-60,38,-128,28,23,-91,-12,-68,-46,-77,125,97,-3,-113,-77,76,85,43,43,100,-3,-85,36,-52,41,18,24,-92,-120,-28,-94,-51,52,9,74,-77,-12,117,-42,110,59,91,82,78,16,53,-50,81,122,80,-98,102,-105,-7,96,109,-18,-99,0,115,46,22,-45,102,84,120 };


static unsigned char veriousPublicKey[] = {
    48,-126,3,-48,48,-126,3,57,-96,3,2,1,2,2,1,0,48,13,6,9,42,-122,72,-122,-9,13,1,1,4,5,0,48,-127,-89,49,11,48,9,6,3,85,4,6,19,2,78,76,49,11,48,9,6,3,85,4,8,19,2,67,65,49,18,48,16,6,3,85,4,7,19,9,83,117,110,110,121,118,97,108,101,49,30,48,28,6,3,85,4,10,19,21,87,101,114,110,101,114,32,73,84,32,67,111,110,115,117,108,116,97,110,99,121,49,10,48,8,6,3,85,4,11,19,1,45,49,30,48,28,6,3,85,4,3,19,21,87,101,114,110,101,114,32,73,84,32,67,111,110,115,117,108,116,97,110,99,121,49,43,48,41,6,9,42,-122,72,-122,-9,13,1,9,1,22,28,119,101,114,110,101,114,46,97,108,116,101,119,105,115,99,104,101,114,64,103,109,97,105,108,46,99,111,109,48,30,23,13,49,51,48,53,49,51,49,48,51,49,49,51,90,23,13,50,51,48,53,49,49,49,48,51,49,49,51,90,48,-127,-89,49,11,48,9,6,3,85,4,6,19,2,78,76,49,11,48,9,6,3,85,4,8,19,2,67,65,49,18,48,16,6,3,85,4,7,19,9,83,117,110,110,121,118,97,108,101,49,30,48,28,6,3,85,4,10,19,21,87,101,114,110,101,114,32,73,84,32,67,111,110,115,117,108,116,97,110,99,121,49,10,48,8,6,3,85,4,11,19,1,45,49,30,48,28,6,3,85,4,3,19,21,87,101,114,110,101,114,32,73,84,32,67,111,110,115,117,108,116,97,110,99,121,49,43,48,41,6,9,42,-122,72,-122,-9,13,1,9,1,22,28,119,101,114,110,101,114,46,97,108,116,101,119,105,115,99,104,101,114,64,103,109,97,105,108,46,99,111,109,48,-127,-97,48,13,6,9,42,-122,72,-122,-9,13,1,1,1,5,0,3,-127,-115,0,48,-127,-119,2,-127,-127,0,-80,-29,-46,-125,-109,66,-92,-61,-84,31,-81,103,110,38,-19,68,55,87,-54,-124,107,-42,81,70,65,17,13,-125,-38,113,-112,-13,-122,115,-25,56,-90,109,-96,2,-81,62,-15,-21,84,-44,1,66,-75,122,-63,-30,124,81,-44,-28,123,116,120,17,53,28,63,61,14,99,-7,102,110,-96,69,-90,-25,-72,93,53,30,6,70,109,-73,31,54,6,98,62,-121,119,102,-56,-55,101,98,-82,-90,5,107,14,-99,-122,110,-101,77,85,-51,-60,87,32,-47,66,-106,68,-16,-28,51,-60,104,26,101,114,63,-122,-11,-30,122,-119,-76,-71,2,3,1,0,1,-93,-126,1,8,48,-126,1,4,48,29,6,3,85,29,14,4,22,4,20,53,39,-24,11,22,-60,-27,17,87,-70,-16,-76,-108,88,-88,118,47,9,-98,33,48,-127,-44,6,3,85,29,35,4,-127,-52,48,-127,-55,-128,20,53,39,-24,11,22,-60,-27,17,87,-70,-16,-76,-108,88,-88,118,47,9,-98,33,-95,-127,-83,-92,-127,-86,48,-127,-89,49,11,48,9,6,3,85,4,6,19,2,78,76,49,11,48,9,6,3,85,4,8,19,2,67,65,49,18,48,16,6,3,85,4,7,19,9,83,117,110,110,121,118,97,108,101,49,30,48,28,6,3,85,4,10,19,21,87,101,114,110,101,114,32,73,84,32,67,111,110,115,117,108,116,97,110,99,121,49,10,48,8,6,3,85,4,11,19,1,45,49,30,48,28,6,3,85,4,3,19,21,87,101,114,110,101,114,32,73,84,32,67,111,110,115,117,108,116,97,110,99,121,49,43,48,41,6,9,42,-122,72,-122,-9,13,1,9,1,22,28,119,101,114,110,101,114,46,97,108,116,101,119,105,115,99,104,101,114,64,103,109,97,105,108,46,99,111,109,-126,1,0,48,12,6,3,85,29,19,4,5,48,3,1,1,-1,48,13,6,9,42,-122,72,-122,-9,13,1,1,4,5,0,3,-127,-127,0,-116,-8,-80,-12,-4,-43,103,58,-120,82,-101,97,31,29,112,-7,-104,99,-93,81,-30,-109,-48,-28,-122,-26,81,37,-59,-73,-16,31,113,-58,-46,51,-44,77,72,76,31,-45,41,-5,-121,-68,58,6,4,-79,4,-88,-35,97,-94,7,37,-74,98,-35,38,-34,-103,93,-47,-26,-49,-107,-14,-92,20,111,-69,-102,-16,74,92,12,121,26,-18,-66,-97,-32,-97,-99,-19,-16,-14,67,-18,53,119,81,45,-76,99,87,-79,102,-56,108,47,-36,102,86,85,-80,49,-12,16,-122,96,-26,-20,-21,126,-12,-21,53,66,116,29,44,70,-51,-17,16
};

static NSData *sPublicKeyData = nil;
static NSData *sVeriousPublicKeyData = nil;

static NSData *getLicenseKeyPublicKeyData() {
    if (sPublicKeyData) {
        return sPublicKeyData;
    } else {
        return [NSData dataWithBytesNoCopy:publicKey length:sizeof(publicKey) freeWhenDone:NO];
    }
}

static NSData *getVeriousLicenseKeyPublicKeyData() {
    if (sVeriousPublicKeyData) {
        return sVeriousPublicKeyData;
    } else {
        return [NSData dataWithBytesNoCopy:veriousPublicKey length:sizeof(veriousPublicKey) freeWhenDone:NO];
    }
}

static SecKeyRef getPublicKeyRef() {
    return [BMSecurityHelper newPublicKeyRefFromData:getLicenseKeyPublicKeyData()];
}

void BMSetLicenseKeyPublicKeyData(NSData *publicKeyData) {
    if (sPublicKeyData != publicKeyData) {
        sPublicKeyData = [[NSData alloc] initWithData:publicKeyData];
    }
}

void BMSetVeriousLicenseKeyPublicKeyData(NSData *publicKeyData) {
    if (sVeriousPublicKeyData != publicKeyData) {
        sVeriousPublicKeyData = [[NSData alloc] initWithData:publicKeyData];
    }
}

BOOL BMCheckLicenseKeyForModule(id module, NSString *key, BOOL *delayedResponse) {
    return BMCheckLicenseKeyForModuleId(NSStringFromClass([module class]), key, delayedResponse);
}

BOOL BMCheckLicenseKeyForModuleId(NSString *moduleIdentifier, NSString *key, BOOL *delayedResponse) {
    NSString* appid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
    return BMCheckLicenseKeyComplete(moduleIdentifier, appid, nil, key, delayedResponse);
}

BOOL BMCheckLicenseKeyComplete(NSString *moduleIdentifier, NSString *appId, NSDate *date, NSString *key, BOOL *delayedResponse) {
    NSString *decryptedString = [BMEncryptionHelper decryptString:key withKey:ENCRYPTION_KEY];
    
    NSArray *components = [decryptedString componentsSeparatedByString:@":"];
    
    if (components.count == 5) {
        
        //last component is signature
        
        NSString *signatureString = [components lastObject];
        NSData *signature = [BMEncodingHelper dataWithBase64EncodedString:signatureString];
        NSString *testString = [NSString stringWithFormat:@"%@:%@:%@:%@", [components objectAtIndex:0], [components objectAtIndex:1], [components objectAtIndex:2], [components objectAtIndex:3]];
        
        SecKeyRef keyRef = getPublicKeyRef();
        
        if (keyRef == NULL) {
            NSException *ex = [NSException exceptionWithName:@"BMInvalidPublicKeyException" reason:@"Public key could not be read" userInfo:nil];
            @throw ex;
        }
        
        BOOL validSignature = [[testString dataUsingEncoding:NSUTF8StringEncoding] bmVerifySignature:signature withKey:keyRef];
        
        if (validSignature) {
            NSString *firstComponent = [components objectAtIndex:0];
            NSArray *coordinates = [firstComponent componentsSeparatedByString:@","];
            
            if (coordinates.count == NUMBER_OF_COORDINATES * 2) {
                int i = 0;
                int32_t x;
                int32_t y;
                BOOL validKey = YES;
                for (NSString *coordinate in coordinates) {
                    int32_t d = BMShortenIntSafely(strtol([coordinate UTF8String], NULL, 0), nil);
                    if ( (i % 2) == 0) {
                        if (i > 0) {
                            int32_t candidateY = LICENSE_KEY_FUNCTION(x);
                            if (candidateY != y) {
                                validKey = NO;
                                break;
                            }
                        }
                        x = d;
                    } else {
                        y = d;
                    }
                    
                    i++;
                }
                
                if (validKey) {
                    NSString *componentRegEx = [components objectAtIndex:1];
                    NSString *appIdRegEx = [components objectAtIndex:2];
                    long long expirationTime = [[components objectAtIndex:3] longLongValue];
                    
                    if (date == nil) {
                        date = [NSDate date];
                    }
                    
                    if ([moduleIdentifier isMatchedByRegex:componentRegEx] && [appId isMatchedByRegex:appIdRegEx] && (expirationTime == 0 || [date timeIntervalSince1970] < expirationTime)) {
                        
                        if (delayedResponse) {
                            [[BMLicenseChecker instance] checkLicense:key forApp:appId module:moduleIdentifier publicKey:keyRef completionBlock:^(BOOL valid) {
                                *delayedResponse = valid;
                                CFRelease(keyRef);
                            }];
                        } else {
                            CFRelease(keyRef);
                        }
                        return YES;
                    }
                }
            }
        }
        CFRelease(keyRef);
    }
    return NO;
}

void BMThrowLicenseException(id module) {
    NSString *reason = [NSString stringWithFormat:@"Invalid license for use of the %@ module", NSStringFromClass([module class])];
    NSException *ex = [NSException exceptionWithName:@"BMLicenseException" reason:reason  userInfo:nil];
    @throw ex;
}

BOOL BMValidateVeriousLicense(NSData *signedHash, NSString *validity) {
    
    if (!signedHash || !validity) {
        return FALSE;
    }
    
    BOOL licenseValid = FALSE;
    
    NSData *encodedKeyBytes = [[NSData alloc] initWithBytes:veriousPublicKey length:sizeof(veriousPublicKey)];
    
    SecKeyRef key = [BMSecurityHelper newPublicKeyRefFromData:encodedKeyBytes];
    
    // Make sure digest matches message
    if ([[validity dataUsingEncoding:NSUTF8StringEncoding] bmVerifySignature:signedHash withKey:key]) {
        if ([validity rangeOfString:@"valid"].location==0) {
            // Check app id
            NSString* appid = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleIdentifier"];
            NSRange idx = [validity rangeOfString:@",appid="];
            if (idx.location!=NSNotFound) {
                idx.location += 7;
                idx.length = [validity length] - idx.location;
                NSRange endIdx = [validity rangeOfString:@"," options:NSLiteralSearch range:idx];
                NSString *sentAppId = [validity substringWithRange:NSMakeRange(idx.location, endIdx.location - idx.location)];
                if ([sentAppId isEqualToString:appid]) {
                    licenseValid = TRUE;
                }
            }
            // Parse validity date
            idx = [validity rangeOfString:@",exp="];
            if (idx.location!=NSNotFound) {
                idx.location += 5;
                idx.length = [validity length] - idx.location;
                NSRange endIdx = [validity rangeOfString:@"," options:NSLiteralSearch range:idx];
                NSString *validityDate = [validity substringWithRange:NSMakeRange(idx.location, endIdx.location - idx.location)];
                NSTimeInterval date = [[NSDate date] timeIntervalSince1970];
                // Date expired?
                if ([validityDate intValue]<(int)date) {
                    licenseValid = FALSE;
                }
            }
        }
    }
    
    CFRelease(key);
    return licenseValid;
}
