//
//  BMJSONSchemaParserTestCase.m
//  BMCommons
//
//  Created by Werner Altewischer on 12/18/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import "BMJSONSchemaParserTestCase.h"
#import <BMCommons/BMJSONSchemaParser.h>
#import <BMCommons/BMFieldMapping.h>

@implementation BMJSONSchemaParserTestCase

- (void)testParseJSONSchema {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"schema" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    [BMFieldMapping setClassChecksEnabled:NO];
    
    BMJSONSchemaParser *parser = [BMJSONSchemaParser new];
    NSError *error;
    
    NSArray *objectMappings = [parser parseSchema:data withError:&error];
    
    NSLog(@"Object mappings: %@", objectMappings);
}
    
- (void)testParseJSONSchema1 {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"schema1" ofType:@"json"];
    
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    [BMFieldMapping setClassChecksEnabled:NO];
    
    BMJSONSchemaParser *parser = [BMJSONSchemaParser new];
    NSError *error;
    
    NSArray *objectMappings = [parser parseSchema:data withError:&error];
    
    NSLog(@"Object mappings: %@", objectMappings);
}

@end
