//
//  FaunaExampleRoomViewController.h
//  FaunaChat
//
//  Created by Johan Hernandez on 12/27/12.
//  Copyright (c) 2012 Fauna. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Fauna/FaunaTimeline.h>

@interface FaunaExampleRoomViewController : UITableViewController

@property (nonatomic, strong) FaunaTimeline* timeline;
@property (nonatomic, strong) FaunaResponse* currentTimelineResponse;
@property (nonatomic, strong) FaunaTimelinePage* currentPage;

- (void)reloadTimeline;

@end
