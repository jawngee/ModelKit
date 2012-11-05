//
//  CSMPNewToDoListViewController.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPNewToDoListViewController.h"
#import "CSMPTodoList.h"

@interface CSMPNewToDoListViewController ()

-(void)cancel:(id)sender;
-(void)save:(id)sender;

@end

@implementation CSMPNewToDoListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"New To Do List";
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)] autorelease];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)save:(id)sender
{
    if (self.listNameTextField.text.length==0)
    {
        [AlertMonger showAlertWithTitle:@"Oops"
                                message:@"Please specify a name."
                      cancelButtonTitle:@"Ok"
                   clickedButtonAtIndex:^(NSInteger buttonIndex) {
                       [self.listNameTextField becomeFirstResponder];
                   }
                      otherButtonTitles:nil];
        return;
    }
    
    CSMPTodoList *todoList=[CSMPTodoList instance];
    todoList.owner=(CSMPUser *)[CSMPUser currentUser];
    todoList.name=self.listNameTextField.text;
    [todoList saveInBackground:^(BOOL succeeded, NSError *error) {
        if (error)
            [AlertMonger showAlertWithTitle:@"Oops" message:[error localizedDescription] cancelButtonTitle:@"Ok"];
        else
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissModalViewControllerAnimated:YES];
            });
        
    }];
}

- (void)dealloc {
    [_listNameTextField release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setListNameTextField:nil];
    [super viewDidUnload];
}
@end
