//
//  SMASHViewController.m
//  CloudSample
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPViewController.h"
#import "CSMPSampleModel.h"

@interface CSMPViewController ()

@end

@implementation CSMPViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // just testing
    CSMPSampleModel *s=[[CSMPSampleModel alloc] init];
    
    s.objectId=@"HEY";
    s.name=@"Jon";
    s.email=@"jon@interfacelab.com";
    s.age=39;
    s.single=NO;
    s.value=SampleValue2;
    s.values=@[@(NO),@(12.4f),@"hello"];
    s.anotherModel=[[[CSMPSampleModel alloc] init] autorelease];
    
    NSDictionary *props=[s toDictionary];
    NSLog(@"%@",props);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
