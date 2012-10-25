//
//  COModelContext.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COModelContext.h"
#import "COModel.h"

@implementation COModelContext

static NSMutableArray *contextStack=nil;

#pragma mark - Init/Dealloc

-(id)init
{
    if ((self=[super init]))
    {
        newStack=[[NSMutableArray alloc] init];
        classCache=[[NSMutableDictionary alloc] init];
    }
    
    return self;
}

-(void)dealloc
{
    [newStack release];
    [classCache release];
    
    [super dealloc];
}

#pragma mark - Class Methods - Stack Management

+(COModelContext *)current
{
    if (contextStack==nil)
        contextStack=[[NSMutableArray alloc] init];
    
    if (contextStack.count==0)
    {
        COModelContext *ctx=[[COModelContext alloc] init];
        [contextStack addObject:ctx];
        
        return ctx;
    }
    
    return [contextStack lastObject];
}

+(COModelContext *)pop
{
    if (contextStack==nil)
        return [self current];
    
    if (contextStack.count>1)
        [contextStack removeObjectAtIndex:contextStack.count-1];
    
    return [contextStack lastObject];
}

+(COModelContext *)push
{
    if (contextStack==nil)
        [self current];
    
    COModelContext *ctx=[[COModelContext alloc] init];
    [contextStack addObject:ctx];
    
    return ctx;
}

#pragma mark - Class Methods - Model Management


+(void)removeFromAnyContext:(COModel *)model
{
    for(COModelContext *ctx in contextStack)
        if ([ctx removeFromContext:model])
            return;
}

#pragma mark - Model Management

-(void)addToContext:(COModel *)model
{
    if ((model.objectId==nil) || ((id)model.objectId==[NSNull null]))
    {
        [newStack addObject:model];
        [model addObserver:self forKeyPath:@"objectId" options:(NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld) context:NULL];
    }
    else
    {
        NSString *className=NSStringFromClass([model class]);
        NSMutableDictionary *objectCache=[classCache objectForKey:className];
        if (!objectCache)
        {
            objectCache=[NSMutableDictionary dictionary];
            [classCache setObject:objectCache forKey:className];
        }
        
        [objectCache setObject:model forKey:model.objectId];
    }
}

-(BOOL)removeFromContext:(COModel *)model
{
    NSInteger idx=[newStack indexOfObject:model];
    if (idx!=NSNotFound)
    {
        [newStack removeObjectAtIndex:idx];
        return YES;
    }
    
    if (!model.objectId)
        return NO;
    
    NSString *className=NSStringFromClass([model class]);
    NSMutableDictionary *objectCache=[classCache objectForKey:className];
    if (!objectCache)
        return NO;
    
    if ([objectCache objectForKey:model.objectId])
    {
        [objectCache removeObjectForKey:model.objectId];
        return YES;
    }
    
    return NO;
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    COModel *model=(COModel *)object;
    
    if ([change objectForKey:@"new"]!=[NSNull null])
    {
        [newStack removeObject:model];
        
        NSString *className=NSStringFromClass([model class]);
        NSMutableDictionary *objectCache=[classCache objectForKey:className];
        if (!objectCache)
        {
            objectCache=[NSMutableDictionary dictionary];
            [classCache setObject:objectCache forKey:className];
        }
        
        [objectCache setObject:model forKey:model.objectId];
        [model removeObserver:self forKeyPath:@"objectId"];
    }
}

-(COModel *)modelForId:(NSString *)objId andClass:(Class)modelClass
{
    NSString *className=NSStringFromClass(modelClass);
    NSMutableDictionary *objectCache=[classCache objectForKey:className];
    if (!objectCache)
        return nil;
    
    return [objectCache objectForKey:objId];
}

@end
