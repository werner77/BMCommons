//
// Copyright 2009-2011 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20Core/BMTTGlobalCoreLocale.h"

// Core
#import "Three20Core/BMTTDebug.h"
#import <BMCommons/BMLocalization.h>


///////////////////////////////////////////////////////////////////////////////////////////////////
NSLocale* BMTTCurrentLocale() {
  NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
  NSArray* languages = [defaults objectForKey:@"AppleLanguages"];
  if (languages.count > 0) {
    NSString* currentLanguage = [languages objectAtIndex:0];
    return [[[NSLocale alloc] initWithLocaleIdentifier:currentLanguage] autorelease];

  } else {
    return [NSLocale currentLocale];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* BMTTLocalizedString(NSString* key, NSString* comment) {
    static NSBundle* bundle = nil;
    if (nil == bundle) {
        NSString* path = [[[NSBundle mainBundle] resourcePath]
                          stringByAppendingPathComponent:@"BMThree20.bundle"];
        bundle = [[NSBundle bundleWithPath:path] retain];
    }
    return [[BMLocalization sharedInstance] localizedStringForKey:key defaultValue:key table:@"BMThree20" fallbackBundle:bundle];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* BMTTDescriptionForError(NSError* error) {
  BMTTDINFO(@"ERROR %@", error);

  if ([error.domain isEqualToString:NSURLErrorDomain]) {
    // Note: If new error codes are added here, be sure to document them in the header.
    if (error.code == NSURLErrorTimedOut) {
      return BMTTLocalizedString(@"Connection Timed Out", @"");

    } else if (error.code == NSURLErrorNotConnectedToInternet) {
      return BMTTLocalizedString(@"No Internet Connection", @"");

    } else {
      return BMTTLocalizedString(@"Connection Error", @"");
    }
  }
  return BMTTLocalizedString(@"Error", @"");
}


///////////////////////////////////////////////////////////////////////////////////////////////////
NSString* BMTTFormatInteger(NSInteger num) {
  NSNumber* number = [NSNumber numberWithInteger:num];
  NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
  NSString* formatted = [formatter stringFromNumber:number];
  [formatter release];
  return formatted;
}
