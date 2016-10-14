//
//  BMMediaItem.m
//  BMCommons
//
//  Created by Werner Altewischer on 24/09/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMediaItem.h>

#import <BMCommons/BMURLCache.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMFileHelper.h>
#import <BMCommons/BMObjectHelper.h>
#import <BMCommons/BMImageHelper.h>
#import <BMCommons/BMPropertyDescriptor.h>
#import <BMCommons/UIImageToJPEGDataTransformer.h>
#import <BMMedia/BMURLCacheMediaStorage.h>

/**
 If data is set a local URL is generated if it was nil.
 If url is set to nil data is removed.
 If url is changed, data is moved.
 If data is set to nil, the url is set to nil as well if it was a local URL.
 */
@interface BMMediaItem(Private)

- (void)setData:(NSData *)theData withExtension:(NSString *)extension andURLPropertyDescriptor:(BMPropertyDescriptor *)pd;
- (void)startObserving;
- (void)stopObserving;

@end

@implementation BMMediaItem {
    BMURLCacheMediaStorage *_storage;
    NSString *url;
    NSString *midSizeImageUrl;
    NSString *thumbnailImageUrl;
    NSDictionary *metaData;
    NSMutableArray *delegates;
    BOOL sendUpdateNotifications;
}

NSString *const BMMediaContainerDidUpdateNotification = @"BMMediaContainerDidUpdateNotification";
NSString *const BMMediaContainerWasDeletedNotification = @"BMMediaContainerWasDeletedNotification";

//Repeat these properties to get rid of warnings
@synthesize url, midSizeImageUrl, thumbnailImageUrl, caption, geoLocation, metaData, entryId, entryUrl, contentType, storage = _storage;

static NSArray *urlKeyPaths = nil;
static id <BMMediaStorage> defaultStorage = nil;

#define DEFAULT_MAX_MIDSIZE_RESOLUTION 960
#define DEFAULT_MAX_THUMBNAIL_RESOLUTION 160
#define DEFAULT_IMAGE_FILE_EXTENSION  @"jpg"

+ (void)initialize {
	if (!urlKeyPaths) {
		urlKeyPaths = @[@"url", @"thumbnailImageUrl", @"midSizeImageUrl"];
	}
}

+ (NSInteger)maxThumbnailResolution {
	return DEFAULT_MAX_THUMBNAIL_RESOLUTION;
}

+ (NSInteger)maxMidSizeResolution {
	return DEFAULT_MAX_MIDSIZE_RESOLUTION;
}

+ (void)setDefaultStorage:(id <BMMediaStorage>)storage {
    if (defaultStorage != storage) {
        defaultStorage = storage;
    }
}

+ (id <BMMediaStorage>)defaultStorage {
    return defaultStorage ? defaultStorage : [BMURLCacheMediaStorage sharedInstance];
}

- (id <BMMediaStorage>)storage {
    if (_storage) {
        return _storage;
    } else {
        return [[self class] defaultStorage];
    }
}

#pragma mark -
#pragma mark Overridden methods

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.url forKey:@"url"];
    [coder encodeObject:self.midSizeImageUrl forKey:@"midSizeImageUrl"];
    [coder encodeObject:self.thumbnailImageUrl forKey:@"thumbnailImageUrl"];
    [coder encodeObject:self.metaData forKey:@"metaData"];
    [coder encodeObject:self.geoLocation forKey:@"geoLocation"];
    [coder encodeObject:self.caption forKey:@"caption"];
    [coder encodeObject:self.entryId forKey:@"entryId"];
    [coder encodeObject:self.entryUrl forKey:@"entryUrl"];
    [coder encodeObject:self.contentType forKey:@"contentType"];
}

- (id)initWithCoder:(NSCoder *)coder {
    if ((self = [super init])) {
        
        self.url = [coder decodeObjectForKey:@"url"];        
        self.midSizeImageUrl = [coder decodeObjectForKey:@"midSizeImageUrl"];
        self.thumbnailImageUrl = [coder decodeObjectForKey:@"thumbnailImageUrl"];
        self.metaData = [coder decodeObjectForKey:@"metaData"];
        self.geoLocation = [coder decodeObjectForKey:@"geoLocation"];
        self.caption = [coder decodeObjectForKey:@"caption"];
        self.entryId = [coder decodeObjectForKey:@"entryId"];
        self.entryUrl = [coder decodeObjectForKey:@"entryUrl"];
        self.contentType = [coder decodeObjectForKey:@"contentType"];
        
        [self commonInit];
    }
    return self;
}

- (void)dealloc {
    BM_RELEASE_SAFELY(entryId);
    BM_RELEASE_SAFELY(entryUrl);
    BM_RELEASE_SAFELY(geoLocation);
    BM_RELEASE_SAFELY(url);
    BM_RELEASE_SAFELY(midSizeImageUrl);
    BM_RELEASE_SAFELY(thumbnailImageUrl);
    BM_RELEASE_SAFELY(caption);
    BM_RELEASE_SAFELY(metaData);
    BM_RELEASE_SAFELY(contentType);
    BM_RELEASE_SAFELY(delegates);
    BM_RELEASE_SAFELY(_storage);
    [self stopObserving];
}

- (void)commonInit {
    sendUpdateNotifications = YES;
    delegates = BMCreateNonRetainingArray();
    [self startObserving];
}

- (id)init {
    if ((self = [super init])) {
        [self commonInit];
    }
    return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
					  ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
	if ([urlKeyPaths containsObject:keyPath]) {
		NSString *oldUrl = [BMObjectHelper filterNSNullObject:change[NSKeyValueChangeOldKey]];
		NSString *newUrl = [BMObjectHelper filterNSNullObject:change[NSKeyValueChangeNewKey]];
		if (oldUrl && ![oldUrl isEqual:newUrl]) {
            if (newUrl) {
                [self.storage moveDataForUrl:oldUrl toUrl:newUrl];
            } else {
                [self.storage setData:nil forUrl:oldUrl];
            }
        }
	}
}

#pragma mark -
#pragma mark MediaContainer implementation

- (void)addDelegate:(id <BMMediaContainerDelegate>)delegate {
	if (![delegates bmContainsObjectIdenticalTo:delegate]) {
		[delegates addObject:delegate];
	}
}

- (void)removeDelegate:(id <BMMediaContainerDelegate>)delegate {
	[delegates removeObjectIdenticalTo:delegate];
}

- (void)setData:(NSData *)theData withExtension:(NSString *)extension {
    [self setData:theData withExtension:extension andURLPropertyDescriptor:[BMPropertyDescriptor propertyDescriptorFromKeyPath:@"url" withTarget:self]];
}

- (void)setData:(NSData *)theData {
    [self setData:theData withExtension:[[self class] fileExtension]];
}

- (void)setThumbnailImageData:(NSData *)data {
    [self setThumbnailImageData:data withExtension:[[self class] thumbnailImageFileExtension]];
}

- (void)setMidSizeImageData:(NSData *)theData {
    [self setMidSizeImageData:theData withExtension:[[self class] midSizeImageFileExtension]];
}

- (void)setDataFromFile:(NSString *)sourcePath {
    
    if (!self.url) {
        self.url = [self.storage createUniqueLocalUrlWithExtension:[sourcePath pathExtension]];
    }
    
    [self.storage moveDataFromFile:sourcePath toUrl:self.url];
    
    for (id <BMMediaContainerDelegate> delegate in [NSArray arrayWithArray:delegates]) {
		[delegate mediaContainerDidUpdate:self];
	}
}

- (NSData *)data {
    return [self.storage dataForUrl:self.url];
}

- (void)setThumbnailImageData:(NSData *)theData withExtension:(NSString *)extension {
    [self setData:theData withExtension:extension andURLPropertyDescriptor:[BMPropertyDescriptor propertyDescriptorFromKeyPath:@"thumbnailImageUrl" withTarget:self]];
}

- (NSData *)thumbnailImageData {
    return [self.storage dataForUrl:self.thumbnailImageUrl];
}

- (void)setMidSizeImageData:(NSData *)theData withExtension:(NSString *)extension {
	[self setData:theData withExtension:extension andURLPropertyDescriptor:[BMPropertyDescriptor propertyDescriptorFromKeyPath:@"midSizeImageUrl" withTarget:self]];
}

- (NSData *)midSizeImageData {
    return [self.storage dataForUrl:self.midSizeImageUrl];
}

- (UIImage *)thumbnailImage {
    return [self.storage imageForUrl:self.thumbnailImageUrl];
}

- (void)setThumbnailImage:(UIImage *)theImage {
	[self setThumbnailImageData:[self dataFromImage:theImage]];
}

- (UIImage *)midSizeImage {
	return [self.storage imageForUrl:self.midSizeImageUrl];
}

- (void)setMidSizeImage:(UIImage *)theImage {
	[self setMidSizeImageData:[self dataFromImage:theImage]];
}

- (BMMediaKind)mediaKind {
	return BMMediaKindUnknown;
}

- (void)releaseMemory {
    [self.storage releaseMemoryForUrl:self.url];
    [self.storage releaseMemoryForUrl:self.midSizeImageUrl];
    [self.storage releaseMemoryForUrl:self.thumbnailImageUrl];
}

- (BOOL)isLoaded {
	return [self.storage hasDataForUrl:self.url];
}

- (BOOL)isThumbnailImageLoaded {
	return [self.storage hasDataForUrl:self.thumbnailImageUrl];
}

- (BOOL)isMidSizeImageLoaded {
	return [self.storage hasDataForUrl:self.midSizeImageUrl];
}

- (NSString *)filePath {
    return [self.storage filePathForUrl:self.url];
}

- (void)deleteObject {
	//Delete the associated files for this object
    sendUpdateNotifications = NO;
    [self setData:nil];
    [self setMidSizeImageData:nil];
    [self setThumbnailImageData:nil];
	[self releaseMemory];
    for (id <BMMediaContainerDelegate> delegate in [NSArray arrayWithArray:delegates]) {
		[delegate mediaContainerWasDeleted:self];
        [[NSNotificationCenter defaultCenter] postNotificationName:BMMediaContainerWasDeletedNotification object:self];
	}
    sendUpdateNotifications = YES;
}

#pragma mark -
#pragma mark Public methods

- (void)saveThumbnailImage:(UIImage *)image {
	[BMImageHelper saveAndScaleImage:image withMaxResolution:[[self class] maxThumbnailResolution] target:self selector:@selector(setThumbnailImageData:)];
}

- (void)saveMidSizeImage:(UIImage *)image {
	[BMImageHelper saveAndScaleImage:image withMaxResolution:[[self class] maxMidSizeResolution] target:self selector:@selector(setMidSizeImageData:)];
}

+ (NSString *)fileExtension {
	return @"bin";
}

+ (NSString *)thumbnailImageFileExtension {
    return DEFAULT_IMAGE_FILE_EXTENSION;
}

+ (NSString *)midSizeImageFileExtension {
    return DEFAULT_IMAGE_FILE_EXTENSION;
}

@end

@implementation BMMediaItem(Protected)

- (NSData *)dataFromImage:(UIImage *)image {
    if (!image) {
        return nil;
    }
    UIImageToJPEGDataTransformer *transformer = [UIImageToJPEGDataTransformer new];
	NSData *theData = [transformer transformedValue:image];
    return theData;
}

@end

@implementation BMMediaItem(Private)

- (void)startObserving {
	for (NSString *keyPath in urlKeyPaths) {
		[self addObserver:self forKeyPath:keyPath options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
	}
}

- (void)stopObserving {
	for (NSString *keyPath in urlKeyPaths) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (void)setData:(NSData *)theData withExtension:(NSString *)extension andURLPropertyDescriptor:(BMPropertyDescriptor *)pd {
	NSString *theUrl = [pd callGetter];
    if (!theUrl && theData) {
		theUrl = [self.storage createUniqueLocalUrlWithExtension:extension];
        [pd callSetter:theUrl];
	} else if (!theData) {
		//Remove data: reset the url
        if ([self.storage isLocalUrl:theUrl]) {
            [pd callSetter:nil];
        }
	}
    
    [self.storage setData:theData forUrl:theUrl];
	
    if (sendUpdateNotifications) {
        for (id <BMMediaContainerDelegate> delegate in [NSArray arrayWithArray:delegates]) {
            [delegate mediaContainerDidUpdate:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:BMMediaContainerDidUpdateNotification object:self];
        }
    }
}

@end
