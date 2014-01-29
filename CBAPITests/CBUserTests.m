//
//  CBUserTests.m
//  CBAPI
//
//  Created by Tyler Dodge on 1/22/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"

@interface CBUserTests : AsyncTestCase

@end

@implementation CBUserTests

-(void)testAnonAuthentication {
    NSError * error;
    [ClearBlade initSettingsSyncWithSystemKey:APP_KEY withSystemSecret:APP_SECRET
                                  withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                                CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL)}
                                    withError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}

-(void)testRegisterAuthentication {
    NSError * error;
    NSString * uid = [[NSUUID UUID] UUIDString];
    [ClearBlade initSettingsSyncWithSystemKey:APP_KEY withSystemSecret:APP_SECRET
                                  withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                                CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                                                CBSettingsOptionEmail: uid,
                                                CBSettingsOptionPassword: @"password",
                                                CBSettingsOptionRegisterUser: @(true)}
                                    withError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}

@end
