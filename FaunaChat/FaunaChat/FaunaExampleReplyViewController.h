//
//  FaunaExampleMessageViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 1/11/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fauna/Fauna.h>

@interface FaunaExampleReplyViewController : UIViewController

@property (nonatomic, strong) IBOutlet UILabel * lblMessage;

@property (nonatomic, strong) IBOutlet UITextField * txtMessage;

@property (nonatomic, strong) IBOutlet FaunaInstance * message;

@property (nonatomic, strong) NSString* timelineResource;

- (IBAction)sendAction:(id)sender;

- (IBAction)editAction:(id)sender;

@end
