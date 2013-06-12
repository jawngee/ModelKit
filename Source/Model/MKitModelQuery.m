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
        subqueries=[[NSMutableArray array] retain];
        modelClass=_modelClass;
    }
    
    return self;
}

-(void)dealloc
{
    [subqueries release];
    [orders release];
    [conditions release];
    [super dealloc];
}

-(MKitModelQuery *)keyExists:(NSString *)key
{
    [conditions addObject:@{@"condition":@(KeyExists),@"key":key}];
    
    return self;
}

-(MKitModelQuery *)keyDoesNotExist:(NSString *)key
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


-(MKitModelQuery *)key:(NSString *)key withinDistance:(double)distance ofPoint:(MKitGeoPoint *)point
{
    [conditions addObject:@{@"condition":@(KeyWithinDistance),@"key":key,@"value":@{@"distance":@(distance),@"point":point}}];
    
    return self;
}

-(MKitModelQuery *)orderBy:(NSString *)key direction:(MKitQueryOrder)order
{
    [orders addObject:@{@"key":key,@"dir":@(order)}];
    
    return self;
}

-(MKitModelQuery *)key:(NSString *)key equals:(id)val
{
    return [self key:key condition:KeyEquals value:val];
}

-(MKitModelQuery *)key:(NSString *)key notEqualTo:(id)val
{
    return [self key:key condition:KeyNotEqual value:val];
}

-(MKitModelQuery *)key:(NSString *)key greaterThanEqual:(id)val
{
    return [self key:key condition:KeyGreaterThanEqual value:val];
}

-(MKitModelQuery *)key:(NSString *)key greater:(id)val
{
    return [self key:key condition:KeyGreaterThan value:val];
}

-(MKitModelQuery *)key:(NSString *)key lessThanEqual:(id)val
{
    return [self key:key condition:KeyLessThanEqual value:val];
}

-(MKitModelQuery *)key:(NSString *)key lessThan:(id)val
{
    return [self key:key condition:KeyLessThan value:val];
}

-(MKitModelQuery *)key:(NSString *)key isIn:(id)val
{
    return [self key:key condition:KeyIn value:val];
}

-(MKitModelQuery *)key:(NSString *)key isNotIn:(id)val
{
    return [self key:key condition:KeyNotIn value:val];
}

-(MKitModelQuery *)key:(NSString *)key beginsWith:(id)val
{
    return [self key:key condition:KeyBeginsWith value:val];
}

-(MKitModelQuery *)key:(NSString *)key endsWith:(id)val
{
    return [self key:key condition:KeyEndsWith value:val];
}

-(MKitModelQuery *)key:(NSString *)key like:(id)val
{
    return [self key:key condition:KeyLike value:val];
}

-(MKitModelQuery *)key:(NSString *)key contains:(id)val
{
    return [self key:key condition:KeyContains value:val];
}

-(MKitModelQuery *)key:(NSString *)key containsAll:(id)val
{
    return [self key:key condition:KeyContainsAll value:val];
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

-(void)addSubquery:(MKitModelQuery *)query
{
    [subqueries addObject:query];
}


@end
