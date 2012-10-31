//
//  MKitModelContext.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModelContext.h"
#import "MKitModel.h"
#import <malloc/malloc.h>

@interface MKitModelContext()

-(void)modelStateChanged:(NSNotification *)notification;
-(void)modelGainedIdentifier:(NSNotification *)notification;
-(void)modelIdentifierChanged:(NSNotification *)notification;

@end

@implementation MKitModelContext

static NSMutableArray *contextStack=nil;

@synthesize contextCount, contextSize;

#pragma mark - Init/Dealloc

-(id)init
{
    if ((self=[super init]))
    {
        modelStack=[[NSMutableDictionary alloc] init];
        classCache=[[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelGainedIdentifier:) name:MKitObjectIdentifierChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelStateChanged:) name:MKitModelStateChangedNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelIdentifierChanged:) name:MKitModelIdentifierChangedNotification object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [modelStack release];
    [classCache release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark - Class Methods - Stack Management

+(MKitModelContext *)current
{
    if (contextStack==nil)
        contextStack=[[NSMutableArray alloc] init];
    
    if (contextStack.count==0)
    {
        MKitModelContext *ctx=[[[MKitModelContext alloc] init] autorelease];
        [contextStack addObject:ctx];
        
        return ctx;
    }
    
    return [contextStack lastObject];
}

+(MKitModelContext *)pop
{
    if (contextStack==nil)
        return [self current];
    
    if (contextStack.count>1)
        [contextStack removeObjectAtIndex:contextStack.count-1];
    
    return [contextStack lastObject];
}

+(MKitModelContext *)push
{
    if (contextStack==nil)
        [self current];
    
    MKitModelContext *ctx=[[[MKitModelContext alloc] init] autorelease];
    [contextStack addObject:ctx];
    
    return ctx;
}

+(void)clearAllContexts
{
    if (contextStack==nil)
        return;
    
    for(MKitModelContext *ctx in contextStack)
        [ctx clear];
    
    [contextStack removeAllObjects];
    
    MKitModelContext *ctx=[[[MKitModelContext alloc] init] autorelease];
    [contextStack addObject:ctx];
}

#pragma mark - Class Methods - Model Management


+(void)removeFromAnyContext:(MKitModel *)model
{
    for(MKitModelContext *ctx in contextStack)
        if ([ctx removeFromContext:model])
            return;
}

#pragma mark - Model Management

-(void)addToContext:(MKitModel *)model
{
    [modelStack setObject:model forKey:model.modelId];

    if ((model.objectId!=nil) && ((id)model.objectId!=[NSNull null]))
    {
        NSString *className=NSStringFromClass([model class]);
        NSMutableDictionary *objectCache=[classCache objectForKey:className];
        if (!objectCache)
        {
            objectCache=[NSMutableDictionary dictionary];
            [classCache setObject:objectCache forKey:className];
        }
        
        [objectCache setObject:model forKey:model.objectId];
        
        contextCount++;
        contextSize+=malloc_size(model);
    }
}

-(BOOL)removeFromContext:(MKitModel *)model
{
    BOOL exists=([modelStack objectForKey:model.modelId]!=nil);
    if (exists)
        [modelStack removeObjectForKey:model.modelId];
    
    if ((model.objectId!=nil) && ((id)model.objectId!=[NSNull null]))
    {
        NSString *className=NSStringFromClass([model class]);
        NSMutableDictionary *objectCache=[classCache objectForKey:className];
        if (!objectCache)
            return exists;
    
        if ([objectCache objectForKey:model.objectId])
        {
            [objectCache removeObjectForKey:model.objectId];
            
            contextCount--;
            contextSize-=malloc_size(model);
            
            return YES;
        }
    }
    
    return exists;
}

-(void)clear
{
    [classCache removeAllObjects];
    [modelStack removeAllObjects];
    
    contextCount=0;
    contextSize=0;
}

-(MKitModel *)modelForObjectId:(NSString *)objId andClass:(Class)modelClass
{
    NSString *className=NSStringFromClass(modelClass);
    NSMutableDictionary *objectCache=[classCache objectForKey:className];
    if (!objectCache)
        return nil;
    
    return [objectCache objectForKey:objId];
}

-(MKitModel *)modelForModelId:(NSString *)modelId
{
    return [modelStack objectForKey:modelId];
}

#pragma mark - Notifications

-(void)modelStateChanged:(NSNotification *)notification
{
    
}

-(void)modelIdentifierChanged:(NSNotification *)notification
{
    MKitModel *model=(MKitModel *)notification.object;
    
    NSString *oldValue=[notification.userInfo objectForKey:NSKeyValueChangeOldKey];
    
    if ([modelStack objectForKey:oldValue])
        [modelStack removeObjectForKey:oldValue];
    
    if ((model.modelId) && (![[self class] conformsToProtocol:@protocol(MKitNoContext)]))
        [modelStack setObject:model forKey:model.modelId];

}

-(void)modelGainedIdentifier:(NSNotification *)notification
{
    MKitModel *model=(MKitModel *)notification.object;
    
    if (![modelStack objectForKey:model.modelId])
        return;
    
    NSString *className=NSStringFromClass([model class]);
    NSMutableDictionary *objectCache=[classCache objectForKey:className];
    if (!objectCache)
    {
        objectCache=[NSMutableDictionary dictionary];
        [classCache setObject:objectCache forKey:className];
    }
    
    if (![objectCache objectForKey:model.objectId])
    {
        [objectCache setObject:model forKey:model.objectId];
    
        contextCount++;
        contextSize+=malloc_size(model);
    }
}

#pragma mark - Activation

-(void)activate
{
    if (contextStack==nil)
        contextStack=[[NSMutableArray alloc] init];
    
    if ([contextStack indexOfObject:self]!=NSNotFound)
        [contextStack removeObject:self];
    
    [contextStack addObject:self];
}

-(void)deactivate
{
    if (contextStack==nil)
        return;
    
    [contextStack removeObject:self];
}

#pragma mark - Persistence

-(BOOL)saveToFile:(NSString *)file error:(NSError **)error
{
    NSMutableData *data=[NSMutableData data];
    NSKeyedArchiver *archiver=[[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeRootObject:@[modelStack,classCache]];
    [archiver finishEncoding];
    [data writeToFile:file atomically:NO];
    return YES;
}

-(BOOL)loadFromFile:(NSString *)file error:(NSError **)error
{
    [self clear];
    
    NSData *data=[NSData dataWithContentsOfFile:file];
    NSKeyedUnarchiver *unarchiver=[[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    NSArray *array=[unarchiver decodeObject];
    if (array)
    {
        [modelStack release];
        modelStack=[[array objectAtIndex:0] retain];
        
        [classCache release];
        classCache=[[array objectAtIndex:1] retain];
        
        return YES;
    }
    
    return NO;
}

@end
