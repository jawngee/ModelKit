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
 * Abstract class for building service specific object queries.
 */
@interface MKitModelQuery : NSObject
{
    NSMutableArray *conditions;
    NSMutableArray *includes;
    Class modelClass;
    MKitReflectedClass *refClass;
}

+(MKitModelQuery *)queryForModelClass:(Class)modelClass;

-(id)initWithModelClass:(Class)modelClass;

-(MKitModelQuery *)includeKey:(NSString *)key;

-(MKitModelQuery *)keyExists:(NSString *)key;
-(MKitModelQuery *)keyDoesNotExit:(NSString *)key;

-(MKitModelQuery *)key:(NSString *)key condition:(MKitQueryCondition)condition value:(id)val;

-(NSArray *)execute:(NSError **)error;
-(void)executeInBackground:(MKitArrayResultBlock)resultBlock;

@end
