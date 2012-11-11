//
//  MKitModelRegistry.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModelRegistry.h"

@implementation MKitModelRegistry

static NSMutableDictionary *registry=nil;

+(void)initialize
{
    [super initialize];
    registry=[[NSMutableDictionary alloc] init];
}

+(void)registerModel:(NSString *)modelName forClass:(Class)class
{
    [registry setObject:class forKey:modelName];
}

+(Class)registeredClassForModel:(NSString *)modelName
{
    return [registry objectForKey:modelName];
}

@end
