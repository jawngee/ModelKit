//
//  MKitParseServiceManager.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseServiceManager.h"
#import "MKitMutableModelArray.h"
#import "AFNetworking.h"
#import "MKitModel+Parse.h"
#import "MKitMutableModelArray+Parse.h"
#import "NSDate+ModelKit.h"
#import "JSONKit.h"
#import "MKitReflectedClass.h"
#import "MKitReflectedProperty.h"
#import "MKitReflectionManager.h"
#import "MKitServiceModel.h"
#import "MKitModelRegistry.h"
#import "MKitParseModelQuery.h"
#import "MKitParseModelBinder.h"

#define PARSE_BASE_URL @"https://api.parse.com/1/"

/**
 * Private methods
 */
@interface MKitParseServiceManager(Internal)

/**
 * Internal model update
 * @param model The model to update
 * @param props The properties to update
 * @param error The error to assign to if one occurs
 * @return YES if successful, otherwise NO
 */
-(BOOL)internalUpdateModel:(MKitModel *)model props:(NSDictionary *)props error:(NSError **)error;

/**
 * Internal model save
 * @param model The model to update
 * @param props The properties to update
 * @param error The error to assign to if one occurs
 * @return YES if successful, otherwise NO
 */
-(BOOL)internalSaveModel:(MKitModel *)model props:(NSDictionary *)props error:(NSError **)error;


@end

@implementation MKitParseServiceManager

-(id)initWithKeys:(NSDictionary *)keys
{
    if ((self=[super init]))
    {
        _appID=[[keys objectForKey:@"AppID"] copy];
        _restKey=[[keys objectForKey:@"RestKey"] copy];
        
        if (!_appID)
            @throw [NSException exceptionWithName:@"Missing App ID" reason:@"Missing AppID in keys dictionary" userInfo:nil];
        
        if (!_restKey)
            @throw [NSException exceptionWithName:@"Missing REST Key" reason:@"Missing RestKey in keys dictionary" userInfo:nil];
        
        parseClient=[[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:PARSE_BASE_URL]];
        [parseClient setDefaultHeader:@"X-Parse-Application-Id" value:_appID];
        [parseClient setDefaultHeader:@"X-Parse-REST-API-Key" value:_restKey];
        [parseClient setDefaultHeader:@"Content-Type" value:@"application/json"];
    }
    
    return self;
}

-(void)dealloc
{
    [_appID release];
    [_restKey release];
    
    [super dealloc];
}

-(MKitServiceModelQuery *)queryForModelClass:(Class)modelClass
{
    return [MKitParseModelQuery queryForModelClass:modelClass manager:self];
}


-(AFHTTPRequestOperation *)classRequestWithMethod:(NSString *)method class:(Class)class params:(NSDictionary *)params body:(NSData *)body
{
    NSMutableURLRequest *req=[parseClient requestWithMethod:method
                                                       path:[NSString stringWithFormat:@"classes/%@",[class modelName]]
                                                 parameters:params];
    
    if  (body)
        [req setHTTPBody:body];
    
    return [[[AFHTTPRequestOperation alloc] initWithRequest:req] autorelease];
}

-(AFHTTPRequestOperation *)modelRequestWithMethod:(NSString *)method model:(MKitModel *)model params:(NSDictionary *)params body:(NSData *)body
{
    NSMutableURLRequest *req=[parseClient requestWithMethod:method
                                                       path:[NSString stringWithFormat:@"classes/%@/%@",[[model class] modelName],model.objectId]
                                                 parameters:params];
    
    if (body)
        [req setHTTPBody:body];
    
    return [[[AFHTTPRequestOperation alloc] initWithRequest:req] autorelease];
}

-(BOOL)internalUpdateModel:(MKitModel *)model props:(NSDictionary *)props error:(NSError **)error
{
    AFHTTPRequestOperation *op=[self modelRequestWithMethod:@"PUT" model:model params:nil body:[props JSONData]];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        NSDictionary *data=[op.responseString objectFromJSONString];
        NSDate *updated=[NSDate dateFromISO8601:[data objectForKey:@"updatedAt"]];
        model.updatedAt=updated;
        model.modelState=ModelStateValid;
        
        return YES;
    }
    
    if (error!=nil)
        *error=op.error;
    
    return NO;
}

-(BOOL)internalSaveModel:(MKitModel *)model props:(NSDictionary *)props error:(NSError **)error
{
    AFHTTPRequestOperation *op=[self classRequestWithMethod:@"POST" class:[model class] params:nil body:[props JSONData]];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        NSDictionary *data=[op.responseString objectFromJSONString];
        NSDate *created=[NSDate dateFromISO8601:[data objectForKey:@"createdAt"]];
        model.objectId=[data objectForKey:@"objectId"];
        model.createdAt=created;
        model.updatedAt=created;
        model.modelState=ModelStateValid;
        
        return YES;
    }
    
    if (error!=nil)
        *error=op.error;
    return NO;
}

-(BOOL)saveModel:(MKitModel *)model error:(NSError **)error
{
    NSDictionary *props=(model.modelState==ModelStateNew) ? [model properties] : model.modelChanges;
    NSMutableDictionary *refs=[NSMutableDictionary dictionary];
    NSMutableDictionary *propsToSave=[NSMutableDictionary dictionary];
    
    [propsToSave setObject:model.modelId forKey:@"modelId"];

    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[obj class] isSubclassOfClass:[MKitModel class]])
        {
            MKitModel *m=(MKitModel *)obj;
            if (m.objectId)
            {
                if (m.modelState==ModelStateDirty)
                    [refs setObject:obj forKey:key];
                else if (m.modelState!=ModelStateDeleted)
                    [propsToSave setObject:[m parsePointer] forKey:key];
                else
                    [propsToSave setObject:[NSNull null] forKey:key];
            }
            else
                [refs setObject:obj forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[MKitMutableModelArray class]])
        {
            NSMutableArray *toSave=nil;
            NSArray *pointerArray=[obj parsePointerArray:&toSave];
            if (toSave!=nil)
                [refs setObject:toSave forKey:key];
            
            if (pointerArray.count>0)
                [propsToSave setObject:pointerArray forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[NSDate class]])
            [propsToSave setObject:@{@"__type":@"Date",@"iso":[((NSDate *)obj) ISO8601String]} forKey:key];
        else if ([[obj class] isSubclassOfClass:[NSMutableArray array]])
        {
            NSMutableArray *arrayCopy=[NSMutableArray array];
            for(id val in ((NSMutableArray *)obj))
                if ([[val class] isSubclassOfClass:[NSDate class]])
                    [arrayCopy addObject:@{@"__type":@"Date",@"iso":[((NSDate *)val) ISO8601String]}];
                else
                    [arrayCopy addObject:val];
            
            [propsToSave setObject:arrayCopy forKey:key];
        }
        else
            [propsToSave setObject:obj forKey:key];
    }];
    
    BOOL result=NO;
    
    if (!model.objectId)
        result=[self internalSaveModel:model props:propsToSave error:error];
    else
        result=[self internalUpdateModel:model props:props error:error];
   
    if (!result)
        return NO;
    
    [propsToSave removeAllObjects];
    if (refs.count>0)
    {
        __block BOOL blockResult=YES;
        [refs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([[obj class] isSubclassOfClass:[MKitModel class]])
            {
                MKitModel *m=(MKitModel *)obj;
                if (!m.objectId)
                {
                    blockResult=[self saveModel:m error:error];
                    if (!blockResult)
                        return;
                }

                [propsToSave setObject:[m parsePointer] forKey:key];
            }
            else if ([[obj class] isSubclassOfClass:[NSMutableArray class]])
            {
                MKitMutableModelArray *savedModels=[MKitMutableModelArray array];
                for(MKitModel *m in ((NSMutableArray *)obj))
                {
                    if (!m.objectId)
                    {
                        blockResult=[self saveModel:m error:error];
                        if (!blockResult)
                            return;
                    }
                    
                    [savedModels addObject:m];
                }
                
                NSMutableArray *toSave=nil;
                [propsToSave setObject:[savedModels parsePointerArray:&toSave] forKey:key];
            }
        }];
        
        if (!blockResult)
            return NO;
        
        return [self internalUpdateModel:model props:propsToSave error:error];
    }
    
    return YES;
}

-(BOOL)deleteModel:(MKitModel *)model error:(NSError **)error
{
    AFHTTPRequestOperation *op=[self modelRequestWithMethod:@"DELETE" model:model params:nil body:nil];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        model.modelState=ModelStateDeleted;
        [model removeFromContext];
        return YES;
    }
    
    if (error!=nil)
        *error=op.error;
    
    return NO;
}

-(BOOL)fetchModel:(MKitModel *)model error:(NSError **)error
{
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[model class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    
    NSMutableArray *toInclude=[NSMutableArray array];
    for(MKitReflectedProperty *p in [ref.properties allValues])
    {
        if (([p.typeClass isSubclassOfClass:[MKitModel class]]) || ([p.typeClass isSubclassOfClass:[MKitMutableModelArray class]]))
            [toInclude addObject:p.name];
    }
    
    NSDictionary *params=nil;
    if (toInclude.count>0)
        params=@{@"include":[toInclude componentsJoinedByString:@","]};
    
    AFHTTPRequestOperation *op=[self modelRequestWithMethod:@"GET" model:model params:params body:nil];
   
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        id data=[op.responseString objectFromJSONString];
        [MKitParseModelBinder bindModel:model data:data];
        return YES;
    }
    
    if (error!=nil)
        *error=op.error;
    
    return NO;
}

@end
