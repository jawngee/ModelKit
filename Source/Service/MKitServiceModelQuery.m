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
    }
    
    return self;
}

-(void)dealloc
{
    [orders release];
    [conditions release];
    [super dealloc];
}

-(void)includeKey:(NSString *)key
{
    [includes addObject:key];
}

-(void)keyExists:(NSString *)key
{
    [conditions addObject:@{@"condition":@(KeyExists),@"key":key}];
}

-(void)keyDoesNotExist:(NSString *)key
{
    [conditions addObject:@{@"condition":@(KeyNotExist),@"key":key}];
}

-(void)key:(NSString *)key condition:(MKitQueryCondition)condition value:(id)val
{
    if (val==nil)
        val=[NSNull null];
    
    [conditions addObject:@{@"condition":@(condition),@"key":key,@"value":val}];
}

-(void)orderBy:(NSString *)key direction:(MKitQueryOrder)order
{
    [orders addObject:@{@"key":key,@"dir":@(order)}];
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
