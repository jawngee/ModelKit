//
//  MKitGeoPoint.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/9/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef EARTH_RADIUS
#define EARTH_RADIUS 6371.01
#endif

@class MKitGeoPoint;

#pragma mark - MKitGeoBounds

/**
 * Geo Boundary
 */
@interface MKitGeoBounds : NSObject

@property (retain, nonatomic) MKitGeoPoint *minPoint;     /**< Minimum point of the boundary */
@property (retain, nonatomic) MKitGeoPoint *maxPoint;     /**< Maximum point of the boundary */

/**
 * Creates a new geo boundary
 * @param minPoint The minimum point
 * @param maxPoint The maximum point
 * @return New instance
 */
+(id)boundsWithMinPoint:(MKitGeoPoint *)minPoint maxPoint:(MKitGeoPoint *)maxPoint;

@end


#pragma mark - MKitGeoPoint

/**
 * Represents a lat/long point
 */
@interface MKitGeoPoint : NSObject

@property (assign, nonatomic) double latitude;      /**< Latitude in degrees */
@property (assign, nonatomic) double longitude;     /**< Longitude in degrees */

@property (readonly, nonatomic) double latitudeRad;     /**< Latitude in radians, automatically calculated */
@property (readonly, nonatomic) double longitudeRad;    /**< Longitude in radians, automatically calculated */

/**
 * Creates a new MKitGeoPoint
 * @param latitude The latitude in degrees
 * @param longitude The longitude in degrees
 * @return New instance
 */
-(id)initWithLatitude:(double)latitude andLongitude:(double)longitude;

/**
 * Creates a new MKitGeoPoint
 * @param latitude The latitude in degrees
 * @param longitude The longitude in degrees
 * @return New instance
 */
+(id)geoPointWithLatitude:(double)latitude andLongitude:(double)longitude;

/**
 * Returns the distance between two points in kilometers
 * @param geoPoint The second point
 * @return The distance in KM
 */
-(double)distanceTo:(MKitGeoPoint *)geoPoint;

/**
 * Returns the bounding coordinates for a given distance in kilometers
 * @param distance The distance in kilometers
 * @return The bounding coordinates
 */
-(MKitGeoBounds *)boundingCoordinatesForDistance:(double)distance;

@end
