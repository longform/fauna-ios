//
//  FaunaExampleSignupViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleSignupViewController.h"
#import <Fauna/Fauna.h>

@implementation FaunaExampleSignupViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Sign Up";
  self.emailField.text = @"test@example.com";
  self.passwordField.text = @"my_pass";
  self.nameField.text = @"tester";
}

- (IBAction)signupAction:(id)sender {
  
  // prepare user info data
  FaunaUser* user = [[FaunaUser alloc] init];
  user.email = self.emailField.text;
  user.password = self.passwordField.text;
  user.name = self.nameField.text;
  
  [FaunaContext background:^id{
    NSError *error;
    if(![FaunaUser create:user error:&error]) {
      return error;
    }
    return nil;
  } success:^(id results) {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Welcome to FaunaChat %@", user.name] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
  } failure:^(NSError *error) {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
  
}

@end
