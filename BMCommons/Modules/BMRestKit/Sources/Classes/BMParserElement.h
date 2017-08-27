//
//  BMParserElement.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMFieldMapping.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Class that is used when parsing XML/JSON documents
 */
@interface BMParserElement : NSObject

- (id)initWithName:(NSString *)elementName attributes:(nullable NSDictionary *)attributes parent:(nullable BMParserElement *)parentElement NS_DESIGNATED_INITIALIZER;

@property(nonatomic, readonly) NSString *elementName;
@property(nullable, nonatomic, readonly) NSDictionary *attributes;
@property(nullable, nonatomic, readonly) BMParserElement *parentElement;
@property(nullable, nonatomic, readonly) NSDictionary *fieldMappings;
@property(nonatomic, assign) BOOL treatAttributesAsElements;
@property(nonatomic, assign) BOOL nilElement;
@property(nullable, nonatomic, strong) NSObject<BMMappableObject> *modelObject;
@property(nullable, nonatomic, strong) id context;
@property(nullable, strong, nonatomic, readonly) NSString *elementText;

- (void)fillModelObject;

//Converts this object to an XML string (using the element name and attibutes and those of its parents recursively)
- (NSString *)xmlString;

//Returns true if the XML returned by xmlString returns > 0 results by matching the supplied xpath expression.
- (BOOL)matchesXPath:(NSString *)xpath;

- (void)appendText:(NSString *)text;

@end

NS_ASSUME_NONNULL_END
