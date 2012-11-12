//
//  TODODetailViewController.h
//  ToDoSampleCoreData
//
//  Created by Jon Gilkison on 11/11/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TODODetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;

@end
