//
//  FNEventSetTest.m
//  Fauna
//
//  Created by Matt Freels on 3/19/13.
//  Copyright (c) 2013 Fauna. All rights reserved.
//

#import <Fauna/FNContext.h>
#import "FNMessage.h"

@interface FNEventSetTest : GHAsyncTestCase { }

@end

@implementation FNEventSetTest

- (void)testPage {
  [FNResource registerClass:[FNMessage class]];

  [TestPublisherContext() performInContext:^{
    FNMessage *msg = [FNMessage new];
    msg.text = @"hey there";
    msg = [msg save].get;

    FNMessage *comment = [FNMessage new];
    comment.text = @"why, hello!";
    comment = [comment save].get;

    [[msg.comments add:comment] get];

    FNEventSetPage *page = [msg.comments pageBefore:FNLast].get;
    NSArray *events = page.events;
    FNEvent *event = events[0];
    FNFuture *resources = page.resources;

    [resources get];

    GHAssertTrue(events.count == 1, @"Should contain the event we created.");
    GHAssertTrue(((NSArray *)resources.value).count == events.count, @"resources should have the same count as events");
    GHAssertTrue(page.creates == 1, @"Should contain a create count.");
    GHAssertTrue(page.updates == 0, @"Should contain an update count.");
    GHAssertTrue(page.deletes == 0, @"Should contain a delete count.");
    GHAssertTrue([event.ref isEqualToString:comment.ref], @"event's ref should point to the comment");
    GHAssertTrue([((FNMessage *)event.resource.get).text isEqual:comment.text], @"resources are the same.");
  }];
}



@end
