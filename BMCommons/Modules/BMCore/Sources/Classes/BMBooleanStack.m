//
//  BMBooleanStack.m
//  BMCommons
//
//  Created by Werner Altewischer on 05/11/14.
//  Copyright (c) 2014 BehindMedia. All rights reserved.
//

#import <BMCommons/BMBooleanStack.h>

@interface BMBooleanStack()

@end

@implementation BMBooleanStack {
    BMPropertyDescriptor *_booleanPropertyDescriptor;
    BMBooleanStackOperationType _operationType;
}

- (instancetype)init {
    if ((self = [super init])) {
        __typeof(self) __weak weakSelf = self;
        self.resultingValueComputationBlock = ^id(NSArray *values) {
            id resultingValue = weakSelf.defaultValue;
            if (weakSelf.operationType == BMBooleanStackOperationTypeTop) {
                resultingValue = [values lastObject];
            } else if (self.operationType == BMBooleanStackOperationTypeOR) {
                for (NSNumber *value in values) {
                    if ([value boolValue]) {
                        resultingValue = @(YES);
                        break;
                    }
                }
            } else if (self.operationType == BMBooleanStackOperationTypeAND) {
                for (NSNumber *value in values) {
                    if ([value boolValue]) {
                        resultingValue = @(YES);
                    } else {
                        resultingValue = @(NO);
                        break;
                    }
                }
            }
            return resultingValue;
        };
    }
    return self;
}

- (void)setDefaultState:(BOOL)defaultState {
    self.defaultValue = @(defaultState);
}

- (BOOL)defaultState {
    return [self.defaultValue boolValue];
}

- (void)pushState:(BOOL)state forOwner:(id)owner {
    [self pushValue:@(state) forOwner:owner];
}

- (void)popStateForOwner:(id)owner {
    [self popValueForOwner:owner];
}

- (void)popStatesForOwner:(id)owner {
    [self popValuesForOwner:owner];
}

- (BOOL)state {
    return [self.value boolValue];
}

- (void)valueDidChange {
    BOOL state = self.state;
    [self.booleanPropertyDescriptor invokeSetter:&state valueLength:sizeof(BOOL) ignoreFailure:YES];
}

- (void)setBooleanPropertyDescriptor:(BMPropertyDescriptor *)booleanPropertyDescriptor {
    @synchronized(self) {
        if (_booleanPropertyDescriptor != booleanPropertyDescriptor) {
            _booleanPropertyDescriptor = booleanPropertyDescriptor;
            BOOL state = self.state;
            [self.booleanPropertyDescriptor invokeSetter:&state valueLength:sizeof(BOOL) ignoreFailure:YES];
        }
    }
}

- (BMPropertyDescriptor *)booleanPropertyDescriptor {
    @synchronized (self) {
        return _booleanPropertyDescriptor;
    }
}

- (void)setOperationType:(BMBooleanStackOperationType)operationType {
    @synchronized(self) {
        if (_operationType != operationType) {
            _operationType = operationType;
            [self updateValue];
        }
    }
}

- (BMBooleanStackOperationType)operationType {
    @synchronized(self) {
        return _operationType;
    }
}

@end
