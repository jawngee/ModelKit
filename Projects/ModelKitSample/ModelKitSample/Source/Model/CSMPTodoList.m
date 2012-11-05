//
//  CSMPTodoList.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPTodoList.h"

@implementation CSMPTodoList

+(void)load
{
    [self register];
}

+(NSString *)modelName
{
    return @"TodoList";
}

+(MKitServiceModelQuery *)query
{
    MKitServiceModelQuery *q=[super query];
    [q includeKey:@"items"];
    return q;
}

-(id)init
{
    if ((self=[super init]))
    {
        self.items=[MKitMutableModelArray array];
    }
    
    return self;
}

@end
