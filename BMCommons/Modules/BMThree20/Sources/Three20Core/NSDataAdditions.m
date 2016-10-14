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

#import "Three20Core/NSDataAdditions.h"

#import <CommonCrypto/CommonDigest.h>
#import <BMCommons/NSString+BMCommons.h>
#import <BMCommons/BMCore.h>

// Core
#import "Three20Core/BMTTCorePreprocessorMacros.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Additions.
 */
BMTT_FIX_CATEGORY_BUG(NSDataAdditions)

@implementation NSData (BMTTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)md5Hash {
  unsigned char result[CC_MD5_DIGEST_LENGTH];
  CC_MD5([self bytes], BMShortenUIntSafely([self length], nil), result);
  return [NSString bmHexEncodedStringForBytes:result length:CC_MD5_DIGEST_LENGTH];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)sha1Hash {
  unsigned char result[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1([self bytes], BMShortenUIntSafely([self length], nil), result);
  return [NSString bmHexEncodedStringForBytes:result length:CC_SHA1_DIGEST_LENGTH];
}

@end
