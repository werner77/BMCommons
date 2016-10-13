//
//  PhotoView.h
//  BTFD
//
//  Created by Werner Altewischer on 23/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <BMThree20/Three20UI/BMTTPhoto.h>

@class BMTTLabel;
@class BMTTStyle;

@interface BMTTPhotoView : UIView {

    id <BMTTPhoto>              _photo;
    UIActivityIndicatorView*  _statusSpinner;
    
    BMTTLabel* _statusLabel;
    BMTTLabel* _captionLabel;
    BMTTStyle* _captionStyle;
    
    BMTTPhotoVersion _photoVersion;
    
    BOOL _hidesExtras;
    BOOL _hidesCaption;
    
    UIImage* _defaultImage;
}

@property (nonatomic, retain) UIImage* defaultImage;
@property (nonatomic, retain) BMTTStyle*    captionStyle;
@property (nonatomic, retain) id<BMTTPhoto> photo;
@property (nonatomic)         BOOL        hidesExtras;
@property (nonatomic)         BOOL        hidesCaption;

/**
 * Is an asynchronous request currently active?
 */
@property (nonatomic, readonly) BOOL isLoading;

/**
 * Has the image been successfully loaded?
 */
@property (nonatomic, readonly) BOOL isLoaded;


- (BOOL)loadPreview:(BOOL)fromNetwork;
- (void)loadImage;
- (void)showProgress:(CGFloat)progress;
- (void)showStatus:(NSString*)text;
- (void)showCaption:(NSString*)caption;
- (UIImage *)image;

@end
