//
//  MKitServiceModel.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"
#import "MKitServiceManager.h"
#import "MKitServiceModelQuery.h"

/**
 * Abstract model class that is tied to a backend service
 * for peristence.
 *
 * You should create your own subclass for the particular
 * backend you are using.
 *
 * When subclassing, you only need to implement:
 * save:
 * delete:
 * fetch:
 * service:
 */
@interface MKitServiceModel : MKitModel

/**
 * Returns a query object for the model.
 * @return The query object
 */
+(MKitServiceModelQuery *)query;

/**
 * Returns a query object for the model using predicates on the graph.
 * @return The query object
 */
+(MKitModelQuery *)graphQuery;

/**
 * Returns the service manager this model uses for persistence
 * @return service The service this model uses
 */
+(MKitServiceManager *)service;

/**
 * Saves the model synchronously.
 * @param error The error to use
 * @return YES if the model was saved, NO if not.
 */
-(BOOL)save:(NSError **)error;

/**
 * Saves the model asynchronously in the background
 * @param resultBlock The block that is called after the save is performed.
 */
-(void)saveInBackground:(MKitBooleanResultBlock)resultBlock;

/**
 * Deletes the model synchronously.
 * @param error The error to use
 * @return YES if the model was deleted, NO if not.
 */
-(BOOL)delete:(NSError **)error;

/**
 * Deletes the model asynchronously in the background
 * @param resultBlock The block that is called after the delete is performed.
 */
-(void)deleteInBackground:(MKitBooleanResultBlock)resultBlock;

/**
 * Fetches the model's data from the service synchronously.
 * @param error The error to use
 * @return YES if the model was fetched, NO if not.
 */
-(BOOL)fetch:(NSError **)error;

/**
 * Fetches the model asynchronously in the background
 * @param resultBlock The block that is called after the fetch is performed.
 */
-(void)fetchInBackground:(MKitBooleanResultBlock)resultBlock;


@end
