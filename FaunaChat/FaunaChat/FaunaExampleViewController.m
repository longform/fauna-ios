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

- (void)logoutAction:(id)sender {
  Fauna.current.userToken = nil;
  [self refreshUI];
}

- (void)refreshUI {
  BOOL userIsAuthenticated = !!Fauna.current.userToken;
  for (UIButton * view in @[self.btnChatRoom, self.btnChangePassword, self.btnLogout]) {
    view.enabled = userIsAuthenticated;
  }
}

@end
