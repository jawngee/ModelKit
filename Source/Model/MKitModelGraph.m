//
//  MKitModelGraph.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModelGraph.h"
#import "MKitModel.h"
#import <malloc/malloc.h>

/**
 * Private methods
 */
@interface MKitModelGraph(Internal)

/**
 * Notification that the model state has changed
 * @param notification The notification
 */
-(void)modelStateChanged:(NSNotification *)notification;

/**
 * Notification that the model has gained an objectId
 * @param notification The notification
 */
-(void)modelGainedIdentifier:(NSNotification *)notification;

/**
 * Notification that the model's ID has changed
 * @param notification The notification
 */
-(void)modelIdentifierChanged:(NSNotification *)notification;

@end

@implementation MKitModelGraph

static NSMutableArray *graphStack=nil;

@synthesize graphCount, graphSize;

#pragma mark - Init/Dealloc

+(void)initialize
{
    [super initialize];
    graphStack=[[NSMutableArray array] retain];
}

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

+(MKitModelGraph *)current
{
    if (graphStack.count==0)
    {
        MKitModelGraph *ctx=[[[MKitModelGraph alloc] init] autorelease];
        [graphStack addObject:ctx];
        
        return ctx;
    }
    
    return [graphStack lastObject];
}

+(MKitModelGraph *)pop
{
    if (graphStack.count>1)
        [graphStack removeObjectAtIndex:graphStack.count-1];
    
    return [graphStack lastObject];
}

+(MKitModelGraph *)push
{
    MKitModelGraph *ctx=[[[MKitModelGraph alloc] init] autorelease];
    [graphStack addObject:ctx];
    
    return ctx;
}

+(void)clearAllGraphs
{
    for(MKitModelGraph *ctx in graphStack)
        [ctx clear];
    
    [graphStack removeAllObjects];
    
    MKitModelGraph *ctx=[[[MKitModelGraph alloc] init] autorelease];
    [graphStack addObject:ctx];
}

#pragma mark - Class Methods - Model Management


+(void)removeFromAnyContext:(MKitModel *)model
{
    for(MKitModelGraph *ctx in graphStack)
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
        
        graphCount++;
        graphSize+=malloc_size(model);
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
            
            graphCount--;
            graphSize-=malloc_size(model);
            
            return YES;
        }
    }
    
    return exists;
}

-(void)clear
{
    [classCache removeAllObjects];
    [modelStack removeAllObjects];
    
    graphCount=0;
    graphSize=0;
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
    
        graphCount++;
        graphSize+=malloc_size(model);
    }
}

#pragma mark - Activation

-(void)activate
{
    if ([graphStack indexOfObject:self]!=NSNotFound)
        [graphStack removeObject:self];
    
    [graphStack addObject:self];
}

-(void)deactivate
{
    if ([graphStack indexOfObject:self]!=0)
        [graphStack removeObject:self];
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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:file])
    {
        if (error)
            *error=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        
        return NO;
    }
    
    NSData *data=[NSData dataWithContentsOfFile:file options:NSDataReadingMappedAlways error:nil];
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

-(NSArray *)queryWithPredicate:(NSPredicate *)predicate forClass:(Class)modelClass
{
    NSString *className=NSStringFromClass(modelClass);
    NSMutableDictionary *objectCache=[classCache objectForKey:className];
    if (!objectCache)
        return nil;
    
    return [[objectCache allValues] filteredArrayUsingPredicate:predicate];
}

@end
