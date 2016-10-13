//
//  MGTemplateStandardMarkers.h
//
//  Created by Matt Gemmell on 13/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import <BMCore/BMMGTemplateEngine.h>
#import <BMCore/BMMGTemplateMarker.h>

/**
 Standard markers for BMMGTemplateEngine.
 */
@interface BMMGTemplateStandardMarkers : NSObject <BMMGTemplateMarker> {
	BMMGTemplateEngine *engine; // weak ref
	NSMutableArray *forStack;
	NSMutableArray *sectionStack;
	NSMutableArray *ifStack;
	NSMutableArray *commentStack;
	NSMutableDictionary *cycles;
}

- (BOOL)currentBlock:(NSDictionary *)blockInfo matchesTopOfStack:(NSMutableArray *)stack;
- (BOOL)argIsNumeric:(NSString *)arg intValue:(NSInteger *)val checkVariables:(BOOL)checkVars;
- (BOOL)argIsTrue:(NSString *)arg;

@end
