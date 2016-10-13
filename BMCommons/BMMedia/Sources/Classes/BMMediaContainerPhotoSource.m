//
//  BMMediaContainerPhotoSource.m
//  BMCommons
//
//  Created by Werner Altewischer on 22/06/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import "BMMediaContainerPhotoSource.h"
#import <BMCore/BMObjectHelper.h>
#import <BMCore/BMStringHelper.h>
#import "BMMediaContainerPhoto.h"
#import <BMMedia/BMMedia.h>

@interface BMMediaContainerPhotoSource(Private)

- (void)deletePhotoAtIndex:(NSInteger)index media:(id <BMMediaContainer>)mc deleteObject:(BOOL)deleteObject;
- (NSMutableArray *)currentPhotoArray;

@end

@implementation BMMediaContainerPhotoSource {
    NSString *title;
	BOOL changed;
    BOOL notificationListenerEnabled;
    
@private
    NSMutableArray *photos;
    
    NSMutableArray *videos;
    NSMutableArray *pictures;
}

@synthesize title, filteredPhotoKinds;

- (id)initWithTitle:(NSString *)theTitle medias:(NSArray *)theMedias {
    if ((self = [self init])) {
        if ([BMStringHelper isEmpty:theTitle]) {
            theTitle = BMMediaLocalizedString(@"mediasource.title.default", @"Media");
        }
        title = theTitle;
        self.loadedTime = [NSDate date];
        [self addMedia:theMedias];
    }
    return self;
}

- (id)init {
    if ((self = [super init])) {
        BMMediaCheckLicense();
        self.filteredPhotoKinds = BMTTPhotoKindAll;
        changed = NO;
        photos = [[NSMutableArray alloc] init];
        videos = [[NSMutableArray alloc] init];
        pictures = [[NSMutableArray alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaContainerDidUpdateNotification:) name:BMMediaContainerDidUpdateNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mediaContainerWasDeletedNotification:) name:BMMediaContainerWasDeletedNotification object:nil];
        notificationListenerEnabled = YES;
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    BM_RELEASE_SAFELY(title);
    BM_RELEASE_SAFELY(photos);
    BM_RELEASE_SAFELY(videos);
    BM_RELEASE_SAFELY(pictures);
}

- (void)addMedia:(NSArray *)theMedias {
    for (id media in theMedias) {
        BMMediaContainerPhoto *photo;
        
        NSArray *theMedia = nil;
        
        if ([media isKindOfClass:[NSArray class]]) {
            photo = [[BMMediaContainerPhoto alloc] initWithMedias:(NSArray *)media];
            theMedia = media;
        } else {
            photo = [[BMMediaContainerPhoto alloc] initWithMedia:(id <BMMediaContainer>)media];
            theMedia = @[media];
        }
        
        [photos addObject:photo];
        
        BOOL isPicture = NO;
        BOOL isVideo = NO;
        
        for (id <BMMediaContainer> m in theMedia) {
            if (m.mediaKind == BMMediaKindPicture) {
                isPicture = YES;
            }
            if (m.mediaKind == BMMediaKindVideo) {
                isVideo = YES;
            }
        }
        
        if (isPicture) {
            [pictures addObject:photo];
        }
        
        if (isVideo) {
            [videos addObject:photo];
        }
        
        photo.photoSource = self;
        
    }
}

- (void)setMedia:(NSArray *)theMedias {
    [self clear];
    [self addMedia:theMedias];
}

- (void)clear {
    for (BMMediaContainerPhoto *photo in photos) {
        photo.photoSource = nil;
    }
    [photos removeAllObjects];
    [pictures removeAllObjects];
    [videos removeAllObjects];
}

- (NSInteger)numberOfPhotos {
    return self.currentPhotoArray.count;
}

- (NSUInteger)numberOfMediaPhotos {
    return [photos count];
}

- (NSUInteger)numberOfPicturePhotos {
    return [pictures count];
}

- (NSUInteger)numberOfVideoPhotos {
    return [videos count];
}

- (NSInteger)maxPhotoIndex {
    return self.currentPhotoArray.count - 1;
}

- (id <BMTTPhoto>)photoAtIndex:(NSInteger)index {
    id <BMTTPhoto> photo = nil;
    NSArray *items = self.currentPhotoArray;
    if (index < items.count) {
        photo = [BMObjectHelper filterNSNullObject:items[index]];
    }
    return photo;
}

- (NSInteger)indexOfPhoto:(id <BMTTPhoto>)photo {
    NSUInteger theIndex = [self.currentPhotoArray indexOfObjectIdenticalTo:photo];
    
    if (theIndex == NSNotFound) {
        return -1;
    } else {
        return (NSInteger)theIndex;
    }
}

- (void)deletePhotoAtIndex:(NSInteger)index {
    [self deletePhotoAtIndex:index media:nil deleteObject:YES];
}

- (void)setCaption:(NSString *)theCaption forPhotoAtIndex:(NSInteger)index {
    NSArray *items = self.currentPhotoArray;
    if (index >= 0 && index < items.count) {
        BMMediaContainerPhoto *photo = items[index];

        if (photo.media.caption != theCaption && ![photo.media.caption isEqual:theCaption]) {
            changed = YES;
            [photo.media setCaption:theCaption];
            [self didUpdateObject:photo atIndexPath:[NSIndexPath indexPathWithIndex:index]];
        }
    }
}

- (BOOL)isChanged {
    return changed;
}

- (NSArray *)media {
    NSMutableArray *ret = [NSMutableArray array];
    for (BMMediaContainerPhoto *photo in self.currentPhotoArray) {
        NSArray *medias = photo.medias;
        if (medias) {
            [ret addObjectsFromArray:medias];
        }
    }
    return ret;
}

- (NSString *)captionForMedia:(id <BMMediaContainer>)mediaContainer {
    return mediaContainer.caption;
}

- (NSInteger)indexForMedia:(id <BMMediaContainer>)mediaContainer {
    NSInteger index = -1;
    NSInteger i = 0;
    for (BMMediaContainerPhoto *photo in self.currentPhotoArray) {
        NSArray *medias = photo.medias;
        
        for (id <BMMediaContainer> media in medias) {
            if ([media isEqual:mediaContainer]) {
                index = i;
                break;
            }
        }
        if (index >= 0) {
            break;
        }
        i++;
    }
    return index;
}

- (void)mediaContainerDidUpdateNotification:(NSNotification *)notification {
    if (notificationListenerEnabled) {
        id <BMMediaContainer> mediaContainer = notification.object;
        NSInteger index = [self indexForMedia:mediaContainer];
        if (index >= 0) {
            changed = YES;
            BMMediaContainerPhoto *photo = (self.currentPhotoArray)[index];
            [self didUpdateObject:photo atIndexPath:[NSIndexPath indexPathWithIndex:index]];
        }    
    }
}

- (void)mediaContainerWasDeletedNotification:(NSNotification *)notification {
    if (notificationListenerEnabled) {
        id <BMMediaContainer> mediaContainer = notification.object;
        NSInteger index = [self indexForMedia:mediaContainer];
        if (index >= 0) {
            [self deletePhotoAtIndex:index media:mediaContainer deleteObject:NO];
        }    
    }
}

@end

@implementation BMMediaContainerPhotoSource(Private)

- (NSMutableArray *)currentPhotoArray {
    if (self.filteredPhotoKinds == BMTTPhotoKindPicture) {
        return pictures;
    } else if (self.filteredPhotoKinds == BMTTPhotoKindVideo) {
        return videos;
    }
    return photos;
}

- (void)deletePhotoAtIndex:(NSInteger)index media:(id <BMMediaContainer>)mc deleteObject:(BOOL)deleteObject {
    if (index >= 0 && index < self.currentPhotoArray.count) {
        notificationListenerEnabled = NO;
        BMMediaContainerPhoto *photo = (self.currentPhotoArray)[index];
        
        if (mc == nil) {
            if (deleteObject) {
                for (id <BMMediaContainer> media in photo.medias) {
                    [media deleteObject];
                }
            }
        } else {
            if (deleteObject) {
                [mc deleteObject];
            }
            [photo removeMedia:mc];
        }
        
        if (mc == nil || photo.medias.count == 0) {
            [photos removeObject:photo];
            [videos removeObject:photo];
            [pictures removeObject:photo];
            
            changed = YES;
            notificationListenerEnabled = YES;
            
            [self didDeleteObject:photo atIndexPath:[NSIndexPath indexPathWithIndex:index]];
        }
    }
}

@end
