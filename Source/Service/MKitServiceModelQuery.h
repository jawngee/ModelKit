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
    NSMutableArray *orders;
    NSMutableArray *conditions;
    NSMutableArray *includes;
    Class modelClass;
    MKitReflectedClass *refClass;
    MKitServiceManager *manager;
}

+(MKitServiceModelQuery *)queryForModelClass:(Class)modelClass manager:(MKitServiceManager *)manager;

-(id)initWithModelClass:(Class)modelClass manager:(MKitServiceManager *)manager;

-(MKitServiceModelQuery *)includeKey:(NSString *)key;

-(MKitServiceModelQuery *)keyExists:(NSString *)key;
-(MKitServiceModelQuery *)keyDoesNotExit:(NSString *)key;

-(MKitServiceModelQuery *)key:(NSString *)key condition:(MKitQueryCondition)condition value:(id)val;

-(MKitServiceModelQuery *)orderBy:(NSString *)key direction:(MKitQueryOrder)order;

-(NSArray *)execute:(NSError **)error;
-(void)executeInBackground:(MKitArrayResultBlock)resultBlock;

@end
