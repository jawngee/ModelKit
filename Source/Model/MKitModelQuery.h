//
//  MKitModelQuery.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#include "MKitDefs.h"

@class MKitGeoPoint;

typedef void (^MKitQueryResultBlock)(NSArray *objects, NSInteger totalCount, NSError *error);

/** Key for result dictionary for number of items matched by query */
extern NSString *const MKitQueryItemCountKey;

/** Key for result dictionary for the array of objects returned by query */
extern NSString *const MKitQueryResultKey;

/**
 * Query conditions
 */
typedef enum
{
    KeyEquals,
    KeyNotEqual,
    KeyGreaterThanEqual,
    KeyGreaterThan,
    KeyLessThan,
    KeyLessThanEqual,
    KeyIn,
    KeyNotIn,
    KeyExists,
    KeyNotExist,
    KeyWithin,
    KeyBeginsWith,
    KeyEndsWith,
    KeyLike,
    KeyWithinDistance
} MKitQueryCondition;

/**
 * Order enum
 */
typedef enum
{
    orderASC,
    orderDESC
} MKitQueryOrder;

/**
 * Abstract class for querying models
 */
@interface MKitModelQuery : NSObject
{
    NSMutableArray *orders;         /**< List of orderings */
    NSMutableArray *conditions;     /**< List of query conditions */
    Class modelClass;               /**< The model class being queried */
}

/**
 * Returns a query object for a given model
 * @param modelClass The model class to query
 * @return The query object
 */
+(MKitModelQuery *)queryForModelClass:(Class)modelClass;


/**
 * Initializes a new instance
 * @param modelClass The model class to query
 * @return The new instance
 */
-(id)initWithModelClass:(Class)modelClass;


/**
 * Adds a condition to return object who has a value for this key
 * @param key The key
 */
-(void)keyExists:(NSString *)key;

/**
 * Adds a condition to return object who does not have a value for this key
 * @param key The key
 */
-(void)keyDoesNotExist:(NSString *)key;

/**
 * Adds a condition to the query
 * @param key The key
 * @param condition The conditional
 * @param val The value to test
 */
-(void)key:(NSString *)key condition:(MKitQueryCondition)condition value:(id)val;

/**
 * Adds a condition where key, being a MKitGeoPoint, is within a given distance of another point.
 * @param key The key
 * @param distance The distance in kilometers
 * @param point The point to measure the distance from
 */
-(void)key:(NSString *)key withinDistance:(double)distance ofPoint:(MKitGeoPoint *)point;

/**
 * Adds an order by clause to the query
 * @param key The key to order on
 * @param order The direction of the order
 */
-(void)orderBy:(NSString *)key direction:(MKitQueryOrder)order;

/**
 * Executes the query and returns a dictionary.  The dictionary has two keys: totalCount and results.
 * totalCount contains the total number of items the query matches, results is an array of objects that
 * match the query.  Note that the number of items returned might be limited by the backend service
 * and therefore, totalCount and number of objects in the results array can be different.
 * @param error The error if any
 * @return The results of the query.
 */
-(NSDictionary *)execute:(NSError **)error;

/**
 * Executes the query in the background
 * @param resultBlock The block to call when the query completes
 */
-(void)executeInBackground:(MKitQueryResultBlock)resultBlock;

/**
 * Executes the query and returns a dictionary.  The dictionary has two keys: totalCount and results.
 * totalCount contains the total number of items the query matches, results is an array of objects that
 * match the query.  Note that the number of items returned might be limited by the backend service
 * and therefore, totalCount and number of objects in the results array can be different.
 * @param limit Limits the number of items returned, use NSNotFound for maximum amount
 * @param skip Skips x number of results
 * @param error The error if any
 * @return The results of the query.
 */
-(NSDictionary *)executeWithLimit:(NSInteger)limit skip:(NSInteger)skip error:(NSError **)error;

/**
 * Executes the query in the background
 * @param limit Limits the number of items returned, use NSNotFound for maximum amount
 * @param skip Skips x number of results
 * @param resultBlock The block to call when the query completes
 */
-(void)executeInBackgroundWithLimit:(NSInteger)limit skip:(NSInteger)skip resultBlock:(MKitQueryResultBlock)resultBlock;


/**
 * Executes the query returning the count of objects
 * @param error The error if any
 * @return The number of objects in the potential results
 */
-(NSInteger)count:(NSError **)error;

/**
 * Executes the query returning the number of results in the background
 * @param resultBlock The block to call when the query completes
 */
-(void)countInBackground:(MKitIntResultBlock)resultBlock;


@end
