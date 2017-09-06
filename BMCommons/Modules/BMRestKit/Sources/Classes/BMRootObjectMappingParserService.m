//
//  BMRootObjectMappingParserService.m
//  BMCommons
//
//  Created by Werner Altewischer on 29/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMRootObjectMappingParserService.h>
#import <BMCommons/BMMappableObject.h>
#import <BMCommons/BMJSONParser.h>

@interface BMRootObjectMappingParserService(Private)

- (NSString *)xpathFromElementName:(NSString *)elementName;

@end

@implementation BMRootObjectMappingParserService

- (void)setRootElementClass:(Class<BMMappableObject>)c {
    if (self.rootElementClass != c) {
        self.rootXPath = [self xpathFromElementName:[c rootElementName]];
    }
    [super setRootElementClass:c];
}

- (void)setErrorElementClass:(Class<BMMappableObject>)c {
    if (self.errorElementClass != c) {
        self.errorXPath = [self xpathFromElementName:[c rootElementName]];
    }
    [super setErrorElementClass:c];
}

@end

@implementation BMRootObjectMappingParserService(Private)

- (NSString *)xpathFromElementName:(NSString *)elementName {
    return (elementName ? [@"/" stringByAppendingString:elementName] : nil);
}

@end
