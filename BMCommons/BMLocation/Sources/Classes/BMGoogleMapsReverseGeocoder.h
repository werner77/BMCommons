//
//  BMGoogleMapsReverseGeocoder.h
//  BMCommons
//
//  Created by Werner Altewischer on 18/07/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <BMCore/BMHTTPService.h>

/**
 Performs a reverse geocode directly against the Google Maps API.
 */
@interface BMGoogleMapsReverseGeocoder : MKReverseGeocoder {
    id <BMService> service;
    MKPlacemark *_placemark1;
}

@end
