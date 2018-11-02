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

NSString * const MKitModelGraphDefault=@"default";

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

static NSMutableDictionary *graphs=nil;

@synthesize objectCount, size, classCache;

#pragma mark - Init/Dealloc

+(void)initialize
{
    [super initialize];
    
    graphs=[[NSMutableDictionary dictionary] retain];
    
    MKitModelGraph *graph=[[[MKitModelGraph alloc] init] autorelease];
    [graphs setObject:graph forKey:MKitModelGraphDefault];
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

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[self init]))
    {
        [self push];
        
        [modelStack release];
        [classCache release];
        
        NSArray *encoded=[aDecoder decodeObjectForKey:@"data"];
        modelStack=[[encoded objectAtIndex:0] mutableCopy];
        classCache=[[encoded objectAtIndex:1] mutableCopy];
        
        [self pop];
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

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [self push];
    [aCoder encodeObject:@[modelStack,classCache] forKey:@"data"];
    [self pop];
}

#pragma mark - Class Methods - Stack Management

+(MKitModelGraph *)defaultGraph
{
    return [self graphNamed:MKitModelGraphDefault];
}


+(MKitModelGraph *)graphNamed:(NSString *)name
{
    MKitModelGraph *graph=[graphs objectForKey:name];
        
    @synchronized(graphs)
    {
        if (!graph)
        {
            graph=[[[MKitModelGraph alloc] init] autorelease];
            [graphs setObject:graph forKey:name];
        }
    }

    return graph;
}


+(void)removeGraph:(MKitModelGraph *)graph
{
    @synchronized(graphs)
    {
        __block NSString *graphKey=nil;
        [graphs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (obj==graph)
            {
                graphKey=key;
                *stop=YES;
            }
        }];
        
        if (graphKey)
            [graphs removeObjectForKey:graphKey];
    }
}

#pragma mark -- Multi graph

/**
 * Sets the current graph for the current thread
 */
-(void)push
{
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    
    NSMutableArray *currentA=dict[@"currentGraphs"];
    
    if (!currentA)
    {
        currentA=[NSMutableArray array];
        [dict setObject:currentA forKey:@"currentGraphs"];
    }
    
    [currentA addObject:self];
}

/**
 * Returns the current model graph for the current thread
 */
+(MKitModelGraph *)current
{
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    NSMutableArray *currentA=dict[@"currentGraphs"];
    if ((currentA) && (currentA.count>0))
        return [currentA lastObject];
    
    return [self defaultGraph];
}

/**
 * Pops the current graph for the thread off the stack
 */
+(void)popCurrent
{
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    NSMutableArray *currentA=dict[@"currentGraphs"];
    if ((currentA) && (currentA.count>0))
        [currentA removeLastObject];
}

/**
 * Pops the current graph for the thread off the stack
 */
-(void)pop
{
    NSMutableDictionary *dict = [[NSThread currentThread] threadDictionary];
    NSMutableArray *currentA=dict[@"currentGraphs"];
    if ((currentA) && (currentA.count>0) && (currentA[0]==self))
        [currentA removeLastObject];
}

-(void)remove
{
    [self push];
    [self clear];
    [self pop];
    
    [MKitModelGraph removeGraph:self];
}

#pragma mark - Model Management

+(void)clearAllGraphs
{
    [graphs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [obj clear];
    }];
}



-(void)clear
{
    [self push];
    
    @synchronized(classCache)
    {
        [classCache removeAllObjects];
    }
    
    @synchronized(modelStack)
    {
        [modelStack removeAllObjects];
    }
    
    objectCount=0;
    size=0;
    
    [self pop];
}

-(void)addToGraph:(MKitModel *)model
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
        
        objectCount++;
        size+=malloc_size(model);
    }
}

+(void)removeFromAnyGraph:(MKitModel *)model
{
    [graphs enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        *stop=[obj removeFromGraph:model];
    }];
}

-(BOOL)removeFromGraph:(MKitModel *)model
{
    [self push];
    
    [model retain];
    
    BOOL exists=([modelStack objectForKey:model.modelId]!=nil);
    if (exists)
        [modelStack removeObjectForKey:model.modelId];
    
    if ((model.objectId!=nil) && ((id)model.objectId!=[NSNull null]))
    {
        NSString *className=NSStringFromClass([model class]);
        NSMutableDictionary *objectCache=[classCache objectForKey:className];
        
        if ((objectCache) && ([objectCache objectForKey:model.objectId]))
        {
            [objectCache removeObjectForKey:model.objectId];
            
            objectCount--;
            size-=malloc_size(model);
            
            exists=YES;
        }
    }
    
    [model release];
    
    [self pop];
    
    return exists;
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
    
    if ([[model class] defaultGraph]!=self)
        return;
    
    NSString *oldValue=[notification.userInfo objectForKey:NSKeyValueChangeOldKey];
    
    [self push];
    
    if ([modelStack objectForKey:oldValue])
        [modelStack removeObjectForKey:oldValue];
    
    if ((model.modelId) && (![[self class] conformsToProtocol:@protocol(MKitNoGraph)]))
        [modelStack setObject:model forKey:model.modelId];
    
    [self pop];

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
    
        objectCount++;
        size+=malloc_size(model);
    }
}

#pragma mark - Persistence


+(BOOL)saveAllToFile:(NSString *)file error:(NSError **)error
{
    NSMutableData *data=[NSMutableData data];
    NSKeyedArchiver *archiver=[[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeRootObject:graphs];
    [archiver finishEncoding];
    [data writeToFile:file atomically:NO];
    return YES;
}

+(BOOL)loadAllFromFile:(NSString *)file error:(NSError **)error
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:file])
    {
        if (error)
            *error=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        
        return NO;
    }

    [graphs release];
    graphs=nil;
    
    NSData *data=[NSData dataWithContentsOfFile:file options:NSDataReadingMappedAlways error:nil];
    NSKeyedUnarchiver *unarchiver=[[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    NSDictionary *graphDict=[unarchiver decodeObject];
    if (graphDict)
    {
        graphs=[graphDict mutableCopy];
        
        return YES;
    }
    
    graphs=[[NSMutableDictionary dictionary] retain];
    
    return NO;

}

-(BOOL)saveToFile:(NSString *)file error:(NSError **)error
{
    [self push];
    
    NSMutableDictionary *modelStackCopy;
    NSMutableDictionary *classCacheCopy;
    
    @synchronized(modelStack)
    {
        modelStackCopy=[[modelStack mutableCopy] autorelease];
    }
    
    @synchronized(classCache)
    {
        classCacheCopy=[[classCache mutableCopy] autorelease];
    }
    
    NSMutableData *data=[NSMutableData data];
    NSKeyedArchiver *archiver=[[[NSKeyedArchiver alloc] initForWritingWithMutableData:data] autorelease];
    [archiver encodeRootObject:@[modelStackCopy,classCacheCopy]];
    [archiver finishEncoding];
    [data writeToFile:file atomically:NO];
    
    [self pop];
    
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
    
    [self push];
    
    NSData *data=[NSData dataWithContentsOfFile:file options:NSDataReadingMappedAlways error:nil];
    NSKeyedUnarchiver *unarchiver=[[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    NSArray *array=[unarchiver decodeObject];
    if (array)
    {
        [modelStack release];
        modelStack=[[array objectAtIndex:0] mutableCopy];
        
        [classCache release];
        classCache=[[array objectAtIndex:1] mutableCopy];
        
        [self pop];
        return YES;
    }
    
    [self pop];
    return NO;
}

-(BOOL)importFromFile:(NSString *)file error:(NSError **)error
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:file])
    {
        if (error)
            *error=[NSError errorWithDomain:NSPOSIXErrorDomain code:ENOENT userInfo:nil];
        
        return NO;
    }
    
    [self push];
    
    NSData *data=[NSData dataWithContentsOfFile:file options:NSDataReadingMappedAlways error:nil];
    NSKeyedUnarchiver *unarchiver=[[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    NSArray *array=[unarchiver decodeObject];
    if (array)
    {
        [modelStack addEntriesFromDictionary:[array objectAtIndex:0]];
        [classCache addEntriesFromDictionary:[array objectAtIndex:1]];
        
        [self pop];
        return YES;
    }
    
    [self pop];
    return NO;
}


#pragma mark - Query

-(NSArray *)queryWithPredicate:(NSPredicate *)predicate forClass:(Class)modelClass
{
    NSString *className=NSStringFromClass(modelClass);
    NSMutableDictionary *objectCache=[classCache objectForKey:className];
    if (!objectCache)
    {
        NSPredicate *p=[NSPredicate predicateWithFormat:@"className==%@",className];
        NSPredicate *c=[NSCompoundPredicate andPredicateWithSubpredicates:@[p,predicate]];
        return [[modelStack allValues] filteredArrayUsingPredicate:c];
    }
    
    return [[objectCache allValues] filteredArrayUsingPredicate:predicate];
}

@end
