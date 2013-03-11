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

@synthesize objectCount, size;

#pragma mark - Init/Dealloc

+(void)initialize
{
    [super initialize];
    
    graphs=[[NSMutableDictionary dictionary] retain];
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
        [modelStack release];
        [classCache release];
        
        NSArray *encoded=[aDecoder decodeObjectForKey:@"data"];
        modelStack=[[encoded objectAtIndex:0] mutableCopy];
        classCache=[[encoded objectAtIndex:1] mutableCopy];
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
    [aCoder encodeObject:@[modelStack,classCache] forKey:@"data"];
}

#pragma mark - Class Methods - Stack Management

+(MKitModelGraph *)defaultGraph
{
    return [self graphNamed:MKitModelGraphDefault];
}


+(MKitModelGraph *)graphNamed:(NSString *)name
{
    MKitModelGraph *graph=[graphs objectForKey:name];
    
    if (!graph)
    {
        graph=[[[MKitModelGraph alloc] init] autorelease];
        [graphs setObject:graph forKey:MKitModelGraphDefault];
    }
    
    return graph;
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
    [classCache removeAllObjects];
    [modelStack removeAllObjects];
    
    objectCount=0;
    size=0;
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
            
            objectCount--;
            size-=malloc_size(model);
            
            return YES;
        }
    }
    
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
    
    if ([[model class] graph]!=self)
        return;
    
    NSString *oldValue=[notification.userInfo objectForKey:NSKeyValueChangeOldKey];
    
    if ([modelStack objectForKey:oldValue])
        [modelStack removeObjectForKey:oldValue];
    
    if ((model.modelId) && (![[self class] conformsToProtocol:@protocol(MKitNoGraph)]))
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
        modelStack=[[array objectAtIndex:0] mutableCopy];
        
        [classCache release];
        classCache=[[array objectAtIndex:1] mutableCopy];
        
        return YES;
    }
    
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
