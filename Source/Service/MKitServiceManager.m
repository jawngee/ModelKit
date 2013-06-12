//
//  MKitServiceManager.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceManager.h"
#import "MKitServiceModelQuery.h"
#import "MKitServiceUser.h"
#import "MKitServiceModel.h"

NSString * const MKitReachabilityChangedNotification=@"MKitReachabilityChangedNotification";

@implementation MKitServiceManager

@synthesize keychain;

static NSMutableDictionary *managers=nil;

+(void)addService:(MKitServiceManager *)service named:(NSString *)serviceName
{
    [managers setObject:service forKey:serviceName];
}

+(MKitServiceManager *)managerForServiceNamed:(NSString *)name;
{
    return [managers objectForKey:name];
}

+(void)initialize
{
    [super initialize];
    
    managers=[[NSMutableDictionary dictionary] retain];
}

-(id)initWithKeys:(NSDictionary *)keys
{
    if ((self=[super init]))
    {
        keychain=nil;
        
        _reachable=YES;
        _reachableOnWifi=YES;
    }
    
    return self;
}

#pragma mark - Query

-(MKitServiceModelQuery *)queryForModelClass:(Class)modelClass
{
    return nil;
}

#pragma mark - Model

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

#pragma mark - Request generation

-(AFHTTPRequestOperation *)classRequestWithMethod:(NSString *)method class:(Class)class params:(NSDictionary *)params body:(NSData *)body
{
    return nil;
}

-(AFHTTPRequestOperation *)modelRequestWithMethod:(NSString *)method model:(MKitModel *)model params:(NSDictionary *)params body:(NSData *)body
{
    return nil;
}

-(AFHTTPRequestOperation *)requestWithMethod:(NSString *)method path:(NSString *)path params:(NSDictionary *)params body:(NSData *)body contentType:(NSString *)contentType
{
    return nil;
}

#pragma mark - Credentials

-(NSDictionary *)userCredentials
{
    return nil;
}

-(void)storeUserCredentials:(MKitServiceModel<MKitServiceUser> *)user
{
    
}

#pragma mark - Installation Data

-(id)installationData
{
    return nil;
}

-(void)storeInstallationData:(MKitServiceModel<MKitServiceInstallation> *)install
{
    
}

#pragma mark - File

-(BOOL)saveFile:(MKitServiceFile *)file progressBlock:(MKitProgressBlock)progressBlock error:(NSError **)error
{
    return NO;
}

-(void)saveFileInBackground:(MKitServiceFile *)file progressBlock:(MKitProgressBlock)progressBlock resultBlock:(MKitBooleanResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self saveFile:file progressBlock:progressBlock error:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}

-(BOOL)deleteFile:(MKitServiceFile *)file error:(NSError **)error
{
    return NO;
}

-(void)deleteFileInBackground:(MKitServiceFile *)file withBlock:(MKitBooleanResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self deleteFile:file error:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}

-(void)callFunction:(NSString *)function parameters:(NSDictionary *)params resultBlock:(MKitServiceResultBlock)resultBlock
{
    if (resultBlock)
        resultBlock(NO,nil,nil);
}

-(void)callFunctionInBackground:(NSString *)function parameters:(NSDictionary *)params resultBlock:(MKitServiceResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self callFunction:function parameters:params resultBlock:resultBlock];
    });
}

@end
