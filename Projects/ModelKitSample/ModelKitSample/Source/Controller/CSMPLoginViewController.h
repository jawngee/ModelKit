//
//  CSMPLoginViewController.h
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CSMPLoginViewController : UIViewController

@property (retain, nonatomic) IBOutlet UITextField *emailTextField;
@property (retain, nonatomic) IBOutlet UITextField *passwordTextField;

- (IBAction)loginTouched:(id)sender;
- (IBAction)forgotPasswordTouched:(id)sender;

@end
