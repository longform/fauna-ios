//
//  FaunaExampleChangePasswordViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 1/16/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fauna/Fauna.h>

@interface FaunaExampleChangePasswordViewController : UIViewController<UIAlertViewDelegate>

@property (nonatomic, strong) IBOutlet UITextField *oldPasswordField;

@property (nonatomic, strong) IBOutlet UITextField *passwordField;

@property (nonatomic, strong) IBOutlet UITextField *confirmationField;

- (IBAction)changeAction:(id)sender;

@end
