//
//  BMYouTubePickerController.m
//  BMCommons
//
//  Created by Werner Altewischer on 23/02/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMYouTubePickerController.h"
#import <BMUICore/BMDialogHelper.h>
#import <BMUICore/BMNavigationController.h>
#import <BMYouTube/BMYouTubeEntryTransformer.h>
#import <BMYouTube/BMYouTubeVideoListController.h>
#import <BMCore/BMApplicationHelper.h>
#import <BMYouTube/BMYouTube.h>

@interface BMYouTubePickerController()<BMYouTubeVideoListControllerDelegate>
@end

@interface BMYouTubePickerController(Private)

- (id <BMVideoContainer>)videoFromEntry:(GDataEntryYouTubeVideo *)entry;

@end

@implementation BMYouTubePickerController {
    GTMOAuth2Authentication *authentication;
    NSString *developerKey;
    BMYouTubeVideoListController *videoListController;
    NSValueTransformer *youTubeEntryTransformer;
    UINavigationController *navController;
}

@synthesize authentication, developerKey, youTubeEntryTransformer, useNativeMode;

- (id)init {
    if ((self = [super init])) {
        BMYouTubeCheckLicense();
        self.useNativeMode = BMSTYLEVAR(nativeYouTubeModeEnabled);
    }
    return self;
}


- (BOOL)presentFromViewController:(UIViewController *)vc withTransitionStyle:(UIModalTransitionStyle)transitionStyle {
    
    if (self.authentication.canAuthorize && !videoListController) {
        [super presentFromViewController:vc withTransitionStyle:transitionStyle];
        videoListController = [[BMYouTubeVideoListController alloc] init];
        videoListController.useNativeMode = self.useNativeMode;
        videoListController.authentication = self.authentication;
        videoListController.developerKey = self.developerKey;
        videoListController.delegate = self;
        
        videoListController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BMUICoreLocalizedString(@"button.title.cancel", @"Cancel") style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)];
        
        videoListController.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:BMUICoreLocalizedString(@"button.title.done", @"Done") style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
                
        navController = [[BMNavigationController alloc] initWithRootViewController:videoListController];
        navController.modalTransitionStyle = transitionStyle;        
        if ([self.delegate respondsToSelector:@selector(mediaPickerController:willPresentViewController:)]) {
            [self.delegate mediaPickerController:self willPresentViewController:navController];
        }
        
        [self.parentViewController presentViewController:navController animated:YES completion:nil];
        
        return YES;
    } else {
        LogError(@"Not authenticated/autorized: ignoring request for presenting YouTubePickerController");
        return NO;
    }    
}

- (void)dismissWithCancel:(BOOL)cancelled {
    if (!cancelled) {
        for (GDataEntryYouTubeVideo *entry in videoListController.selectedEntries) {
            id <BMVideoContainer> video = [self videoFromEntry:entry];
            [self addMedia:video];
        }
    }
    
    [self.parentViewController dismissViewControllerAnimated:YES completion:nil];
    BM_RELEASE_SAFELY(videoListController);
    BM_RELEASE_SAFELY(navController);
	[super dismissWithCancel:cancelled];
}

- (UIViewController *)rootViewController {
    return navController;
}

#pragma mark - BMYouTubeVideoListControllerDelegate implementation

- (BOOL)youTubeVideoListController:(BMYouTubeVideoListController *)vc shouldSelectVideo:(GDataEntryYouTubeVideo *)video {
    BOOL allowed = YES;
    NSUInteger limit = MIN(self.maxSelectableMedia, self.maxSelectableVideos);
    if (vc.selectedEntries.count >= limit) {
        [self maxSelectableMediaReached];
        allowed = NO;
    }
    
    if (allowed && [self.delegate respondsToSelector:@selector(mediaPickerController:shouldAllowSelectionOfMedia:)]) {
        allowed = [self.delegate mediaPickerController:self shouldAllowSelectionOfMedia:[self videoFromEntry:video]];
    }
    
    return allowed;
}

@end

@implementation BMYouTubePickerController(Private)

- (id <BMVideoContainer>)videoFromEntry:(GDataEntryYouTubeVideo *)entry {
    NSValueTransformer *vt = self.youTubeEntryTransformer;
    BOOL release = NO;
    if (!vt) {
        __weak __block BMYouTubePickerController *bSelf = self;
        BMYouTubeEntryTransformer *transformer = [[BMYouTubeEntryTransformer alloc] initWithVideoContainerConstructorBlock:^id<BMVideoContainer>{
            return [bSelf.delegate videoContainerForMediaPickerController:bSelf];
        }];
        vt = transformer;
        release = YES;
    }
    
    id <BMVideoContainer> videoContainer = [vt transformedValue:entry];
    
    return videoContainer;
}

@end
