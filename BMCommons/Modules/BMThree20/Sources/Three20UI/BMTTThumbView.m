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

#import "Three20UI/BMTTThumbView.h"

// Style
#import "Three20Style/BMTTGlobalStyle.h"
#import "Three20Style/BMTTDefaultStyleSheet.h"
#import <BMCommons/BMAsyncImageLoader.h>

@interface BMTTThumbView()<BMAsyncDataLoaderDelegate>

@end

///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTThumbView {
    BMAsyncDataLoader *_dataLoader;
    UIImage *_placeHolderImage;
}

@synthesize video = _video;
@synthesize placeHolderImage = _placeHolderImage;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = BMTTSTYLEVAR(thumbnailBackgroundColor);
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)dealloc {
    [self suspendLoadingImage:YES];
    [_placeHolderImage release];
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Properties


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)thumbURL {
    return _thumbURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setThumbURL:(NSString*)URL {
    if (_thumbURL != URL) {
        [_thumbURL release];
        _thumbURL = [URL copy];
        
        [self suspendLoadingImage:YES];
        [self suspendLoadingImage:NO];
    }
}

- (void)suspendLoadingImage:(BOOL)suspended {
    if (suspended) {
        _dataLoader.delegate = nil;
        [_dataLoader cancelLoading];
        [_dataLoader release];
        _dataLoader = nil;
    } else if (!_dataLoader) {
        _dataLoader = [[BMAsyncImageLoader alloc] initWithURLString:self.thumbURL];
        _dataLoader.delegate = self;
        if (self.placeHolderImage) {
            [self setImage:self.placeHolderImage forState:UIControlStateNormal];
        }
        [_dataLoader startLoading];
    }
}

#pragma mark - 
#pragma mark BMAsyncLoaderDelegate

- (void)asyncDataLoader:(BMAsyncDataLoader *)dataLoader didFinishLoadingWithError:(NSError *)error {
    if (error) {
        [self setImage:self.placeHolderImage forState:UIControlStateNormal];
    } else {
        [self setImage:[(BMAsyncImageLoader *)dataLoader image] forState:UIControlStateNormal];
    }
}

@end
