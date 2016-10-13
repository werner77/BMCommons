//
//  BMLicensedModule.h
//  BMCommons
//
//  Created by Werner Altewischer on 6/26/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 Protocol for modules that require a valid license key to expose all functionality.
 */
@protocol BMLicensedModule <NSObject>

/**
 Register the specified license key for this module.
 
 Should be done as early as possible in the application lifecycle, e.g. in the init method of the AppDelegate.
 */
- (void)registerLicenseKey:(NSString *)licenseKey;

@end
