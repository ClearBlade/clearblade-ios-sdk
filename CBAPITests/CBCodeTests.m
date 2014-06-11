//
//  CBCodeTests.m
//  CBAPI
//
//  Created by Michael on 6/11/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "CBAPI.h"

@interface CBCodeTests : AsyncTestCase

@end

@implementation CBCodeTests

- (void)setUp {
    [super setUp];
    NSError * error;
    [ClearBlade initSettingsSyncWithSystemKey:APP_KEY
                             withSystemSecret:APP_SECRET
                                  withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                                CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL)}
                                    withError:&error];
    if(error){
        XCTFail(@"Unexpected error <%@>", error);
    }
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCloudCode {
    CBCode *code = [[CBCode alloc] init];
    [code executeFunction:@"test" withParams:@{@"name":@"michael"} withSuccessCallback:^(NSString * response) {
        XCTAssertEqual(response, @"michael");
    }withErrorCallback:^(NSError *error){
        
    }];
}


@end
