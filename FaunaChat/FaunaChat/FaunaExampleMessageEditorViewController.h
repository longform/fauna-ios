//
//  FaunaExampleMessageEditorViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 1/12/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FaunaExampleMessageEditorViewController : UIViewController

@property (nonatomic, strong) IBOutlet UITextField * txtMessage;

@property (nonatomic, strong) IBOutlet NSString * messageRef;

@property (nonatomic, strong) NSString* timelineResource;

- (IBAction)sendAction:(id)sender;

@end
