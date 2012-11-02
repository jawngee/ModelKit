//
//  MKitModelQuery.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceModelQuery.h"

NSString *const MKitQueryItemCountKey=@"itemCount";
NSString *const MKitQueryResultKey=@"result";

@implementation MKitServiceModelQuery

+(MKitServiceModelQuery *)queryForModelClass:(Class)_modelClass manager:(MKitServiceManager *)_manager
{
    return [[[self alloc] initWithModelClass:_modelClass manager:_manager] autorelease];
}

-(id)initWithModelClass:(Class)_modelClass manager:(MKitServiceManager *)_manager
{
    if ((self=[super initWithModelClass:_modelClass]))
    {
        manager=_manager;
        includes=[[NSMutableArray array] retain];
    }
    
    return self;
}

-(void)dealloc
{
    [includes release];
    [super dealloc];
}

-(void)includeKey:(NSString *)key
{
    [includes addObject:key];
}

@end
