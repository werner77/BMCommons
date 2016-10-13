//
//  BMWebMoviePlayerViewController.m
//  BMCommons
//
//  Created by Werner Altewischer on 26/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMWebMoviePlayerViewController.h>
#import <BMMedia/BMEmbeddedVideoView.h>
#import <BMMedia/BMMedia.h>

@interface BMWebMoviePlayerViewController(Private)

@end

@implementation BMWebMoviePlayerViewController {
    BMEmbeddedVideoView *_videoView;
    NSString *_videoUrl;
}

@synthesize videoUrl = _videoUrl;
@synthesize videoView = _videoView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        BMMediaCheckLicense();
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _videoView = [[BMEmbeddedVideoView alloc] initWithFrame:self.view.bounds];
    _videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:_videoView];
    
    _videoView.url = self.videoUrl;    
}

- (void)viewDidUnload {
    [_videoView stopLoading];
    BM_RELEASE_SAFELY(_videoView);
    [super viewDidUnload];
}

- (void)setVideoUrl:(NSString *)url {
    if (url != _videoUrl) {
        _videoUrl = url;
        _videoView.url = _videoUrl;
    }
}

@end

@implementation BMWebMoviePlayerViewController(Private)

@end


