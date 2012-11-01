//
//  MKitParseModel.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseModel.h"

@implementation MKitParseModel

static MKitServiceManager *parseService=nil;

+(MKitServiceManager *)service
{
    if (parseService==nil)
        parseService=[MKitServiceManager managerForService:@"Parse"];
    
    return parseService;
}

@end
