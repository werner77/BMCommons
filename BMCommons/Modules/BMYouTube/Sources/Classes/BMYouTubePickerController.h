//
//  BMYouTubePickerController.h
//  BMCommons
//
//  Created by Werner Altewischer on 23/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMMedia/BMMediaPickerController.h>
#import <GData/GTMOAuth2Authentication.h>

@class BMYouTubeVideoListController;

/**
 Media picker for selecting videos from the user's YouTube account.
 
 Use a BMGoogleAuthenticationController to log the user in first if necessary.
 */
@interface BMYouTubePickerController : BMMediaPickerController 

/**
 The Google authentication to use. 
 
 Acquire it with an instance of BMGoogleAuthenticationController.
 */
@property (nonatomic, strong) GTMOAuth2Authentication *authentication;

/**
 The developerKey to use to access the YouTube API.
 */
@property (nonatomic, strong) NSString *developerKey;

/**
 If nil by default an instance of BMYouTubeEntryTransformer is used.
 
 The transformer is used to transform instances of GDataEntryYouTubeVideo to instances of BMVideoContainer.
 */
@property (nonatomic, strong) NSValueTransformer *youTubeEntryTransformer;

/**
 If set to true, the mp4 streams of YouTube are used for a native look and feel. 
 
 The mp4 streams are not officially exposed by YouTube but can be parsed nonetheless using some nifty tricks.
 */
@property (nonatomic, assign) BOOL useNativeMode;

@end
