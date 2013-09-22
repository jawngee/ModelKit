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
    KeyWithinDistance,
    KeyContains,
    KeyContainsAll
} MKitQueryCondition;

/**
 * Order enum
 */
typedef enum
{
    orderASC    = YES,
    orderDESC   = NO
} MKitQueryOrder;

/**
 * Abstract class for querying models
 */
@interface MKitModelQuery : NSObject
{
    NSMutableArray *orders;         /**< List of orderings */
    NSMutableArray *conditions;     /**< List of query conditions */
    Class modelClass;               /**< The model class being queried */
    NSMutableArray *subqueries;     /**< Subqueries */
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
 * @return The query
 */
-(MKitModelQuery *)keyExists:(NSString *)key;

/**
 * Adds a condition to return object who does not have a value for this key
 * @param key The key
 * @return The query
 */
-(MKitModelQuery *)keyDoesNotExist:(NSString *)key;

/**
 * Adds a condition to the query
 * @param key The key
 * @param condition The conditional
 * @param val The value to test
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key condition:(MKitQueryCondition)condition value:(id)val;

/**
 * Adds a condition where key, being a MKitGeoPoint, is within a given distance of another point.
 * @param key The key
 * @param distance The distance in kilometers
 * @param point The point to measure the distance from
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key withinDistance:(double)distance ofPoint:(MKitGeoPoint *)point;

/**
 * Adds an order by clause to the query
 * @param key The key to order on
 * @param order The direction of the order
 * @return The query
 */
-(MKitModelQuery *)orderBy:(NSString *)key direction:(MKitQueryOrder)order;

/**
 * Adds a condition that the key is equal to value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key equals:(id)val;

/**
 * Adds a condition that the key is not equal to value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key notEqualTo:(id)val;

/**
 * Adds a condition that the key is greater than or equal to value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key greaterThanEqual:(id)val;

/**
 * Adds a condition that the key is greater than value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key greater:(id)val;

/**
 * Adds a condition that the key is less than equal to value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key lessThanEqual:(id)val;

/**
 * Adds a condition that the key is less than value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key lessThan:(id)val;

/**
 * Adds a condition that the key is in an array of vals
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key isIn:(id)val;

/**
 * Adds a condition that the key is not in array of vals
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key isNotIn:(id)val;

/**
 * Adds a condition that the key begins with value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key beginsWith:(id)val;

/**
 * Adds a condition that the key ends with value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key endsWith:(id)val;

/**
 * Adds a condition that the key is like value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key like:(id)val;

/**
 * Adds a condition that the key contains value
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key contains:(id)val;

/**
 * Adds a condition that the key is contains all values
 * @param key The key to compare
 * @param val The value
 * @return The query
 */
-(MKitModelQuery *)key:(NSString *)key containsAll:(id)val;

/**
 *	Returns the first model found
 *
 *	@return The first model found
 */
-(id)first;

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

/**
 * Adds a subquery to the query.
 * @param query The subquery to add
 */
-(void)addSubquery:(MKitModelQuery *)query;


@end
