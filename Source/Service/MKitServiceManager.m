//
//  MKitServiceManager.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceManager.h"

@implementation MKitServiceManager

static MKitServiceManager *currentManager=nil;

+(MKitServiceManager *)setupService:(NSString *)name withKeys:(NSDictionary *)keys
{
    if (currentManager)
        [currentManager release];
    
    Class serviceClass=NSClassFromString([NSString stringWithFormat:@"MKit%@ServiceManager",name]);
    if (!serviceClass)
        @throw [NSException exceptionWithName:@"Service Not Found" reason:[NSString stringWithFormat:@"Service named '%@' could not be found.",name] userInfo:nil];
    
    currentManager=[[serviceClass alloc] initWithKeys:keys];
    return currentManager;
}

+(MKitServiceManager *)current
{
    return currentManager;
}

-(id)initWithKeys:(NSDictionary *)keys
{
    if ((self=[super init]))
    {
        
    }
    
    return self;
}

-(BOOL)saveModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

-(void)saveModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self saveModel:model error:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}

-(BOOL)updateModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

-(void)updateModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self updateModel:model error:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}

-(BOOL)deleteModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

-(void)deleteModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self deleteModel:model error:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}

-(BOOL)fetchModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

-(void)fetchModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self fetchModel:model error:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}

@end
