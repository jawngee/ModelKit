//
//  CSMPNewItemViewController.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/5/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPNewItemViewController.h"
#import "CSMPTodoItem.h"

@interface CSMPNewItemViewController ()

-(void)cancel:(id)sender;
-(void)save:(id)sender;

@end

@implementation CSMPNewItemViewController

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
    
    
    self.title=@"New Item";
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)] autorelease];
    self.navigationItem.rightBarButtonItem=[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)] autorelease];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

-(void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

-(void)save:(id)sender
{
    if (self.itemTitleField.text.length==0)
    {
        [AlertMonger showAlertWithTitle:@"Oops"
                                message:@"Please specify the to do item."
                      cancelButtonTitle:@"Ok"
                   clickedButtonAtIndex:^(NSInteger buttonIndex) {
                       [self.itemTitleField becomeFirstResponder];
                   }
                      otherButtonTitles:nil];
        return;
    }
    
    CSMPTodoItem *item=[CSMPTodoItem instance];
    
    item.list=self.list;
    item.item=self.itemTitleField.text;
    
    if (!self.list.items)
        self.list.items=[MKitMutableModelArray array];
    
    [self.list.items addObject:item];
    
    [self.list saveInBackground:^(BOOL succeeded, NSError *error) {
        if (error)
            [AlertMonger showAlertWithTitle:@"Oops" message:[error localizedDescription] cancelButtonTitle:@"Ok"];
        else
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissModalViewControllerAnimated:YES];
            });
        
    }];
}

- (void)dealloc {
    [_itemTitleField release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setItemTitleField:nil];
    [super viewDidUnload];
}
@end
