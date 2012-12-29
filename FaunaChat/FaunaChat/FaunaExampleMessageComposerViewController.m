//
//  FaunaExampleNewMessageViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleMessageComposerViewController.h"
#import <Fauna/FaunaInstance.h>
#import <Fauna/FaunaTimeline.h>

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
  FaunaInstance *instance = [[FaunaInstance alloc] init];
  instance.className = @"message";
  instance.data = @{@"body" : self.messageField.text};
  [instance save:^(FaunaResponse *response, NSError *error) {
    if(error) {
      NSLog(@"Instance save error: %@", error);
    } else {
      FaunaInstance * instance = (FaunaInstance*)response.resource;
      NSString * instanceReference = instance.reference;
      NSLog(@"Instance saved successfully: %@", instanceReference);
      [self.timeline add:instance callback:^(FaunaResponse *response, NSError *error) {
        if(error) {
          NSLog(@"Timeline add error: %@", error);
        } else {
          FaunaTimeline *timeline = (FaunaTimeline*)response.resource;
          NSLog(@"Added to timeline successfully: %@", timeline.reference);
          [self.navigationController dismissModalViewControllerAnimated:YES];
        }
      }];
    }
  }];
}

@end
