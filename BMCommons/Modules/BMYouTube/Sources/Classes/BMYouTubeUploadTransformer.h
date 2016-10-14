//
//  BMYouTubeUploadTransformer.h
//  BMCommons
//
//  Created by Werner Altewischer on 08/03/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BMMedia/BMMediaContainer.h>
#import <GoogleAPIClientForREST/GTLRYouTube.h>

/**
 Transformer for converting a BMVideoContainer to a GDataEntryYouTubeUpload instance for uploading content to YouTube.
 */
@interface BMYouTubeUploadTransformer : NSValueTransformer

@end

@interface BMYouTubeUploadTransformer(Protected)

/**
 Override to do additional conversion
 */
- (void)populateMediaGroup:(GDataYouTubeMediaGroup *)mediaGroup forVideo:(id <BMVideoContainer>)theVideo;

@end
