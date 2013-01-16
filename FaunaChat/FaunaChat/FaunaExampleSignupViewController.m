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
  NSDictionary * newUserInfo = @{
    @"email" : self.emailField.text,
    @"password" : self.passwordField.text,
    @"name" : self.nameField.text
  };
  
  [Fauna.client.users create:newUserInfo callback:^(FaunaResponse *response, NSError *error) {
    if(error) {
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      NSDictionary *userInfo = response.resource;
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Welcome to FaunaChat %@", userInfo[@"name"]] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    }
  }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
  
}

@end
