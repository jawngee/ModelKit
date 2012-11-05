//
//  CSMPTodoItem.h
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseModel.h"
#import "CSMPTodoList.h"

@interface CSMPTodoItem : MKitParseModel

@property (assign, nonatomic) CSMPTodoList *list;
@property (copy, nonatomic) NSString *item;
@property (copy, nonatomic) NSDate *dueDate;
@property (assign, nonatomic) BOOL finished;
@property (assign, nonatomic) NSInteger priority;

@end
