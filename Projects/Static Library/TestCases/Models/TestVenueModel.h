//
//  TestVenueModel.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/10/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"
#import "MKitGeoPoint.h"

@interface TestVenueModel : MKitModel

@property (retain, nonatomic) MKitGeoPoint *location;
@property (copy, nonatomic) NSString *name;
@property (assign, nonatomic) double distance;

@end
