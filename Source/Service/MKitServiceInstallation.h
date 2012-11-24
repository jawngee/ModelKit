//
//  MKitServiceInstallation.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/17/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitServiceModel.h"

@protocol MKitServiceInstallation

@property (nonatomic, copy) NSString *deviceType;
@property (nonatomic, copy) NSString *installationId;
@property (nonatomic, copy) NSString *deviceToken;
@property (nonatomic, assign) NSInteger badge;
@property (nonatomic, copy) NSString *timeZone;
@property (nonatomic, retain) NSMutableArray *channels;

+(id<MKitServiceInstallation>)currentInstallation;

@end
