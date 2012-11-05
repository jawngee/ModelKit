//
//  CSMPLoginViewController.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "CSMPLoginViewController.h"

@interface CSMPLoginViewController ()

@end

@implementation CSMPLoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title=@"Log In";
}

- (void)viewDidUnload
{
    [self setEmailTextField:nil];
    [self setPasswordTextField:nil];
    [super viewDidUnload];
}

- (void)dealloc
{
    [_emailTextField release];
    [_passwordTextField release];
    [super dealloc];
}

- (IBAction)loginTouched:(id)sender
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
    
    [CSMPUser logInInBackgroundWithUserName:self.emailTextField.text
                                   password:self.passwordTextField.text
                                resultBlock:^(id object, NSError *error) {
                                    if (error)
                                        [AlertMonger showAlertWithTitle:@"Oops" message:[error localizedDescription] cancelButtonTitle:@"Ok"];
                                }];
}

- (IBAction)forgotPasswordTouched:(id)sender
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
    
    [CSMPUser requestPasswordResetInBackgroundForEmail:self.emailTextField.text
                                           resultBlock:^(BOOL succeeded, NSError *error) {
                                               if (error)
                                                   [AlertMonger showAlertWithTitle:@"Oops" message:[error localizedDescription] cancelButtonTitle:@"Ok"];
                                               else
                                                   [AlertMonger showAlertWithTitle:@"Success" message:@"Password change email sent.  Please check your inbox." cancelButtonTitle:@"Ok"];
                                           }];
}

@end
