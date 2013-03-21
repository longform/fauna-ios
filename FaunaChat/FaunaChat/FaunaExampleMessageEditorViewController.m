//
// FaunaExampleMessageEditorViewController.m
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

#import "FaunaExampleMessageEditorViewController.h"
#import <Fauna/Fauna.h>
#import "SVProgressHUD.h"

@interface FaunaExampleMessageEditorViewController ()

- (void)loadMessageDetails;

- (void)showMessageDetails;

@property (nonatomic, strong) IBOutlet FaunaInstance * message;

@end

@implementation FaunaExampleMessageEditorViewController

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
  [FaunaContext background:^id{
    NSError*error;
    FaunaInstance *instance = [FaunaInstance get:self.messageRef error:&error];
    if(error) {
      return error;
    }
    return instance;
  } success:^(FaunaInstance* message) {
    self.message = message;
    NSLog(@"Instance details retrieved successfully: %@", self.message);
    [SVProgressHUD showSuccessWithStatus:@"Done"];
    [self showMessageDetails];
  } failure:^(NSError *error) {
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

- (void)showMessageDetails {
  self.txtMessage.text = self.message.data[@"body"];
}

- (void)cancelAction:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
  [SVProgressHUD showWithStatus:@"Saving"];
  NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithDictionary:self.message.data];
  data[@"body"] = self.txtMessage.text;
  NSDictionary *modifications = @{
    @"data": data
  };
  [FaunaContext background:^id{
    NSError*error;
    FaunaInstance *updatedInstance = [FaunaInstance update:self.message.reference changes:modifications error:&error];
    if(error) {
      return error;
    }
    return updatedInstance;
  } success:^(FaunaInstance* updatedInstance) {
    [SVProgressHUD showSuccessWithStatus:@"Done"];
    NSLog(@"Instance updated successfully: %@", updatedInstance.reference);
    [self.navigationController dismissModalViewControllerAnimated:YES];
  } failure:^(NSError *error) {
    [SVProgressHUD dismiss];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

@end
