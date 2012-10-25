//
//  CSMPSampleModel.h
//  CloudSample
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COModel.h"

typedef enum
{
    SampleValue1,
    SampleValue2,
    SampleValue3
} CSMPSampleModelEnum;

@interface CSMPSampleModel : COModel

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *email;
@property (assign, nonatomic) NSInteger age;
@property (assign, nonatomic) NSInteger gender;
@property (assign, nonatomic) BOOL single;
@property (assign, nonatomic) CSMPSampleModelEnum value;
@property (retain, nonatomic) NSArray *values;
@property (retain, nonatomic) COModel *anotherModel;

@end
