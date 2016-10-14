//
//  BMReverseGeocoder.h
//  BMCommons
//
//  Created by Werner Altewischer on 16/08/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class BMReverseGeocoder;

@protocol BMReverseGeocoderDelegate

- (void)reverseGeocoder:(BMReverseGeocoder *)geocoder didFailWithError:(NSError *)error;
- (void)reverseGeocoder:(BMReverseGeocoder *)geocoder didFindPlacemark:(CLPlacemark *)placemark;

@end

/**
 Cached/queuing version of reverse geocoder which can use different implementation under water.
 */
@interface BMReverseGeocoder : NSObject {
	__weak id <BMReverseGeocoderDelegate> delegate;
}

@property (nonatomic, weak) id <BMReverseGeocoderDelegate> delegate;

+ (void)cancelAll;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate;
- (void)start;
- (void)cancel;
- (BOOL)querying;


@end
