//
// FaunaExampleSignupViewController.m
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

#import <Fauna/Fauna.h>
#import "FaunaChatUser.h"
#import "FaunaExampleSignupViewController.h"

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
  FaunaChatUser* user = [FaunaChatUser new];
  user.email = self.emailField.text;
  user.password = self.passwordField.text;
  user.name = self.nameField.text;

  [[user save] onSuccess:^(id value) {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                     message:[NSString stringWithFormat:@"Welcome to FaunaChat %@", user.name]
                                                    delegate:self
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
    [self.navigationController popViewControllerAnimated:YES];
  } onError:^(NSError *error) {
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                     message:[NSString stringWithFormat:@"Error: %@", error]
                                                    delegate:nil
                                           cancelButtonTitle:@"OK"
                                           otherButtonTitles:nil, nil];
    [alert show];
  }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
  
}

@end
