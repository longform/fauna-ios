//
//  FaunaExampleNewMessageViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleNewMessageViewController.h"
#import <Fauna/FaunaInstance.h>

@implementation FaunaExampleNewMessageViewController

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
  // TODO: Send Message
  FaunaInstance *instance = [[FaunaInstance alloc] init];
  instance.className = @"message";
  instance.data = @{@"body" : self.messageField.text};
  [instance save:^(FaunaResponse *response, NSError *error) {
    if(error) {
      NSLog(@"Instance save error: %@", error);
    } else {
      NSLog(@"Instance saved successfully");
      [self.navigationController dismissModalViewControllerAnimated:YES];
    }
  }];
}

@end
