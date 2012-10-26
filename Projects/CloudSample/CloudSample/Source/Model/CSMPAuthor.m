//
//  CSMPAuthor.m
//  CloudSample
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPAuthor.h"

@implementation CSMPAuthor

-(NSString *)modelName
{
    return @"Author";
}

-(void)dealloc
{
    self.name=nil;
    self.email=nil;
    self.avatarURL=nil;
    
    [super dealloc];
}

@end
