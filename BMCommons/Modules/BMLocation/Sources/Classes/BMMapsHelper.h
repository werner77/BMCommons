//
//  BMMapsHelper.h
//  BMCommons
//
//  Created by Werner Altewischer on 16/08/11.
//  Copyright 2011 BehindMedia. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

#define MAP_STYLE_GOOGLE_STANDARD		1976845
#define MAP_STYLE_GOOGLE_SATELLITE		1976846
#define MAP_STYLE_GOOGLE_HYBRID		1976847
#define MAP_STYLE_GOOGLE_TERRAIN		1976848
#define MAP_STYLE_CLOUDMADE_FINE_LINE	2
#define MAP_STYLE_CLOUDMADE_IPHONE		1818
#define MAP_STYLE_CLOUDMADE_ORIGINAL	1
#define MAP_STYLE_CLOUDMADE_MIDNIGHT	999
#define MAP_STYLE_CLOUDMADE_OPEN_CYCLE  1976848
#define MAP_STYLE_CLOUDMADE_BLACK_AND_WHITE 14098
#define MAP_STYLE_CLOUDMADE_BLACKOUT 1960 

typedef enum BMMapStyle {
	BMMapStyleGoogleStandard = MAP_STYLE_GOOGLE_STANDARD,
	BMMapStyleGoogleHybrid = MAP_STYLE_GOOGLE_HYBRID,
	BMMapStyleGoogleSattelite = MAP_STYLE_GOOGLE_SATELLITE,
	BMMapStyleGoogleTerrain = MAP_STYLE_GOOGLE_TERRAIN,
	BMMapStyleCloudMadeFineLine = MAP_STYLE_CLOUDMADE_FINE_LINE,
	BMMapStyleCloudMadeIPhone = MAP_STYLE_CLOUDMADE_IPHONE,
	BMMapStyleCloudMadeOriginal = MAP_STYLE_CLOUDMADE_ORIGINAL,
	BMMapStyleCloudMadeMidnight = MAP_STYLE_CLOUDMADE_MIDNIGHT,
	BMMapStyleCloudMadeOpenCycle = MAP_STYLE_CLOUDMADE_OPEN_CYCLE,
	BMMapStyleCloudMadeBlackAndWhite = MAP_STYLE_CLOUDMADE_BLACK_AND_WHITE,
	BMMapStyleCloudMadeBlackout = MAP_STYLE_CLOUDMADE_BLACKOUT
} BMMapStyle;

typedef struct BMRegionDimensions
{
	CLLocationDistance longitudinalDistance;
	CLLocationDistance latitudinalDistance;
} BMRegionDimensions;


@interface BMMapsHelper : NSObject  {
	
}

+ (void)setGoogleAPIKey:(NSString *)key;
+ (void)setCloudeMadeAPIKey:(NSString *)key;

+ (NSString *)geoNameFromPlaceMark:(CLPlacemark *)placeMark;
+ (void)getDirectionsInMapsApplicationFromLocation:(CLLocation *)fromLocation toLocation:(CLLocation *)toLocation;
+ (NSString *)getStaticMapUrlForCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(int)zoomLevel imageSize:(CGSize)size;
+ (NSString *)getStaticMapUrlForCoordinate:(CLLocationCoordinate2D)coordinate zoomLevel:(int)zoomLevel imageSize:(CGSize)size withMarkerImage:(NSString *)markerImage mapStyle:(BMMapStyle)mapStyle;
+ (NSString *)getStaticMapUrlForLocations:(NSArray *)locations imageSize:(CGSize)size pathWeight:(NSInteger)weight color:(UIColor *)color mapStyle:(BMMapStyle)mapStyle;
+ (NSString *)getStaticMapUrlForRegion:(MKCoordinateRegion)region imageSize:(CGSize)size mapStyle:(BMMapStyle)mapStyle;
+ (NSString *)hexStringForColor:(UIColor *)color;
+ (NSString *)googlePolyline:(NSArray *)locations;
+ (NSMutableArray *)decodeGooglePolyLine:(NSString *)polyline;


+ (BMRegionDimensions)dimensionsForRegion:(MKCoordinateRegion)region;
+ (MKCoordinateRegion)regionWithCenterCoordinate:(CLLocationCoordinate2D)center dimensions:(BMRegionDimensions)dimensions;
+ (CLLocationCoordinate2D)upperLeftCoordinateFromRegion:(MKCoordinateRegion)region;
+ (CLLocationCoordinate2D)upperRightCoordinateFromRegion:(MKCoordinateRegion)region;
+ (CLLocationCoordinate2D)lowerRightCoordinateFromRegion:(MKCoordinateRegion)region;
+ (CLLocationCoordinate2D)lowerLeftCoordinateFromRegion:(MKCoordinateRegion)region;
+ (MKCoordinateRegion)regionWithUpperleft:(CLLocationCoordinate2D)upperLeft lowerRight:(CLLocationCoordinate2D)lowerRight;

@end
