//
// Created by Werner Altewischer on 10/10/16.
// Copyright (c) 2016 BehindMedia. All rights reserved.
//

#import "BMValueStack.h"
#import "BMPropertyDescriptor.h"
#import "NSObject+BMCommons.h"
#import <BMCommons/BMWeakReferenceRegistry.h>

@interface BMValueStackObject : NSObject

@property (nonatomic, strong) id value;
@property (nonatomic, strong) id key;

@end

@implementation BMValueStackObject

@end

@implementation BMValueStack {
    NSMutableArray *_stack;
    id _value;
    id _defaultValue;
    BMPropertyDescriptor *_propertyDescriptor;
}

BM_LISTENER_METHODS_IMPLEMENTATION(BMValueStackListener)

- (id)init {
    if ((self = [super init])) {
        _stack = [NSMutableArray new];
    }
    return self;
}

- (id)keyForOwner:(id)owner {
    return [NSNumber numberWithUnsignedInteger:(NSUInteger)owner];
}

- (void)pushValue:(id)value forOwner:(id)owner {
    @synchronized(self) {
        __typeof(self) __weak weakSelf = self;
        id key = [self keyForOwner:owner];

        if (self.shouldAutomaticallyCleanupStatesForDeallocatedOwners) {
            [[BMWeakReferenceRegistry sharedInstance] registerReference:owner withCleanupBlock:^{
                [weakSelf valuesForOwnerKey:key all:YES pop:YES];
            }];
        }

        BMValueStackObject *stackValue = [BMValueStackObject new];
        stackValue.value = value;
        stackValue.key = key;

        [_stack addObject:stackValue];
        [self updateValue];
    }
}

- (NSArray *)valuesForOwner:(id)owner all:(BOOL)all pop:(BOOL)pop {
    @synchronized(self) {
        NSArray *values = nil;
        if (_stack.count > 0) {
            id key = [self keyForOwner:owner];
            values = [self valuesForOwnerKey:key all:all pop:pop];
        }
        return values;
    }
}

- (NSArray *)popValuesForOwner:(id)owner {
    return [self valuesForOwner:owner all:YES pop:YES];
}

- (id)popValueForOwner:(id)owner {
    return [[self valuesForOwner:owner all:NO pop:YES] firstObject];
}

- (NSArray *)valuesForOwner:(id)owner {
    return [self valuesForOwner:owner all:YES pop:NO];
}

- (id)resultingValueFromStackValues:(NSArray *)stackValues {
    id ret;
    if (self.resultingValueComputationBlock != nil) {
        ret = self.resultingValueComputationBlock(stackValues);
    } else {
        ret = [stackValues lastObject];
    }
    return ret;
}

- (void)updateValue {
    @synchronized(self) {
        id resultingValue = self.defaultValue;
        if (_stack.count > 0) {
            resultingValue = [self resultingValueFromStackValues:[_stack bmArrayByTransformingObjectsWithBlock:^id(BMValueStackObject *stackValue) {
                return stackValue.value;
            }]];
        }

        BOOL changed = (_value != resultingValue && ![_value isEqual:resultingValue]);

        if (changed) {
            _value = resultingValue;

            if (self.propertyDescriptor) {
                [_propertyDescriptor callSetter:_value ignoreFailure:YES];
            }

            [self valueDidChange];

            [self notifyListeners:^(NSObject <BMValueStackListener> *listener) {
                [listener bmSafePerformSelector:@selector(valueStackDidChangeValue:) withObject:self];
            }];
        }
    }
}

- (void)setPropertyDescriptor:(BMPropertyDescriptor *)propertyDescriptor {
    @synchronized(self) {
        if (_propertyDescriptor != propertyDescriptor) {
            _propertyDescriptor = propertyDescriptor;
            id value = self.value;
            [_propertyDescriptor callSetter:value ignoreFailure:YES];
        }
    }
}

- (BMPropertyDescriptor *)propertyDescriptor {
    @synchronized(self) {
        return _propertyDescriptor;
    }
}

- (void)reset {
    @synchronized(self) {
        [_stack removeAllObjects];
        [self updateValue];
    }
}

- (void)setDefaultValue:(id)defaultValue {
    @synchronized(self) {
        if (defaultValue != _defaultValue) {
            _defaultValue = defaultValue;
            if (_stack.count == 0) {
                [self updateValue];
            }
        }
    }
}

- (id)defaultValue {
    @synchronized(self) {
        return _defaultValue;
    }
}

- (id)value {
    @synchronized(self) {
        return _value;
    }
}

- (NSArray *)valuesForOwnerKey:(id)key all:(BOOL)all pop:(BOOL)pop {
    @synchronized(self) {
        NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:_stack.count];
        if (_stack.count > 0) {
            for (NSInteger i = (_stack.count - 1); i >= 0; --i) {
                BMValueStackObject *stackValue = [_stack objectAtIndex:i];
                if ([stackValue.key isEqual:key]) {
                    [ret addObject:stackValue.value];
                    if (pop) {
                        [_stack removeObjectAtIndex:i];
                    }
                    if (!all) {
                        break;
                    }
                }
            }
        }
        if (ret.count > 0 && pop) {
            [self updateValue];
        }
        return ret;
    }
}

- (void)valueDidChange {

}

@end
