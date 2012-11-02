//
//  MKitModelQuery.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitModel.h"
#import "MKitModelQuery.h"
#import "MKitReflectedClass.h"
#import "MKitReflectionManager.h"
#import "MKitMutableOrderedDictionary.h"
#import "MKitServiceManager.h"

/**
 * Abstract class for building service specific object queries.
 */
@interface MKitServiceModelQuery : MKitModelQuery
{
    NSMutableArray *includes;       /**< List of fields to include */
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

@end
