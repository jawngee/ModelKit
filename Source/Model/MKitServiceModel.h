//
//  MKitServiceModel.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"
#import "MKitServiceManager.h"

@interface MKitServiceModel : MKitModel

-(MKitServiceManager *)service;

-(BOOL)save:(NSError **)error;
-(void)saveInBackground:(MKitBooleanResultBlock)resultBlock;

-(BOOL)delete:(NSError **)error;
-(void)deleteInBackground:(MKitBooleanResultBlock)resultBlock;

-(BOOL)fetch:(NSError **)error;
-(void)fetchInBackground:(MKitBooleanResultBlock)resultBlock;


@end
