//
//  TODOMasterViewController.h
//  ToDoSampleCoreData
//
//  Created by Jon Gilkison on 11/11/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TODODetailViewController;

#import <CoreData/CoreData.h>

@interface TODOMasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) TODODetailViewController *detailViewController;

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
