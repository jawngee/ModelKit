//
//  MKitGeoPoint+Parse.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/10/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitGeoPoint+Parse.h"

@implementation MKitGeoPoint (Parse)

-(NSDictionary *)parsePointer
{
    return @{@"__type":@"GeoPoint",@"latitude":@(self.latitude),@"longitude":@(self.longitude)};
}

@end
