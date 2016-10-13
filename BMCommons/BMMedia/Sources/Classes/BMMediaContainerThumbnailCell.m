//
//  BMMediaContainerThumbnailCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 17/09/09.
//  Copyright 2009 BehindMedia. All rights reserved.
//

#import "BMMediaContainerThumbnailCell.h"
#import "BMMediaThumbnailView.h"

#import <QuartzCore/QuartzCore.h>

@implementation BMMediaContainerThumbnailCell {
	IBOutlet BMAsyncLoadingMediaThumbnailButton *thumbnailImageView;
}

@synthesize thumbnailImageView;


+ (Class)supportedValueClass {
    return [NSObject class];
}

- (void)initialize {
    [super initialize];
    thumbnailImageView.clipsToBounds = YES;
    thumbnailImageView.imageView.clipsToBounds = YES;
    self.contentView.clipsToBounds = YES;
    self.clipsToBounds = YES;
}

- (void)setViewWithData:(id)value {
    if (![value conformsToProtocol:@protocol(BMMediaContainer)]) {
        NSException *ex = [NSException exceptionWithName:@"IllegalArgumentException" reason:@"Supplied object does not implement BMMediaContainer" userInfo:nil];
        @throw ex;
    }
    
    id <BMMediaContainer> mediaContainer = value;
    
    [thumbnailImageView setMedia:mediaContainer];    
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.thumbnailImageView stopLoading];
}

@end
