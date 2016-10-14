//
//  BMYouTubeUploadTransformer.m
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMYouTubeUploadTransformer.h>
#import <CoreLocation/CoreLocation.h>
#import <GData/GData.h>

#define MIMETYPE_QUICKTIME @"video/quicktime"

@implementation BMYouTubeUploadTransformer


+ (Class)transformedValueClass {
    return [GDataEntryYouTubeUpload class];
}

+ (BOOL)allowsReverseTransformation {
    return NO;
}

- (id)transformedValue:(id)value {
    
    if (![value conformsToProtocol:@protocol(BMVideoContainer)]) {
        return nil;
    }
    
    id <BMVideoContainer> theVideo = value;
    
    NSString *filePath = theVideo.filePath;
    
    if (!filePath || ![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return nil;
    }
    
	NSString *fileName = [filePath lastPathComponent];
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    
    GDataYouTubeMediaGroup *mediaGroup = [GDataYouTubeMediaGroup mediaGroup];
    [self populateMediaGroup:mediaGroup forVideo:theVideo];
    
	NSString *mimeType = [GDataUtilities MIMETypeForFileAtPath:theVideo.filePath
											   defaultMIMEType:MIMETYPE_QUICKTIME];
	
	// create the upload entry with the mediaGroup and the file data
	GDataEntryYouTubeUpload *entry = [GDataEntryYouTubeUpload uploadEntryWithMediaGroup:mediaGroup
                                                                             fileHandle:fileHandle
                                                                               MIMEType:mimeType
                                                                                   slug:fileName];
    
    
    CLLocation *location = theVideo.geoLocation;
    if (location) {
        GDataGeoRSSWhere *geo = [GDataGeoRSSWhere geoWithLatitude:location.coordinate.latitude
                                                        longitude:location.coordinate.longitude];
        [GDataGeo setGeoLocation:geo forObject:entry];
    }
	
	return entry;
    
}



@end

@implementation BMYouTubeUploadTransformer(Protected)

- (void)populateMediaGroup:(GDataYouTubeMediaGroup *)mediaGroup forVideo:(id <BMVideoContainer>)theVideo {
}

@end