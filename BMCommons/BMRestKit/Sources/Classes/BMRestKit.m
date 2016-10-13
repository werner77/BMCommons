//
//  BMMappingService.m
//  BMMappingService
//
//  Created by Werner Altewischer on 5/16/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMRestKit.h"
#if BM_PRIVATE_ENABLED
#import <BMCore/BMLicenseKey_Private.h>
#endif

@implementation BMRestKit

static BMRestKit *instance = nil;

NSString * const BMParserDocumentTypeXML = @"com.behindmedia.BMParserDocumentTypeXML";
NSString * const BMParserDocumentTypeJSONArray = @"com.behindmedia.BMParserDocumentTypeJSONArray";
NSString * const BMParserDocumentTypeJSONDictionary = @"com.behindmedia.BMParserDocumentTypeJSONDictionary";

+ (id)instance {
    if (instance == nil) {
        instance = [BMRestKit new];
    }
    return instance;
}

BM_LICENSED_MODULE_IMPLEMENTATION(BMRestKit)

@end
