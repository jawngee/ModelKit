//
//  COReflectionManager.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COReflectionManager.h"
#import "COReflectedClass.h"

@implementation COReflectionManager

static NSMutableDictionary *cache=nil;

+(COReflectedClass *)reflectionForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix recurseChainUntil:(Class)topclass
{
    if (cache==nil)
        cache=[[NSMutableDictionary alloc] init];
    
    NSString *className=NSStringFromClass(class);
    COReflectedClass *ref=[cache objectForKey:className];
    if (!ref)
    {
        ref=[COReflectedClass reflectionForClass:class ignorePropPrefix:ignorePropPrefix recurseChainUntil:topclass];
        [cache setObject:ref forKey:className];
    }
    
    return ref;
}

@end
