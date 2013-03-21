//
// FaunaExampleMessageComposerViewController.m
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

#import "FaunaExampleMessageComposerViewController.h"
#import <Fauna/Fauna.h>

@implementation FaunaExampleMessageComposerViewController

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
  NSString * message = self.messageField.text;
  [FaunaContext background:^id{
    NSError *error;
    FaunaInstance *instance = [[FaunaInstance alloc] init];
    instance.className = @"message";
    instance.data = @{
                      @"body" : message
                    };
    [FaunaInstance create:instance error:&error];
    if(error) {
      return error;
    }
    /*[FaunaTimeline addInstance:instance.reference toTimeline:self.timelineResource error:&error];
    if(error) {
      return error;
    }*/
    return nil;
  } success:^(id results) {
    NSLog(@"Added to timeline successfully");
    [self.navigationController dismissModalViewControllerAnimated:YES];
  } failure:^(NSError *error) {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

@end
