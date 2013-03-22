//
// FaunaExampleReplyViewController.h
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
#import <Fauna/Fauna.h>
#import "FaunaChatMessage.h"

@interface FaunaExampleReplyViewController : UIViewController

@property IBOutlet UILabel *lblMessage;

@property IBOutlet UITextField *txtMessage;

@property IBOutlet FaunaChatMessage *message;

- (IBAction)sendAction:(id)sender;

- (IBAction)editAction:(id)sender;

@end
