//
//  BMMediaThumbnailView.h
//  BMCommons
//
//  Created by Werner Altewischer on 26/02/10.
//  Copyright 2010 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMOverlayImageView.h>
#import <BMMedia/BMMediaContainer.h>

/**
 Thumbnail view for BMMediaContainer instances. 
 
 Auto-selects the right overlay view for the bmMediaKind set.
 */
@interface BMMediaThumbnailView : BMOverlayImageView 

/**
 The BMMediaKind to use for selecting the overlay view.
 */
@property (nonatomic, assign) BMMediaKind mediaKind;

/**
 Sets the image from the specified BMMediaContainer and displays the proper overlay.
 */
- (void)setImageFromMedia:(id <BMMediaContainer>)media;


@end
