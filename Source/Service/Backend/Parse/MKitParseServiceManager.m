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
#import "MKitParseUser.h"
#import "MKitParseFile.h"

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
        
        keychain=[[MKitServiceKeyChain alloc] initWithService:_appID];
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
    [parseClient setDefaultHeader:@"Content-Type" value:@"application/json"];

    // If we are currently logged in, set the session token
    if ([MKitParseUser currentUser])
        [parseClient setDefaultHeader:@"X-Parse-Session-Token" value:[MKitParseUser currentUser].modelSessionToken];
    
    // Parse uses a slightly different path for users, though the procedures are the same.  pita.
    NSString *path=[class isSubclassOfClass:[MKitParseUser class]] ? @"users" : [NSString stringWithFormat:@"classes/%@",[class modelName]];
    
    NSMutableURLRequest *req=[parseClient requestWithMethod:method
                                                       path:path
                                                 parameters:params];
    
    if  (body)
        [req setHTTPBody:body];
    
    return [[[AFHTTPRequestOperation alloc] initWithRequest:req] autorelease];
}

-(AFHTTPRequestOperation *)modelRequestWithMethod:(NSString *)method model:(MKitModel *)model params:(NSDictionary *)params body:(NSData *)body
{
    [parseClient setDefaultHeader:@"Content-Type" value:@"application/json"];

    // If we are currently logged in, set the session token
    if ([MKitParseUser currentUser])
        [parseClient setDefaultHeader:@"X-Parse-Session-Token" value:[MKitParseUser currentUser].modelSessionToken];
    
    // Parse uses a slightly different path for users, though the procedures are the same.  pita.
    NSString *path=[model isKindOfClass:[MKitParseUser class]] ? [NSString stringWithFormat:@"users/%@",model.objectId] : [NSString stringWithFormat:@"classes/%@/%@",[[model class] modelName],model.objectId];
    
    NSMutableURLRequest *req=[parseClient requestWithMethod:method
                                                       path:path
                                                 parameters:params];
    
    if (body)
        [req setHTTPBody:body];
    
    return [[[AFHTTPRequestOperation alloc] initWithRequest:req] autorelease];
}

-(AFHTTPRequestOperation *)requestWithMethod:(NSString *)method path:(NSString *)path params:(NSDictionary *)params body:(NSData *)body contentType:(NSString *)contentType
{
    contentType=(contentType) ? contentType : @"application/json";
    [parseClient setDefaultHeader:@"Content-Type" value:contentType];

    NSMutableURLRequest *req=[parseClient requestWithMethod:method
                                                       path:path
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
        
        // If this class is a user, we need to do some special handling
        if (([model isKindOfClass:[MKitParseUser class]]) && (data[@"sessionToken"]))
        {
            ((MKitParseUser *)model).modelSessionToken=data[@"sessionToken"];
            
            // save the credentials in the keychain
            [self storeUserCredentials:(MKitParseUser *)model];
        }
        
        return YES;
    }
    
    // TODO: Handle JSON error response
    if (error!=nil)
        *error=op.error;
    
    return NO;
}

-(BOOL)saveModel:(MKitModel *)model error:(NSError **)error
{
    // normally I don't comment this much, but since you are reading this
    // you are possibly trying to write a new backend for ModelKit.  Hopefully
    // these comments will be helpful to you
    
    // If saving new, we want all of the properties, otherwise just the ones that have changed
    NSDictionary *props=(model.modelState==ModelStateNew) ? [model properties] : model.modelChanges;
    
    NSMutableDictionary *refs=[NSMutableDictionary dictionary];
    NSMutableDictionary *propsToSave=[NSMutableDictionary dictionary];
    
    // Not sure we need to do this, but better safe than sorry.  Will revisit.
    [propsToSave setObject:model.modelId forKey:@"modelId"];

    // Loop through all of the properties we are saving
    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        if ([[obj class] isSubclassOfClass:[MKitModel class]])
        {
            MKitModel *m=(MKitModel *)obj;
            
            // If the model has an object id then it has been saved before
            if (m.objectId)
            {
                if (m.modelState==ModelStateDirty)
                {
                    // we need to save this
                    [refs setObject:obj forKey:key];
                }
                else if (m.modelState!=ModelStateDeleted)
                {
                    // no need to save, so we just turn it into the "pointer" format parse uses
                    [propsToSave setObject:[m parsePointer] forKey:key];
                }
                else
                {
                    // set it to NULL
                    [propsToSave setObject:[NSNull null] forKey:key];
                }
            }
            else
            {
                // model has never been saved
                [refs setObject:obj forKey:key];
            }
        }
        else if ([[obj class] isSubclassOfClass:[MKitMutableModelArray class]])
        {
            NSMutableArray *toSave=nil;
            
            // Convert what we can to parse "pointers", the rest we will process later
            NSArray *pointerArray=[obj parsePointerArray:&toSave];
            
            // Save the ones we need to process later
            if (toSave!=nil)
                [refs setObject:toSave forKey:key];
            
            // We'll save the ones we can now
            if (pointerArray.count>0)
                [propsToSave setObject:pointerArray forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[NSDate class]])
        {
            // convert to parse's date format
            [propsToSave setObject:@{@"__type":@"Date",@"iso":[((NSDate *)obj) ISO8601String]} forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[MKitParseFile class]])
        {
            [propsToSave setObject:[((MKitParseFile *)obj) parseFilePointer] forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[NSMutableArray array]])
        {
            NSMutableArray *arrayCopy=[NSMutableArray array];
            for(id val in ((NSMutableArray *)obj))
                if ([[val class] isSubclassOfClass:[NSDate class]])
                    [arrayCopy addObject:@{@"__type":@"Date",@"iso":[((NSDate *)val) ISO8601String]}];
                else if ([[val class] isSubclassOfClass:[MKitParseFile class]])
                    [arrayCopy addObject:[((MKitParseFile *)val) parseFilePointer]];
                else
                    [arrayCopy addObject:val];
            
            [propsToSave setObject:arrayCopy forKey:key];
        }
        else
            [propsToSave setObject:obj forKey:key];
    }];
    
    BOOL result=NO;
    
    if (!model.objectId)
    {
        // this model is "new" and needs to be saved
        result=[self internalSaveModel:model props:propsToSave error:error];
    }
    else if (propsToSave.count>0)
    {
        // just needs to be updated
        result=[self internalUpdateModel:model props:propsToSave error:error];
    }
    
    // if we failed we're going to bail here.
    if (!result)
        return NO;
    
    [propsToSave removeAllObjects];
    
    // process all of the other models this model contains/points to
    if (refs.count>0)
    {
        __block BOOL blockResult=YES;
        
        [refs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if ([[obj class] isSubclassOfClass:[MKitModel class]])
            {
                MKitModel *m=(MKitModel *)obj;
                blockResult=[self saveModel:m error:error];
                if (!blockResult)
                    return;

                [propsToSave setObject:[m parsePointer] forKey:key];
            }
            else if ([[obj class] isSubclassOfClass:[NSMutableArray class]])
            {
                MKitMutableModelArray *savedModels=[MKitMutableModelArray array];
                for(MKitModel *m in ((NSMutableArray *)obj))
                {
                    blockResult=[self saveModel:m error:error];
                    if (!blockResult)
                        return;
                    
                    [savedModels addObject:m];
                }
                
                NSMutableArray *toSave=nil;
                [propsToSave setObject:[savedModels parsePointerArray:&toSave] forKey:key];
            }
        }];
        
        if (!blockResult)
            return NO;
        
        // now update this model with the changes
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
    
    // We want Parse to return the full object data for all models this model points to/contains
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

-(NSDictionary *)userCredentials
{
    NSString *username=[[NSUserDefaults standardUserDefaults] stringForKey:[NSString stringWithFormat:@"%@-username",_appID]];
    
    if (!username)
        return nil;
    
    return [keychain credentialsForUsername:username];
}

-(void)storeUserCredentials:(MKitServiceModel<MKitServiceUser> *)user
{
    MKitParseUser *puser=(MKitParseUser *)user;
    [keychain storeUsername:puser.username password:puser.password sessionToken:puser.modelSessionToken data:[user serialize]];
    
    // We store the user name so we can pull the credentials from the keychain next time the app starts
    [[NSUserDefaults standardUserDefaults] setObject:puser.username forKey:[NSString stringWithFormat:@"%@-username",_appID]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - File

-(BOOL)saveFile:(MKitServiceFile *)file progressBlock:(MKitProgressBlock)progressBlock error:(NSError **)error
{
    if (file.state!=FileStateNew)
        return YES;
    
    AFHTTPRequestOperation *op=[self requestWithMethod:@"POST"
                                                  path:[NSString stringWithFormat:@"files/%@",file.name]
                                                params:nil
                                                  body:file.data
                                           contentType:file.contentType];

    if (progressBlock)
        [op setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
            progressBlock((float)totalBytesWritten/(float)totalBytesExpectedToWrite);
        }];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        NSDictionary *result=[op.responseString objectFromJSONString];
        file.url=result[@"url"];
        file.name=result[@"name"];
        file.state=FileStateSaved;
        file.data=nil;
        
        return YES;
    }
    
    if (error!=nil)
        *error=op.error;
    
    return NO;
}

-(BOOL)deleteFile:(MKitServiceFile *)file error:(NSError **)error
{
    // Parse requires a master key to delete files, so we always return NO.
    return NO;
}

@end
