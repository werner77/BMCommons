/*
 *  BMMediaContainer.h
 *  BMCommons
 *
 *  Created by Werner Altewischer on 17/09/09.
 *  Copyright 2009 BehindMedia. All rights reserved.
 *
 */

#import <CoreLocation/CoreLocation.h>
#import <UIKit/UIKit.h>

/**
 @constant Notification posted when a media container is updated.
 */
extern NSString *const BMMediaContainerDidUpdateNotification;

/**
 @constant Notification posted when a media container is deleted.
 */
extern NSString *const BMMediaContainerWasDeletedNotification;

@protocol BMMediaContainer;

typedef NS_ENUM(NSUInteger,BMMediaKind) {
	BMMediaKindUnknown = 0x0,
	BMMediaKindPicture = 0x1,
	BMMediaKindVideo = 0x2,
	BMMediaKindAudio = 0x4,
    BMMediaKindAll = 0xFF
};

typedef NS_ENUM(NSUInteger, BMMediaOrientation) {
    BMMediaOrientationUnknown = 0x0,
    BMMediaOrientationPortrait = 0x1,
    BMMediaOrientationLandscape = 0x2
};


/**
 Delegate protocol for listening to events on a BMMediaContainer.
 */

@protocol BMMediaContainerDelegate<NSObject>

/**
 Implement to act on update of the media container.
 
 Update means that the visual representation should update to reflect the media because its data has changed (downloaded successfully for example) or the caption changed just to name two possibilities.
 */
- (void)mediaContainerDidUpdate:(id <BMMediaContainer>)mediaContainer;

/**
 Implement to act on deletion of media. 
 
 The data is no longer available when this method is called.
 */
- (void)mediaContainerWasDeleted:(id <BMMediaContainer>)mediaContainer;

@end

/**
 Protocol defining a container for media data that can reside both locally and remotely.
 */
@protocol BMMediaContainer<NSObject>

/**
 URL for the media data. 
 
 This can be a remote url even if the data is cached locally. The property filePath will return a path to the local data if it is present on the file system.
 @see filePath
 */
@property (nonatomic, retain) NSString *url;

/**
 URL to access the media data via its native API.
 
 Has different meanings depending on where the media is hosted. For YouTube this is the url to update the corresponding video entry for example.
 */
@property (nonatomic, retain) NSString *entryUrl;

/**
 ID to access the media data via its native API.
 
 Has different meanings depending on where the data is hosted. For YouTube this would be the video ID for example.
 */
@property (nonatomic, retain) NSString *entryId;

/**
 url for the mid size image which is suitable for full screen viewing.
 
 This is not necessarily the highest resolution image, but an image suitable for full screen viewing on iOS devices.
 */
@property (nonatomic, retain) NSString *midSizeImageUrl;

/**
 url for the thumbnail image.
 
 The thumbnail image is the smallest and normally loaded before other images to give the user a visual representation as soon as possible.
 */
@property (nonatomic, retain) NSString *thumbnailImageUrl;

/**
 Caption for the media.
 */
@property (nonatomic, retain) NSString *caption;

/**
 Media meta data. 
 
 The contents of the dictionary may vary. In case the source is an ALAsset, normally the mediaData is copied from that ALAsset instance.
 */
@property (nonatomic, retain) NSDictionary *metaData;

/**
 The geographic location of the media.
 */
@property (nonatomic, retain) CLLocation *geoLocation;

/**
 Content type of the media item if known. 
 
 This should be a registered mime type.
 
 @see BMMIMEType
 */
@property (nonatomic, retain) NSString *contentType;

/**
 The actual media data. 
 
 The content type of the data should reflect the contentType property and may vary according to the type of media.
 */
- (NSData *)data;

/**
 Sets the data using the file extension returned by [BMMediaContainer fileExtension].
 */
- (void)setData:(NSData *)theData;

/**
 Sets the data using a custom file extension.
 
 The file exentension is important because without a proper extension sometimes data cannot be loaded properly, e.g. by a MPMoviePlayerController.
 */
- (void)setData:(NSData *)theData withExtension:(NSString *)extension;

/**
 Calls setMidSizeImageData:withExtension: using [BMMediaContainer midSizeImageFileExtension] as default file extension.
 */
- (void)setMidSizeImageData:(NSData *)theData;

/**
 Sets the data for the mid size image using a custom file extension.
 
 @see midSizeImageUrl
 @see setData:withExtension:
 */
- (void)setMidSizeImageData:(NSData *)theData withExtension:(NSString *)extension;

/**
 The data for the midsize image if present locally.
 */
- (NSData *)midSizeImageData;

/**
 Calls setThumbnailImageData:withExtension: supplying [BMMediaContainer thumbnailImageFileExtension] as file extension.
 */
- (void)setThumbnailImageData:(NSData *)data;

/**
 Sets the data for the thumbnail image using a custom file extension.
 
 @see thumbnailImageUrl
 @see setData:withExtension:
 */
- (void)setThumbnailImageData:(NSData *)theData withExtension:(NSString *)extension;

/**
 The data for the thumbnail image if present locally.
 */
- (NSData *)thumbnailImageData;

/**
 Default file extension for the data if none is supplied.
 */
+ (NSString *)fileExtension;

/**
 Default file extension for the thumbnail image data if none is supplied.
 */
+ (NSString *)thumbnailImageFileExtension;

/**
 Default file extension for the midsize image data if none is supplied.
 */
+ (NSString *)midSizeImageFileExtension;


/**
 Thumbnail image to display for the media if present locally.
 */
- (UIImage *)thumbnailImage;
- (void)setThumbnailImage:(UIImage *)image;

/**
 Midsize image to display for the media if present locally.
 */
- (UIImage *)midSizeImage;
- (void)setMidSizeImage:(UIImage *)image;

/**
 The kind of media (video, audio, picture)
 @see BMMediaKind
 */
- (BMMediaKind)mediaKind;

/**
 Release any memory held by caches for the media
 */
- (void)releaseMemory;

/**
 Deletes the object and corresponding data from disk and memory.
 
 Will trigger a BMMediaContainerWasDeletedNotification and a delegate message [BMMediaContainerDelegate mediaContainerWasDeleted:].
 */
- (void)deleteObject;

/**
 The filePath for retrieving the locally stored data if present.
 
If the data is remote or not stored on the file system, this will return nil.
 */
- (NSString *)filePath;

/**
 Sets the data from the specified file by moving the file. (Note: the data is not copied but the file is moved to the data directory).
 
 This is useful for saving video data for example without having to copy the whole file thereby improving performance a lot.
 */
- (void)setDataFromFile:(NSString *)filePath;

/**
 Adds a delegate for receiving updates.
 */
- (void)addDelegate:(id <BMMediaContainerDelegate>)delegate;

/**
 Removes a delegate.
 */
- (void)removeDelegate:(id <BMMediaContainerDelegate>)delegate;

/**
 Saves the thumbnail image (rescales it first if needed to the appropriate size returned by maxThumbnailResolution).
 
 This method should be thread safe so it is possible to execute it in a background thread.
 
 @see [BMMediaContainer maxThumbnailResolution]
 */
- (void)saveThumbnailImage:(UIImage *)image;

/**
 Saves the mid size image (rescales it first if needed to the appropriate size returned by maxMidSizeResolution).
 
 This method should be thread safe so it is possible to execute it in a background thread.
 
 @see [BMMediaContainer maxMidSizeResolution]
 */
- (void)saveMidSizeImage:(UIImage *)image;

/**
 Resolution specifying the max number of pixels in the biggest dimension (width for landscape, height for portrait) for a thumbnail image. 
 */
+ (NSInteger)maxThumbnailResolution;

/**
 Resolution specifying the max number of pixels in the biggest dimension (width for landscape, height for portrait) for a mid size image.
 */
+ (NSInteger)maxMidSizeResolution;

/**
 Returns YES if data is present locally, NO otherwise.
 */
- (BOOL)isLoaded;

/**
 Returns YES if thumbnail image data is present locally, NO otherwise.
 */
- (BOOL)isThumbnailImageLoaded;

/**
 Returns YES if mid size image data is present locally, NO otherwise.
 */
- (BOOL)isMidSizeImageLoaded;

@end

/**
 Extension of BMMediaContainer for media containing a duration (such as video and audio).
 */
@protocol BMMediaWithDurationContainer <BMMediaContainer>

/**
 The duration in seconds.
 */
@property (nonatomic, retain) NSNumber *duration;

@end

/**
 Extension of BMMediaContainer for media that have a size (width/height) and orientation.
 */
@protocol BMMediaWithSizeContainer <BMMediaContainer>

/**
 The width of the media in pixels.
 */
@property (nonatomic, retain) NSNumber *width;

/**
 The height of the media in pixels.
 */
@property (nonatomic, retain) NSNumber *height;

/**
 The orientation of the media.
 */
@property (nonatomic, assign) BMMediaOrientation mediaOrientation;

@end

/**
 Extension of BMMediaContainer for pictures.
 */
@protocol BMPictureContainer <BMMediaWithSizeContainer>

/**
 The full size image.
 */
- (UIImage *)image;
- (void)setImage:(UIImage *)image;

/** Saves the full size image in a thread safe manner.
 
 This method should be safe to call from a different thread.
 The image is resized if it exceeds the maxFullSizeResolution.
 
 @see [BMMediaContainer maxFullSizeResolution]
 */
- (void)saveFullSizeImage:(UIImage *)image;

/**
 Resolution specifying the max number of pixels in the biggest dimension (width for landscape, height for portrait) for a full size image.
 */
+ (NSInteger)maxFullSizeResolution;

@end

/**
 Extension of BMMediaContainer for videos.
 */
@protocol BMVideoContainer <BMMediaWithDurationContainer, BMMediaWithSizeContainer>

/**
 Whether or not the url contains streamable media.
 
 If YES the url should be suitable for opening with a MPMoviePlayerController.
 */
- (BOOL)isStreamable;

@end

@protocol BMAudioContainer <BMMediaWithDurationContainer>

@end

/**
 Protocol for a loader of data for BMMediaContainer instances.
 */
@protocol BMMediaContainerLoader<NSObject>

/**
 Load the data from [BMMediaContainer url]
 */
- (BOOL)startLoading;

/**
 Load the data from [BMMediaContainer thumbnailImageUrl]
 */
- (BOOL)startLoadingThumbnailImage;

/**
 Load the data from [BMMediaContainer midSizeImageUrl]
 */
- (BOOL)startLoadingMidSizeImage;

/**
 Stops/cancels loading.
 */
- (void)stopLoading;

/**
 Returns YES if the loader is currently loading data.
 */
@property (nonatomic, readonly, getter=isLoading) BOOL loading;

/**
 Returns YES if loading failed.
 */
@property (nonatomic, readonly) BOOL failedLoading;

/**
 Returns YES if loading has completed.
 */
@property (nonatomic, readonly) BOOL completedLoading;

@end

