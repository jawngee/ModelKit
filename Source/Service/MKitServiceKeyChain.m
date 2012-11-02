//
//  MKitKeyChain.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceKeyChain.h"

NSString *const MKitKeychainPassword=@"password";
NSString *const MKitKeychainUsername=@"username";
NSString *const MKitKeychainSessionToken=@"sessionToken";
NSString *const MKitKeychainData=@"data";

@implementation MKitServiceKeyChain

-(id)initWithService:(NSString *)_service
{
    if ((self=[super init]))
    {
        service=[_service copy];
    }
    
    return self;
}

-(void)dealloc
{
    [service release];
    [super dealloc];
}

-(BOOL)storeUsername:(NSString *)username password:(NSString *)password sessionToken:(NSString *)sessionToken data:(NSDictionary *)data
{
    if ([self deleteCredentialsForUsername:username])
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           (id)kSecClassGenericPassword, (id)kSecClass,
                                           [username dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService, nil];
        
        if (sessionToken)
            [dictionary setObject:[sessionToken dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecAttrGeneric];
        
        [dictionary setValue:[password dataUsingEncoding:NSUTF8StringEncoding] forKey:(id)kSecValueData];
        
        if (data)
        {
            NSMutableData *mdata = [NSMutableData data];
            NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:mdata];
            [archiver encodeObject:data forKey:MKitKeychainData];
            [archiver finishEncoding];
            [dictionary setValue:mdata forKey:(id)kSecAttrComment];
        }
        
        OSStatus status = SecItemAdd((CFDictionaryRef)dictionary, NULL);
        return (status == errSecSuccess);
    }
    
    return NO;
}

-(NSDictionary *)credentialsForUsername:(NSString *)username
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, (id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                           [username dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                           (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                           (id)kCFBooleanTrue, (id)kSecReturnData,
                           nil];
    
    CFDictionaryRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&resultRef);
    if (status == errSecSuccess && resultRef != NULL)
    {
        NSDictionary *result=(NSDictionary *)resultRef;
        
        NSString *username = [[NSString alloc] initWithData:[result valueForKey:(id)kSecAttrAccount] encoding:NSUTF8StringEncoding];
        
        NSString *sessionToken = nil;
        NSData *sessionTokenData=[result valueForKey:(id)kSecAttrGeneric];
        sessionToken=[[NSString alloc] initWithData:sessionTokenData encoding:NSUTF8StringEncoding];
        
        NSString *password = nil;
        NSData *passwordData = [result valueForKey:(id)kSecValueData];
        if (passwordData)
            password = [[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding];
        
        NSData *data = [result valueForKey:(id)kSecAttrComment];
        NSDictionary *misc = nil;
        
        if (data) {
            NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
            misc = [unarchiver decodeObjectForKey:MKitKeychainData];
            [unarchiver finishDecoding];
        }
        
        NSMutableDictionary *credentials = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            username, MKitKeychainUsername,
                                            nil];
        
        if (sessionToken)
            [credentials setValue:sessionToken forKey:MKitKeychainSessionToken];

        if (password)
            [credentials setValue:password forKey:MKitKeychainPassword];
        
        if (misc)
            [credentials setValue:misc forKey:MKitKeychainData];
        
        return credentials;
    }
    
    return nil;
}

-(BOOL)deleteCredentialsForUsername:(NSString *)username
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, (id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                           [username dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                           nil];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

@end
