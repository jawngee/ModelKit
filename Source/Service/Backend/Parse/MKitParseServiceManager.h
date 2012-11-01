//
//  MKitParseServiceManager.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceManager.h"
#import "AFNetworking.h"

/**
 * Parse.com Service Manager
 */
@interface MKitParseServiceManager : MKitServiceManager
{
@private
    AFHTTPClient *parseClient;
    NSString *_appID;
    NSString *_restKey;
}

@end
