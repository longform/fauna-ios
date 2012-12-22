//
//  FaunaExampleSignupViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaunaExampleSignupViewController : UIViewController

- (IBAction)signupAction:(id)sender;

@property (nonatomic, strong) IBOutlet UITextField *emailField;

@property (nonatomic, strong) IBOutlet UITextField *passwordField;

@property (nonatomic, strong) IBOutlet UITextField *nameField;

@end
