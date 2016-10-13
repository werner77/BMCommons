//
//  BMYouTubeEntryCell.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeEntryCell.h>
#import "GDataEntryYouTubeVideo.h"
#import <BMCommons/BMYouTubeEntryTransformer.h>
#import <BMYouTube/BMYouTube.h>

#define LOCATION_ENABLED 0

#if LOCATION_ENABLED
#import <BMLocation/BMMapsHelper.h>
#import <BMLocation/BMReverseGeocoder.h>

@interface BMYouTubeEntryCell()<BMReverseGeocoderDelegate>
#else
@interface BMYouTubeEntryCell()
#endif

@property(nonatomic, strong) UIColor *selectionColor;

@end



@implementation BMYouTubeEntryCell {
#if LOCATION_ENABLED
    BMReverseGeocoder *reverseGeocoder;
#endif
    UIColor *selectionColor;
}

@synthesize thumbnailView;
@synthesize likesLabel;
@synthesize viewsLabel;
@synthesize userLabel;
@synthesize selectionColor;
@synthesize durationLabel, uploadDateLabel, locationLabel;

static NSDateFormatter *df = nil;

+ (void)initialize {
    if (!df) {
        df = [[NSDateFormatter alloc] init];
        [df setDateStyle:NSDateFormatterShortStyle];
    }
}

+ (Class)supportedValueClass {
    return [GDataEntryYouTubeVideo class];
}

+ (CGFloat)heightForValue:(id)value {
    return 90.0;
}

- (void)dealloc {
    [self.thumbnailView stopLoading];
    
#if LOCATION_ENABLED
    [reverseGeocoder cancel];
    BM_RELEASE_SAFELY(reverseGeocoder);
#endif
}

- (void)initialize {
    [super initialize];
    
    BMYouTubeCheckLicense();
    
    self.enabledSelectionStyle = BMSTYLEVAR(tableViewCellSelectionStyle);
    self.thumbnailView.loadingImage = BMSTYLEVAR(youTubeLoadingPlaceHolderImage);
    self.thumbnailView.errorImage = self.thumbnailView.loadingImage;
    self.thumbnailView.backgroundColor = BMSTYLEVAR(youTubeLoadingPlaceHolderBackgroundColor);
    
    [super setSelectionStyle:UITableViewCellEditingStyleNone];
    [self setClickEnabled:YES];
}

- (void)setSelectionStyle:(UITableViewCellSelectionStyle)selectionStyle {
    if (selectionStyle == UITableViewCellSelectionStyleBlue) {
        self.selectionColor = [UIColor colorWithRed:0.02 green:0.549 blue:0.961 alpha:1.0];
    } else if (selectionStyle == UITableViewCellSelectionStyleGray) {
        self.selectionColor = [UIColor grayColor];
    } else {
        self.selectionColor = [UIColor clearColor];
    }
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.thumbnailView stopLoading];
#if LOCATION_ENABLED
    [reverseGeocoder cancel];
    BM_RELEASE_SAFELY(reverseGeocoder);
#endif
}

- (void)setViewWithData:(id)value {
    GDataEntryYouTubeVideo *video = value;
    GDataYouTubeMediaGroup *mediaGroup = [video mediaGroup];
    GDataYouTubeRating *rating = [video rating];
    GDataYouTubeStatistics *statistics = [video statistics];
    GDataPerson *author = video.authors.count > 0 ? (video.authors)[0] : nil;
    
    NSNumber *duration = [mediaGroup duration];
    
    int minutes = [duration intValue] / 60;
    int seconds = [duration intValue] - minutes * 60;
    
    NSDate *uploadedDate = [[mediaGroup uploadedDate] date];
    NSString *title = [[mediaGroup mediaTitle] stringValue];
    
    GDataMediaContent *defaultMediaContent = [GDataUtilities firstObjectFromArray:[mediaGroup mediaContents]
                                                                        withValue:@YES
                                                                       forKeyPath:@"isDefault"];
    
    NSString *urlString = [defaultMediaContent URLString];
    
    long long viewCount = [[statistics viewCount] longLongValue];
    
    self.thumbnailView.url = urlString;
    
    float likePercentage = [rating.numberOfLikes intValue] > 0 ? ([rating.numberOfLikes floatValue] * 100.0) / ([rating.numberOfLikes floatValue] + [rating.numberOfDislikes floatValue]) : 0.0f;
    
    self.titleLabel.text = title;
    self.likesLabel.text = [NSString stringWithFormat:@"%d%%", (int)likePercentage];
    self.locationLabel.text = @"";
    
    self.viewsLabel.text = [NSString stringWithFormat:@"%lld %@", viewCount, BMYouTubeLocalizedString(@"cell.youtubeentry.text.views", @"views")];
    self.userLabel.text = author.name;
    self.uploadDateLabel.text = [df stringFromDate:uploadedDate];
    self.durationLabel.text = [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
    
    [self.thumbnailView startLoading];
    
#if LOCATION_ENABLED
    GDataGeo *geoLocation = [video geoLocation];
    if (geoLocation && self.locationLabel) {
        reverseGeocoder = [[BMReverseGeocoder alloc] initWithCoordinate:CLLocationCoordinate2DMake(geoLocation.latitude, geoLocation.longitude)];
        reverseGeocoder.delegate = self;
        [reverseGeocoder start];
    }
#endif
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    
    int backgroundViewTag = 888;
    UIView *backgroundView = [self viewWithTag:backgroundViewTag];
    
    if (selected) {
        if (!backgroundView) {
            backgroundView = [[UIView alloc] initWithFrame:self.bounds];
            backgroundView.tag = backgroundViewTag;
            backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;            
            backgroundView.backgroundColor = self.selectionColor;
            backgroundView.alpha = 0.0;
            [self insertSubview:backgroundView atIndex:0];
        }
        
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                backgroundView.alpha = 1.0;
            }];
        } else {
            backgroundView.alpha = 1.0;
        }
    } else if (backgroundView) {
        if (animated) {
            [UIView animateWithDuration:0.5 animations:^{
                backgroundView.alpha = 0.0;
            } completion:^(BOOL finished) {
            }];
        } else {
            backgroundView.alpha = 0.0;
        }
    }
    [super setSelected:selected animated:animated];
}

#if LOCATION_ENABLED

#pragma mark - BMReverseGeocoderDelegate

- (void)reverseGeocoder:(BMReverseGeocoder *)geocoder didFailWithError:(NSError *)error {
    LogWarn(@"Reverse geocoding failed: %@", error);
    BM_AUTORELEASE_SAFELY(reverseGeocoder);
}

- (void)reverseGeocoder:(BMReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark {
    NSString *geoName = [BMMapsHelper geoNameFromPlaceMark:placemark];
    self.locationLabel.text = geoName;
    BM_AUTORELEASE_SAFELY(reverseGeocoder);
}

#endif
@end
