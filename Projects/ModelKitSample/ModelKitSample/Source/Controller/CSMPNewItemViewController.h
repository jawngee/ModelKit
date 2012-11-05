//
//  CSMPNewItemViewController.h
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/5/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CSMPTodoItem.h"

@interface CSMPNewItemViewController : UIViewController

@property (assign, nonatomic) CSMPTodoList *list;
@property (retain, nonatomic) IBOutlet UITextField *itemTitleField;

@end
