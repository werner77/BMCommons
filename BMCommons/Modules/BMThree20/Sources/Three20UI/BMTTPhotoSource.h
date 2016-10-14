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

// Network
#import <BMCommons/Three20Network/BMTTModel.h>

#define BMTT_NULL_PHOTO_INDEX NSIntegerMax

typedef NS_ENUM(NSUInteger, BMTTPhotoKind) {
    BMTTPhotoKindNone = 0x0,
    BMTTPhotoKindPicture = 0x1,
    BMTTPhotoKindVideo = 0x2,
    BMTTPhotoKindAll = 0xFF
};

@protocol BMTTPhoto;

@protocol BMTTPhotoSource <BMTTModel>

/**
 * The title of this collection of photos.
 */
@property (nonatomic, copy) NSString* title;

/**
 * The total number of photos in the source, independent of the number that have been loaded.
 */
@property (nonatomic, readonly) NSInteger numberOfPhotos;

/**
 * The maximum index of photos that have already been loaded.
 */
@property (nonatomic, readonly) NSInteger maxPhotoIndex;

/**
 * The filtered photo kinds, default should be all.
 */
@property (nonatomic, assign) BMTTPhotoKind filteredPhotoKinds;

- (id<BMTTPhoto>)photoAtIndex:(NSInteger)index;
- (NSInteger)indexOfPhoto:(id <BMTTPhoto>)photo;

@end
