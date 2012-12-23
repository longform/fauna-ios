//
//  FaunaExampleLoginViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 12/22/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaunaExampleLoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *emailField;

@property (nonatomic, strong) IBOutlet UITextField *passwordField;

- (IBAction)loginAction:(id)sender;

@end
