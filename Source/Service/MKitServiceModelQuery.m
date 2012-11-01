//
//  MKitModelQuery.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceModelQuery.h"

@implementation MKitServiceModelQuery

+(MKitServiceModelQuery *)queryForModelClass:(Class)_modelClass manager:(MKitServiceManager *)_manager
{
    return [[[self alloc] initWithModelClass:_modelClass manager:_manager] autorelease];
}

-(id)initWithModelClass:(Class)_modelClass manager:(MKitServiceManager *)_manager
{
    if ((self=[super init]))
    {
        manager=_manager;
        orders=[[NSMutableArray array] retain];
        includes=[[NSMutableArray array] retain];
        conditions=[[NSMutableArray array] retain];
        modelClass=_modelClass;
        refClass=[[MKitReflectionManager reflectionForClass:_modelClass ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]] retain];
    }
    
    return self;
}

-(void)dealloc
{
    [orders release];
    [conditions release];
    [refClass release];
    [super dealloc];
}

-(MKitServiceModelQuery *)includeKey:(NSString *)key
{
    [includes addObject:key];
    return self;
}

-(MKitServiceModelQuery *)keyExists:(NSString *)key
{
    [conditions addObject:@{@"condition":@(KeyExists),@"key":key}];
    return self;
}

-(MKitServiceModelQuery *)keyDoesNotExit:(NSString *)key
{
    [conditions addObject:@{@"condition":@(KeyNotExist),@"key":key}];
    return self;
}

-(MKitServiceModelQuery *)key:(NSString *)key condition:(MKitQueryCondition)condition value:(id)val
{
    if (val==nil)
        val=[NSNull null];
    
    [conditions addObject:@{@"condition":@(condition),@"key":key,@"value":val}];
    return self;
}

-(MKitServiceModelQuery *)orderBy:(NSString *)key direction:(MKitQueryOrder)order
{
    [orders addObject:@{@"key":key,@"dir":@(order)}];
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
