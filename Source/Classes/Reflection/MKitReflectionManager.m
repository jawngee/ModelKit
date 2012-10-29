//
//  MKitReflectionManager.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitReflectionManager.h"
#import "MKitReflectedClass.h"

@implementation MKitReflectionManager

static NSMutableDictionary *cache=nil;

+(MKitReflectedClass *)reflectionForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix recurseChainUntil:(Class)topclass
{
    if (cache==nil)
        cache=[[NSMutableDictionary alloc] init];
    
    NSString *className=NSStringFromClass(class);
    MKitReflectedClass *ref=[cache objectForKey:className];
    if (!ref)
    {
        ref=[MKitReflectedClass reflectionForClass:class ignorePropPrefix:ignorePropPrefix recurseChainUntil:topclass];
        [cache setObject:ref forKey:className];
    }
    
    return ref;
}

@end
