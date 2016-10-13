//
//  BMTTThumbView.h
//  BMCommons
//
//  Created by Werner Altewischer on 5/10/13.
//  Copyright (c) 2013 BehindMedia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BMMedia/BMAsyncLoadingMediaThumbnailButton.h>

@interface BMTTThumbView : UIButton {
    NSString *_thumbURL;
    BOOL _video;
}

@property (nonatomic, copy) NSString* thumbURL;
@property (nonatomic, assign, getter = isVideo) BOOL video;
@property (nonatomic, retain) UIImage *placeHolderImage;

- (void)suspendLoadingImage:(BOOL)suspended;

@end
