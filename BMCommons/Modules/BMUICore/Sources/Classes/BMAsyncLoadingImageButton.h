//
//  BMAsyncLoadingImageButton.h
//  BMCommons
//
//  Created by Werner Altewischer on 18/11/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 Button capable of loading its image from a remote source
 */
@interface BMAsyncLoadingImageButton : UIView

/**
 Whether the button is enabled or not.
 */
@property (nonatomic, assign, getter = isEnabled) BOOL enabled;

/**
 Whether the button is highlighted or not.
 */
@property (nonatomic, assign, getter = isHighlighted) BOOL highlighted;

/**
 The URL for loading the image. 
 
 If changed stopLoading is called. You have to manually call startLoading or startLoading: for loading the new image.
 */
@property (nullable, nonatomic, strong) NSURL *url;

/**
 Optional placeholder image to show while loading is underway.
 */
@property (nullable, nonatomic, strong) UIImage *placeHolderImage;

/**
 The image view used by the button for showing the image.
 */
@property (nonatomic, strong) IBOutlet UIImageView *imageView;

/**
 The activity indicator used by the button while loading if showActivity is set to YES.
 */
@property (nullable, nonatomic, strong) IBOutlet UIActivityIndicatorView *activityIndicator;

/**
 Optional context object to attach to the button.
 */
@property (nullable, nonatomic, strong) id context;

/**
 If set to YES the activityIndicator will spin while loading.
 */
@property (nonatomic, assign) BOOL showActivity;

/**
 If set to true the image will be adjusted automatically when the button is disabled.
 
 It will be drawn sligthly lighter.
 */
@property(nonatomic, assign) BOOL adjustsImageWhenDisabled;

/**
 If set to true the image will be adjusted automatically when the button is disabled.
 
 It will be drawn slightly darker.
 */
@property(nonatomic, assign) BOOL adjustsImageWhenHighlighted;

/**
 Initializes the button with the specified URL for loading the image.
 */
- (id)initWithURL:(nullable NSURL *)theURL;

/**
 Calls startLoadingByShowingPlaceHolder: with argument YES.
 */
- (void)startLoading;

/**
 Starts loading the image, optionally showing a placeholder image while the image is not yes loaded.
 
 @see placeHolderImage.
 */
- (void)startLoadingByShowingPlaceHolder:(BOOL)showPlaceHolder;

/**
 Stops/cancels loading the image.
 */
- (void)stopLoading;

/**
 Sets the button image directly.
 */
- (void)setImage:(nullable UIImage *)theImage;
- (nullable UIImage *)image;

/**
 Sets a target and action for receiving button press events.
 
 The action selector may have one argument which will be a reference to self when the button press event is fired.
 */
- (void)setTarget:(nullable id)target action:(nullable SEL)action;

@end

NS_ASSUME_NONNULL_END
