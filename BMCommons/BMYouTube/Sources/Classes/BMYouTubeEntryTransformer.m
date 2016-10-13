//
//  BMYouTubeEntryTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMYouTubeEntryTransformer.h"
#import <CoreLocation/CoreLocation.h>
#import <BMYouTube/BMYouTube.h>

@interface BMYouTubeEntryTransformer()

@end

@implementation BMYouTubeEntryTransformer {
    id <BMVideoContainer> videoContainer;
    Class videoContainerClass;
    BMVideoContainerConstructorBlock constructorBlock;
}

@synthesize videoContainer, videoContainerClass, constructorBlock;


+ (Class)transformedValueClass {
    return [NSObject class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)initWithVideoContainer:(id <BMVideoContainer>)theVideoContainer {
    if ((self = [self init])) {
        videoContainer = theVideoContainer;
    }
    return self;
}

- (id)initWithVideoContainerClass:(Class<BMVideoContainer>)theClass {
    if ((self = [self init])) {
        videoContainerClass = theClass;
    }
    return self;
}

- (id)initWithVideoContainerConstructorBlock:(BMVideoContainerConstructorBlock)block {
    if ((self = [self init])) {
        constructorBlock = [block copy];
    }
    return self;
}

- (id)transformedValue:(id)value {
    id <BMVideoContainer> vc = videoContainer;
    if (self.videoContainerClass) {
        vc = [[videoContainerClass alloc] init];
    } else if (self.constructorBlock) {
        vc = self.constructorBlock();
    }
    
    GDataEntryYouTubeVideo *entry = value;
    
    GDataYouTubeMediaGroup *mediaGroup = [entry mediaGroup];
    NSArray *thumbnails = [mediaGroup mediaThumbnails];
    GDataMediaThumbnail *thumbnail = thumbnails.count > 0 ? thumbnails[0] : nil;
    GDataMediaThumbnail *hqThumbnail = [mediaGroup highQualityThumbnail];
    NSNumber *duration = [mediaGroup duration];
    NSString *title = [[mediaGroup mediaTitle] stringValue];
    
    NSArray *mediaContents = [mediaGroup mediaContents];
    
    GDataMediaContent *defaultContent = [GDataUtilities firstObjectFromArray:mediaContents withValue:@YES forKeyPath:@"isDefault"];
    
    //Set values
    vc.url = defaultContent.URLString;
    vc.entryUrl = [[[entry selfLink] URL] absoluteString];
    vc.entryId = [mediaGroup videoID];
    vc.contentType = defaultContent.type;
    vc.thumbnailImageUrl = [thumbnail URLString];
    vc.midSizeImageUrl = [hqThumbnail URLString];
    vc.caption = title;
    vc.duration = duration;
        
    if ([entry geoLocation]) {
        CLLocation *location = [[CLLocation alloc] initWithLatitude:entry.geoLocation.latitude longitude:entry.geoLocation.longitude];
        [vc setGeoLocation:location];
    }
    
    [self populateVideo:vc withMediaGroup:mediaGroup];
    
    return vc;
}

@end

@implementation BMYouTubeEntryTransformer(Protected)

//Override to perform additional conversion
- (void)populateVideo:(id <BMVideoContainer>)video withMediaGroup:(GDataYouTubeMediaGroup *)mediaGroup {
    /*
     NSDate *uploadedDate = [[mediaGroup uploadedDate] date];
     NSString *description = [[mediaGroup mediaDescription] stringValue];
     NSArray *keywords = [[mediaGroup mediaKeywords] keywords];
     NSString *keywordString = [GDataMediaKeywords stringFromKeywords:keywords];
     GDataYouTubeRating *rating = [entry rating];
     NSNumber *numberOfLikes = rating.numberOfLikes;
     NSNumber *numberOfDisLikes = rating.numberOfDislikes;
     */
    //Override to do any additional mappings
}

@end
