//
//  FaunaExampleRoomViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleRoomViewController.h"
#import "FaunaExampleMessageComposerViewController.h"
#import "FaunaExampleReplyViewController.h"
#import "SVProgressHUD.h"

#define kEventsPageSize 30

@implementation FaunaExampleRoomViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.timelineResource = @"classes/message/creates";
  self.title = @"Room";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarStyleBlackTranslucent target:self action:@selector(postAction:)];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self reloadTimeline];
}

- (void)reloadTimeline {
  [SVProgressHUD showWithStatus:@"Loading"];
  [FaunaContext background:^id{
    NSError * __block error;
    FaunaTimelinePage * __block page = nil;
    [FaunaCache transient:^{
      page = [FaunaTimeline pageFromTimeline:self.timelineResource count:kEventsPageSize error:&error];
    }];
    // if there is an error in my background block
    if(error) {
      // ... then return error, failure callback will be executed.
      return error;
    }
    NSArray * incomingEvents = page.events;
    _messages = [[NSMutableArray alloc] initWithCapacity:incomingEvents.count];
    
    for (NSDictionary * event in incomingEvents) {
      NSString* instanceRef = (NSString*)event[@"resource"];
      NSError* error;
      FaunaResource *resource = [FaunaResource get:instanceRef error:&error];
      if(error) {
        return error;
      }
      if(resource) {
        [_messages addObject:resource];
      }
    }
    return nil;
  } success:^(id response) {
    /*
     SUCCESS
     */
    [self.tableView reloadData];
    [SVProgressHUD showSuccessWithStatus:@"Done"];

  } failure:^(NSError *error) {
    /*
     FAILURE
     */
    NSLog(@"Error retrieving timeline: %@", error);
    [SVProgressHUD showErrorWithStatus:@"Error"];
  }];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
  return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  FaunaInstance* messageInstance = self.messages[indexPath.row];
  NSDictionary* messageData = messageInstance.data;
  NSString* messageBody = messageData[@"body"];
  cell.textLabel.text = messageBody;
  
  return cell;
}

 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 return YES;
 }

 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
   FaunaResource *resource = self.messages[indexPath.row];
   NSString* instanceRef = resource.reference;
   [self.messages removeObject:resource];
   
   [FaunaContext background:^id{
     NSError *error;
     [FaunaTimeline removeInstance:instanceRef fromTimeline:self.timelineResource error:&error];
     if(error) {
       return error;
     }
     [FaunaInstance destroy:instanceRef error:&error];
     if(error) {
       return error;
     }
     return nil;
   } success:^(id results) {
     // nop
   } failure:^(NSError *error) {
     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
     [alert show];
   }];
   [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
}
 

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  FaunaInstance* messageInstance = self.messages[indexPath.row];
  
  FaunaExampleReplyViewController *detailViewController = [[FaunaExampleReplyViewController alloc] initWithNibName:@"FaunaExampleReplyViewController" bundle:nil];
  detailViewController.timelineResource = self.timelineResource;
  detailViewController.message = messageInstance;
  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:detailViewController];
  [self presentModalViewController:navController animated:YES];
}

#pragma mark - Post

- (void)postAction:(id)sender {
  FaunaExampleMessageComposerViewController * controller = [[FaunaExampleMessageComposerViewController alloc] initWithNibName:@"FaunaExampleMessageComposerViewController" bundle:nil];
  controller.timelineResource = self.timelineResource;
  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
  [self presentModalViewController:navController animated:YES];
}

@end
