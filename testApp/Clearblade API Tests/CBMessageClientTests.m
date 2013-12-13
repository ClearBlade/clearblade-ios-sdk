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
@property (weak, nonatomic) void (^connectHandler)();
@property (weak, nonatomic) void (^connectFailHandler)(CBMessageClientConnectStatus);
@property (weak, nonatomic) void (^disconnectHandler)();
@property (weak, nonatomic) CBMessageClient * client;
@end

typedef void (^BlockHandler)();
typedef void (^ConnectFailHandler)(CBMessageClientConnectStatus);
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

- (void)testConnectDisconnect
{
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
}

@end
