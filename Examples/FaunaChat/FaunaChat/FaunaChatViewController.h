//
// FaunaChatViewController.h
//
// Copyright (c) 2013 Fauna, Inc.
//
// Licensed under the Mozilla Public License, Version 2.0 (the "License"); you may
// not use this file except in compliance with the License. You may obtain a
// copy of the License at
//
// http://mozilla.org/MPL/2.0/
//
// Unless required by applicable law or agreed to in writing, software distributed
// under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
// CONDITIONS OF ANY KIND, either express or implied. See the License for the
// specific language governing permissions and limitations under the License.
//

#import <UIKit/UIKit.h>

@interface FaunaChatViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *btnChatRoom;

@property (nonatomic, strong) IBOutlet UIButton *btnChangePassword;

@property (nonatomic, strong) IBOutlet UIButton *btnLogout;

-(IBAction)signupAction:(id)sender;

-(IBAction)loginAction:(id)sender;

-(IBAction)chatRoomAction:(id)sender;

-(IBAction)changePasswordAction:(id)sender;

-(IBAction)logoutAction:(id)sender;

@end
