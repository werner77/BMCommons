//
//  BMLocalization.h
//  BMCommons
//
//  Created by Werner Altewischer on 28/09/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMCoreObject.h>
#import <BMCommons/BMSingleton.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Protocol to be implemented by classes that want to be notified when the locale settings change.
 */
@protocol BMLocalizable

- (void)localize;

@end

#define BMLocalizedString(s, c) ([[BMLocalization sharedInstance] localizedStringForKey:s defaultValue:c])
#define BMLocalizedStringFromTable(s, t, c) ([[BMLocalization sharedInstance] localizedStringForKey:s defaultValue:c table:t])
#define BMLocalizedStringFromTableInBundle(key, tbl, bundle, comment) \
    [[BMLocalization sharedInstance] localizedStringForKey:(key) defaultValue:(comment) table:(tbl) fallbackBundle:(bundle)]
#define BMLocalizedStringWithDefaultValue(key, tbl, bundle, val, comment) \
    [[BMLocalization sharedInstance] localizedStringForKey:(key) defaultValue:(val) table:(tbl) fallbackBundle:(bundle)]


/**
 Class with support for manually setting the current locale and switching string resources accordingly.
 */
@interface BMLocalization : BMCoreObject

/**
 The currently active locale identifier.
 
 @see [NSLocale localeIdentifier]
 */
@property(nullable, nonatomic, strong) NSString *currentLocaleIdentifier;

/**
 The currently active NSLocale.
 */
@property(nullable, nonatomic, readonly) NSLocale *currentLocale;

/**
 The bundle whith which this instance was initialized.
 */
@property(nonatomic, readonly) NSBundle *bundle;

/**
 A dictionary with key the locale identifier and as value the display name for that locale of all locales for which string resources exist.
 */
@property(nonatomic, readonly) NSDictionary *availableLocales;

BM_DECLARE_DEFAULT_SINGLETON

/**
 * Initializes with the specified resource bundle. If bundle is not specified the mainBundle is used.
 *
 * @param bundle The bundle to use or nil for the main bundle.
 * @return The instance
 */
- (id)initWithBundle:(nullable NSBundle *)bundle NS_DESIGNATED_INITIALIZER;

/**
 * Returns a localized string for the specified key, with optional default value and table.
 *
 * @param key The key to lookup the localized string for
 * @param defaultValue The optional default value
 * @param table The optional custom table to use
 * @return The localized string if found
 * @see [NSBundle localizedStringForKey:value:table:]
 */
- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue table:(nullable NSString *)table;

/**
 * Calls localizedStringForKey:defaultValue:table: with nil table.
 */
- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue;

/**
 Display name for the specified localeIdentifier. 
 
 Works only for available locales.
 
 @see [NSLocale localeIdentifier]
 @see availableLocales
 */
- (nullable NSString *)localeDisplayNameForIdentifier:(NSString *)localeIdentifier;

/**
 Gets the localized string from the specified table with a fallback bundle in case the value could not be found.
 
 First tries to retrieve a localized version for the specified key in the bundle in this instance. If not found it searches the fallback bundle.
 */
- (NSString *)localizedStringForKey:(NSString *)key defaultValue:(nullable NSString *)defaultValue table:(nullable NSString *)table fallbackBundle:(nullable NSBundle *)fallbackBundle;

/**
 Registers a listener for locale changes.
 */
- (void)registerLocalizable:(id<BMLocalizable>)item;

/**
 Deregisters a listener for locale changes.
 */
- (void)deregisterLocalizable:(id<BMLocalizable>)item;

/**
 Human readable name for the current locale
 
 @see currentLocaleIdentifier
 @see currentLocale
 @see localeDisplayNameForIdentifier:
 */
- (nullable NSString *)currentLocaleDisplayName;

/**
 Sends the localize message to all registered localizables
 
 @see BMLocalizable
 */
- (void)localize;

@end

NS_ASSUME_NONNULL_END
