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

#import "Three20UI/BMTTThumbsTableViewCell.h"

// UI
#import "Three20UI/BMTTThumbView.h"
#import "Three20UI/BMTTThumbsTableViewCellDelegate.h"
#import "Three20UI/BMTTPhotoVersion.h"
#import "Three20UI/BMTTPhotoSource.h"
#import "Three20UI/BMTTPhoto.h"

// Core
#import "Three20Core/BMTTCorePreprocessorMacros.h"

static const CGFloat kSpacing = 4;
static const CGFloat kDefaultThumbSize = 75;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation BMTTThumbsTableViewCell

@synthesize photo       = _photo;
@synthesize thumbSize   = _thumbSize;
@synthesize thumbOrigin = _thumbOrigin;
@synthesize columnCount = _columnCount;
@synthesize delegate    = _delegate;
@synthesize thumbViewClass = _thumbViewClass;

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
    if (self = [super initWithStyle:style reuseIdentifier:identifier]) {
        _thumbViews = [[NSMutableArray alloc] init];
        _thumbSize = kDefaultThumbSize;
        _thumbOrigin = CGPointMake(kSpacing, 0);
        _thumbViewClass = [BMTTThumbView class];
        
        self.accessoryType = UITableViewCellAccessoryNone;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    BMTT_RELEASE_SAFELY(_photo);
    BMTT_RELEASE_SAFELY(_thumbViews);
    
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Private


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)assignPhotoAtIndex:(NSInteger)photoIndex toView:(BMTTThumbView*)thumbView {
    id<BMTTPhoto> photo = [_photo.photoSource photoAtIndex:photoIndex];
    BOOL video = NO;
    if (photo) {
        thumbView.thumbURL = [photo URLForVersion:BMTTPhotoVersionThumbnail];
        thumbView.hidden = NO;
        if ([photo respondsToSelector:@selector(isVideo)]) {
            video = [photo isVideo];
        }
    } else {
        thumbView.thumbURL = nil;
        thumbView.hidden = YES;
    }
    thumbView.video = video;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)thumbTouched:(BMTTThumbView*)thumbView {
    NSUInteger thumbViewIndex = [_thumbViews indexOfObject:thumbView];
    NSInteger offsetIndex = _photo.index + thumbViewIndex;
    
    id<BMTTPhoto> photo = [_photo.photoSource photoAtIndex:offsetIndex];
    [_delegate thumbsTableViewCell:self didSelectPhoto:photo];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutThumbViews {
    CGRect thumbFrame = CGRectMake(self.thumbOrigin.x, self.thumbOrigin.y,
                                   self.thumbSize, self.thumbSize);
    
    for (BMTTThumbView* thumbView in _thumbViews) {
        thumbView.frame = thumbFrame;
        thumbFrame.origin.x += kSpacing + self.thumbSize;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UIView


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)layoutSubviews {
    [super layoutSubviews];
    [self layoutThumbViews];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark BMTTTableViewCell


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)object {
    return _photo;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setObject:(id)object {
    [self setPhoto:object];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setThumbSize:(CGFloat)thumbSize {
    _thumbSize = thumbSize;
    [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setThumbOrigin:(CGPoint)thumbOrigin {
    _thumbOrigin = thumbOrigin;
    [self setNeedsLayout];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setColumnCount:(NSInteger)columnCount {
    if (_columnCount != columnCount) {
        for (BMTTThumbView* thumbView in _thumbViews) {
            [thumbView removeFromSuperview];
        }
        [_thumbViews removeAllObjects];
        
        _columnCount = columnCount;
        
        for (NSInteger i = _thumbViews.count; i < _columnCount; ++i) {
            BMTTThumbView* thumbView = [[[self.thumbViewClass alloc] init] autorelease];
            [thumbView addTarget:self action:@selector(thumbTouched:)
                forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:thumbView];
            [_thumbViews addObject:thumbView];
            if (_photo) {
                [self assignPhotoAtIndex:_photo.index+i toView:thumbView];
            }
        }
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPhoto:(id<BMTTPhoto>)photo {
    if (_photo != photo) {
        [_photo release];
        _photo = [photo retain];
    }
    
    if (!_photo) {
        for (BMTTThumbView* thumbView in _thumbViews) {
            thumbView.thumbURL = nil;
        }
        return;
    }
    
    NSInteger i = 0;
    for (BMTTThumbView* thumbView in _thumbViews) {
        [self assignPhotoAtIndex:_photo.index+i toView:thumbView];
        ++i;
    }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)suspendLoading:(BOOL)suspended {
    for (BMTTThumbView* thumbView in _thumbViews) {
        [thumbView suspendLoadingImage:suspended];
    }
}


@end
