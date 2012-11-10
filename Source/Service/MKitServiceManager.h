//
//  MKitServiceManager.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#include "MKitDefs.h"

#import "MKitModel.h"
#import "AFNetworking.h"
#import "MKitServiceKeyChain.h"
#import "MKitServiceFile.h"

@class MKitServiceModel;
@class MKitServiceModelQuery;
@protocol MKitServiceUser;

/**
 * Abstract class for building an interface between models and a backend service
 */
@interface MKitServiceManager : NSObject
{
    MKitServiceKeyChain *keychain;      /**< Keychain for storing credentials */
}

@property (readonly) MKitServiceKeyChain *keychain;

/**
 * Sets up a service for use
 * @param name The name of the service, eg "Parse"
 * @param keys Dictionary of keys needed by the service, eg Application ID, Rest Key, etc.
 * @return An instance of the service that has been setup
 */
+(MKitServiceManager *)setupService:(NSString *)name withKeys:(NSDictionary *)keys;

/**
 * Returns a service for a given name, eg "Parse"
 * @param name The name of the service, eg "Parse"
 * @return The manager instance, nil if not found
 */
+(MKitServiceManager *)managerForService:(NSString *)name;

/**
 * Initializes the service with the given keys
 * @param keys The keys to setup the service with, eg application id, rest key, auth token, etc.
 * @return The new instance
 */
-(id)initWithKeys:(NSDictionary *)keys;

/**
 * Returns a service specific query for a given class
 * @param modelClass The class of the model to return the query for
 * @return The query object
 */
-(MKitServiceModelQuery *)queryForModelClass:(Class)modelClass;

/**
 * Saves the model with the service synchronously.  When subclassing MKitServiceManager, you must implement this method.
 * @param model The model to save
 * @param error The error to return, nil if none
 * @return YES if successful, NO if not.
 */
-(BOOL)saveModel:(MKitModel *)model error:(NSError **)error;

/**
 * Saves the model asynchronously in the background.  No need to implement in subclasses.
 * @param model The model to save
 * @param resultBlock The block that gets called after the save completes
 */
-(void)saveModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock;


/**
 * Deletes the model from the service synchronously.  When subclassing MKitServiceManager, you must implement this method.
 * @param model The model to delete
 * @param error The error to return, nil if none
 * @return YES if successful, NO if not.
 */
-(BOOL)deleteModel:(MKitModel *)model error:(NSError **)error;

/**
 * Deletes the model asynchronously in the background.  No need to implement in subclasses.
 * @param model The model to delete
 * @param resultBlock The block that gets called after the delete completes
 */
-(void)deleteModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock;


/**
 * Fetches the model from the service synchronously.  When subclassing MKitServiceManager, you must implement this method.
 * @param model The model to fetch
 * @param error The error to return, nil if none
 * @return YES if successful, NO if not.
 */
-(BOOL)fetchModel:(MKitModel *)model error:(NSError **)error;

/**
 * Fetches the model asynchronously in the background.  No need to implement in subclasses.
 * @param model The model to fetch
 * @param resultBlock The block that gets called after the fetch completes
 */
-(void)fetchModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock;

/**
 * Creates a HTTP request for class methods (create/delete)
 * @param method The HTTP method to use
 * @param class The model class to generate the request for
 * @param params The query parameters for the request
 * @param body The body data for the request
 * @return The operation
 */
-(AFHTTPRequestOperation *)classRequestWithMethod:(NSString *)method class:(Class)class params:(NSDictionary *)params body:(NSData *)body;


/**
 * Creates a HTTP request for model methods (update/query)
 * @param method The HTTP method to use
 * @param model The model to generate the request for
 * @param params The query parameters for the request
 * @param body The body data for the request
 * @return The operation
 */
-(AFHTTPRequestOperation *)modelRequestWithMethod:(NSString *)method model:(MKitModel *)model params:(NSDictionary *)params body:(NSData *)body;

/**
 * Creates a generic HTTP request
 * @param method The HTTP method to use
 * @param path The path
 * @param params The query parameters for the request
 * @param body The body data for the request
 * @param contentType The content type, if nil will use default for particular backend
 * @return The operation
 */
-(AFHTTPRequestOperation *)requestWithMethod:(NSString *)method path:(NSString *)path params:(NSDictionary *)params body:(NSData *)body contentType:(NSString *)contentType;


/**
 * Returns user's credentials
 * @return Dictionary of credentials, nil if none
 */
-(NSDictionary *)userCredentials;

/**
 * Stores a user's credentials
 * @param user The user to store
 */
-(void)storeUserCredentials:(MKitServiceModel<MKitServiceUser> *)user;

/**
 * Saves the file with the service synchronously.  When subclassing MKitServiceManager, you must implement this method.
 * @param file The file to save
 * @param progressBlock The progress block to call with updates
 * @param error The error to return, nil if none
 * @return YES if successful, NO if not.
 */
-(BOOL)saveFile:(MKitServiceFile *)file progressBlock:(MKitProgressBlock)progressBlock error:(NSError **)error;

/**
 * Saves the file asynchronously in the background.  No need to implement in subclasses.
 * @param file The file to save
 * @param progressBlock The progress block with updates
 * @param resultBlock The block that gets called after the save completes
 */
-(void)saveFileInBackground:(MKitServiceFile *)file progressBlock:(MKitProgressBlock)progressBlock resultBlock:(MKitBooleanResultBlock)resultBlock;


/**
 * Deletes the file from the service synchronously.  When subclassing MKitServiceManager, you must implement this method.
 * @param file The file to delete
 * @param error The error to return, nil if none
 * @return YES if successful, NO if not.
 */
-(BOOL)deleteFile:(MKitServiceFile *)file error:(NSError **)error;

/**
 * Deletes the file asynchronously in the background.  No need to implement in subclasses.
 * @param file The file to delete
 * @param resultBlock The block that gets called after the delete completes
 */
-(void)deleteFileInBackground:(MKitServiceFile *)file withBlock:(MKitBooleanResultBlock)resultBlock;


@end
