//
//  CSMPBlog.m
//  CloudSample
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPBlog.h"

@implementation CSMPBlog

-(NSString *)modelName
{
    return @"Blog";
}

-(void)dealloc
{
    self.title=nil;
    self.posts=nil;
    
    [super dealloc];
}

@end
