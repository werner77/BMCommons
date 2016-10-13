/*
 *  BMMutablePhotoSource.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 23/06/11.
 *  Copyright 2011 BehindMedia. All rights reserved.
 *
 */

#import <BMThree20/Three20UI/BMTTPhotoSource.h>

/**
 Protocol declaring a mutable photo source.
 */
@protocol BMMutablePhotoSource<BMTTPhotoSource>

/**
 Deletes the photo at the specified index, also removing its data.
 */
- (void)deletePhotoAtIndex:(NSInteger)index;

/**
 Sets the caption for the photo at the specified index.
 */
- (void)setCaption:(NSString *)theCaption forPhotoAtIndex:(NSInteger)index;

/**
 Returns true if the model for this source has changed after initialization. 
 
 Calling deletePhotoAtIndex: or setCaption:forPhotoAtIndex: with a changed caption should cause this method to return true.
 */
- (BOOL)isChanged;

@end