//
// FaunaExampleChangePasswordViewController.m
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

#import "FaunaExampleChangePasswordViewController.h"
#import "SVProgressHUD.h"

@implementation FaunaExampleChangePasswordViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Change Password";
  [self.oldPasswordField becomeFirstResponder];
}

- (void)changeAction:(id)sender {
  [SVProgressHUD showWithStatus:@"Processing"];
  NSString* oldPassword = self.oldPasswordField.text;
  NSString* newPassword = self.passwordField.text;
  NSString* confirmationPassword = self.confirmationField.text;
  [FaunaContext background:^id{
    NSError*error;
    if(![FaunaUser changePassword:oldPassword newPassword:newPassword confirmation:confirmationPassword error:&error]) {
      return error;
    }
    return nil;
  } success:^(id results) {
    [SVProgressHUD showSuccessWithStatus:@"Success"];
    NSLog(@"Change Password successfully");
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Changed!" message:@"Your password was changed! You may need to sign in again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  } failure:^(NSError *error) {
    [SVProgressHUD dismiss];
    NSLog(@"Change Password error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
