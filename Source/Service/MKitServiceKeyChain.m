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

-(BOOL)storeUsername:(NSString *)username password:(NSString *)password sessionToken:(NSString *)sessionToken data:(id)data
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
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:mdata] autorelease];
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
    NSDictionary *query = [[NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, (id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                           [username dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                           (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                           (id)kCFBooleanTrue, (id)kSecReturnData,
                           nil] retain];
    
    CFDictionaryRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&resultRef);
    if (status == errSecSuccess && resultRef != NULL)
    {
        NSDictionary *result=(NSDictionary *)resultRef;
        
        NSString *username = [[[NSString alloc] initWithData:[result valueForKey:(id)kSecAttrAccount] encoding:NSUTF8StringEncoding] autorelease];
        
        NSString *sessionToken = nil;
        NSData *sessionTokenData=[result valueForKey:(id)kSecAttrGeneric];
        sessionToken=[[[NSString alloc] initWithData:sessionTokenData encoding:NSUTF8StringEncoding] autorelease];
        
        NSString *password = nil;
        NSData *passwordData = [result valueForKey:(id)kSecValueData];
        if (passwordData)
            password = [[[NSString alloc] initWithData:passwordData encoding:NSUTF8StringEncoding] autorelease];
        
        NSData *data = [result valueForKey:(id)kSecAttrComment];
        id misc = nil;
        
        if (data) {
            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
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
    NSData *sd=[service dataUsingEncoding:NSUTF8StringEncoding];
    NSData *un=[username dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *query = [[NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassGenericPassword, (id)kSecClass,
                           sd, (id)kSecAttrService,
                           un, (id)kSecAttrAccount,
                           nil] retain];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}


-(BOOL)storeInstallation:(NSString *)installationId installationData:(id)data
{
    if ([self deleteInstallationForId:installationId])
    {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                           (id)kSecClassKey, (id)kSecClass,
                                           [installationId dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService, nil];
        
         if (data)
        {
            NSMutableData *mdata = [NSMutableData data];
            NSKeyedArchiver *archiver = [[[NSKeyedArchiver alloc] initForWritingWithMutableData:mdata] autorelease];
            [archiver encodeObject:data forKey:MKitKeychainData];
            [archiver finishEncoding];
            [dictionary setValue:mdata forKey:(id)kSecAttrComment];
        }
        
        OSStatus status = SecItemAdd((CFDictionaryRef)dictionary, NULL);
        return (status == errSecSuccess);
    }
    
    return NO;
}

-(id)installationDataForId:(NSString *)installationId
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassKey, (id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                           [installationId dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                           (id)kCFBooleanTrue, (id)kSecReturnAttributes,
                           (id)kCFBooleanTrue, (id)kSecReturnData,
                           nil];
    
    CFDictionaryRef resultRef = NULL;
    OSStatus status = SecItemCopyMatching((CFDictionaryRef)query, (CFTypeRef *)&resultRef);
    if (status == errSecSuccess && resultRef != NULL)
    {
        NSDictionary *result=(NSDictionary *)resultRef;
        
        NSData *data = [result valueForKey:(id)kSecAttrComment];
        id misc = nil;
        
        if (data) {
            NSKeyedUnarchiver *unarchiver = [[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
            misc = [unarchiver decodeObjectForKey:MKitKeychainData];
            [unarchiver finishDecoding];
        }
        
    
        return misc;
    }
    
    return nil;
}

-(BOOL)deleteInstallationForId:(NSString *)installationId
{
    NSDictionary *query = [NSDictionary dictionaryWithObjectsAndKeys:
                           (id)kSecClassKey, (id)kSecClass,
                           [service dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrService,
                           [installationId dataUsingEncoding:NSUTF8StringEncoding], (id)kSecAttrAccount,
                           nil];
    OSStatus status = SecItemDelete((CFDictionaryRef)query);
    return (status == errSecSuccess || status == errSecItemNotFound);
}

@end
