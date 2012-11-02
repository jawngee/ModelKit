//
//  MKitKeyChain.h
//  ModelKit
//
//  Based on code from Alex Chugunov ( https://github.com/alexchugunov/ACSimpleKeychain )
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Security/Security.h>

/** Password entry */
extern NSString *const MKitKeychainPassword;

/** Username entry */
extern NSString *const MKitKeychainUsername;

/** Session token entry */
extern NSString *const MKitKeychainSessionToken;

/** Data entry */
extern NSString *const MKitKeychainData;

/**
 * Simple means to securely* store user credentials in the keychain.
 */
@interface MKitServiceKeyChain : NSObject
{
    NSString *service;  /**< The service name to store the credentials under, typically the app id. */
}

/**
 * Creates a new instance
 * @param service The name of the service to store credentials under.
 * @return A new instance
 */
-(id)initWithService:(NSString *)service;

/**
 * Stores the user's credentials
 * @param username The username
 * @param password The password
 * @param sessionToken The session token
 * @param data Other related data
 * @return YES if successful, NO otherwise
 */
-(BOOL)storeUsername:(NSString *)username password:(NSString *)password sessionToken:(NSString *)sessionToken data:(NSDictionary *)data;

/**
 * Returns the credentials for a given username
 * @param username The username
 * @return Dictionary of credentials if successful, nil if not.
 */
-(NSDictionary *)credentialsForUsername:(NSString *)username;

/**
 * Removes the credentials for a given username
 * @param username The username
 * @return YES if successful, NO if not.
 */
-(BOOL)deleteCredentialsForUsername:(NSString *)username;

@end
