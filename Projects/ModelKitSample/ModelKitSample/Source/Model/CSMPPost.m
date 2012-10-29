//
//  CSMPPost.m
//  CloudSample
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPPost.h"

@implementation CSMPPost

-(NSString *)modelName
{
    return @"Post";
}

-(void)dealloc
{
    self.author=nil;
    self.title=nil;
    self.body=nil;
    self.comments=nil;
    
    [super dealloc];
}

@end
