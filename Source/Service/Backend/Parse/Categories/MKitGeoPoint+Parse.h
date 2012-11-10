//
//  MKitGeoPoint+Parse.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/10/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitGeoPoint.h"

/**
 * Parse related categories for MKitGeoPoint
 */
@interface MKitGeoPoint (Parse)

/**
 * Returns the geo point as a parse pointer
 * @return Dictionary in parse pointer "format"
 */
-(NSDictionary *)parsePointer;

@end
