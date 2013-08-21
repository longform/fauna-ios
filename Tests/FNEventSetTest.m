//
// FNEventSetTest.m
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

#import <Fauna/FNContext.h>
#import "FNMessage.h"

@interface FNEventSetTest : GHAsyncTestCase {
  FNMessage *msg1;
  FNMessage *comment1;
  FNMessage *msg2;
  FNMessage *comment2;
}
@end

@implementation FNEventSetTest

- (void)setUpClass {
  [FNResource registerClass:[FNMessage class]];

  [TestPublisherContext() performInContext:^{
    msg1 = [FNMessage new];
    msg1.text = @"hey there";
    msg1 = [msg1 save].get;

    comment1 = [FNMessage new];
    comment1.text = @"why, hello!";
    comment1 = [comment1 save].get;

    [[msg1.comments add:comment1] get];

    msg2 = [FNMessage new];
    msg2.text = @"sup";
    msg2 = [msg2 save].get;

    comment2 = [FNMessage new];
    comment2.text = @"word";
    comment2 = [comment2 save].get;

    [[msg2.comments add:comment2] get];
  }];
}

- (void)testBasics {
  [TestPublisherContext() performInContext:^{
    FNEventSetPage *page = [msg1.comments pageBefore:FNLast].get;
    NSArray *events = page.events;
    FNEvent *event = events[0];
    FNFuture *resources = page.resources;

    [resources get];

    GHAssertTrue(events.count == 1, @"Should contain the event we created.");
    GHAssertTrue(((NSArray *)resources.value).count == events.count, @"resources should have the same count as events");
    GHAssertTrue(page.creates == 1, @"Should contain a create count.");
    GHAssertTrue(page.updates == 0, @"Should contain an update count.");
    GHAssertTrue(page.deletes == 0, @"Should contain a delete count.");
    GHAssertTrue([event.ref isEqualToString:comment1.ref], @"event's ref should point to the comment");
    GHAssertTrue([((FNMessage *)event.resource.get).text isEqual:comment1.text], @"resources are the same.");
  }];
}

- (void)testQueries {
  [TestPublisherContext() performInContext:^{
    FNQueryEventSet *set = FNUnion(msg1.comments, msg2.comments);
    NSString *query = [NSString stringWithFormat:@"union('%@','%@')", msg1.comments.ref, msg2.comments.ref];
    FNEventSetPage *creates = [set createsBefore:FNLast].get;

    GHAssertTrue(creates.events.count == 2, @"should contain the correct number of creates.");
    GHAssertEqualStrings(set.query, query, @"should have a correct query.");
  }];
}

- (void)testJoinStringGeneration {
  FNQueryEventSet *q = FNJoin(@"publisher/sets/foo", @"sets/bar", @"sets/baz");
  GHAssertEqualStrings(q.query, @"join('publisher/sets/foo','sets/bar','sets/baz')", @"queries");
  GHAssertEqualStrings(q.ref, @"queries?q=join('publisher/sets/foo','sets/bar','sets/baz')", @"ref");
}

- (void)testUnionStringGeneration {
  FNQueryEventSet *q = FNUnion(@"publisher/sets/foo", @"users/self/sets/bar");
  GHAssertEqualStrings(q.query, @"union('publisher/sets/foo','users/self/sets/bar')", @"queries");
  GHAssertEqualStrings(q.ref, @"queries?q=union('publisher/sets/foo','users/self/sets/bar')", @"ref");
}

- (void)testIntersectionStringGeneration {
  FNQueryEventSet *q = FNIntersection(@"publisher/sets/foo", @"users/self/sets/bar");
  GHAssertEqualStrings(q.query, @"intersection('publisher/sets/foo','users/self/sets/bar')", @"queries");
  GHAssertEqualStrings(q.ref, @"queries?q=intersection('publisher/sets/foo','users/self/sets/bar')", @"ref");
}

- (void)testDifferenceStringGeneration {
  FNQueryEventSet *q = FNDifference(@"publisher/sets/foo", @"users/self/sets/bar");
  GHAssertEqualStrings(q.query, @"difference('publisher/sets/foo','users/self/sets/bar')", @"queries");
  GHAssertEqualStrings(q.ref, @"queries?q=difference('publisher/sets/foo','users/self/sets/bar')", @"ref");
}

@end
