//
//  BMAbstractSettingsObject.h
//  BMCommons
//
//  Created by Werner Altewischer on 09/11/09.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMCommons/BMSettingsObject.h>
#import <BMCommons/BMCoreObject.h>
#import <BMCommons/BMSettingsPropertyDescriptor.h>
#import <BMCommons/BMSingleton.h>

/**
 Base class for implementing application settings, stored in NSUserDefaults.
 */
@interface BMAbstractSettingsObject : BMCoreObject<BMSettingsObject> {
	BOOL observing;
}

BM_DECLARE_DEFAULT_SINGLETON

/**
 Returns the array of keys that should be used to store the values in NSUserDefaults. 
 
 Array length should match defaultValuesArray length and valuePropertiesArray length.
 Default implementation returns an array with values "${className}_${propertyName}" in uppercase, where $className is the name of this class and $propertyName are the values returned by valuePropertiesArray.
 */
+ (NSArray *)keysArray;

/**
 Returns the array of default values that should be used to store defaults in NSUserDefaults. 
 
 Defaults are only stored the first time, if a value is already present this has no effect. Array length should match
  keysArray length and valuePropertiesArray length.
 */
+ (NSArray *)defaultValuesArray;

/**
 Returns the array of property names that should be stored to NSUserDefaults. 
 
 Array length should match defaultValuesArray length and keysArray length.
 Properties returned here are automatically set to nil upon dealloc (effectively freeing the memory for retain properties), so there is no need to release them manually.
 */
+ (NSArray *)valuePropertiesArray;

/**
 Use this in favor of keysArray, defaultValuesArray and valuePropertiesArray to specify descriptors for all properties that need to be stored.
 
 The array should contain instances of BMSettingsPropertyDescriptor. If this method is not implemented the descriptors are constructed using the information returned from
 keysArray, defaultValuesArray and valuePropertiesArray.
 */
+ (NSArray *)settingsPropertiesDescriptorsArray;

@end
