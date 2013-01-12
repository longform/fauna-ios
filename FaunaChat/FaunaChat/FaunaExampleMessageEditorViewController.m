//
//  FaunaExampleMessageEditorViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 1/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaExampleMessageEditorViewController.h"
#import <Fauna/Fauna.h>

@implementation FaunaExampleMessageEditorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    self.title = @"Edit Message";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(sendAction:)];
    
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.txtMessage.text = [self.message valueForKeyPath:@"data.body"];
}

- (IBAction)sendAction:(id)sender {
  NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary: self.message[@"data"]];
  data[@"body"] = self.txtMessage.text;
  NSString *ref = self.message[@"ref"];
  NSDictionary *modifications = @{
  @"data": data
  };
  [Fauna.current.instances update:ref changes:modifications callback:^(FaunaResponse *response, NSError *error) {
    if(error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      NSLog(@"Instance updated successfully: %@", response.resource);
      NSDictionary *instance = response.resource;
      [self.navigationController dismissModalViewControllerAnimated:YES];
    }
  }];}

@end
