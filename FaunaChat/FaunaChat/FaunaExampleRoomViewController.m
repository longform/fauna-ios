//
// FaunaExampleRoomViewController.m
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

#import "FaunaExampleRoomViewController.h"
#import "FaunaExampleMessageComposerViewController.h"
#import "FaunaExampleReplyViewController.h"
#import "SVProgressHUD.h"

#define kEventsPageSize 30

@implementation FaunaExampleRoomViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.eventSet = FaunaChatMessage.all;
  self.title = @"Room";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarStyleBlackTranslucent target:self action:@selector(postAction:)];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self reloadTimeline];
}

- (void)reloadTimeline {
  [SVProgressHUD showWithStatus:@"Loading"];

  [[[self.eventSet createsBefore:FNLast] flatMap:^(FNEventSetPage *page) {
    return page.resources;
  }] onSuccess:^(NSArray *messages) {
    _messages = [NSMutableArray arrayWithArray:messages];
    [self.tableView reloadData];
    [SVProgressHUD showSuccessWithStatus:@"Done"];
  } onError:^(NSError *error) {
    NSLog(@"Error retrieving timeline: %@", error);
    [SVProgressHUD showErrorWithStatus:@"Error"];
  }];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }

  cell.textLabel.text = ((FaunaChatMessage *)self.messages[indexPath.row]).body;
  
  return cell;
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 return YES;
 }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
   FaunaChatMessage *msg = self.messages[indexPath.row];

   [self.messages removeObject:msg];

   [[msg destroy] onError:^(NSError *error) {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     [alert show];
   }];
   
   [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
}
 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  FaunaChatMessage *message = self.messages[indexPath.row];

  FaunaExampleReplyViewController *detailViewController = [[FaunaExampleReplyViewController alloc] initWithNibName:@"FaunaExampleReplyViewController" bundle:nil];
  detailViewController.message = message;

  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
  [self presentModalViewController:navController animated:YES];
}

#pragma mark - Post

- (void)postAction:(id)sender {
  FaunaExampleMessageComposerViewController * controller = [[FaunaExampleMessageComposerViewController alloc] initWithNibName:@"FaunaExampleMessageComposerViewController" bundle:nil];
  controller.eventSet = self.eventSet;
  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
  [self presentModalViewController:navController animated:YES];
}

@end
