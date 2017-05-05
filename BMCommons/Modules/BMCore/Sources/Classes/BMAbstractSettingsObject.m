//
//  BMAbstractSettingsObject.m
//  BMCommons
//
//  Created by Werner Altewischer on 09/11/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMAbstractSettingsObject.h>
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/NSObject+BMCommons.h>
#import <BMCommons/BMCore.h>

@interface BMAbstractSettingsObject()

@property(getter=isObserving) BOOL observing;

@end

@implementation BMAbstractSettingsObject

BM_SYNTHESIZE_DEFAULT_ABSTRACT_SINGLETON

static NSMutableDictionary *cachedDescriptors = nil;

+ (void)initialize {
	if (cachedDescriptors == nil) {
		cachedDescriptors = [NSMutableDictionary new];
	}
}

+ (NSArray *)keysArray {
	NSMutableArray *keysArray = [NSMutableArray new];
    NSArray *valueIVars = [self valuePropertiesArray];
    for (int i = 0; i < valueIVars.count; ++i) {
        [keysArray addObject:[NSNull null]];
    }
	return keysArray;
}

+ (NSArray *)defaultValuesArray {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+ (NSArray *)valuePropertiesArray {
	[self doesNotRecognizeSelector:_cmd];
	return nil;
}

+ (NSArray *)settingsPropertiesDescriptorsArray {
    NSArray *keys = [self keysArray];
    NSArray *objects = [self defaultValuesArray];
    NSArray *valueProperties = [self valuePropertiesArray];
    
    if (keys.count != objects.count || keys.count != valueProperties.count || objects.count != valueProperties.count) {
        NSException *exception = [NSException exceptionWithName:@"BMInvalidDefaultsException" reason:@"Number of keys should equal number of default values and value properties" userInfo:nil];
        @throw exception;
    }
    
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:keys.count];
    for (int i = 0; i < keys.count; ++i) {
        NSString *key = [BMObjectHelper filterNSNullObject:keys[i]];
        id defaultValue = [BMObjectHelper filterNSNullObject:objects[i]];
        NSString *propertyKeyPath = [BMObjectHelper filterNSNullObject:valueProperties[i]];
        if (propertyKeyPath) {
            BMSettingsPropertyDescriptor *pd = [BMSettingsPropertyDescriptor propertyDescriptorFromKeyPath:propertyKeyPath valueType:BMValueTypeObject defaultValue:defaultValue keyName:key];
            [ret addObject:pd];
        }
    }
    return ret;
}

+ (NSDictionary *)settingsPropertyDescriptorsDictionary {
    id<NSCopying> classKey = NSStringFromClass(self);

    @synchronized (self) {
        NSMutableDictionary *dict = [cachedDescriptors objectForKey:classKey];
        if (dict == nil) {
            dict = [NSMutableDictionary new];
            for (BMSettingsPropertyDescriptor *pd in [self settingsPropertiesDescriptorsArray]) {
                if (pd && pd.keyPath) {
                    if (pd.keyName == nil) {
                        //Use default keyName
                        NSString *defaultKeyName = [self defaultKeyNameForKeyPath:pd.keyPath];
                        pd.keyName = defaultKeyName;
                    }
                    [dict setObject:pd forKey:pd.keyPath];
                }
            }
            [cachedDescriptors setObject:dict forKey:classKey];
        }
        return dict;
    }
}

+ (BMSettingsPropertyDescriptor *)settingsPropertyDescriptorForKeyPath:(NSString *)keyPath {
    return [[[self class] settingsPropertyDescriptorsDictionary] objectForKey:keyPath];
}

+ (NSDictionary *)defaultValues {
    
    NSArray *descriptors = [[self settingsPropertyDescriptorsDictionary] allValues];
	NSMutableDictionary *defaults = [NSMutableDictionary dictionaryWithCapacity:descriptors.count];
	
	for (BMSettingsPropertyDescriptor *pd in descriptors) {
		id key = pd.keyName;
		id value = pd.defaultValue;
		
		if (value && ![value isKindOfClass:[NSNull class]]) {
			if ([value isKindOfClass:[NSString class]] ||
				[value isKindOfClass:[NSNumber class]] ||
				[value isKindOfClass:[NSDate class]] ||
				[value isKindOfClass:[NSArray class]] ||
				[value isKindOfClass:[NSDictionary class]]) {
				[defaults setObject:value forKey:key];
			} else if ([value conformsToProtocol:@protocol(NSCoding)]) {
				NSData *data = [NSKeyedArchiver archivedDataWithRootObject:(id <NSCoding>)value];
				[defaults setObject:data forKey:key];
			} else {
				LogError(@"Unsupported value %@ for key %@", value, key);
			}
		}
	}
	
	return defaults;
}

+ (BOOL)allowRestoreToDefaults {
	return YES;
}

+ (BMValueTypeConverter *)primitiveValueConverterForValueType:(BMValueType)valueType {
    return (valueType == BMValueTypeObject) ? nil : [BMValueTypeConverter converterForValueType:valueType];
}

+ (NSString *)defaultKeyNameForKeyPath:(NSString *)keyPath {
    return [[NSString stringWithFormat:@"%@_%@", [self namespace], [keyPath stringByReplacingOccurrencesOfString:@"." withString:@"_"]] uppercaseString];
}

+ (NSString *)namespace {
    return NSStringFromClass(self);
}

- (void)dealloc {
	NSArray *descriptors = [[[self class] settingsPropertyDescriptorsDictionary] allValues];
	if (self.isObserving) {
		for (BMSettingsPropertyDescriptor *pd in descriptors) {
            [self removeObserver:self forKeyPath:pd.keyPath];
		}
	}
}

- (void)saveValueForIvar:(NSString *)valueIvar withKey:(NSString *)key inDefaults:(NSUserDefaults *)defaults {
    BMSettingsPropertyDescriptor *pd = [[self class] settingsPropertyDescriptorForKeyPath:valueIvar];
    BMValueTypeConverter *converter = [[self class] primitiveValueConverterForValueType:pd.valueType];

    NSObject *value = nil;
    if (converter) {
        NSUInteger valueLength;
        void *valueBuffer = [pd invokeGetterOnTarget:self valueLength:&valueLength];
        value = [converter objectValueFromPrimitiveValue:valueBuffer withLength:valueLength];
    } else {
        value = [pd callGetterOnTarget:self];
    }

    if (value && ![value isKindOfClass:[NSNull class]]) {
        if ([value isKindOfClass:[NSString class]] ||
                [value isKindOfClass:[NSNumber class]] ||
                [value isKindOfClass:[NSDate class]] ||
                [value isKindOfClass:[NSArray class]] ||
                [value isKindOfClass:[NSDictionary class]]) {
            [defaults setObject:value forKey:key];
        } else if ([value conformsToProtocol:@protocol(NSCoding)]) {
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:(id <NSCoding>)value];
            [defaults setObject:data forKey:key];
        } else {
            LogError(@"Unsupported value %@ for key %@", value, key);
        }
    } else {
        [defaults removeObjectForKey:key];
    }
}

- (void)saveStateInUserDefaults:(NSUserDefaults *)defaults {
    NSArray *descriptors = [[[self class] settingsPropertyDescriptorsDictionary] allValues];
	
	for (BMSettingsPropertyDescriptor *pd in descriptors) {
		NSString *key = pd.keyName;
		NSString *valueIvar = pd.keyPath;
		[self saveValueForIvar:valueIvar withKey:key inDefaults:defaults];
	}
}

- (void)invokeSetterForPropertyDescriptor:(BMSettingsPropertyDescriptor *)pd withValue:(id)value {
    BMValueTypeConverter *converter = [[self class] primitiveValueConverterForValueType:pd.valueType];
    if (converter) {
        NSUInteger size = [converter sizeOfPrimitiveValue];
        void *buffer = malloc(size);
        [converter getPrimitiveValue:buffer withLength:size fromObjectValue:value];
        [pd invokeSetterOnTarget:self withValue:buffer valueLength:size];
        free(buffer);
    } else {
        [pd callSetterOnTarget:self withValue:value];
    }
}

- (void)loadStateFromUserDefaults:(NSUserDefaults *)defaults {
	NSArray *descriptors = [[[self class] settingsPropertyDescriptorsDictionary] allValues];
	
	for (BMSettingsPropertyDescriptor *pd in descriptors) {
        NSString *key = pd.keyName;
        id value = [defaults objectForKey:key];
        if ([value isKindOfClass:[NSData class]]) {
            value = [NSKeyedUnarchiver unarchiveObjectWithData:(NSData *)value];
        }
        [self invokeSetterForPropertyDescriptor:pd withValue:value];
	}
	
	if (!self.isObserving) {
        self.observing = YES;
        for (BMSettingsPropertyDescriptor *pd in descriptors) {
			[self addObserver:self forKeyPath:pd.keyPath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:(__bridge void *)(defaults)];
		}
	}
}

- (void)reset {
    NSDictionary *settingsPropertiesDictionary = [[self class] settingsPropertyDescriptorsDictionary];
    for (NSString *key in settingsPropertiesDictionary) {
        BMSettingsPropertyDescriptor *pd = [settingsPropertiesDictionary objectForKey:key];
        [self invokeSetterForPropertyDescriptor:pd withValue:[BMObjectHelper filterNSNullObject:pd.defaultValue]];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
						change:(NSDictionary *)change
					   context:(void *)context {
	NSUserDefaults *defaults = (__bridge NSUserDefaults *)context;
    
    BMSettingsPropertyDescriptor *pd = [[self class] settingsPropertyDescriptorForKeyPath:keyPath];
	if (pd != nil) {
		[self saveValueForIvar:keyPath withKey:pd.keyName inDefaults:defaults];
	}
}

@end

