//
//  FaunaExampleRoomViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleRoomViewController.h"
#import "FaunaExampleMessageComposerViewController.h"

@interface FaunaExampleRoomViewController ()

@end

@implementation FaunaExampleRoomViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.timeline = [FaunaTimeline timelineForReference:@"classes/message/timelines/chat"];
  self.title = @"Room";
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Post" style:UIBarStyleBlackTranslucent target:self action:@selector(postAction:)];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
  [self reloadTimeline];
}

- (void)reloadTimeline {
  [self.timeline pageWithCount:10 callback:^(FaunaResponse *response, NSError *error) {
    if(error) {
      NSLog(@"Error retrieving timeline: %@", error);
    } else {
      self.currentTimelineResponse = response;
      self.currentPage = (FaunaTimelinePage*)response.resource;
      NSLog(@"Timeline page");
      [self.tableView reloadData];
    }
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
  return self.currentPage.events.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
  static NSString *CellIdentifier = @"Cell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
  }
  
  //HACK: These magic numbers and blind parsing are temporary, FaunaResponse should be smarter than this.
  // https://fauna.org/API#timelines
  NSArray* eventArray = self.currentPage.events[indexPath.row];
  NSString* ref = (NSString*)eventArray[2];
  FaunaResource* messageInstance = (FaunaInstance*)[self.currentTimelineResponse.references objectForKey:ref];
  NSDictionary* messageData = [messageInstance.resourceDictionary objectForKey:@"data"];
  NSString* messageBody = (NSString*)[messageData objectForKey:@"body"];
  cell.textLabel.text = messageBody;
  
  return cell;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
 {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 }
 else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
 {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
 {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
  // Navigation logic may go here. Create and push another view controller.
  /*
   <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
   // ...
   // Pass the selected object to the new view controller.
   [self.navigationController pushViewController:detailViewController animated:YES];
   */
}

#pragma mark - Post

- (void)postAction:(id)sender {
  FaunaExampleMessageComposerViewController * controller = [[FaunaExampleMessageComposerViewController alloc] initWithNibName:@"FaunaExampleNewMessageViewController" bundle:nil];
  controller.timeline = self.timeline;
  UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:controller];
  [self presentModalViewController:navController animated:YES];
}

@end
