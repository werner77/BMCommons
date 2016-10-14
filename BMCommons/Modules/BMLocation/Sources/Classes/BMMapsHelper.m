//
//  BMMapsHelper.m
//  BMCommons
//
//  Created by Werner Altewischer on 16/08/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <BMCommons/BMMapsHelper.h>
#import <BMCommons/BMStringHelper.h>
#import <BMCommons/BMCore.h>

#define MAX_LOCATIONS_COUNT 50
#define CHARACTER_LIMIT 1450

#define MIN_LATITUDE(region) region.center.latitude - (region.span.latitudeDelta / 2)
#define MIN_LONGITUDE(region) region.center.longitude - (region.span.longitudeDelta / 2) 
#define MAX_LATITUDE(region) region.center.latitude + (region.span.latitudeDelta / 2)
#define MAX_LONGITUDE(region) region.center.longitude + (region.span.longitudeDelta / 2) 

@interface BMMapsHelper(Private)

+ (NSString *)encodeSignedInt:(int)num;
+ (NSString *)encodeUnsignedInt:(int)num;
+ (int)floor1e5:(double)coordinate;
+ (NSString *)googleMapTypeForMapStyle:(BMMapStyle)mapStyle;

@end

@implementation BMMapsHelper

static NSString *googleAPIKey = nil;
static NSString *cloudmadeAPIKey = nil;

+ (void)initialize {
    
}

+ (void)setGoogleAPIKey:(NSString *)key {
    if (googleAPIKey != key) {
        googleAPIKey = [key copy];
    }
}

+ (void)setCloudeMadeAPIKey:(NSString *)key {
    if (cloudmadeAPIKey != key) {
        cloudmadeAPIKey = [key copy];
    }
}

+ (NSString *)geoNameFromPlaceMark:(CLPlacemark *)placeMark {
	
	NSMutableArray *items = [NSMutableArray new];
    /*
    if (![BMStringHelper isEmpty:placeMark.subLocality]) {
		[items addObject:placeMark.subLocality];
	}
    */ 
    if (![BMStringHelper isEmpty:placeMark.locality]) {
		[items addObject:placeMark.locality];
	} else if (![BMStringHelper isEmpty:placeMark.subAdministrativeArea]) {
        [items addObject:placeMark.subAdministrativeArea];
    } else if (![BMStringHelper isEmpty:placeMark.thoroughfare]) {
        [items addObject:placeMark.thoroughfare];
    }
    if (![BMStringHelper isEmpty:placeMark.administrativeArea]) {
		[items addObject:placeMark.administrativeArea];
	}
	if (![BMStringHelper isEmpty:placeMark.country]) {
		[items addObject:placeMark.country];
	}
	
	NSMutableString *string = [NSMutableString new];
	for (int i = 0; i < items.count; ++i) {
		NSString *item = items[i];
		if (i > 0) {
			[string appendString:@", "];
		}
		[string appendString:item];
	}
	return string;
}

+ (void)getDirectionsInMapsApplicationFromLocation:(CLLocation *)fromLocation toLocation:(CLLocation *)toLocation {
	NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=%f,%f&daddr=%f,%f",
					 fromLocation.coordinate.latitude, fromLocation.coordinate.longitude,
					 toLocation.coordinate.latitude, toLocation.coordinate.longitude];
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
}

+ (NSString *)getStaticMapUrlForCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(int)zoomLevel imageSize:(CGSize)size {
	return [self getStaticMapUrlForCoordinate:coordinate zoomLevel:zoomLevel imageSize:size withMarkerImage:nil mapStyle:BMMapStyleGoogleStandard];		 
}

+ (NSString *)getStaticMapUrlForCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(int)zoomLevel imageSize:(CGSize)size withMarkerImage:(NSString *)markerImage mapStyle:(BMMapStyle)mapStyle {
	NSString *markerString;
	if (![BMStringHelper isEmpty:markerImage]) {
		NSString *encodedMarkerURLString = [markerImage stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
		markerString = [NSString stringWithFormat:@"icon:%@|", encodedMarkerURLString];
	} else {
		markerString = @"size:mid|color:red|";
	}
	
	NSString *mapType = [self googleMapTypeForMapStyle:mapStyle];
	NSMutableString *url = [NSMutableString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?center=%f,%f"
					 @"&zoom=%d&size=%dx%d&mobile=true&maptype=%@&markers=%@%f,%f&sensor=false", 
					 coordinate.latitude, coordinate.longitude,
					 zoomLevel,
					 (int)size.width, (int)size.height,
					 mapType,
					 markerString,
					 coordinate.latitude, coordinate.longitude];
    
    if (googleAPIKey != nil) {
        [url appendFormat:@"&key=%@", googleAPIKey];
    }
	return url;				 
}

+ (NSString *)getStaticMapUrlForLocations:(NSArray *)locations imageSize:(CGSize)size pathWeight:(NSInteger)weight color:(UIColor *)color mapStyle:(BMMapStyle)mapStyle {
	NSString *colorString = [self hexStringForColor:color];
	
	NSUInteger locationIncludeModulus = (locations.count / MAX_LOCATIONS_COUNT) + 1;
	
	if (locationIncludeModulus > 1) {
		int i = 0;
		NSMutableArray *newLocations = [NSMutableArray arrayWithCapacity:MAX_LOCATIONS_COUNT];
		for (CLLocation *loc in locations) {
			if (i++ % locationIncludeModulus == 0) {
				[newLocations addObject:loc];
			}
		}
		locations = newLocations;
	}
	
	NSString *polylineData = [self googlePolyline:locations];
	
	NSString *mapType = [self googleMapTypeForMapStyle:mapStyle];
	
	
	NSMutableString *url = [NSMutableString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?"
					 @"size=%dx%d&mobile=true"
					 "&maptype=%@"
					 @"&path=weight:%zd|color:%@|enc:%@"
					 "&sensor=false", 
					 (int)size.width, (int)size.height, 
					 mapType,
					 weight, colorString, polylineData];
	
    if (googleAPIKey != nil) {
        [url appendFormat:@"&key=%@", googleAPIKey];
    }
	return url;
}

+ (NSString *)getStaticMapUrlForRegion:(MKCoordinateRegion)region imageSize:(CGSize)size mapStyle:(BMMapStyle)mapStyle {
	if (!cloudmadeAPIKey) {
        LogWarn(@"No cloudmade API Key set: returning nil");
        return nil;
    }
	CLLocationCoordinate2D upperLeft = [self upperLeftCoordinateFromRegion:region];
	CLLocationCoordinate2D lowerRight = [self lowerRightCoordinateFromRegion:region];
	
	NSString *url = [NSString stringWithFormat:@"http://staticmaps.cloudmade.com/%@/staticmap?styleid=%d&size=%dx%d&bbox=%f,%f,%f,%f", 
					 cloudmadeAPIKey, (int)mapStyle, (int)size.width, (int)size.height, 
					 upperLeft.latitude, upperLeft.longitude, lowerRight.latitude, lowerRight.longitude];
	
	return url;
	
}

+ (NSString *)hexStringForColor:(UIColor *)color {
	if (!color) return nil;
	
	CGColorRef colorref = [color CGColor];
	
	size_t numComponents = CGColorGetNumberOfComponents(colorref);
	
	const CGFloat *components = CGColorGetComponents(colorref);
	NSInteger redIntValue, greenIntValue, blueIntValue, alphaIntValue;
	NSString *redHexValue, *greenHexValue, *blueHexValue, *alphaHexValue;
	
	CGFloat red = components[0];
	CGFloat green = components[1];
	CGFloat blue = components[2];
	
	redIntValue=lround(red * 255.0);
    greenIntValue=lround(green * 255.0);
    blueIntValue=lround(blue * 255.0);
	
    // Convert the numbers to hex strings
    redHexValue=[NSString stringWithFormat:@"%02lx", (long)redIntValue];
    greenHexValue=[NSString stringWithFormat:@"%02lx", (long)greenIntValue];
    blueHexValue=[NSString stringWithFormat:@"%02lx", (long)blueIntValue];
	
	NSString *colorString = [NSString stringWithFormat:@"0x%@%@%@", redHexValue, greenHexValue, blueHexValue];
	
	if (numComponents == 4) {
		CGFloat alpha = components[3];
		alphaIntValue = round(alpha*255.0f);
		alphaHexValue = [NSString stringWithFormat:@"%02lx", (long)alphaIntValue];
		colorString = [colorString stringByAppendingString:alphaHexValue];
	}
	return colorString;
}


+ (NSString *)googlePolyline:(NSArray *)locations {
	int i, late5, lnge5, dlat, dlng, plat, plng;
	
	if ([locations count] == 0) {
		return @"";
	}
	
	NSMutableString *encodedPoints = [NSMutableString stringWithCapacity:100];
	CLLocation *tmploc;
	
	plat = 0;
	plng = 0;
	
	for (i = 0; i < [locations count]; i++) {
		tmploc = locations[i];
		
		late5 = [self floor1e5: tmploc.coordinate.latitude];
		lnge5 = [self floor1e5: tmploc.coordinate.longitude];
		
		dlat = late5 - plat;
		dlng = lnge5 - plng;
		
		plat = late5;
		plng = lnge5;
		
		[encodedPoints appendString:[self encodeSignedInt:dlat]];
		[encodedPoints appendString:[self encodeSignedInt:dlng]];
	}
	return encodedPoints;
}

+ (NSMutableArray *)decodeGooglePolyLine:(NSString *)polyline {
	NSMutableString *encoded = [NSMutableString stringWithString:polyline];
	[encoded replaceOccurrencesOfString:@"\\\\" withString:@"\\"
								options:NSLiteralSearch
								  range:NSMakeRange(0, [encoded length])];
	NSInteger len = [encoded length];
	NSInteger index = 0;
	NSMutableArray *array = [[NSMutableArray alloc] init];
	NSInteger lat=0;
	NSInteger lng=0;
	
	while (index < len) {
		NSInteger b;
		NSInteger shift = 0;
		NSInteger result = 0;
		do {
			if (index >= len) {
				//corrupt, jump out of outer loop
				return array;
			}
			
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lat += dlat;
		shift = 0;
		result = 0;
		do {
			if (index >= len) {
				return array;
			}
			b = [encoded characterAtIndex:index++] - 63;
			result |= (b & 0x1f) << shift;
			shift += 5;
		} while (b >= 0x20);
		NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
		lng += dlng;
		NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
		NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
		CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
		[array addObject:loc];
	}
	
	return array;
}



+ (BMRegionDimensions)dimensionsForRegion:(MKCoordinateRegion)region {
	CLLocationDegrees minLat = MIN_LATITUDE(region);
	CLLocationDegrees maxLat = MAX_LATITUDE(region);
	CLLocationDegrees minLon = MIN_LONGITUDE(region);
	CLLocationDegrees maxLon = MAX_LONGITUDE(region);
	
	CLLocation *locMin = [[CLLocation alloc] initWithLatitude:minLat longitude:minLon];
	CLLocation *locMax = [[CLLocation alloc] initWithLatitude:maxLat longitude:maxLon];
	CLLocation *locMid = [[CLLocation alloc] initWithLatitude:minLat longitude:maxLon];
	
	BMRegionDimensions dimensions;
	
	dimensions.longitudinalDistance = [locMid distanceFromLocation:locMin];
	dimensions.latitudinalDistance = [locMax distanceFromLocation:locMid];
	
	
	return dimensions;
}

+ (MKCoordinateRegion)regionWithCenterCoordinate:(CLLocationCoordinate2D)center dimensions:(BMRegionDimensions)dimensions {
	return MKCoordinateRegionMakeWithDistance(center, dimensions.latitudinalDistance, dimensions.longitudinalDistance);
}

+ (CLLocationCoordinate2D)upperLeftCoordinateFromRegion:(MKCoordinateRegion)region {
	CLLocationCoordinate2D upperLeft;
	upperLeft.latitude = region.center.latitude + (region.span.latitudeDelta / 2);	
	upperLeft.longitude = region.center.longitude - (region.span.longitudeDelta / 2);
	return upperLeft;
}

+ (CLLocationCoordinate2D)upperRightCoordinateFromRegion:(MKCoordinateRegion)region {
	CLLocationCoordinate2D upperRight;
	upperRight.latitude = region.center.latitude + (region.span.latitudeDelta / 2);	
	upperRight.longitude = region.center.longitude + (region.span.longitudeDelta / 2);
	return upperRight;
}

+ (CLLocationCoordinate2D)lowerRightCoordinateFromRegion:(MKCoordinateRegion)region {
	CLLocationCoordinate2D lowerRight;
	lowerRight.latitude = region.center.latitude - (region.span.latitudeDelta / 2);
	lowerRight.longitude = region.center.longitude + (region.span.longitudeDelta / 2);
	return lowerRight;
}

+ (CLLocationCoordinate2D)lowerLeftCoordinateFromRegion:(MKCoordinateRegion)region {
	CLLocationCoordinate2D lowerLeft;
	lowerLeft.latitude = region.center.latitude - (region.span.latitudeDelta / 2);	
	lowerLeft.longitude = region.center.longitude - (region.span.longitudeDelta / 2);
	return lowerLeft;
}

+ (MKCoordinateRegion)regionWithUpperleft:(CLLocationCoordinate2D)upperLeft lowerRight:(CLLocationCoordinate2D)lowerRight {
	MKCoordinateRegion region;
	CLLocationCoordinate2D center;
	center.latitude = (upperLeft.latitude + lowerRight.latitude) / 2.0;
	center.longitude = (upperLeft.longitude + lowerRight.longitude) / 2.0;
	
	MKCoordinateSpan span;	
	span.latitudeDelta = upperLeft.latitude - lowerRight.latitude;
	span.longitudeDelta = lowerRight.longitude - upperLeft.longitude;
	
	region.center = center;
	region.span = span;
	return region;
}



@end

@implementation BMMapsHelper(Private)

+ (NSString *)encodeSignedInt:(int)num {
	int sgn_num = num << 1;
	if (num < 0) {
		sgn_num = ~(sgn_num);
	}
	return [self encodeUnsignedInt: sgn_num];
}

+ (NSString *)encodeUnsignedInt:(int)num {
	int nextValue;
	NSMutableString *encodeString = [NSMutableString stringWithCapacity:5];
	
	while (num >= 0x20) {
		nextValue = (0x20 | (num & 0x1f)) + 63;
		[encodeString appendFormat:@"%c", ((char) (nextValue))];
		num >>= 5;
	}
	
	num += 63;
	[encodeString appendFormat:@"%c", ((char) (num))];
	
	return encodeString;
}

+ (int)floor1e5:(double)coordinate {
	return (int) floor(coordinate * 1e5);
}

// defaults to roadmap
+ (NSString *)googleMapTypeForMapStyle:(BMMapStyle)mapStyle {
	NSString *mapType; 
	switch (mapStyle) {
		case BMMapStyleGoogleHybrid:
			mapType = @"hybrid";
			break;
		case BMMapStyleGoogleSattelite:
			mapType = @"satellite";
			break;
		case BMMapStyleGoogleTerrain:
			mapType = @"terrain";
			break;
		default:
			mapType = @"roadmap";
	}
	return mapType;
}

@end
