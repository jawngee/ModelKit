//
//  SMASHViewController.m
//  CloudSample
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPViewController.h"
#import "JSONKit.h"
#import "MKitMutableModelArray.h"
#import "CSMPAuthor.h"
#import "CSMPPost.h"
#import "CSMPComment.h"

@interface CSMPViewController ()

@end

@implementation CSMPViewController

- (void)viewDidLoad
{
    CSMPPost *post=[CSMPPost instanceWithObjectId:@"AhKmx8FSGv"];
    [post fetchInBackground:^(BOOL succeeded, NSError *error) {
        NSLog(@"POST: %@",[post serialize]);
    }];
    
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)buttonTouched:(id)sender
{
}

- (IBAction)removeButtonTouched:(id)sender
{
}

@end
