//
//  BMJSONSchemaParser.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/17/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMRestKit/BMAbstractSchemaParserHandler.h>
#import <BMRestKit/BMMappableObjectClassResolver.h>

@interface BMJSONSchemaParser : BMAbstractSchemaParserHandler {
}

@property (nonatomic, strong) id <BMMappableObjectClassResolver> classResolver;

@end
