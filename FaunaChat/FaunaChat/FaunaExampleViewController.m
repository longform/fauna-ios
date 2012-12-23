//
//  FaunaExampleViewController.m
//  FaunaChat
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import "FaunaExampleViewController.h"
#import "FaunaExampleSignupViewController.h"
#import "FaunaExampleLoginViewController.h"

@interface FaunaExampleViewController ()

@end

@implementation FaunaExampleViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)signupAction:(id)sender {
  FaunaExampleSignupViewController * controller = [[FaunaExampleSignupViewController alloc] initWithNibName:@"FaunaExampleSignupViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)loginAction:(id)sender {
  FaunaExampleLoginViewController * controller = [[FaunaExampleLoginViewController alloc] initWithNibName:@"FaunaExampleLoginViewController" bundle:nil];
  [self.navigationController pushViewController:controller animated:YES];
}


@end
