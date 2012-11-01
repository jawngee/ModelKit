//
//  MKitModelQuery.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModelQuery.h"

@implementation MKitModelQuery

+(MKitModelQuery *)queryForModelClass:(Class)_modelClass
{
    return [[[self alloc] initWithModelClass:_modelClass] autorelease];
}

-(id)initWithModelClass:(Class)_modelClass
{
    if ((self=[super init]))
    {
        includes=[[NSMutableArray array] retain];
        conditions=[[NSMutableArray array] retain];
        modelClass=_modelClass;
        refClass=[[MKitReflectionManager reflectionForClass:_modelClass ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]] retain];
    }
    
    return self;
}

-(void)dealloc
{
    [includes release];
    [conditions release];
    [refClass release];
    [super dealloc];
}

-(MKitModelQuery *)includeKey:(NSString *)key
{
    [includes addObject:key];
    return self;
}

-(MKitModelQuery *)keyExists:(NSString *)key
{
    [conditions addObject:@{@"condition":@(KeyExists),@"key":key}];
    return self;
}

-(MKitModelQuery *)keyDoesNotExit:(NSString *)key
{
    [conditions addObject:@{@"condition":@(KeyNotExist),@"key":key}];
    return self;
}

-(MKitModelQuery *)key:(NSString *)key condition:(MKitQueryCondition)condition value:(id)val
{
    if (val==nil)
        val=[NSNull null];
    
    [conditions addObject:@{@"condition":@(condition),@"key":key,@"value":val}];
    return self;
}

-(NSArray *)execute:(NSError **)error
{
    return NO;
}

-(void)executeInBackground:(MKitArrayResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        NSArray *result=[self execute:&error];
        if (resultBlock)
            resultBlock(result, error);
    });
}

@end
