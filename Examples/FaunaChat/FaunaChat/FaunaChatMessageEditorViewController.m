//
// FaunaChatMessageEditorViewController.m
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

#import "FaunaChatMessageEditorViewController.h"
#import <Fauna/Fauna.h>
#import "FaunaChatMessage.h"
#import "SVProgressHUD.h"

@interface FaunaChatMessageEditorViewController ()

- (void)loadMessageDetails;

- (void)showMessageDetails;

@property (nonatomic, strong) IBOutlet FaunaChatMessage *message;

@end

@implementation FaunaChatMessageEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Edit Message";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendAction:)];
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self loadMessageDetails];
}

- (void)loadMessageDetails {
  [SVProgressHUD showWithStatus:@"Loading"];

  [[FaunaChatMessage get:self.messageRef] onSuccess:^(FaunaChatMessage *message) {
    self.message = message;
    [SVProgressHUD showSuccessWithStatus:@"Done"];
    [self showMessageDetails];
  } onError:^(NSError *error) {
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

- (void)showMessageDetails {
  self.txtMessage.text = self.message.body;
}

- (void)cancelAction:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
  [SVProgressHUD showWithStatus:@"Saving"];
  self.message.body = self.txtMessage.text;

  [[self.message save] onSuccess:^(FaunaChatMessage *message) {
    self.message = message;
    [SVProgressHUD showSuccessWithStatus:@"Done"];
    [self.navigationController dismissModalViewControllerAnimated:YES];
  } onError:^(NSError *error) {
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

@end
