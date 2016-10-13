//
//  BMGoogleMapsReverseGeocoder.m
//  BMCommons
//
//  Created by Werner Altewischer on 18/07/12.
//  Copyright (c) 2012 BehindMedia. All rights reserved.
//

#import "BMGoogleMapsReverseGeocoder.h"
#import "SBJSON.h"
#import <BMCore/BMErrorHelper.h>
#import <BMCore/NSDictionary+BMCommons.h>
#import <BMCore/NSArray+BMCommons.h>
#import <BMCore/BMCore.h>

@interface BMGoogleMapsReverseGeocoderService :BMHTTPService {
    CLLocationCoordinate2D coordinate;
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate;

@end


@implementation BMGoogleMapsReverseGeocoderService

static NSCharacterSet *whitespaceCharSet = nil;

+ (void)initialize {
    if (!whitespaceCharSet) {
        whitespaceCharSet = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    }
}

- (id)initWithCoordinate:(CLLocationCoordinate2D)theCoordinate {
    if ((self = [self init])) {
        coordinate = theCoordinate;
    }
    return self;
}


- (BMHTTPRequest *)requestForServiceWithError:(NSError **)error {
    
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    parameters[@"latlng"] = [NSString stringWithFormat:@"%f,%f", coordinate.latitude, coordinate.longitude];
    parameters[@"sensor"] = @"true";
    parameters[@"language"] = @"en";
    
	return [[BMHTTPRequest alloc] initGetRequestWithUrl:[NSURL URLWithString:@"http://maps.googleapis.com/maps/api/geocode/json"]
                                             parameters:parameters
                                     customHeaderFields:nil 
                                               userName:nil
                                               password:nil
                                               delegate:self];
}

- (NSDictionary *)parseGoogleResponse:(id)response {
    NSMutableDictionary *ret = nil;
    if ([response isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dict = (NSDictionary *)response;
        NSString *status = [dict bmObjectForKey:@"status" ofClass:[NSString class]];
        if ([status isEqual:@"OK"]) {
            NSArray *results = [dict bmObjectForKey:@"results" ofClass:[NSArray class]];
            NSDictionary *firstResult = [results bmSafeObjectAtIndex:0 ofClass:[NSDictionary class]];
            NSArray *addressComponents = [firstResult bmObjectForKey:@"address_components" ofClass:[NSArray class]];
            
            if (addressComponents.count > 0) {
                ret = [NSMutableDictionary dictionary]; 
                for (int i = 0; i < addressComponents.count; ++i) {
                    NSDictionary *addressComponentDict = [addressComponents bmSafeObjectAtIndex:i ofClass:[NSDictionary class]];
                    id addressComponentType = addressComponentDict[@"types"];
                    NSArray *typeArray = nil;
                    if ([addressComponentType isKindOfClass:[NSArray class]]) {
                        typeArray = addressComponentType;
                    } else if ([addressComponentType isKindOfClass:[NSString class]]) {
                        typeArray = @[addressComponentType];
                    }
                    NSString *shortName = [addressComponentDict bmObjectForKey:@"short_name" ofClass:[NSString class]];
                    NSString *longName = [addressComponentDict bmObjectForKey:@"long_name" ofClass:[NSString class]];
                    NSString *value = shortName ? shortName : longName;
                    if (value) {
                        if ([typeArray containsObject:@"country"]) {
                            [ret bmSafeSetObject:longName forKey:@"Country"];
                            [ret bmSafeSetObject:shortName forKey:@"CountryCode"];
                        } else if ([typeArray containsObject:@"locality"]) {
                            [ret bmSafeSetObject:longName forKey:@"City"];
                        } else if ([typeArray containsObject:@"sublocality"]) {
                            ret[@"SubLocality"] = value;
                        } else if ([typeArray containsObject:@"route"]) {
                            ret[@"Thoroughfare"] = value;
                            ret[@"Street"] = value;
                        } else if ([typeArray containsObject:@"administrative_area_level_1"]) {
                            ret[@"State"] = value;
                        } else if ([typeArray containsObject:@"administrative_area_level_2"]) {
                            ret[@"SubAdministrativeArea"] = value;
                        }   
                    }
                }
            }
            
            NSString *formattedAddress = [firstResult bmObjectForKey:@"formatted_address" ofClass:[NSString class]];
            
            if (formattedAddress) {
                NSArray *addressLines = [formattedAddress componentsSeparatedByString:@","];
                NSMutableArray *trimmedAddressLines = [NSMutableArray array];
                for (NSString *addressLine in addressLines) {
                    [trimmedAddressLines addObject:[addressLine stringByTrimmingCharactersInSet:whitespaceCharSet]]; 
                }
                ret[@"FormattedAddressLines"] = trimmedAddressLines;
            }                
        }
    }    
    return ret;
}

- (id)resultFromRequest:(BMHTTPRequest *)theRequest {
    
    MKPlacemark *thePlacemark = nil;
    NSError *error = nil;
    SBJSON *sbjson = [SBJSON new];
    id parsedResult = [sbjson objectWithString:theRequest.reply error:&error];
    if (parsedResult) {
        NSDictionary *addressDictionary = [self parseGoogleResponse:parsedResult];
        if (addressDictionary) {
            thePlacemark = [[MKPlacemark alloc] initWithCoordinate:coordinate addressDictionary:addressDictionary];
        } else {
            LogWarn(@"Invalid response returned from Google reverse geocoding service");
        }
    } else {
        LogWarn(@"Could not parse response: %@", error);
    }
    return thePlacemark;
}

@end

@interface BMGoogleMapsReverseGeocoder()<BMServiceDelegate>

@end


@implementation BMGoogleMapsReverseGeocoder

- (void)dealloc {
    BM_RELEASE_SAFELY(_placemark1);
    [self cancel];
}

// A MKReverseGeocoder object should only be started once.
- (void)start {
    if (!service) {
        service = [[BMGoogleMapsReverseGeocoderService alloc] initWithCoordinate:self.coordinate];
        service.delegate = self;
        [service execute];
    }
}

- (void)cancel {
    [service cancel];
    service.delegate = nil;
    BM_AUTORELEASE_SAFELY(service);
}

- (MKPlacemark *)placemark {
    return _placemark1;
}

- (void)setPlacemark:(MKPlacemark *)thePlacemark {
    if (_placemark1 != thePlacemark) {
        _placemark1 = thePlacemark;
    }
}

- (BOOL)isQuerying {
    return service != nil;
}

#pragma mark -
#pragma mark BMServiceDelegate implementation

/**
 * Implement to act on successful completion of a service. 
 */
- (void)service:(id <BMService>)theService succeededWithResult:(id)result {
    [self setPlacemark:result];
    [self.delegate reverseGeocoder:self didFindPlacemark:result];
    BM_AUTORELEASE_SAFELY(service);
}

/**
 * Implement to act on failure of a service. 
 */
- (void)service:(id <BMService>)theService failedWithError:(NSError *)error {
    [self.delegate reverseGeocoder:self didFailWithError:error];
    BM_AUTORELEASE_SAFELY(service);
}

@end
