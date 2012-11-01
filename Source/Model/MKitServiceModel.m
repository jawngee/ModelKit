//
//  MKitServiceModel.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceModel.h"

@implementation MKitServiceModel

+(MKitModelQuery *)query
{
    return [[self service] queryForModelClass:self];
}

+(MKitServiceManager *)service
{
    return nil;
}

-(BOOL)save:(NSError **)error
{
    return [[[self class] service] saveModel:self error:error];
}

-(void)saveInBackground:(MKitBooleanResultBlock)resultBlock
{
    [[[self class] service] saveModelInBackground:self withBlock:resultBlock];
}

-(BOOL)delete:(NSError **)error
{
    return [[[self class] service] deleteModel:self error:error];
}

-(void)deleteInBackground:(MKitBooleanResultBlock)resultBlock
{
    [[[self class] service] deleteModelInBackground:self withBlock:resultBlock];
}

-(BOOL)fetch:(NSError **)error
{
    return [[[self class] service] fetchModel:self error:error];
}

-(void)fetchInBackground:(MKitBooleanResultBlock)resultBlock
{
    [[[self class] service] fetchModelInBackground:self withBlock:resultBlock];
}
@end
