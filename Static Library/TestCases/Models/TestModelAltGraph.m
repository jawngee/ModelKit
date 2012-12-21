//
//  TestModelAltGraph.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/14/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "TestModelAltGraph.h"
#import "MKitModelGraph.h"

@implementation TestModelAltGraph

+(MKitModelGraph *)graph
{
    return [MKitModelGraph graphNamed:@"alt"];
}

@end
