//
//  FaunaExampleSignupViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/20/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleSignupViewController.h"
#import <Fauna/FaunaUser.h>

@interface FaunaExampleSignupViewController ()

@end

@implementation FaunaExampleSignupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.emailField.text = @"test@example.com";
  self.passwordField.text = @"my_pass";
  self.nameField.text = @"tester";
  // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (IBAction)signupAction:(id)sender {
  FaunaUser * user = [[FaunaUser alloc] init];
  user.email = self.emailField.text;
  user.password = self.passwordField.text;
  user.name = self.nameField.text;
  [user save:^(FaunaResponse *response, NSError *error) {
    if(error) {
      NSLog(@"Error: %@", error);
    } else {
      FaunaUser *user = (FaunaUser*)response.resource;
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"HI %@", user.name] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    }
  }];
}

@end
