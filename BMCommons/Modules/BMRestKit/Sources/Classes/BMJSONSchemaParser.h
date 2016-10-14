//
//  BMJSONSchemaParser.h
//  BMCommons
//
//  Created by Werner Altewischer on 12/17/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractSchemaParserHandler.h>
#import <BMCommons/BMMappableObjectClassResolver.h>

@interface BMJSONSchemaParser : BMAbstractSchemaParserHandler {
}

@property (nonatomic, strong) id <BMMappableObjectClassResolver> classResolver;

@end
