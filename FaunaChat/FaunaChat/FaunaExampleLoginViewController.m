//
//  FaunaExampleLoginViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/22/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleLoginViewController.h"
#import <Fauna/Fauna.h>

@implementation FaunaExampleLoginViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Sign In";
  self.emailField.text = @"test@example.com";
  self.passwordField.text = @"my_pass";
}

- (IBAction)loginAction:(id)sender {
  NSString* email = self.emailField.text;
  NSString* password = self.passwordField.text;
  [FaunaContext background:^id{
    NSError* error;
    if(![FaunaUser loginWithEmail:email password:password error:&error]) {
      return error;
    }
    return nil;
  } success:^(id results) {
    NSLog(@"Token: %@", FaunaContext.current.client.userToken);
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Welcome to FaunaChat!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
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
