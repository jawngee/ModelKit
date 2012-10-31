//
//  MKitParseServiceManager.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseServiceManager.h"
#import "AFNetworking.h"

@interface MKitParseServiceManager()
@end

@implementation MKitParseServiceManager

-(id)initWithKeys:(NSDictionary *)keys
{
    if ((self=[super init]))
    {
        _appID=[[keys objectForKey:@"AppID"] copy];
        _restKey=[[keys objectForKey:@"RestKey"] copy];
        
        if (!_appID)
            @throw [NSException exceptionWithName:@"Missing App ID" reason:@"Missing AppID in keys dictionary" userInfo:nil];
        
        if (!_restKey)
            @throw [NSException exceptionWithName:@"Missing REST Key" reason:@"Missing RestKey in keys dictionary" userInfo:nil];
    }
    
    return self;
}

-(void)dealloc
{
    [_appID release];
    [_restKey release];
    
    [super dealloc];
}

-(BOOL)saveModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

-(BOOL)updateModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

-(BOOL)deleteModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

-(BOOL)fetchModel:(MKitModel *)model error:(NSError **)error
{
    return NO;
}

@end
