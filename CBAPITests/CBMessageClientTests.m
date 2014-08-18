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

#define TEST_TOPIC_ONE @"TEST_TOPIC_ONE"
#define TEST_TOPIC_TWO @"TEST_TOPIC_TWO"
#define TEST_PUBLISH_TOPIC_ONE @"TEST_PUB_ONE"
#define TEST_PUBLISH_TOPIC_TWO @"TEST_PUB_TWO"
#define TEST_MESSAGE_ONE @"Message 1"
#define TEST_MESSAGE_TWO @"Message 2"
#define TEST_MESSAGE_THREE @"Message 3"
#define RECEIVE_COMPLETION @"RECEIVE MESSAGE"

typedef void (^BlockHandler)();
typedef void (^ConnectFailHandler)(CBMessageClientConnectStatus);
typedef void (^SubscribeHandler)(NSString *);
typedef void (^MessageHandler)(CBMessageClient *, NSString *, CBMessage *);

@interface CBMessageClientTests : AsyncTestCase <CBMessageClientDelegate>
@property (weak, nonatomic) BlockHandler connectHandler;
@property (weak, nonatomic) ConnectFailHandler connectFailHandler;
@property (weak, nonatomic) BlockHandler disconnectHandler;
@property (weak, nonatomic) SubscribeHandler subscribeHandler;
@property (weak, nonatomic) SubscribeHandler unsubscribeHandler;
@property (weak, nonatomic) MessageHandler publishHandler;
@property (weak, nonatomic) MessageHandler receiveHandler;

@property (strong, nonatomic) CBMessageClient * client;
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

-(void)messageClient:(CBMessageClient *)client didPublishToTopic:(NSString *)topic withMessage:(CBMessage *)message {
    MessageHandler publishHandler = self.publishHandler;
    if (publishHandler) {
        publishHandler(client, topic, message);
    }
}
-(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message {
    MessageHandler receiveHandler = self.receiveHandler;
    if (receiveHandler) {
        receiveHandler(client, message.topic, message);
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
    NSError * error;
    [ClearBlade initSettingsSyncWithSystemKey:AUTH_APP_KEY
                             withSystemSecret:AUTH_APP_SECRET
                                  withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                                CBSettingsOptionMessagingAddress: MESSAGING_ADDRESS,
                                                CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL)}
                                    withError:&error];
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
        XCTAssertTrue([topic isEqualToString:TEST_TOPIC_ONE], @"Topic should be the expected topic");
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
    
    [self.client subscribeToTopic:TEST_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:TEST_TOPIC_TWO], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    self.subscribeHandler = subscribeHandler;
    [self.client subscribeToTopic:TEST_TOPIC_TWO];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    XCTAssertTrue([self.client.topics containsObject:TEST_TOPIC_ONE], @"Should contain TEST SUBSCRIBE1");
    XCTAssertTrue([self.client.topics containsObject:TEST_TOPIC_TWO], @"Should contain TEST SUBSCRIBE2");
    
    SubscribeHandler unsubscribeHandler = ^(NSString *topic) {
        XCTAssertTrue([topic isEqualToString:TEST_TOPIC_ONE], @"Should unsubscribe from 'TEST SUBSCRIBE1'");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    self.unsubscribeHandler = unsubscribeHandler;
    
    [self.client unsubscribeFromTopic:TEST_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    XCTAssertTrue([self.client.topics containsObject:TEST_TOPIC_TWO], @"Should still be subscribed to TEST SUBSCRIBE2");
    XCTAssertFalse([self.client.topics containsObject:TEST_TOPIC_ONE], @"Should not be subscribed to TEST SUBSCRIBE1");
    
    [self.client disconnect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    XCTAssertTrue(self.client.topics.count == 0, @"Should not have any topics when disconnected");
}

- (void)testReceiveMessage {
    
    BlockHandler connectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    BlockHandler disconnectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    SubscribeHandler subscribeHandler;
    MessageHandler receiveHandler;
    ConnectFailHandler connectFailHandler = ^(CBMessageClientConnectStatus status) {
        XCTFail(@"Unexpected failure for message client with status %d", status);
    };
    self.connectFailHandler = connectFailHandler;
    self.connectHandler = connectHandler;
    self.disconnectHandler = disconnectHandler;
    self.subscribeHandler = subscribeHandler;
    [self.client connect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:TEST_TOPIC_ONE], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    [self.client subscribeToTopic:TEST_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    CBMessageClient * publishClient = [CBMessageClient client];
    publishClient.delegate = self;
    [publishClient connect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    self.receiveHandler = receiveHandler = ^(CBMessageClient * client, NSString * topic, CBMessage * message) {
        XCTAssertTrue(client == self.client, @"Should be the client listening to the topic");
        XCTAssertTrue([message.topic isEqualToString:TEST_TOPIC_ONE], @"Should be the expected topic");
        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"Should be the expected message");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    [publishClient publishMessage:TEST_MESSAGE_ONE toTopic:TEST_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self.client disconnect];
    [publishClient disconnect];
}

- (void)testPublish {
    BlockHandler connectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    BlockHandler disconnectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    SubscribeHandler subscribeHandler;
    MessageHandler messageHandler;
    MessageHandler receiveHandler;
    ConnectFailHandler connectFailHandler = ^(CBMessageClientConnectStatus status) {
        XCTFail(@"Unexpected failure for message client with status %d", status);
    };
    self.connectFailHandler = connectFailHandler;
    self.connectHandler = connectHandler;
    self.disconnectHandler = disconnectHandler;
    self.subscribeHandler = subscribeHandler;
    [self.client connect];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_ONE], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    [self.client subscribeToTopic:TEST_PUBLISH_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_TWO], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    [self.client subscribeToTopic:TEST_PUBLISH_TOPIC_TWO];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    self.publishHandler = messageHandler = ^(CBMessageClient *client, NSString * topic, CBMessage * message) {
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_ONE] , @"Should be expected topic");
        XCTAssertTrue([message.topic isEqualToString:TEST_PUBLISH_TOPIC_ONE], @"should be expected topic");
        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"should be expected message");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    self.receiveHandler = receiveHandler = ^(CBMessageClient * client, NSString * topic, CBMessage * message) {
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_ONE] , @"Should be expected topic");
        XCTAssertTrue([message.topic isEqualToString:TEST_PUBLISH_TOPIC_ONE], @"should be expected topic");
        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"should be expected message");
        [self signalAsyncComplete:RECEIVE_COMPLETION];
    };
    [self.client publishMessage:TEST_MESSAGE_ONE toTopic:TEST_PUBLISH_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self waitForAsyncCompletion:RECEIVE_COMPLETION];
    [self.client disconnect];
}

-(void)testExactlyOnceQoS {
    BlockHandler connectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    BlockHandler disconnectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    SubscribeHandler subscribeHandler;
    MessageHandler receiveHandler = ^(CBMessageClient * client, NSString * topic, CBMessage *message){
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_ONE], @"Topic should be expected topic");
        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"Message should be expected message");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    ConnectFailHandler connectFailHandler = ^(CBMessageClientConnectStatus status) {
        XCTFail(@"Unexpected failure for message client with status %d", status);
    };
    self.connectFailHandler = connectFailHandler;
    self.connectHandler = connectHandler;
    self.disconnectHandler = disconnectHandler;
    self.subscribeHandler = subscribeHandler;
    self.receiveHandler = receiveHandler;
    [self.client connectWithQoS:CBMessageClientQualityExactlyOnce];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_ONE], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    [self.client subscribeToTopic:TEST_PUBLISH_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self.client publishMessage:TEST_MESSAGE_ONE toTopic:TEST_PUBLISH_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self.client disconnect];
}

-(void)testAtLeastOnceQoS {
    BlockHandler connectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    BlockHandler disconnectHandler = ^{
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    SubscribeHandler subscribeHandler;
    MessageHandler receiveHandler = ^(CBMessageClient * client, NSString * topic, CBMessage *message){
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_ONE], @"Topic should be expected topic");
        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"Message should be expected message");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    ConnectFailHandler connectFailHandler = ^(CBMessageClientConnectStatus status) {
        XCTFail(@"Unexpected failure for message client with status %d", status);
    };
    self.connectFailHandler = connectFailHandler;
    self.connectHandler = connectHandler;
    self.disconnectHandler = disconnectHandler;
    self.subscribeHandler = subscribeHandler;
    self.receiveHandler = receiveHandler;
    [self.client connectWithQoS:CBMessageClientQualityAtLeastOnce];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
        XCTAssertTrue([topic isEqualToString:TEST_PUBLISH_TOPIC_ONE], @"Topic should be the expected topic");
        [self signalAsyncComplete:MAIN_COMPLETION];
    };
    [self.client subscribeToTopic:TEST_PUBLISH_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self.client publishMessage:TEST_MESSAGE_ONE toTopic:TEST_PUBLISH_TOPIC_ONE];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self.client disconnect];
}

-(void)testMessageHistory {
    NSDate *testDate = [NSDate date];
    NSError *error;
    NSArray *history = [CBMessageClient getMessageHistoryOfTopic:TEST_TOPIC_ONE fromTime:testDate withCount:[NSNumber numberWithInt:10] withError:error];
    XCTAssertNotNil(history, @"history should not be nil for TEST_TOPIC_ONE");
}

// Pending more information from tdodge this test is marked as invalid
//-(void)testDoubleSubscribe {
//    BlockHandler connectHandler = ^{
//        [self signalAsyncComplete:MAIN_COMPLETION];
//    };
//    BlockHandler disconnectHandler = ^{
//        [self signalAsyncComplete:MAIN_COMPLETION];
//    };
//    SubscribeHandler subscribeHandler;
//    MessageHandler messageHandler;
//    MessageHandler receiveHandler;
//    ConnectFailHandler connectFailHandler = ^(CBMessageClientConnectStatus status) {
//        XCTFail(@"Unexpected failure for message client with status %d", status);
//    };
//    self.connectFailHandler = connectFailHandler;
//    self.connectHandler = connectHandler;
//    self.disconnectHandler = disconnectHandler;
//    self.subscribeHandler = subscribeHandler;
//    NSString * randomTopic = [NSString stringWithFormat:@"Test_%d", arc4random()];
//    NSString * randomTopic2 = [NSString stringWithFormat:@"Test2_%d", arc4random()];
//    [self.client connect];
//    [self waitForAsyncCompletion:MAIN_COMPLETION];
//    
//    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
//        XCTAssertTrue([topic isEqualToString:randomTopic], @"Topic should be the expected topic");
//        [self signalAsyncComplete:MAIN_COMPLETION];
//    };
//    [self.client subscribeToTopic:randomTopic];
//    [self waitForAsyncCompletion:MAIN_COMPLETION];
//    
//    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
//        XCTAssertTrue([topic isEqualToString:randomTopic2], @"Topic should be the expected topic");
//        [self signalAsyncComplete:MAIN_COMPLETION];
//    };
//    [self.client subscribeToTopic:randomTopic2];
//    [self waitForAsyncCompletion:MAIN_COMPLETION];
//    
//    self.publishHandler = messageHandler = ^(CBMessageClient *client, NSString * topic, CBMessage * message) {
//        XCTAssertTrue([topic isEqualToString:randomTopic] , @"Should be expected topic");
//        XCTAssertTrue([message.topic isEqualToString:randomTopic], @"should be expected topic");
//        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"should be expected message");
//        [self signalAsyncComplete:MAIN_COMPLETION];
//    };
//    self.receiveHandler = receiveHandler = ^(CBMessageClient * client, NSString * topic, CBMessage * message) {
//        XCTAssertTrue([topic isEqualToString:randomTopic] , @"Should be expected topic");
//        XCTAssertTrue([message.topic isEqualToString:randomTopic], @"should be expected topic");
//        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"should be expected message");
//        [self signalAsyncComplete:RECEIVE_COMPLETION];
//    };
//    [self.client publishMessage:TEST_MESSAGE_ONE toTopic:randomTopic];
//    [self waitForAsyncCompletion:MAIN_COMPLETION];
//    [self waitForAsyncCompletion:RECEIVE_COMPLETION];
//    [self.client disconnect];
//    
//    [self.client connect];
//    [self waitForAsyncCompletion:MAIN_COMPLETION];
//    self.subscribeHandler = subscribeHandler = ^(NSString * topic) {
//        XCTAssertTrue([topic isEqualToString:randomTopic], @"Topic should be the expected topic");
//        [self signalAsyncComplete:MAIN_COMPLETION];
//    };
//    [self.client subscribeToTopic:randomTopic];
//    [self waitForAsyncCompletion:MAIN_COMPLETION];
//    self.publishHandler = messageHandler = ^(CBMessageClient *client, NSString * topic, CBMessage * message) {
//        XCTAssertTrue([topic isEqualToString:randomTopic] , @"Should be expected topic");
//        XCTAssertTrue([message.topic isEqualToString:randomTopic], @"should be expected topic");
//        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"should be expected message");
//        [self signalAsyncComplete:MAIN_COMPLETION];
//    };
//    self.receiveHandler = receiveHandler = ^(CBMessageClient * client, NSString * topic, CBMessage * message) {
//        XCTAssertTrue([topic isEqualToString:randomTopic] , @"Should be expected topic");
//        XCTAssertTrue([message.topic isEqualToString:randomTopic], @"should be expected topic");
//        XCTAssertTrue([message.payloadText isEqualToString:TEST_MESSAGE_ONE], @"should be expected message");
//        [self signalAsyncComplete:RECEIVE_COMPLETION];
//    };
//    [self.client publishMessage:TEST_MESSAGE_ONE toTopic:randomTopic];
//    [self waitForAsyncCompletion:MAIN_COMPLETION];
//    [self waitForAsyncCompletion:RECEIVE_COMPLETION];
//    [self.client disconnect];
//}

@end
