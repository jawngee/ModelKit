//
//  CSMPComment.m
//  CloudSample
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPComment.h"

@implementation CSMPComment

+(void)load
{
    [self register];
}

-(NSString *)modelName
{
    return @"Comment";
}

-(void)dealloc
{
    self.author=nil;
    self.comment=nil;
    
    [super dealloc];
}

@end
