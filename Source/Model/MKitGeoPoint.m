//
//  MKitGeoPoint.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/9/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitGeoPoint.h"

#define RADIANS_TO_DEGREES(radians) ((radians) * (180.0 / M_PI))
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define MIN_LAT (-M_PI/2)
#define MAX_LAT (M_PI/2)
#define MIN_LON (-M_PI)
#define MAX_LON M_PI

#pragma mark - MKitGeoBounds

@implementation MKitGeoBounds

+(id)boundsWithMinPoint:(MKitGeoPoint *)minPoint maxPoint:(MKitGeoPoint *)maxPoint
{
    MKitGeoBounds *s=[[[self alloc] init] autorelease];
    s.minPoint=minPoint;
    s.maxPoint=maxPoint;
    
    return s;
}

-(void)dealloc
{
    self.minPoint=nil;
    self.maxPoint=nil;
    
    [super dealloc];
}

@end


#pragma mark - MKitGeoPoint

@implementation MKitGeoPoint

-(id)initWithLatitude:(double)latitude andLongitude:(double)longitude
{
    if ((self=[super init]))
    {
        self.longitude=longitude;
        self.latitude=latitude;
    }
    
    return self;
}

+(id)geoPointWithLatitude:(double)latitude andLongitude:(double)longitude
{
    return [[[self alloc] initWithLatitude:latitude andLongitude:longitude] autorelease];
}

-(double)distanceTo:(MKitGeoPoint *)geoPoint
{
    return acos(sin(_latitudeRad)*sin(geoPoint.latitudeRad)+cos(_latitudeRad)*cos(geoPoint.latitudeRad)*cos(_longitudeRad-geoPoint.longitudeRad))*EARTH_RADIUS;
}


-(MKitGeoBounds *)boundingCoordinatesForDistance:(double)distance
{
    double radDist = distance / EARTH_RADIUS;
    
    double minLat = _latitudeRad - radDist;
    double maxLat = _latitudeRad + radDist;
    
    double minLon, maxLon;
    if ((minLat > MIN_LAT) && (maxLat < MAX_LAT))
    {
        double deltaLon = asin(sin(radDist) / cos(_latitudeRad));
        
        minLon = _longitudeRad - deltaLon;
        if (minLon < MIN_LON)
            minLon += 2.0 * M_PI;
        
        maxLon = _longitudeRad + deltaLon;
        if (maxLon > MAX_LON)
            maxLon -= 2.0 * M_PI;
    }
    else
    {
        // a pole is within the distance
        minLat = MAX(minLat, MIN_LAT);
        maxLat = MIN(maxLat, MAX_LAT);
        minLon = MIN_LON;
        maxLon = MAX_LON;
    }
    
    return [MKitGeoBounds boundsWithMinPoint:[[self class] geoPointWithLatitude:RADIANS_TO_DEGREES(minLat) andLongitude:RADIANS_TO_DEGREES(minLon)]
                                    maxPoint:[[self class] geoPointWithLatitude:RADIANS_TO_DEGREES(maxLat) andLongitude:RADIANS_TO_DEGREES(maxLon)]];
}

-(void)setLatitude:(double)val
{
    _latitude=val;
    _latitudeRad=DEGREES_TO_RADIANS(val);
}

-(void)setLongitude:(double)val
{
    _longitude=val;
    _longitudeRad=DEGREES_TO_RADIANS(val);
}

@end
