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

/**
 * Facts concerning cache policies:
 *
 * - Using NoCache will also disable Etag support.
 */
typedef NS_ENUM(NSUInteger, BMTTURLRequestCachePolicy) {
  BMTTURLRequestCachePolicyNone    = 0,
  BMTTURLRequestCachePolicyMemory  = 1,
  BMTTURLRequestCachePolicyDisk    = 2,
  BMTTURLRequestCachePolicyNetwork = 4,
  BMTTURLRequestCachePolicyNoCache = 8,
  BMTTURLRequestCachePolicyEtag    = 16 | BMTTURLRequestCachePolicyDisk,
  BMTTURLRequestCachePolicyLocal
  = (BMTTURLRequestCachePolicyMemory | BMTTURLRequestCachePolicyDisk),
  BMTTURLRequestCachePolicyDefault
  = (BMTTURLRequestCachePolicyMemory | BMTTURLRequestCachePolicyDisk
     | BMTTURLRequestCachePolicyNetwork),
};
