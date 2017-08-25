//
//  BMLocalization.m
//  BMCommons
//
//  Created by Werner Altewischer on 28/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <BMCommons/BMLocalization.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMLogging.h>
#import <BMCommons/BMCore.h>

@implementation BMLocalization {
@private
    NSBundle *_activeBundle;
    NSBundle *_bundle;
    NSMutableArray *_localizables;
    NSLocale *_currentLocale;
    NSString *_currentLocaleIdentifier;
    NSMutableDictionary *_availableLocales;
}

@synthesize currentLocaleIdentifier = _currentLocaleIdentifier, currentLocale = _currentLocale, bundle = _bundle, availableLocales = _availableLocales;

BM_SYNTHESIZE_DEFAULT_SINGLETON

- (NSString *)localeDisplayNameForIdentifier:(NSString *)localeIdentifier {
    return [[self availableLocales] objectForKey:localeIdentifier];
}

- (id)init {
    return [self initWithBundle:nil];
}

- (id)initWithBundle:(NSBundle *)theBundle NS_DESIGNATED_INITIALIZER {
    if ((self = [super init])) {
        if (theBundle == nil) {
            theBundle = [NSBundle mainBundle];
        }
        _bundle = theBundle;
        NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
        NSArray *languages = [defs objectForKey:@"AppleLanguages"];

        //Initialize with the default language
        NSString *current = [languages firstObject];
        [self setCurrentLocaleIdentifier:current];
        
        NSString *extension = @"lproj";
        NSArray *paths = [[NSBundle mainBundle] pathsForResourcesOfType:extension inDirectory:nil];
        _availableLocales = [NSMutableDictionary new];
        NSMutableSet *handledLocales = [NSMutableSet setWithCapacity:paths.count];
        
        for (NSString *path in paths) {
            NSString *filename = [path lastPathComponent];
            NSString *localeIdentifier = [filename substringToIndex:(filename.length - extension.length - 1)];
            
            if (![handledLocales containsObject:localeIdentifier]) {
                [handledLocales addObject:localeIdentifier];
                NSLocale *theLocale = [[NSLocale alloc] initWithLocaleIdentifier:localeIdentifier];
                if (theLocale) {
                    NSString *displayNameString = [theLocale displayNameForKey:NSLocaleLanguageCode value:theLocale.localeIdentifier];
                    [_availableLocales setObject:[BMStringHelper filterNilString:displayNameString] forKey:localeIdentifier];
                }
            }
        }

        _localizables = BMCreateNonRetainingArray();
    }
    return self;
}


- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue table:(NSString *)table {
    NSString *ret = [_activeBundle localizedStringForKey:key value:defaultValue table:table];
    return ret;
}

- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue table:(NSString *)table fallbackBundle:(NSBundle *)fallbackBundle
{
    NSString *notFoundString = @"***";
    NSString *ret = [self localizedStringForKey:key defaultValue:notFoundString table:table];
    
    if ([ret isEqualToString:notFoundString]) {
        NSBundle *b = [self bundleForLocaleIdentifier:self.currentLocaleIdentifier withinBundle:fallbackBundle];
        if (!b) {
            b = fallbackBundle;
        }
        ret = [b localizedStringForKey:key value:defaultValue table:table];
    }
    return ret;
}

- (NSString *)currentLocaleDisplayName {
    return [self localeDisplayNameForIdentifier:self.currentLocaleIdentifier];
}

- (void)localize {
    for (id <BMLocalizable> loc in [NSArray arrayWithArray:_localizables]) {
        [loc localize];
    }
}

- (NSBundle *)bundleForLocaleIdentifier:(NSString *)l withinBundle:(NSBundle *)b {
    NSString *path = [b pathForResource:l ofType:@"lproj"];
    return [NSBundle bundleWithPath:path];
}

- (void)setCurrentLocaleIdentifier:(NSString *)l {
    if (![self.currentLocaleIdentifier isEqual:l]) {

        BM_RELEASE_SAFELY(_activeBundle);
        BM_RELEASE_SAFELY(_currentLocale);
        BM_RELEASE_SAFELY(_currentLocaleIdentifier);

        if (l) {
            LogInfo(@"Setting locale to: %@", l);
            _activeBundle = [self bundleForLocaleIdentifier:l withinBundle:self.bundle];

            if (_activeBundle) {
                _currentLocale = [[NSLocale alloc] initWithLocaleIdentifier:l];
                if (_currentLocale != nil) {
                    _currentLocaleIdentifier = l;
                }
            } else {
                //Use main bundle as default
                _activeBundle = self.bundle;
            }
        }

        [self localize];
    }
}

- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(NSString *)defaultValue {
    return [self localizedStringForKey:key defaultValue:defaultValue table:nil];
}

- (void)registerLocalizable:(id <BMLocalizable>)item {
    if (![_localizables containsObject:item]) {
        [_localizables addObject:item];
    }
}

- (void)deregisterLocalizable:(id <BMLocalizable>)item {
    [_localizables removeObjectIdenticalTo:item];
}

@end
