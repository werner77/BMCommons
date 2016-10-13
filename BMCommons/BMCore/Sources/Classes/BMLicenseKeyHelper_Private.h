//
//  BMLicenseKeyHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/24/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

void BMSetLicenseKeyPublicKeyData(NSData *publicKeyData);
BOOL BMCheckLicenseKeyForModule(id module, NSString *key, BOOL *delayedResponse);
BOOL BMCheckLicenseKeyForModuleId(NSString *moduleIdentifier, NSString *key, BOOL *delayedResponse);
BOOL BMCheckLicenseKeyComplete(NSString *moduleIdentifier, NSString *appId, NSDate *date, NSString *key, BOOL *delayedResponse);
void BMThrowLicenseException(id module);

//Make this a plain C function to prevent method swapping.
BOOL BMValidateVeriousLicense(NSData *signedHash, NSString *validity);
void BMSetVeriousLicenseKeyPublicKeyData(NSData *publicKeyData);
