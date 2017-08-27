//
//  BMObjectMappingParserHandler.h
//  BMCommons
//
//  Created by Werner Altewischer on 10/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMParserHandler.h>
#import <BMCommons/BMMappableObjectClassResolver.h>

NS_ASSUME_NONNULL_BEGIN

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
+ (void)setDefaultInitBlock:(nullable BMObjectMappingParserHandlerInitBlock)block;

/**
 The element that is parsed currently.
 */
@property(nullable, strong, nonatomic, readonly) BMParserElement *currentElement;

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
@property (nullable, nonatomic, strong) id <BMMappableObjectClassResolver> mappableObjectClassResolver;

/**
 The name of the attribute that contains a type descriptor in case of polymorphic mappings.
 */
@property (nullable, nonatomic, strong) NSString *customTypeDescriptorAttributeName;

/**
 The root model object that has been parsed.
 */
- (nullable id <BMMappableObject>)rootModelObject;

/**
 Intitializes with the specified xpath which designates the XML Node from which parsing should commence and the class which implements BMMappableObject to which the parser should map the message.
 */
- (id)initWithXPath:(nullable NSString *)rootXPath
			 rootElementClass:(nullable Class <BMMappableObject>)elementClass
					 delegate:(nullable id <BMParserHandlerDelegate>)theDelegate;

/**
 Initializes with a separate error xpath for an error response.
 */
- (id)initWithXPath:(nullable NSString *)rootXPath rootElementClass:(nullable Class <BMMappableObject>)elementClass
		 errorXPath:(nullable NSString *)errorXPath errorRootElementClass:(nullable Class <BMMappableObject>)errorElementClass
					 delegate:(nullable id <BMParserHandlerDelegate>)theDelegate;

@end

NS_ASSUME_NONNULL_END
