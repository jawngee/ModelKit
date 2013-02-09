//
//  MKitParseUser.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseModel.h"
#import "MKitServiceUser.h"

/**
 * Represents a Parse user
 */
@interface MKitParseUser : MKitParseModel<MKitServiceUser>

@property (nonatomic, retain) NSString *sessionToken;       /**< Session token for authenticating other requests. */
@property (nonatomic, retain) NSString *username;           /**< User name */
@property (nonatomic, retain) NSString *password;           /**< Password */
@property (nonatomic, retain) NSString *email;              /**< Email */
@property (nonatomic, retain) NSDictionary *authData;       /**< Authentication data */
@property (nonatomic, assign) BOOL isNew;                   /**< Is a new user who just signed up. */

+(MKitParseUser *)currentUser;

+(BOOL)signUpWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password error:(NSError **)error;
+(void)signUpInBackgroundWithUserName:(NSString *)userName email:(NSString *)email password:(NSString *)password resultBlock:(MKitObjectResultBlock)resultBlock;

+(BOOL)logInWithUserName:(NSString *)userName password:(NSString *)password error:(NSError **)error;
+(void)logInInBackgroundWithUserName:(NSString *)userName password:(NSString *)password resultBlock:(MKitObjectResultBlock)resultBlock;

+(BOOL)logInWithAuthData:(NSDictionary *)authData error:(NSError **)error;
+(void)logInWithAuthDataInBackground:(NSDictionary *)authData resultBlock:(MKitObjectResultBlock)resultBlock;

+(BOOL)requestPasswordResetForEmail:(NSString *)email error:(NSError **)error;
+(void)requestPasswordResetInBackgroundForEmail:(NSString *)email resultBlock:(MKitBooleanResultBlock)resultBlock;

-(void)logOut;

@end
