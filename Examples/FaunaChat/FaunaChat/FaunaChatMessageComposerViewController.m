//
// FaunaChatMessageComposerViewController.m
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

#import <Fauna/Fauna.h>
#import "FaunaChatMessage.h"
#import "FaunaChatMessageComposerViewController.h"

@implementation FaunaChatMessageComposerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"New Message";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendAction:)];
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  [self.messageField becomeFirstResponder];
}

- (void)cancelAction:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)sendAction:(id)sender {
  FaunaChatMessage *message = [FaunaChatMessage new];
  message.body = self.messageField.text;

  [[message save] onSuccess:^(FaunaChatMessage *msg) {
    [self.navigationController dismissModalViewControllerAnimated:YES];
  } onError:^(NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion]
                                                   delegate:nil
                                          cancelButtonTitle:@"OK"
                                          otherButtonTitles:nil, nil];
    [alert show];
  }];
}

@end
