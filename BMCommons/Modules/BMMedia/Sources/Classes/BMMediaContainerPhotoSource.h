//
//  BMMediaContainerPhotoSource.h
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMutablePhotoSource.h>
#import <BMMedia/BMMediaContainer.h>
#import <BMMedia/BMServiceModel.h>

/**
 BMTTPhotoSource implementation containing BMMediaContainer instances.
 
 This class has support for loading it's model asynchronously using a BMService implementation because it inherits from BMServiceModel. It also supports the mutation methods specified by BMMutablePhotoSource.
 The class uses BMMediaContainerPhoto for each BMMediaContainer or array of BMMediaContainers specified in the methods
 initWithTitle:medias: , addMedia: or setMedia:.
 The term "photo" is slightly misused because in fact it's an item containing either multiple pictures (presented in a slideshow) or a video.
 */
@interface BMMediaContainerPhotoSource : BMServiceModel <BMMutablePhotoSource>

/**
 The array of media containers. 
 
 Instances of BMMediaContainer.
 */
@property (nonatomic, readonly) NSArray *media;

/**
 Initializes with a title for the source and an array of BMMediaContainer instances.
 
 @see addMedia:
 */
- (id)initWithTitle:(NSString*)theTitle medias:(NSArray*)theMedias;

/**
 Adds media from an array containing BMMediaContainer instances or an array of BMMediaContainer instances. Internally BMMediaContainerPhoto instances are instantiated using either a single BMMediaContainer or an array of BMMediaContainers.
 
 @see [BMMediaContainerPhoto initWithMedia:]
 @see [BMMediaContainerPhoto initWithMedias:]
 */
- (void)addMedia:(NSArray *)theMedias;
 
/**
 Clears the current array. Does *not* perform deletion on the individual items, it just clears the internal array of media containers. Use [BMMutablePhotoSource deletePhotoAtIndex:] to delete items.
 */
- (void)clear;

/**
 Overwrites the medias with a new array.
 
 @see clear
 @see addMedia:
 */
- (void)setMedia:(NSArray *)theMedias;

/**
 A string containing the caption for the specified mediaContainer. 
 
 Sub classes may override this.
 */
- (NSString *)captionForMedia:(id <BMMediaContainer>)mediaContainer;

/**
 The total number of BMMediaContainerPhoto instances within this source. The result is always the total count independent of the value set for filteredPhotoKinds. The method numberOfPhotos will return a value which reflects the filteredPhotoKinds.
 
 @see numberOfPhotos
 @see filteredPhotoKinds
 */
- (NSUInteger)numberOfMediaPhotos;

/**
 The total number of BMMediaContainerPhoto instances containing pictures within this source.
 */
- (NSUInteger)numberOfPicturePhotos;

/**
 The total number of BMMediaContainerPhoto instances containing videos within this source.
 */
- (NSUInteger)numberOfVideoPhotos;

@end
