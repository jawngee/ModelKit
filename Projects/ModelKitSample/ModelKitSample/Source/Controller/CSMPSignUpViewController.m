//
//  CSMPSignUpViewController.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPSignUpViewController.h"
#import "CSMPLoginViewController.h"

@interface CSMPSignUpViewController ()

@end

@implementation CSMPSignUpViewController

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
    
    self.title=@"Register";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [_emailTextField release];
    [_passwordTextField release];
    [super dealloc];
}
- (void)viewDidUnload {
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
}
- (IBAction)registerTouched:(id)sender
{
    if (self.emailTextField.text.length==0)
    {
        [AlertMonger showAlertWithTitle:@"Oops"
                                message:@"Please specify an email address."
                      cancelButtonTitle:@"Ok"
                   clickedButtonAtIndex:^(NSInteger buttonIndex) {
                       [self.emailTextField becomeFirstResponder];
                   }
                      otherButtonTitles:nil];
        return;
    }
    
    if (self.passwordTextField.text.length==0)
    {
        [AlertMonger showAlertWithTitle:@"Oops"
                                message:@"Please specify a password."
                      cancelButtonTitle:@"Ok"
                   clickedButtonAtIndex:^(NSInteger buttonIndex) {
                       [self.passwordTextField becomeFirstResponder];
                   }
                      otherButtonTitles:nil];
        return;
    }
    
    [CSMPUser signUpInBackgroundWithUserName:self.emailTextField.text
                                       email:self.emailTextField.text
                                    password:self.passwordTextField.text
                                 resultBlock:^(id object, NSError *error) {
                                     if (error)
                                         [AlertMonger showAlertWithTitle:@"Oops" message:[error localizedDescription] cancelButtonTitle:@"Ok"];
                                 }];
}

- (IBAction)loginTouched:(id)sender
{
    [self.navigationController pushViewController:[[[CSMPLoginViewController alloc] initWithNibName:@"CSMPLoginViewController" bundle:nil] autorelease] animated:YES];
}

@end
