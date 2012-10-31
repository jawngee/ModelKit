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

#define PARSE_BASE_URL @"https://api.parse.com/1/"

@interface MKitParseServiceManager()

-(BOOL)internalUpdateModel:(MKitModel *)model props:(NSDictionary *)props error:(NSError **)error;
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

-(BOOL)internalUpdateModel:(MKitModel *)model props:(NSDictionary *)props error:(NSError **)error
{
    NSString *modelName=(model.modelName) ? model.modelName : NSStringFromClass([model class]);
    NSMutableURLRequest *req=[parseClient requestWithMethod:@"PUT"
                                                       path:[NSString stringWithFormat:@"classes/%@/%@",modelName,model.objectId]
                                                 parameters:nil];
    [req setHTTPBody:[props JSONData]];
    
    AFHTTPRequestOperation *op=[[AFHTTPRequestOperation alloc] initWithRequest:req];
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
    
    *error=op.error;
    return NO;
}

-(BOOL)internalSaveModel:(MKitModel *)model props:(NSDictionary *)props error:(NSError **)error
{
    NSString *modelName=(model.modelName) ? model.modelName : NSStringFromClass([model class]);
    NSMutableURLRequest *req=[parseClient requestWithMethod:@"POST"
                                                       path:[NSString stringWithFormat:@"classes/%@",modelName]
                                                 parameters:nil];
    [req setHTTPBody:[props JSONData]];
    
    AFHTTPRequestOperation *op=[[AFHTTPRequestOperation alloc] initWithRequest:req];
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
                
                [propsToSave setObject:savedModels forKey:key];
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
    return NO;
}

-(BOOL)fetchModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

@end
