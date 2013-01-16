//
//  FaunaExampleViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 12/12/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaunaExampleViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *btnChatRoom;

@property (nonatomic, strong) IBOutlet UIButton *btnChangePassword;

@property (nonatomic, strong) IBOutlet UIButton *btnLogout;

-(IBAction)signupAction:(id)sender;

-(IBAction)loginAction:(id)sender;

-(IBAction)chatRoomAction:(id)sender;

-(IBAction)changePasswordAction:(id)sender;

-(IBAction)logoutAction:(id)sender;

@end
