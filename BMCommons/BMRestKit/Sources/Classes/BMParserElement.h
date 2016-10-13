//
//  BMParserElement.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMRestKit/BMFieldMapping.h>

/**
 Class that is used when parsing XML/JSON documents
 */
@interface BMParserElement : NSObject {
    @private
	NSString *elementName;
	NSDictionary *attributes;
	BMParserElement *parentElement;
	NSDictionary *fieldMappings;
	NSObject<BMMappableObject> *modelObject; 
	BMFieldMapping *textFieldMapping;
	NSObject<BMMappableObject> *textModelObject;
	id context;
    BOOL treatAttributesAsElements;
    BOOL nilElement;
    NSMutableString *buffer;
}

- (id)initWithName:(NSString *)elementName attributes:(NSDictionary *)attributes parent:(BMParserElement *)parentElement;

@property(nonatomic, readonly) NSString *elementName;
@property(nonatomic, readonly) NSDictionary *attributes;
@property(nonatomic, readonly) BMParserElement *parentElement;
@property(nonatomic, readonly) NSDictionary *fieldMappings;
@property(nonatomic, assign) BOOL treatAttributesAsElements;
@property(nonatomic, assign) BOOL nilElement;
@property(nonatomic, strong) NSObject<BMMappableObject> *modelObject;
@property(nonatomic, strong) id context;
@property(strong, nonatomic, readonly) NSString *elementText;

- (void)fillModelObject;

//Converts this object to an XML string (using the element name and attibutes and those of its parents recursively)
- (NSString *)xmlString;

//Returns true if the XML returned by xmlString returns > 0 results by matching the supplied xpath expression.
- (BOOL)matchesXPath:(NSString *)xpath;

- (void)appendText:(NSString *)text;

@end
