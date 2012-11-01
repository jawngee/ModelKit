//
//  MKitServiceManager.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceManager.h"
#import "MKitServiceModelQuery.h"

@implementation MKitServiceManager

static NSMutableDictionary *managers=nil;

+(MKitServiceManager *)setupService:(NSString *)name withKeys:(NSDictionary *)keys
{
    if (!managers)
        managers=[[NSMutableDictionary dictionary] retain];
    
    MKitServiceManager *m=[managers objectForKey:name];
    if (m)
        [managers removeObjectForKey:m];
    
    Class serviceClass=NSClassFromString([NSString stringWithFormat:@"MKit%@ServiceManager",name]);
    if (!serviceClass)
        @throw [NSException exceptionWithName:@"Service Not Found" reason:[NSString stringWithFormat:@"Service named '%@' could not be found.",name] userInfo:nil];
    
    m=[[serviceClass alloc] initWithKeys:keys];
    [managers setObject:m forKey:name];
    return m;
}

+(MKitServiceManager *)managerForService:(NSString *)name;
{
    if (!managers)
        managers=[[NSMutableDictionary dictionary] retain];
    
    return [managers objectForKey:name];
}

-(id)initWithKeys:(NSDictionary *)keys
{
    if ((self=[super init]))
    {
        
    }
    
    return self;
}

-(MKitServiceModelQuery *)queryForModelClass:(Class)modelClass
{
    return nil;
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

-(AFHTTPRequestOperation *)classRequestWithMethod:(NSString *)method class:(Class)class params:(NSDictionary *)params body:(NSData *)body
{
    return nil;
}

-(AFHTTPRequestOperation *)modelRequestWithMethod:(NSString *)method model:(MKitModel *)model params:(NSDictionary *)params body:(NSData *)body
{
    return nil;
}

@end
