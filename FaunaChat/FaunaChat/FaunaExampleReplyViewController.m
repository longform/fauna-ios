//
//  FaunaExampleMessageViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 1/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaExampleReplyViewController.h"
#import "FaunaExampleMessageEditorViewController.h"
#import <Fauna/Fauna.h>

@implementation FaunaExampleReplyViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.title = @"Reply";
  self.lblMessage.text = [self.message valueForKeyPath:@"data.body"];
  
  self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
  self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendAction:)];
}

- (void)cancelAction:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (void)editAction:(id)sender {
  FaunaExampleMessageEditorViewController *controller = [[FaunaExampleMessageEditorViewController alloc] initWithNibName:@"FaunaExampleMessageEditorViewController" bundle:nil];
  controller.messageRef = self.message[@"ref"];
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)sendAction:(id)sender {
  [Fauna.client.commands execute:@"reply_message" params:@{@"body": self.txtMessage.text} callback:^(FaunaResponse *response, NSError *error) {
    if(error) {
      NSLog(@"Command execute error: %@", error);
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      NSLog(@"Command executed successfully: %@", response.resource);
      [Fauna.client.timelines addInstance:response.resource[@"ref"] toTimeline:self.timelineResource callback:^(FaunaResponse *response, NSError *error) {
        if(error) {
          NSLog(@"Timeline add error: %@", error);
          UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
          [alert show];
        } else {
          NSLog(@"Added to timeline successfully: %@", response.resource[@"ref"]);
          [self.navigationController dismissModalViewControllerAnimated:YES];
        }
      }];
    }
  }];
}

@end
