//
//  CSMPAuthor.h
//  CloudSample
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"

@interface CSMPAuthor : MKitModel

@property (copy, nonatomic) NSString *name;
@property (copy, nonatomic) NSString *email;
@property (retain, nonatomic) NSDate *birthday;
@property (assign, nonatomic) NSInteger age;
@property (assign, nonatomic) BOOL displayEmail;
@property (copy, nonatomic) NSString *avatarURL;

@end
