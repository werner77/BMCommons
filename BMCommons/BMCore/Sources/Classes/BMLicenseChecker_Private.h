//
//  BMLicenseChecker_Private.h
//  BMCommons
//
//  Created by Werner Altewischer on 7/23/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^BMLicenseCheckerBlock)(BOOL);

@interface BMLicenseChecker : NSObject {
@private
    NSOperationQueue *_queue;
    NSMutableDictionary *_blocksToCall;
}

+ (id)instance;

- (void)checkLicense:(NSString *)license forApp:(NSString *)appId module:(NSString *)moduleIdentifier publicKey:(SecKeyRef)publicKey completionBlock:(BMLicenseCheckerBlock)block;

@end
