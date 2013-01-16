//
//  FaunaExampleViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleViewController.h"
#import "FaunaExampleSignupViewController.h"
#import "FaunaExampleLoginViewController.h"
#import "FaunaExampleRoomViewController.h"
#import "FaunaExampleChangePasswordViewController.h"

@interface FaunaExampleViewController ()

@end

@implementation FaunaExampleViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"FaunaChat";
}

- (IBAction)signupAction:(id)sender {
  FaunaExampleSignupViewController * controller = [[FaunaExampleSignupViewController alloc] initWithNibName:@"FaunaExampleSignupViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)loginAction:(id)sender {
  FaunaExampleLoginViewController * controller = [[FaunaExampleLoginViewController alloc] initWithNibName:@"FaunaExampleLoginViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)chatRoomAction:(id)sender {
  FaunaExampleRoomViewController * controller = [[FaunaExampleRoomViewController alloc] initWithNibName:@"FaunaExampleRoomViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

-(IBAction)changePasswordAction:(id)sender {
  FaunaExampleChangePasswordViewController * controller = [[FaunaExampleChangePasswordViewController alloc] initWithNibName:@"FaunaExampleChangePasswordViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

@end
