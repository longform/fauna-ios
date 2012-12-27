//
//  FaunaExampleLoginViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/22/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleLoginViewController.h"
#import <Fauna/FaunaUser.h>
#import <Fauna/FaunaUserToken.h>

@interface FaunaExampleLoginViewController ()

@end

@implementation FaunaExampleLoginViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (IBAction)loginAction:(id)sender {
  NSString * email = self.emailField.text;
  NSString * password = self.passwordField.text;
  [FaunaToken tokenWithEmail:email password:password block:^(FaunaResponse *response, NSError *error) {
    if(error) {
      NSLog(@"Error: %@", error);
    } else {
      FaunaToken *token = (FaunaToken*)response.resource;
      UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Success" message:[NSString stringWithFormat:@"HI %@", token.token] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
      [alert show];
    }
  }];
}

@end
