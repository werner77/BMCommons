//
//  BMObjectMappingParserHandler.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMRestKit/BMParserHandler.h>
#import <BMRestKit/BMMappableObjectClassResolver.h>

@class BMXMLElement;
@class BMXMLDocument;

/**
 Implementation of BMParserHandler that automatically maps XML/JSON to objects.
 */
@interface BMObjectMappingParserHandler : BMParserHandler

typedef void(^BMObjectMappingParserHandlerInitBlock)(BMObjectMappingParserHandler *handler);

/**
 Set a block to apply default configuration for every instance that is created.
 */
+ (void)setDefaultInitBlock:(BMObjectMappingParserHandlerInitBlock)block;

/**
 The element that is parsed currently.
 */
@property(strong, nonatomic, readonly) BMParserElement *currentElement;

/**
 Returns true if the parsed response is an error response, false otherwise.
 */
@property(nonatomic, readonly) BOOL errorResponse;

/**
 Set to true to force the error path of parsing.
 
 This may be necessary to parse error elements in JSON when there is no root element to distinguish on.
 */
@property (nonatomic, assign) BOOL forceErrorResponse;

/**
 Class resolver for mapping a custom class from an optional type descriptor.
 
 @see customTypeDescriptorAttributeName
 */
@property (nonatomic, strong) id <BMMappableObjectClassResolver> mappableObjectClassResolver;

/**
 The name of the attribute that contains a type descriptor in case of polymorphic mappings.
 */
@property (nonatomic, strong) NSString *customTypeDescriptorAttributeName;

/**
 The root model object that has been parsed.
 */
- (id <BMMappableObject>)rootModelObject;

/**
 Intitializes with the specified xpath which designates the XML Node from which parsing should commence and the class which implements BMMappableObject to which the parser should map the message.
 */
- (id)initWithXPath:(NSString *)rootXPath 
			 rootElementClass:(Class <BMMappableObject>)elementClass 
					 delegate:(id <BMParserHandlerDelegate>)theDelegate;

/**
 Initializes with a separate error xpath for an error response.
 */
- (id)initWithXPath:(NSString *)rootXPath rootElementClass:(Class <BMMappableObject>)elementClass 
		 errorXPath:(NSString *)errorXPath errorRootElementClass:(Class <BMMappableObject>)errorElementClass	
					 delegate:(id <BMParserHandlerDelegate>)theDelegate;

@end
