//
//  MGTemplateEngine.h
//
//  Created by Matt Gemmell on 11/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

// Keys in blockInfo dictionaries passed to delegate methods.
#import <Foundation/Foundation.h>

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
- (id)initWithTemplateEngine:(BMMGTemplateEngine *)engine;
- (void)engineSettingsChanged; // always called at least once before beginning to process a template.
- (NSDictionary *)firstMarkerWithinRange:(NSRange)range;
@end

#import <BMCore/BMMGTemplateMarker.h>
#import <BMCore/BMMGTemplateFilter.h>

/**
 Fork of MGTemplateEngine part of Matt Gemmel's MGTemplateEngine project.
 
 @see http://mattgemmell.com/2008/05/20/mgtemplateengine-templates-with-cocoa/
 */
@interface BMMGTemplateEngine : NSObject {
@public
	NSString *markerStartDelimiter;		// default: {%
	NSString *markerEndDelimiter;		// default: %}
	NSString *expressionStartDelimiter;	// default: {{
	NSString *expressionEndDelimiter;	// default: }}
	NSString *filterDelimiter;			// default: |	example: {{ myVar|uppercase }}
	NSString *literalStartMarker;		// default: literal
	NSString *literalEndMarker;			// default: /literal
@private
	NSMutableArray *_openBlocksStack;
	NSMutableDictionary *_globals;
	NSInteger _outputDisabledCount;
	NSUInteger _templateLength;
	NSMutableDictionary *_filters;
	NSMutableDictionary *_markers;
	NSMutableDictionary *_templateVariables;
	BOOL _literal;
@public
	NSRange remainingRange;
	id <BMMGTemplateEngineDelegate> __weak delegate;
	id <BMMGTemplateEngineMatcher> matcher;
	NSString *templateContents;
}

@property(strong) NSString *markerStartDelimiter;
@property(strong) NSString *markerEndDelimiter;
@property(strong) NSString *expressionStartDelimiter;
@property(strong) NSString *expressionEndDelimiter;
@property(strong) NSString *filterDelimiter;
@property(strong) NSString *literalStartMarker;
@property(strong) NSString *literalEndMarker;
@property(assign, readonly) NSRange remainingRange;
@property(weak) id <BMMGTemplateEngineDelegate> delegate;	// weak ref
@property(strong) id <BMMGTemplateEngineMatcher> matcher;
@property(strong, readonly) NSString *templateContents;

// Creation.
+ (NSString *)version;
+ (BMMGTemplateEngine *)templateEngine;

// Managing persistent values.
- (void)setObject:(id)anObject forKey:(id)aKey;
- (void)addEntriesFromDictionary:(NSDictionary *)dict;
- (id)objectForKey:(id)aKey;

// Configuration and extensibility.
- (void)loadMarker:(NSObject <BMMGTemplateMarker> *)marker;
- (void)loadFilter:(NSObject <BMMGTemplateFilter> *)filter;

// Utilities.
- (NSObject *)resolveVariable:(NSString *)var;
- (NSDictionary *)templateVariables;

// Processing templates.
- (NSString *)processTemplate:(NSString *)templateString withVariables:(NSDictionary *)variables;
- (NSString *)processTemplateInFileAtPath:(NSString *)templatePath withVariables:(NSDictionary *)variables;

@end
