//
//  FaunaExampleNewMessageViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
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
  NSDictionary *newInstance = @{
    @"class" : @"message",
    @"data": @{
      @"body" : self.messageField.text
    }
  };
  [Fauna.client createInstance:newInstance callback:^(FaunaResponse *response, NSError *error) {
    if(error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      NSLog(@"Instance saved successfully: %@", response.resource);
      NSDictionary *instance = response.resource;
      [Fauna.client addInstance:instance[@"ref"] toTimeline:self.timelineResource callback:^(FaunaResponse *response, NSError *error) {
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
