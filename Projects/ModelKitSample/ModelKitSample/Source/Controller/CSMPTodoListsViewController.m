//
//  CSMPTodoListViewController.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPTodoListsViewController.h"
#import "CSMPSignUpViewController.h"
#import "CSMPNewToDoListViewController.h"
#import "CSMPTodoList.h"
#import "CSMPTodoListViewController.h"

@interface CSMPTodoListsViewController ()

-(void)showSignUp;
-(void)updateForLoggedInUser;
-(void)logOutUser:(id)sender;

-(void)addToDoList:(id)sender;

-(void)userLoggedInNotification:(NSNotification *)notification;
-(void)userLoggedOutNotification:(NSNotification *)notification;

@end

@implementation CSMPTodoListsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    lists=[[NSMutableArray alloc] init];
    
    self.title=@"To Do Lists";
    self.clearsSelectionOnViewWillAppear = NO;
    self.navigationItem.rightBarButtonItems=@[[[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addToDoList:)] autorelease],self.editButtonItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedInNotification:) name:MKitUserLoggedInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userLoggedOutNotification:) name:MKitUserLoggedOutNotification object:nil];

}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"View Will Appear");
    
    [super viewWillAppear:animated];
    
    if (![CSMPUser currentUser])
    {
        [self performSelector:@selector(showSignUp) withObject:nil afterDelay:0.66f];
    }
    else
        [self updateForLoggedInUser];
}

-(void)viewDidUnload
{
    [lists release];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Sign Up

-(void)showSignUp
{
    CSMPSignUpViewController *signUp=[[[CSMPSignUpViewController alloc] initWithNibName:@"CSMPSignUpViewController" bundle:nil] autorelease];
    UINavigationController *nav=[[[UINavigationController alloc] initWithRootViewController:signUp] autorelease];
    
    [self presentModalViewController:nav animated:YES];
}

-(void)updateForLoggedInUser
{
    self.navigationItem.leftBarButtonItem=[[[UIBarButtonItem alloc] initWithTitle:@"Log Out" style:UIBarButtonItemStyleBordered target:self action:@selector(logOutUser:)] autorelease];
    
    [lists removeAllObjects];
    
    MKitModelQuery *q=[CSMPTodoList graphQuery];
    [q key:@"owner" condition:KeyEquals value:[CSMPUser currentUser]];
    [q orderBy:@"createdAt" direction:orderASC];
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    [lists addObjectsFromArray:results];
    [self.tableView reloadData];
    
    q=[CSMPTodoList query];
    [q key:@"owner" condition:KeyEquals value:[CSMPUser currentUser]];
    [q orderBy:@"createdAt" direction:orderASC];
    [q executeInBackground:^(NSArray *objects, NSInteger totalCount, NSError *error) {
        if (objects!=nil)
        {
            [lists removeAllObjects];
            [lists addObjectsFromArray:objects];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
            });
            
        }
    }];
}

-(void)logOutUser:(id)sender
{
    [[CSMPUser currentUser] logOut];
    [MKitModelGraph clearAllGraphs];
}

-(void)addToDoList:(id)sender
{
    CSMPNewToDoListViewController *ntd=[[[CSMPNewToDoListViewController alloc] initWithNibName:@"CSMPNewToDoListViewController" bundle:nil] autorelease];
    UINavigationController *nav=[[[UINavigationController alloc] initWithRootViewController:ntd] autorelease];
    
    [self presentModalViewController:nav animated:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return lists.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell)
        cell=[[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
              
    CSMPTodoList *list=[lists objectAtIndex:indexPath.row];
    cell.textLabel.text=list.name;
    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
    
    // Configure the cell...
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CSMPTodoListViewController *lv=[[[CSMPTodoListViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    lv.list=[lists objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:lv animated:YES];
}

#pragma mark - Notifications


-(void)userLoggedInNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissModalViewControllerAnimated:YES];
        [self updateForLoggedInUser];
    });
}

-(void)userLoggedOutNotification:(NSNotification *)notification
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.navigationItem.leftBarButtonItem=nil;
        [self showSignUp];
    });
}

@end
