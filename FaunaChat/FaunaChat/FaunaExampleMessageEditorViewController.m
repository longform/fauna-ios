//
//  FaunaExampleMessageEditorViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 1/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import "FaunaExampleMessageEditorViewController.h"
#import <Fauna/Fauna.h>
#import "SVProgressHUD.h"

@interface FaunaExampleMessageEditorViewController ()

- (void)loadMessageDetails;

- (void)showMessageDetails;

@property (nonatomic, strong) IBOutlet NSDictionary * message;

@end

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
  [self loadMessageDetails];
}

- (void)loadMessageDetails {
  [SVProgressHUD showWithStatus:@"Loading"];
  [Fauna.client.instances details:self.messageRef callback:^(FaunaResponse *response, NSError *error) {
    if(error) {
      [SVProgressHUD dismiss];
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      NSLog(@"Instance details retrieved successfully: %@", response.resource);
      self.message = response.resource;
      [self showMessageDetails];
      [SVProgressHUD showSuccessWithStatus:@"Done"];
    }
  }];
}

- (void)showMessageDetails {
  self.txtMessage.text = [self.message valueForKeyPath:@"data.body"];
}

- (void)cancelAction:(id)sender {
  [self.navigationController dismissModalViewControllerAnimated:YES];
}

- (IBAction)sendAction:(id)sender {
  NSMutableDictionary * data = [NSMutableDictionary dictionaryWithDictionary: self.message[@"data"]];
  data[@"body"] = self.txtMessage.text;
  NSString *ref = self.message[@"ref"];
  NSDictionary *modifications = @{
  @"data": data
  };
  [Fauna.client.instances update:ref changes:modifications callback:^(FaunaResponse *response, NSError *error) {
    if(error) {
      UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:[NSString stringWithFormat:@"Error: %@", error.localizedRecoverySuggestion] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    } else {
      NSLog(@"Instance updated successfully: %@", response.resource);
      [self.navigationController dismissModalViewControllerAnimated:YES];
    }
  }];
}

@end
