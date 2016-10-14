//
//  BMMappingService.h
//  BMMappingService
//
//  Created by Werner Altewischer on 5/16/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCore.h>
#import <BMCommons/BMXML.h>

/**
 BMRestKit module
 */
@interface BMRestKit : NSObject

+ (id)instance;

@end

extern NSString * const BMParserDocumentTypeXML;
extern NSString * const BMParserDocumentTypeJSONArray;
extern NSString * const BMParserDocumentTypeJSONDictionary;
