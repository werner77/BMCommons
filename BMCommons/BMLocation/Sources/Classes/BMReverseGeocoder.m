//
//  BMReverseGeocoder.m
//  BMCommons
//
//  Created by Werner Altewischer on 16/08/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMReverseGeoCoder.h>
#import <BMCommons/BMService.h>
#import <BMCommons/BMGoogleMapsReverseGeocoder.h>
#import <BMCore/NSArray+BMCommons.h>
#import <BMCore/BMCore.h>

#define PLACEMARK_CACHE_SIZE 100

#define MAX_CONCURRENT_GEOCODERS 1
#define TIMEOUT_INTERVAL 5.0

#define GEOCODER_CLASS BMGoogleMapsReverseGeocoder

@protocol BMGeocoderImplementationDelegate;

@protocol BMGeocoderImplementation<NSObject>

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;

// A MKReverseGeocoder object should only be started once.
- (void)start;
- (void)cancel;

@property (nonatomic, assign) id<BMGeocoderImplementationDelegate> delegate;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) CLPlacemark *placemark;
@property (nonatomic, readonly, getter=isQuerying) BOOL querying;

@end

@protocol BMGeocoderImplementationDelegate<NSObject>

- (void)reverseGeocoder:(id <BMGeocoderImplementation>)geocoder didFailWithError:(NSError *)error;
- (void)reverseGeocoder:(id <BMGeocoderImplementation>)geocoder didFindPlacemark:(CLPlacemark *)placemark;

@end

@interface BMCLReverseGeocoder : NSObject<BMGeocoderImplementation>

@end

@implementation BMCLReverseGeocoder {
    CLGeocoder *_impl;
}

@synthesize delegate = _delegate, coordinate = _coordinate, placemark = _placemark, querying = _querying;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
    if ((self = [super init])) {
        _coordinate = coordinate;
        _impl = [[CLGeocoder alloc] init];
    }
    return self;
}

- (void)dealloc {
    [_impl cancelGeocode];
    BM_RELEASE_SAFELY(_impl);
    BM_RELEASE_SAFELY(_placemark);
}

// A MKReverseGeocoder object should only be started once.
- (void)start {
    __block __weak id bSelf = self;
    CLLocation *location = [[CLLocation alloc] initWithLatitude:self.coordinate.latitude longitude:self.coordinate.longitude];
    [_impl reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            [self.delegate reverseGeocoder:bSelf didFailWithError:error];
        } else {
            [self.delegate reverseGeocoder:bSelf didFindPlacemark:[placemarks firstObject]];
        }
    }];
}

- (void)cancel {
    [_impl cancelGeocode];
}

- (BOOL)isQuerying {
    return [_impl isGeocoding];
}

@end


@interface BMReverseGeocoder()<BMGeocoderImplementationDelegate>
@end

@implementation BMReverseGeocoder {
    id <BMGeocoderImplementation> _reverseGeocoder;
    NSTimer *timer;
}

@synthesize delegate;

static NSMutableArray *reverseGeocoders = nil;
static NSMutableDictionary *placemarkCache = nil;
static NSMutableArray *orderedCacheKeys = nil;
static NSDate *lastStartDate = nil;

+ (NSString *)keyForCoordinate:(CLLocationCoordinate2D)coordinate {
	return [NSString stringWithFormat:@"lat=%.5f,lon=%.5f", coordinate.latitude, coordinate.longitude];
}

+ (void)initialize {
	if (!reverseGeocoders) {
		reverseGeocoders = [NSMutableArray new];
	}
	if (!placemarkCache) {
		placemarkCache = [NSMutableDictionary new];
	}
	if (!orderedCacheKeys) {
		orderedCacheKeys = [NSMutableArray new];
	}
}

+ (void)dequeue:(id <BMGeocoderImplementation>)geocoder {
	[reverseGeocoders removeObjectIdenticalTo:geocoder];
}

+ (void)dequeueAndStartNext:(id <BMGeocoderImplementation>)geocoder {
	[reverseGeocoders removeObjectIdenticalTo:geocoder];
	if (reverseGeocoders.count > 0) {
		geocoder = reverseGeocoders[0];
        [geocoder start];
        LogDebug(@"Reverse geocoder started");
	}
}

+ (void)queue:(id <BMGeocoderImplementation>)geocoder {
	if (![reverseGeocoders containsObject:geocoder]) {
		[reverseGeocoders addObject:geocoder];
        NSDate *currentDate = [NSDate date];
        if (reverseGeocoders.count <= MAX_CONCURRENT_GEOCODERS) {
            lastStartDate = currentDate;
            [geocoder start];
            LogDebug(@"Reverse geocoder started for coordinate: %f, %f", geocoder.coordinate.latitude, geocoder.coordinate.longitude);
        } else {
            LogDebug(@"Reverse geocoder queued");
            if ([currentDate timeIntervalSinceDate:lastStartDate] > TIMEOUT_INTERVAL) {
                //Dequeue the first in the list and continue with the next
                [self dequeueAndStartNext:reverseGeocoders[0]];
            }
        }    
	}
}

+ (void)cancelAll {
	for (id geocoder in reverseGeocoders) {
		[geocoder cancel];
	}
	[reverseGeocoders removeAllObjects];
}

+ (MKPlacemark *)cachedPlaceMarkForCoordinate:(CLLocationCoordinate2D)coordinate {
	id key = [self keyForCoordinate:coordinate];
	return placemarkCache[key];
}

+ (void)setCachedPlacemark:(MKPlacemark *)placeMark fromReverseGeocoder:(id <BMGeocoderImplementation>)theReverseGeocoder {
	NSString *key = placeMark ? [self keyForCoordinate:placeMark.coordinate] : nil;
    if (key) {
        if (orderedCacheKeys.count >= PLACEMARK_CACHE_SIZE && !placemarkCache[key]) {
            NSString *firstKey = orderedCacheKeys[0];
            [placemarkCache removeObjectForKey:firstKey];
            [orderedCacheKeys removeObjectAtIndex:0];
            [orderedCacheKeys addObject:key];
        }
        placemarkCache[key] = placeMark;
        
        for (id <BMGeocoderImplementation> geocoder in [NSArray arrayWithArray:reverseGeocoders]) {
            if (geocoder != theReverseGeocoder) {
                NSString *key1 = [self keyForCoordinate:geocoder.coordinate];
                if ([key isEqual:key1]) {
                    BMReverseGeocoder *bmGeocoder = (BMReverseGeocoder *)(geocoder.delegate);
                    [bmGeocoder.delegate reverseGeocoder:bmGeocoder didFindPlacemark:placeMark];
                    [self dequeue:geocoder];
                }    
            }
        }
    }
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate {
	if (self = [super init]) {
		_reverseGeocoder = (id <BMGeocoderImplementation>)[[GEOCODER_CLASS alloc] initWithCoordinate:coordinate];
		_reverseGeocoder.delegate = self;
	}
	return self;
}

- (void)dealloc {
	[BMReverseGeocoder dequeue:_reverseGeocoder];
	_reverseGeocoder.delegate = nil;
    BM_AUTORELEASE_SAFELY(_reverseGeocoder);
}

- (void)start {
	MKPlacemark *cachedPlacemark = [BMReverseGeocoder cachedPlaceMarkForCoordinate:_reverseGeocoder.coordinate];
	if (cachedPlacemark) {
		[self.delegate reverseGeocoder:self didFindPlacemark:cachedPlacemark];
	} else {
		[BMReverseGeocoder queue:_reverseGeocoder];
	}
}

- (void)cancel {
	[_reverseGeocoder cancel];
	[BMReverseGeocoder dequeue:_reverseGeocoder];
}

- (BOOL)querying {
	return _reverseGeocoder.querying;
}

#pragma mark -
#pragma mark BMGeoCoderImplementationDelegate implementation

- (void)reverseGeocoder:(id)geocoder didFailWithError:(NSError *)error {
	[self.delegate reverseGeocoder:self didFailWithError:error];
    [BMReverseGeocoder dequeueAndStartNext:geocoder];
}

- (void)reverseGeocoder:(id)geocoder didFindPlacemark:(MKPlacemark *)placemark {
	[BMReverseGeocoder setCachedPlacemark:placemark fromReverseGeocoder:geocoder];
    [self.delegate reverseGeocoder:self didFindPlacemark:placemark];
	[BMReverseGeocoder dequeueAndStartNext:geocoder];
}

@end
