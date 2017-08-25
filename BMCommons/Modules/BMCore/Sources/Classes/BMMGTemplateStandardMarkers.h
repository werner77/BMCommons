//
//  MGTemplateStandardMarkers.h
//
//  Created by Matt Gemmell on 13/05/2008.
//  Copyright 2008 Instinctive Code. All rights reserved.
//

#import <BMCommons/BMMGTemplateEngine.h>
#import <BMCommons/BMMGTemplateMarker.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Standard markers for BMMGTemplateEngine.
 */
@interface BMMGTemplateStandardMarkers : NSObject <BMMGTemplateMarker>

@property (nullable, nonatomic, weak) BMMGTemplateEngine *engine;

- (BOOL)currentBlock:(nullable NSDictionary *)blockInfo matchesTopOfStack:(NSMutableArray *)stack;
- (BOOL)argIsNumeric:(NSString *)arg intValue:(NSInteger *)val checkVariables:(BOOL)checkVars;
- (BOOL)argIsTrue:(NSString *)arg;

@end

NS_ASSUME_NONNULL_END
