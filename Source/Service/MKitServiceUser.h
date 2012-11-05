//
//  MKitServiceUser.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitDefs.h"
#import "MKitServiceModel.h"

/** User Has Logged In */
extern NSString *const MKitUserLoggedInNotification;

/** User Has Logged Out */
extern NSString *const MKitUserLoggedOutNotification;

/**
 * Protocol for implementing service specific user class
 */
@protocol MKitServiceUser

@property (nonatomic, retain) NSString *modelSessionToken;  /**< Session token for authenticating other requests.  Uses model prefix so it isn't serialized */
@property (nonatomic, retain) NSString *username;           /**< User name */
@property (nonatomic, retain) NSString *password;           /**< Password */
@property (nonatomic, retain) NSString *email;              /**< Email */

/**
 * The current user.
 * @return The current user if logged in, nil if not logged in.
 */
+(MKitServiceModel<MKitServiceUser> *)currentUser;

/**
 * Signs a user up.
 * @param userName The user's login name
 * @param email The user's email address
 * @param password The user's password
 * @param error The error
 * @return YES if successful, NO if not.
 */
+(BOOL)signUpWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password error:(NSError **)error;

/**
 * Signs a user up in the background.
 * @param userName The user's login name
 * @param email The user's email address
 * @param password The user's password
 * @param resultBlock The result block
 */
+(void)signUpInBackgroundWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password resultBlock:(MKitObjectResultBlock)resultBlock;

/**
 * Logs a user in.
 * @param userName The user's login name
 * @param password The user's password
 * @param error The error
 * @return YES if successful, NO if not.
 */
+(BOOL)logInWithUserName:(NSString *)userName password:(NSString *)password error:(NSError **)error;

/**
 * Logs a user in in the background.
 * @param userName The user's login name
 * @param password The user's password
 * @param resultBlock The result block to call when the operation completes
 */
+(void)logInInBackgroundWithUserName:(NSString *)userName password:(NSString *)password resultBlock:(MKitObjectResultBlock)resultBlock;

/**
 * Request a password reset email.
 * @param email The user's email
 * @param error The error
 * @return YES if successful, NO if not.
 */
+(BOOL)requestPasswordResetForEmail:(NSString *)email error:(NSError **)error;

/**
 * Request a password reset email in the background.
 * @param email The user's email
 * @param resultBlock The block to call when the operation is complete
 */
+(void)requestPasswordResetInBackgroundForEmail:(NSString *)email resultBlock:(MKitBooleanResultBlock)resultBlock;

/**
 * Logs a user out
 */
-(void)logOut;

@end
