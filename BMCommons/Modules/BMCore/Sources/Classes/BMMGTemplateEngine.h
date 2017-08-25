//
//  MGTemplateEngine.h
//
//  Created by Matt Gemmell on 11/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

// Keys in blockInfo dictionaries passed to delegate methods.
#import <Foundation/Foundation.h>
#import <BMCommons/BMMGTemplateMarker.h>
#import <BMCommons/BMMGTemplateFilter.h>

NS_ASSUME_NONNULL_BEGIN

#define	BLOCK_NAME_KEY					@"name"				// NSString containing block name (first word of marker)
#define BLOCK_END_NAMES_KEY				@"endNames"			// NSArray containing names of possible ending-markers for block
#define BLOCK_ARGUMENTS_KEY				@"args"				// NSArray of further arguments in block start marker
#define BLOCK_START_MARKER_RANGE_KEY	@"startMarkerRange"	// NSRange (as NSValue) of block's starting marker
#define BLOCK_VARIABLES_KEY				@"vars"				// NSDictionary of variables

#define TEMPLATE_ENGINE_ERROR_DOMAIN	@"BMMGTemplateEngineErrorDomain"

@class BMMGTemplateEngine;

/**
 Delegate for BMMGTemplateEngine.
 */
@protocol BMMGTemplateEngineDelegate <NSObject>
@optional
- (void)templateEngine:(BMMGTemplateEngine *)engine blockStarted:(NSDictionary *)blockInfo;
- (void)templateEngine:(BMMGTemplateEngine *)engine blockEnded:(NSDictionary *)blockInfo;
- (void)templateEngineFinishedProcessingTemplate:(BMMGTemplateEngine *)engine;
- (void)templateEngine:(BMMGTemplateEngine *)engine encounteredError:(NSError *)error isContinuing:(BOOL)continuing;
@end

// Keys in marker dictionaries returned from Matcher methods.
#define MARKER_NAME_KEY					@"name"				// NSString containing marker name (first word of marker)
#define MARKER_TYPE_KEY					@"type"				// NSString, either MARKER_TYPE_EXPRESSION or MARKER_TYPE_MARKER
#define MARKER_TYPE_MARKER				@"marker"
#define MARKER_TYPE_EXPRESSION			@"expression"
#define MARKER_ARGUMENTS_KEY			@"args"				// NSArray of further arguments in marker, if any
#define MARKER_FILTER_KEY				@"filter"			// NSString containing name of filter attached to marker, if any
#define MARKER_FILTER_ARGUMENTS_KEY		@"filterArgs"		// NSArray of filter arguments, if any
#define MARKER_RANGE_KEY				@"range"			// NSRange (as NSValue) of marker's range

/**
 Matcher for BMMGTemplateEngine.
 */
@protocol BMMGTemplateEngineMatcher <NSObject>
@required
- (id)initWithTemplateEngine:(BMMGTemplateEngine *)engine NS_DESIGNATED_INITIALIZER;
- (void)engineSettingsChanged; // always called at least once before beginning to process a template.
- (nullable NSDictionary *)firstMarkerWithinRange:(NSRange)range;
@end

/**
 Fork of MGTemplateEngine part of Matt Gemmel's MGTemplateEngine project.
 
 @see http://mattgemmell.com/2008/05/20/mgtemplateengine-templates-with-cocoa/
 */
@interface BMMGTemplateEngine : NSObject

@property(strong) NSString *markerStartDelimiter;
@property(strong) NSString *markerEndDelimiter;
@property(strong) NSString *expressionStartDelimiter;
@property(strong) NSString *expressionEndDelimiter;
@property(strong) NSString *filterDelimiter;
@property(strong) NSString *literalStartMarker;
@property(strong) NSString *literalEndMarker;
@property(assign, readonly) NSRange remainingRange;

@property(nullable, weak) id <BMMGTemplateEngineDelegate> delegate;
@property(nullable, strong) id <BMMGTemplateEngineMatcher> matcher;
@property(nullable, strong, readonly) NSString *templateContents;

// Creation.
+ (BMMGTemplateEngine *)templateEngine;

// Managing persistent values.
- (void)setObject:(id)anObject forKey:(id)aKey;
- (void)addEntriesFromDictionary:(NSDictionary *)dict;
- (nullable id)objectForKey:(id)aKey;

// Configuration and extensibility.
- (void)loadMarker:(NSObject <BMMGTemplateMarker> *)marker;
- (void)loadFilter:(NSObject <BMMGTemplateFilter> *)filter;

// Utilities.
- (nullable NSObject *)resolveVariable:(NSString *)var;
- (NSDictionary *)templateVariables;

// Processing templates.
- (nullable NSString *)processTemplate:(NSString *)templateString withVariables:(nullable NSDictionary *)variables;
- (nullable NSString *)processTemplateInFileAtPath:(NSString *)templatePath withVariables:(nullable NSDictionary *)variables;

@end

NS_ASSUME_NONNULL_END
