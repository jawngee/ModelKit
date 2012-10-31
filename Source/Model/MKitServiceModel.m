//
//  MKitServiceModel.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceModel.h"

@implementation MKitServiceModel

-(MKitServiceManager *)service
{
    return nil;
}

-(BOOL)save:(NSError **)error
{
    return [[self service] saveModel:self error:error];
}

-(void)saveInBackground:(MKitBooleanResultBlock)resultBlock
{
    [[self service] saveModelInBackground:self withBlock:resultBlock];
}

-(BOOL)delete:(NSError **)error
{
    return [[self service] deleteModel:self error:error];
}

-(void)deleteInBackground:(MKitBooleanResultBlock)resultBlock
{
    [[self service] deleteModelInBackground:self withBlock:resultBlock];
}

-(BOOL)fetch:(NSError **)error
{
    return [[self service] fetchModel:self error:error];
}

-(void)fetchInBackground:(MKitBooleanResultBlock)resultBlock
{
    [[self service] fetchModelInBackground:self withBlock:resultBlock];
}
@end
