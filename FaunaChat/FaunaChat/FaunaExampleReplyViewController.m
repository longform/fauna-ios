//
//  FaunaExampleMessageViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 1/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaExampleReplyViewController.h"
#import "FaunaExampleMessageEditorViewController.h"

@implementation FaunaExampleReplyViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Reply";
  self.lblMessage.text = self.message.data[@"body"];
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendAction:)];
}

- (void)cancelAction:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)editAction:(id)sender {
  FaunaExampleMessageEditorViewController *controller = [[FaunaExampleMessageEditorViewController alloc] initWithNibName:@"FaunaExampleMessageEditorViewController" bundle:nil];
  controller.messageRef = self.message.reference;
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)sendAction:(id)sender {
  NSString * textMessage = self.txtMessage.text;
  [FaunaContext background:^id{
    NSError *error;
    FaunaResource* messageResource = [FaunaCommand execute:@"reply_message" params:@{@"body": textMessage} error:&error];
    if(error) {
      return error;
    }
    NSLog(@"Command executed successfully: %@", messageResource.reference);
    [FaunaTimeline addInstance:messageResource.reference toTimeline:self.timelineResource error:&error];
    if(error) {
      return error;
    }
    NSLog(@"Added to timeline successfully");
    return nil;
  } success:^(id results) {
    [self.navigationController dismissModalViewControllerAnimated:YES];
  } failure:^(NSError *error) {
    NSLog(@"Command execute error: %@", error);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
    [alert show];
  }];
}

@end
