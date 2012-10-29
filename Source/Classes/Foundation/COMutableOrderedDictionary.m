//
//  COMutableOrderedDictionary.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COMutableOrderedDictionary.h"

@implementation COMutableOrderedDictionary

-(id)init
{
    if ((self=[super init]))
    {
        _dictionary=CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _orderedKeyArray=[[NSMutableArray array] retain];
    }
    
    return self;
}

-(id)initWithCapacity:(NSUInteger)numItems
{
    if ((self=[super init]))
    {
        _dictionary=CFDictionaryCreateMutable(NULL, numItems, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
        _orderedKeyArray=[[NSMutableArray array] retain];
    }
    
    return self;
}

-(id)initWithObjects:(NSArray *)objects forKeys:(NSArray *)keys
{
    if ((self=[self initWithCapacity:objects.count]))
    {
        if (objects.count!=keys.count)
            @throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"Object and key counts don't match up." userInfo:nil];
        
        for(int i=0; i<keys.count; i++)
            [self setObject:objects[i] forKey:keys[i]];
    }
    
    return self;
}

-(void)dealloc
{
    CFRelease(_dictionary);
    [_orderedKeyArray release];
    
    [super dealloc];
}

-(void)setObject:(id)anObject forKey:(id<NSCopying>)aKey
{
    [_orderedKeyArray addObject:aKey];
    CFDictionarySetValue(_dictionary, (const void *)aKey, (const void *)anObject);
}

-(void)removeObjectForKey:(id)aKey
{
    [_orderedKeyArray removeObject:aKey];
    CFDictionaryRemoveValue(_dictionary, (const void *)aKey);
}

-(NSUInteger)count
{
    return CFDictionaryGetCount(_dictionary);
}

-(id)objectForKey:(id)aKey
{
    return CFDictionaryGetValue(_dictionary, (const void *)aKey);
}

-(NSEnumerator *)keyEnumerator
{
    return [_orderedKeyArray objectEnumerator];
}



@end
