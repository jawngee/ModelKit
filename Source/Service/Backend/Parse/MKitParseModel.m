//
//  MKitParseModel.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseModel.h"
#import "MKitParseServiceManager.h"

@implementation MKitParseModel


+(MKitServiceManager *)service
{
    static MKitServiceManager *parseService=nil;
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        parseService=[MKitServiceManager managerForServiceNamed:MKitParseServiceName];
    });
    
    return parseService;
}

@end
