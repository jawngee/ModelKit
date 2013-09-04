//
//  NSDictionary+MKitQuery.m
//  Aspekt
//
//  Created by Jon Gilkison on 6/12/13.
//  Copyright (c) 2013 Interfacelab LLC. All rights reserved.
//

#import "NSDictionary+MKitQuery.h"
#import "MKitModelQuery.h"

@implementation NSDictionary (MKitQuery)

-(NSArray *)queryResults
{
    return [self objectForKey:MKitQueryResultKey];
}

-(NSInteger)queryCount
{
    return [[self objectForKey:MKitQueryItemCountKey] integerValue];
}

@end
