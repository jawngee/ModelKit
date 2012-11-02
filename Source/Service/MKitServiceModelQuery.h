//
//  MKitModelQuery.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitModel.h"
#import "MKitReflectedClass.h"
#import "MKitReflectionManager.h"
#import "MKitMutableOrderedDictionary.h"
#import "MKitServiceManager.h"

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
 * Abstract class for building service specific object queries.
 */
@interface MKitServiceModelQuery : NSObject
{
    NSMutableArray *orders;         /**< List of orderings */
    NSMutableArray *conditions;     /**< List of query conditions */
    NSMutableArray *includes;       /**< List of fields to include */
    Class modelClass;               /**< The model class being queried */
    MKitServiceManager *manager;    /**< The service the model uses */
}

/**
 * Returns a query object for a given model
 * @param modelClass The model class to query
 * @param manager The service manager
 * @return The query object
 */
+(MKitServiceModelQuery *)queryForModelClass:(Class)modelClass manager:(MKitServiceManager *)manager;


/**
 * Initializes a new instance
 * @param modelClass The model class to query
 * @param manager The service manager
 * @return The new instance
 */
-(id)initWithModelClass:(Class)modelClass manager:(MKitServiceManager *)manager;

/**
 * Specifies the keys to include the full object in the results.  This is service
 * dependent.  Services like Parse will only contain "pointers" for properties
 * that are other models.  Including these keys will return the full objects
 * @param key The key
 */
-(void)includeKey:(NSString *)key;

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
 * Adds an order by clause to the query
 * @param key The key to order on
 * @param order The direction of the order
 */
-(void)orderBy:(NSString *)key direction:(MKitQueryOrder)order;

/**
 * Executes the query
 * @param error The error if any
 * @return The results of the query
 */
-(NSArray *)execute:(NSError **)error;

/**
 * Executes the query in the background
 * @param resultBlock The block to call when the query completes
 */
-(void)executeInBackground:(MKitArrayResultBlock)resultBlock;

@end
