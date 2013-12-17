//
//  CBMessageClientTests.m
//  testApp
//
//  Created by Tyler Dodge on 12/13/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "CBAPI.h"

typedef void (^BlockHandler)();
typedef void (^ConnectFailHandler)(CBMessageClientConnectStatus);
typedef void (^SubscribeHandler)(NSString *);

@interface CBMessageClientTests : AsyncTestCase <CBMessageClientDelegate>
@property (weak, nonatomic) BlockHandler connectHandler;
@property (weak, nonatomic) ConnectFailHandler connectFailHandler;
@property (weak, nonatomic) BlockHandler disconnectHandler;
@property (weak, nonatomic) SubscribeHandler subscribeHandler;
@property (weak, nonatomic) SubscribeHandler unsubscribeHandler;
@property (weak, nonatomic) CBMessageClient * client;
@end


@implementation CBMessageClientTests

-(void)messageClientDidConnect:(CBMessageClient *)client {
    BlockHandler connectHandler = self.connectHandler;
    if (connectHandler) {
        connectHandler();
    }
}
-(void)messageClient:(CBMessageClient *)client didFailToConnect:(CBMessageClientConnectStatus)reason {
    ConnectFailHandler connectFailHandler = self.connectFailHandler;
    if (connectFailHandler) {
        connectFailHandler(reason);
    }
}
-(void)messageClient:(CBMessageClient *)client didSubscribe:(NSString *)topic {
    SubscribeHandler subscribeHandler = self.subscribeHandler;
    if (subscribeHandler) {
        subscribeHandler(topic);
    }
}
-(void)messageClient:(CBMessageClient *)client didUnsubscribe:(NSString *)topic {
    SubscribeHandler unsubscribeHandler = self.unsubscribeHandler;
    if (unsubscribeHandler) {
        unsubscribeHandler(topic);
    }
}

-(void)messageClientDidDisconnect:(CBMessageClient *)client {
    BlockHandler disconnectHandler = self.disconnectHandler;
    if (disconnectHandler) {
        self.disconnectHandler();
    }
}

- (void)setUp
{
    [super setUp];
    [ClearBlade initSettingsWithAppKey:APP_KEY withAppSecret:APP_SECRET];
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
    [self.client disconnect];
    self.client = nil;
}

-(CBMessageClient *)client {
    if (!_client) {
        _client = [CBMessageClient client];
        _client.delegate = self;
    }
    return _client;
}

- (void)testConnectDisconnect {
    BlockHandler connectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    BlockHandler disconnectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    ConnectFailHandler connectFailHandler = ^(CBMessageClientConnectStatus status) {
        XCTFail(@"Unexpected failure for message client with status %d", status);
    };
    self.connectFailHandler = connectFailHandler;
    self.connectHandler = connectHandler;
    self.disconnectHandler = disconnectHandler;
    
    [self.client connect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [self.client disconnect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

- (void)testSubscribeToChannel {
    BlockHandler connectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    BlockHandler disconnectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    SubscribeHandler subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:@"TEST SUBSCRIBE1"], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    ConnectFailHandler connectFailHandler = ^(CBMessageClientConnectStatus status) {
        XCTFail(@"Unexpected failure for message client with status %d", status);
    };
    self.connectFailHandler = connectFailHandler;
    self.connectHandler = connectHandler;
    self.disconnectHandler = disconnectHandler;
    self.subscribeHandler = subscribeHandler;
    [self.client connect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [self.client subscribeToTopic:@"TEST SUBSCRIBE1"];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:@"TEST SUBSCRIBE2"], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    self.subscribeHandler = subscribeHandler;
    [self.client subscribeToTopic:@"TEST SUBSCRIBE2"];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    XCTAssertTrue([self.client.topics containsObject:@"TEST SUBSCRIBE1"], @"Should contain TEST SUBSCRIBE1");
    XCTAssertTrue([self.client.topics containsObject:@"TEST SUBSCRIBE2"], @"Should contain TEST SUBSCRIBE2");
    
    SubscribeHandler unsubscribeHandler = ^(NSString *topic) {
        XCTAssertTrue([topic isEqualToString:@"TEST SUBSCRIBE1"], @"Should unsubscribe from 'TEST SUBSCRIBE1'");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    self.unsubscribeHandler = unsubscribeHandler;
    
    [self.client unsubscribeFromTopic:@"TEST SUBSCRIBE1"];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    XCTAssertTrue([self.client.topics containsObject:@"TEST SUBSCRIBE2"], @"Should still be subscribed to TEST SUBSCRIBE2");
    XCTAssertFalse([self.client.topics containsObject:@"TEST SUBSCRIBE1"], @"Should not be subscribed to TEST SUBSCRIBE1");
    
    [self.client disconnect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    XCTAssertTrue(self.client.topics.count == 0, @"Should not have any topics when disconnected");
}

@end
