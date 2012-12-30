//
//  TestModel.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/28/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "TestModel.h"

@implementation TestModel

+(NSArray *)ignoredProperties
{
    return @[@"ignoredProperty1",@"ignoredProperty2"];
}

-(id)init
{
    if ((self=[super init]))
    {
        self.amodelArrayV=nil;
    }
    
    return self;
}

-(void)dealloc
{
    self.stringV=nil;
    self.amodelArrayV=nil;
    self.dateV=nil;
    
    [super dealloc];
}

@end
