//
//  BMParserHandler.h
//  BMCommons
//
//  Created by Werner Altewischer on 15/12/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMRestKit/BMParserElement.h>
#import <BMCore/BMParser.h>
#import <BMCore/BMResponseContainer.h>
#import <BMCore/BMErrorContainer.h>

@class BMParserHandler;
@protocol BMMappableObject;

/**
 Delegate protocol for BMParserHandler.
 */
@protocol BMParserHandlerDelegate<NSObject>

@optional

/**
 Whether or not to map the specified element to a model object.
 
 If not implemented, true is assumed.
 */
- (BOOL)handler:(BMParserHandler *)handler shouldParseModelObjectForElementName:(NSString *)elementName;

/**
 Sent after a model object has been parsed.
 */
- (void)handler:(BMParserHandler *)handler didParseModelObject:(NSObject<BMMappableObject> *)modelObject forElementName:(NSString *)elementName;

/**
 Sent when parsing has started.
 */
- (void)handlerDidStartParsing:(BMParserHandler *)handler;

/**
 Sent when parsing has finished.
 */
- (void)handlerDidEndParsing:(BMParserHandler *)handler;	

@end

/**
 Base class for parser handlers.
 
 Handler for SAX style parsing.
 */
@interface BMParserHandler : NSObject<BMParserDelegate, BMResponseContainer, BMErrorContainer> {
    @private
	id <BMParserHandlerDelegate> __weak delegate;
}

/**
 The handler delegate.
 
 @see BMParserHandlerDelegate
 */
@property (nonatomic, weak) id <BMParserHandlerDelegate> delegate;

@end
