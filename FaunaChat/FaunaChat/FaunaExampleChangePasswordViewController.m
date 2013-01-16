//
//  FaunaExampleChangePasswordViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 1/16/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
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
  [Fauna.current.users changePassword:self.oldPasswordField.text newPassword:self.passwordField.text confirmation:self.confirmationField.text callback:^(NSError *error) {
    if(error) {
      [SVProgressHUD dismiss];
      NSLog(@"Change Password error: %@", error);
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      [SVProgressHUD showSuccessWithStatus:@"Success"];
      NSLog(@"Change Password successfully");
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Password Changed!" message:@"Your password was changed! You may need to sign in again." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    }
  }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
