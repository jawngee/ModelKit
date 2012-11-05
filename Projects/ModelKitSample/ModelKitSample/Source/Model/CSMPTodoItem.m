//
//  CSMPTodoItem.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPTodoItem.h"

@implementation CSMPTodoItem

+(void)load
{
    [self register];
}

+(NSString *)modelName
{
    return @"Item";
}

@end
