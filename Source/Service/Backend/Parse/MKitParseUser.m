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

static MKitParseUser *_currentUser=nil;

+(void)load
{
    [self register];
}

+(NSString *)modelName
{
    return @"_User";
}

+(MKitParseUser *)currentUser
{
    if (_currentUser)
        return _currentUser;
    
    NSDictionary *credentials=[[self service] userCredentials];
    
    if (!credentials)
        return nil;
    
    _currentUser=[[self instanceWithSerializedData:[credentials objectForKey:MKitKeychainData]] retain];
    _currentUser.modelSessionToken=[credentials objectForKey:MKitKeychainSessionToken];
 
    return _currentUser;
}

+(BOOL)signUpWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password error:(NSError **)error
{
    MKitParseUser *m=[MKitParseUser instance];
    m.username=userName;
    m.email=email;
    m.password=password;
    
    BOOL result=[m save:error];
    
    if (!result)
        [m removeFromContext];
    else
    {
        _currentUser=m;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitUserLoggedInNotification object:_currentUser];
    }
    
    return result;
}

+(void)signUpInBackgroundWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password resultBlock:(MKitObjectResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        [self signUpWithUserName:userName email:email password:password error:&error];
        if (resultBlock)
            resultBlock(_currentUser,error);
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
        
        MKitParseUser *user=[MKitParseUser instanceWithObjectId:objId];
        if (user.modelState==ModelStateNeedsData)
        {
            BOOL result=[user fetch:error];
            if (!result)
            {
                [user removeFromContext];
                return NO;
            }
        }
        
        user.modelSessionToken=data[@"sessionToken"];
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        [self logInWithUserName:userName password:password error:&error];
        if (resultBlock)
            resultBlock(_currentUser,error);
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
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self requestPasswordResetForEmail:email error:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}

-(void)logOut
{
    _currentUser=nil;
    MKitParseServiceManager *manager=(MKitParseServiceManager *)[[self class] service];
    [manager.keychain deleteCredentialsForUsername:self.username];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MKitUserLoggedOutNotification object:nil];
}

@end
