//
//  MKitParseUser.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseUser.h"
#import "MKitParseServiceManager.h"
#import "AFNetworking.h"
#import "JSONKit.h"
#import "NSDate+ModelKit.h"

@implementation MKitParseUser

@synthesize sessionToken=_sessionToken, username=_username, password=_password, email=_email, isNew=_isNew;

static MKitParseUser *_currentUser=nil;


+(void)load
{
    [self register];
}

+(NSString *)modelName
{
    return @"_User";
}

+(NSArray *)ignoredProperties
{
    return @[@"sessionToken",@"isNew"];
}

-(void)setup
{
    [super setup];
    self.authData=[NSMutableDictionary dictionary];
}

+(MKitParseUser *)currentUser
{
    if (_currentUser)
        return _currentUser;
    
    NSDictionary *credentials=[[self service] userCredentials];
    
    if (!credentials)
        return nil;
    
    _currentUser=[[self instanceWithSerializedData:[credentials objectForKey:MKitKeychainData]] retain];
    _currentUser.sessionToken=[credentials objectForKey:MKitKeychainSessionToken];
 
    return _currentUser;
}

+(BOOL)signUpWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password error:(NSError **)error
{
    MKitParseUser *m=[self instance];
    m.username=userName;
    m.email=email;
    m.password=password;
    m.isNew=YES;
    
    BOOL result=[m save:error];
    
    if (!result)
        [m removeFromGraph];
    else
    {
        _currentUser=m;
        
        [[[self class] service] storeUserCredentials:_currentUser];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitUserSignedUpNotification object:_currentUser];
    }
    
    return result;
}

+(void)signUpInBackgroundWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password resultBlock:(MKitObjectResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        
        [currentGraph push];
        
        [self signUpWithUserName:userName email:email password:password error:&error];
        
        if (resultBlock)
            resultBlock(_currentUser,error);
        
        [currentGraph pop];
    });
}

+(BOOL)logInWithUserName:(NSString *)userName password:(NSString *)password error:(NSError **)error
{
    MKitParseServiceManager *manager=(MKitParseServiceManager *)[[self class] service];
    
    AFHTTPRequestOperation *op=[manager requestWithMethod:@"GET"
                                                     path:@"login"
                                                   params:@{@"username":userName,@"password":password}
                                                     body:nil
                                              contentType:nil];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        NSDictionary *data=[op.responseString objectFromJSONString];
        NSString *objId=data[@"objectId"];
        
        MKitParseUser *user=[self instanceWithObjectId:objId];
        user.isNew=NO;
        if (user.modelState==ModelStateNeedsData)
        {
            BOOL result=[user fetch:error];
            if (!result)
            {
                [user removeFromGraph];
                return NO;
            }
        }
        
        user.sessionToken=data[@"sessionToken"];
        [manager storeUserCredentials:user];
        
        _currentUser=user;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitUserLoggedInNotification object:_currentUser];
        
        return YES;
    }
    
    if (error!=nil)
        *error=op.error;
    
    return NO;
}

+(void)logInInBackgroundWithUserName:(NSString *)userName password:(NSString *)password resultBlock:(MKitObjectResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [currentGraph push];
        
        NSError *error=nil;
        [self logInWithUserName:userName password:password error:&error];
        
        if (resultBlock)
            resultBlock(_currentUser,error);
        
        [currentGraph pop];
    });
}

+(BOOL)logInWithAuthData:(NSDictionary *)authData error:(NSError **)error
{
    MKitParseServiceManager *manager=(MKitParseServiceManager *)[[self class] service];
    
    AFHTTPRequestOperation *op=[manager requestWithMethod:@"POST"
                                                     path:@"users"
                                                   params:nil
                                                     body:[[@{@"authData":authData} JSONString] dataUsingEncoding:NSUTF8StringEncoding]
                                              contentType:@"application/json"];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        NSDictionary *data=[op.responseString objectFromJSONString];
        NSString *objId=data[@"objectId"];
        
        MKitParseUser *user=[self instanceWithObjectId:objId];
        user.username=data[@"username"];
        user.sessionToken=data[@"sessionToken"];
        user.createdAt=[NSDate dateFromISO8601:data[@"createdAt"]];
        
        user.isNew=(op.response.statusCode==201);
        
        user.sessionToken=data[@"sessionToken"];
        [manager storeUserCredentials:user];
        
        _currentUser=user;
        
        return YES;
    }
    
    if (error!=nil)
        *error=op.error;
    
    return NO;

}

+(void)logInWithAuthDataInBackground:(NSDictionary *)authData resultBlock:(MKitObjectResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [currentGraph push];
        
        NSError *error=nil;
        [self logInWithAuthData:authData error:&error];
        
        if (resultBlock)
            resultBlock(_currentUser,error);
        
        [currentGraph pop];
    });
}


+(BOOL)requestPasswordResetForEmail:(NSString *)email error:(NSError **)error
{
    MKitParseServiceManager *manager=(MKitParseServiceManager *)[[self class] service];
    
    AFHTTPRequestOperation *op=[manager requestWithMethod:@"POST"
                                                     path:@"requestPasswordReset"
                                                   params:nil
                                                     body:[[NSString stringWithFormat:@"{\"email\":\"%@\"}",email] dataUsingEncoding:NSUTF8StringEncoding]
                                              contentType:nil];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
        return YES;
    
    if (error!=nil)
        *error=op.error;
    
    return NO;
}

+(void)requestPasswordResetInBackgroundForEmail:(NSString *)email resultBlock:(MKitBooleanResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [currentGraph push];
        
        NSError *error=nil;
        BOOL result=[self requestPasswordResetForEmail:email error:&error];
        
        if (resultBlock)
            resultBlock(result,error);
        
        [currentGraph pop];
    });
}

-(void)logOut
{
    _currentUser=nil;
    MKitParseServiceManager *manager=(MKitParseServiceManager *)[[self class] service];
    [manager.keychain deleteCredentialsForUsername:self.username];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MKitUserLoggedOutNotification object:nil];
}

-(BOOL)save:(NSError **)error
{
    BOOL result=[super save:error];
    
    if (result)
        [[[self class] service] storeUserCredentials:self];
    
    return result;
}


@end
