//
//  MKitModelQuery.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
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
        orders=[[NSMutableArray array] retain];
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

-(NSDictionary *)execute:(NSError **)error
{
    return [self executeWithLimit:NSNotFound skip:NSNotFound error:error];
}

-(void)executeInBackground:(MKitQueryResultBlock)resultBlock
{
    [self executeInBackgroundWithLimit:NSNotFound skip:NSNotFound resultBlock:resultBlock];
}


-(NSDictionary *)executeWithLimit:(NSInteger)limit skip:(NSInteger)skip error:(NSError **)error
{
    return nil;
}

-(void)executeInBackgroundWithLimit:(NSInteger)limit skip:(NSInteger)skip resultBlock:(MKitQueryResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        NSDictionary *result=[self executeWithLimit:limit skip:skip error:&error];
        
        if ((result!=nil) && (resultBlock!=nil))
            resultBlock(result[MKitQueryResultKey], [result[MKitQueryItemCountKey] integerValue], error);
        else if (resultBlock)
            resultBlock(nil, 0, error);
    });
}

-(NSInteger)count:(NSError **)error
{
    return 0;
}

-(void)countInBackground:(MKitIntResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        NSInteger result=[self count:&error];
        if (resultBlock)
            resultBlock(result, error);
    });
}


@end
