//
//  BMParser.h
//  BMCommons
//
//  Created by Werner Altewischer on 2/3/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BMParser;

/**
 Delegate protocol for receiving parser events. 
 
 Modelled after NSXMLParserDelegate. See the documentation of that protocol for more details.
 */
@protocol BMParserDelegate <NSObject>

@optional

/**
 Sent when the parser begins parsing of the document.
 */
- (void)parser:(BMParser *)parser didStartDocumentOfType:(NSString *)documentType;

/** 
 Sent when the parser has completed parsing. 
 
 If this is encountered, the parse was successful.
 */
- (void)parserDidEndDocument:(BMParser *)parser;

/**
 Sent when the parser finds an element start tag.
 
 In the case of the cvslog tag, the following is what the delegate receives:
 
 - elementName == cvslog, namespaceURI == http://xml.apple.com/cvslog, qualifiedName == cvslog
 
 In the case of the radar tag, the following is what's passed in:
 
 - elementName == radar, namespaceURI == http://xml.apple.com/radar, qualifiedName == radar:radar
 
 If namespace processing isn't on, the xmlns:radar="http://xml.apple.com/radar" is returned as an attribute pair, the elementName is 'radar:radar' and there is no qualifiedName.
 */
- (void)parser:(BMParser *)parser
didStartElement:(NSString *)elementName 
	namespaceURI:(NSString *)namespaceURI 
	qualifiedName:(NSString *)qName 
	attributes:(NSDictionary *)attributeDict;


/**
 Sent when an end tag is encountered.
 
 The various parameters are supplied as in parser:didStartElement:namespaceURI:qualifiedName:attributes:.
 */
- (void)parser:(BMParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName;

/** 
 This returns the string of the characters encountered thus far. 
 
 You may not necessarily get the longest character run. The parser reserves the right to hand these to the delegate as potentially many calls in a row to parser:foundCharacters:
 */
- (void)parser:(BMParser *)parser foundCharacters:(NSString *)string;

/**
 The parser reports ignorable whitespace in the same way as characters it's found.
 */
- (void)parser:(BMParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString;

/**
 A comment (Text in a <!-- --> block) is reported to the delegate as a single string.
 */
- (void)parser:(BMParser *)parser foundComment:(NSString *)comment;

/**
 Reports a fatal error to the delegate. 
 
 The parser will stop parsing.
 */
- (void)parser:(BMParser *)parser parseErrorOccurred:(NSError *)parseError;

/**
 If validation is on, this will report a fatal validation error to the delegate. 
 
 The parser will stop parsing.
 */
- (void)parser:(BMParser *)parser validationErrorOccurred:(NSError *)validationError;


@end

/**
 Delegate protocol for parser progress messages. The parser reports progress as a value between 0.0 and 1.0.
 */
@protocol BMParserProgressDelegate <NSObject>
- (void) parser: (BMParser *) parser updateProgress: (float) progress;
@end


extern NSString * const BMParsingRunLoopMode;


/**
 Base class for parsing XML/JSON documents.
 */
@interface BMParser : NSObject<NSStreamDelegate>

/**
 The parser delegate
 */
@property (nonatomic, weak) id<BMParserDelegate> delegate;

/**
 The progress delegate
 */
@property (nonatomic, weak) id<BMParserProgressDelegate> progressDelegate;

/**
 Contains the error in case parsing was unsuccessful
 */
@property (strong, nonatomic, readonly) NSError * parserError;

/**
 The total length of the the data to parse in bytes
 */
@property (nonatomic, readonly) NSUInteger totalDataLength;

/**
 The parsed data length in bytes
 */
@property (nonatomic, readonly) NSUInteger parsedDataLength;

/**
 Returns true if parsing was aborted.
 */
@property (nonatomic, readonly) BOOL parsingAborted;

/**
 Designated initializer: Initializes the parser with an input stream for streaming parsing. 
 
 All other initializers call this one.
 */
- (id) initWithStream: (NSInputStream *) stream;

/**
 Initializes the parser with the supplied data.
 */
- (id) initWithData: (NSData *) data; 

/**
 Starts a URL connection for the specified request and reads data from the response.
 */
- (id) initWithResultOfURLRequest:(NSURLRequest*)request;

/**
 Creates a URL request for the specified URL and reads from the response.
 */
- (id) initWithContentsOfURL:(NSURL *)url;

/**
 Starts parsing synchronously. 
 
 The method returns when the parser has finished parsing.
 @returns true if parsed successfully, false otherwise
 */
- (BOOL) parse;

/**
 Returns true if parsing is underway, false otherwise. 
 
 Only relevant when asynchronous parsing is used.
 */
- (BOOL) isParsing;

/**
 Aborts asynchronous parsing
 */
- (void) abortParsing;

/**
 Does the same as abortParsing but additionally sends a completion message to the asyncDelegate
 */
- (void) stopParsing;

/**
 Parses asynchronously
 
 @param runloop The runloop to use for parsing
 @param mode The runloop mode to use
 @param asyncCompletionDelegate the delegate to inform of completion event
 @param completionSelector the completion selector to call on the delegate
 @param contextPtr an optional context to supply to the callback
 
 The completionSelector should match the following structure:
 @code
 - (void) xmlParser: (AQXMLParser *) parser completedOK: (BOOL) parsedOK context: (void *) context;
 @endcode
 */
- (BOOL) parseAsynchronouslyUsingRunLoop: (NSRunLoop *) runloop
                                    mode: (NSString *) mode
                       notifyingDelegate: (id) asyncCompletionDelegate
                                selector: (SEL) completionSelector
                                 context: (id <NSObject>) contextPtr;


@end

/**
 Protected methods: can be used/overridden by sub classes. 
 
 Be sure to call super version for all methods.
 */
@interface BMParser(Protected)

/**
 Called when parser has finished.
 */
- (void)parserFinished;

/**
 Called when parser was aborted.
 */
- (void)parserAborted;

/**
 Implement to parse the supplied bytes
 */
- (void)parseData:(const void *)bytes length:(NSUInteger)length;

/**
 Override to perform additional initialization
 */
- (void)initializeParserWithBytes: (const void *) buf length: (NSUInteger) length;

/**
 Override this method instead of dealloc
 */
- (void)parserDealloc;

/**
 Sets the parser error.
 */
- (void)setParserError:(NSError *)error;

@end