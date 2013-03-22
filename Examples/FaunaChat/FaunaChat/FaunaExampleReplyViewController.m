//
// FaunaExampleReplyViewController.m
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

#import "FaunaExampleReplyViewController.h"
#import "FaunaExampleMessageEditorViewController.h"

@implementation FaunaExampleReplyViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Reply";
  self.lblMessage.text = self.message.body;
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendAction:)];
}

- (void)cancelAction:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)editAction:(id)sender {
  FaunaExampleMessageEditorViewController *controller = [[FaunaExampleMessageEditorViewController alloc] initWithNibName:@"FaunaExampleMessageEditorViewController" bundle:nil];
  controller.messageRef = self.message.ref;
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)sendAction:(id)sender {
  //NSString * textMessage = self.txtMessage.text;

  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Cannot reply, yet"
                                                 delegate:nil
                                        cancelButtonTitle:@"OK"
                                        otherButtonTitles:nil, nil];
  [alert show];
}

@end
