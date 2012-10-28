//
//  COModelContext.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COModelContext.h"
#import "COModel.h"
#import <malloc/malloc.h>

@interface COModelContext()

-(void)modelStateChanged:(NSNotification *)notification;
-(void)modelGainedIdentifier:(NSNotification *)notification;

@end

@implementation COModelContext

static NSMutableArray *contextStack=nil;

@synthesize contextCount, contextSize;

#pragma mark - Init/Dealloc

-(id)init
{
    if ((self=[super init]))
    {
        newStack=[[NSMutableArray alloc] init];
        classCache=[[NSMutableDictionary alloc] init];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelGainedIdentifier:) name:COModelGainedIdentifierNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modelStateChanged:) name:COModelStateChangedNotification object:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [newStack release];
    [classCache release];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super dealloc];
}

#pragma mark - Class Methods - Stack Management

+(COModelContext *)current
{
    if (contextStack==nil)
        contextStack=[[NSMutableArray alloc] init];
    
    if (contextStack.count==0)
    {
        COModelContext *ctx=[[[COModelContext alloc] init] autorelease];
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
    
    COModelContext *ctx=[[[COModelContext alloc] init] autorelease];
    [contextStack addObject:ctx];
    
    return ctx;
}

+(void)clearAllContexts
{
    if (contextStack==nil)
        return;
    
    for(COModelContext *ctx in contextStack)
        [ctx clear];
    
    [contextStack removeAllObjects];
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
        
        contextCount++;
        contextSize+=malloc_size(model);
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
        
        contextCount--;
        contextSize-=malloc_size(model);
        
        return YES;
    }
    
    return NO;
}

-(void)clear
{
    [classCache removeAllObjects];
    [newStack removeAllObjects];
    
    contextCount=0;
    contextSize=0;
}

-(COModel *)modelForId:(NSString *)objId andClass:(Class)modelClass
{
    NSString *className=NSStringFromClass(modelClass);
    NSMutableDictionary *objectCache=[classCache objectForKey:className];
    if (!objectCache)
        return nil;
    
    return [objectCache objectForKey:objId];
}

#pragma mark - Notifications

-(void)modelStateChanged:(NSNotification *)notification
{
    
}

-(void)modelGainedIdentifier:(NSNotification *)notification
{
    COModel *model=(COModel *)notification.object;
    
    if ([newStack indexOfObject:model]==NSNotFound)
        return;
    
    [newStack removeObject:model];
    
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
    [archiver encodeRootObject:classCache];
    [archiver finishEncoding];
    [data writeToFile:file atomically:NO];
    return YES;
}

-(BOOL)loadFromFile:(NSString *)file error:(NSError **)error
{
    [self clear];
    
    NSData *data=[NSData dataWithContentsOfFile:file];
    NSKeyedUnarchiver *unarchiver=[[[NSKeyedUnarchiver alloc] initForReadingWithData:data] autorelease];
    NSMutableDictionary *dict=[unarchiver decodeObject];
    if (dict)
    {
        [classCache release];
        classCache=[dict retain];
        
        return YES;
    }
    
    return NO;
}

@end
