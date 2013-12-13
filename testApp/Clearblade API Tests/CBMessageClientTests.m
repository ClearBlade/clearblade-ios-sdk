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

@interface CBMessageClientTests : AsyncTestCase <CBMessageClientDelegate>
@property (strong, nonatomic) void (^connectHandler)();
@property (strong, nonatomic) void (^connectFailHandler)(CBMessageClientConnectStatus);
@property (strong, nonatomic) void (^disconnectHandler)();
@property (strong, nonatomic) CBMessageClient * client;
@end

@implementation CBMessageClientTests

-(void (^)())connectHandler {
    if (!_connectHandler) {
        _connectHandler = ^() {};
    }
    return _connectHandler;
}
-(void (^)())disconnectHandler {
    if (!_disconnectHandler) {
        _disconnectHandler = ^() {};
    }
    return _disconnectHandler;
}
-(void (^)(CBMessageClientConnectStatus))connectFailHandler {
    if (!_connectFailHandler) {
        _connectFailHandler = ^(CBMessageClientConnectStatus status) {};
    }
    return _connectFailHandler;
}
-(void)messageClientDidConnect:(CBMessageClient *)client {
    self.connectHandler();
}
-(void)messageClient:(CBMessageClient *)client didFailToConnect:(CBMessageClientConnectStatus)reason {
    self.connectFailHandler(reason);
}
-(void)messageClientDidDisconnect:(CBMessageClient *)client {
    self.disconnectHandler();
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
    self.connectFailHandler = nil;
    self.connectHandler = nil;
    self.disconnectHandler = nil;
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

- (void)testConnectDisconnect
{
    __weak AsyncTestCase * weakSelf = self;
    self.connectHandler = ^{
        [weakSelf signalAsyncComplete:MAIN_COMPLETION];
    };
    self.disconnectHandler = ^{
        [weakSelf signalAsyncComplete:MAIN_COMPLETION];
    };
    self.connectFailHandler = ^(CBMessageClientConnectStatus status) {
        XCTFail(@"Unexpected failure for message client with status %d", status);
    };
    [self.client connect];
    //[self waitForAsyncCompletion:MAIN_COMPLETION];
}

@end
