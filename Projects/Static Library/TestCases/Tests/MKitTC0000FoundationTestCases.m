//
//  MKitTC0000FoundationTestCases.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitTC0000FoundationTestCases.h"

@implementation MKitTC0000FoundationTestCases

-(void)test0001OrderedDictionary
{
    MKitMutableOrderedDictionary *dict=[MKitMutableOrderedDictionary dictionary];
    [dict setObject:@"1" forKey:@"1"];
    [dict setObject:@"2" forKey:@"2"];
    [dict setObject:@"3" forKey:@"3"];
    [dict setObject:@"4" forKey:@"4"];
    [dict setObject:@"5" forKey:@"5"];
    [dict setObject:@"6" forKey:@"6"];
    
    NSArray *dvalues=[dict allValues];
    
    for(int i=0; i<dvalues.count; i++)
    {
        STAssertTrue(([((NSString *)dvalues[i]) isEqualToString:[NSString stringWithFormat:@"%d",i+1]]),@"Objects are not in order");
    }
}

@end
