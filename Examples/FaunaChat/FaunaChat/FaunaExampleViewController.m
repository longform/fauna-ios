//
// FaunaExampleViewController.m
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

#import "FaunaChatClientKey.h"
#import "FaunaExampleViewController.h"
#import "FaunaExampleSignupViewController.h"
#import "FaunaExampleLoginViewController.h"
#import "FaunaExampleRoomViewController.h"
#import "FaunaExampleChangePasswordViewController.h"

@interface FaunaExampleViewController ()

- (void)refreshUI;

@end

@implementation FaunaExampleViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"FaunaChat";
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self refreshUI];
}

- (IBAction)signupAction:(id)sender {
  FaunaExampleSignupViewController *controller = [[FaunaExampleSignupViewController alloc] initWithNibName:@"FaunaExampleSignupViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)loginAction:(id)sender {
  FaunaExampleLoginViewController *controller = [[FaunaExampleLoginViewController alloc] initWithNibName:@"FaunaExampleLoginViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)chatRoomAction:(id)sender {
  FaunaExampleRoomViewController *controller = [[FaunaExampleRoomViewController alloc] initWithNibName:@"FaunaExampleRoomViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)changePasswordAction:(id)sender {
  FaunaExampleChangePasswordViewController *controller = [[FaunaExampleChangePasswordViewController alloc] initWithNibName:@"FaunaExampleChangePasswordViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

- (void)logoutAction:(id)sender {
  FNContext.defaultContext = FaunaChatClientKeyContext();
  [self refreshUI];
}

- (void)refreshUI {
  BOOL userIsAuthenticated = FNContext.defaultContext != FaunaChatClientKeyContext();
  for (UIButton *view in @[self.btnChatRoom, self.btnChangePassword, self.btnLogout]) {
    view.enabled = userIsAuthenticated;
  }
}

@end
