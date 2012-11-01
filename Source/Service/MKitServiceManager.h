//
//  MKitServiceManager.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitModel.h"
#import "AFNetworking.h"

@class MKitServiceModelQuery;

/**
 * Abstract class for building an interface between models and a backend service
 */
@interface MKitServiceManager : NSObject

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
 * Saves the model with the service asynchronously.  When subclassing MKitServiceManager, you must implement this method.
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
 * Deletes the model from the service asynchronously.  When subclassing MKitServiceManager, you must implement this method.
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
 * Fetches the model from the service asynchronously.  When subclassing MKitServiceManager, you must implement this method.
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

-(AFHTTPRequestOperation *)classRequestWithMethod:(NSString *)method class:(Class)class params:(NSDictionary *)params body:(NSData *)body;
-(AFHTTPRequestOperation *)modelRequestWithMethod:(NSString *)method model:(MKitModel *)model params:(NSDictionary *)params body:(NSData *)body;


@end
