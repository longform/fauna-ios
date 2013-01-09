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
  NSDictionary *credentials = @{
    @"email": self.emailField.text,
    @"password": self.passwordField.text
  };
  [Fauna.current.tokens create:credentials block:^(FaunaResponse *response, NSError *error) {
    if(error) {
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      NSDictionary *tokenInfo = response.resource;
      NSString * token = tokenInfo[@"token"];
      
      // set the token in the fauna context
      Fauna.current.userToken = token;
      
      NSLog(@"Token: %@", token);
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"Welcome to FaunaChat!"] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    }
  }];
}

- (void)alertViewCancel:(UIAlertView *)alertView {
  
}


@end
