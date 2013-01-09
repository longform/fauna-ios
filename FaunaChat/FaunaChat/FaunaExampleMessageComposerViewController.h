//
//  FaunaExampleNewMessageViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fauna/FaunaTimeline.h>

@interface FaunaExampleMessageComposerViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *messageField;

@property (nonatomic, strong) NSString* timelineResource;

@end
