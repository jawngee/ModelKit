//
//  CSMPTodoList.h
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseModel.h"

@interface CSMPTodoList : MKitParseModel

@property (assign, nonatomic) CSMPUser *owner;
@property (copy, nonatomic) NSString *name;
@property (retain, nonatomic) MKitMutableModelArray *items;

@end
