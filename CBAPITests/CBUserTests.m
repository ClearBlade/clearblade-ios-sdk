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
    [[[[[ClearBlade initSettingsWithBuilder] withSystemKey:APP_KEY withSystemSecret:APP_SECRET]
      withServerAddress:PLATFORM_ADDRESS]
      withLoggingLevel:TEST_LOGGING_LEVEL]
     runSyncWithError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}

-(void)testRegisterAuthentication {
    NSError * error;
    NSString * uid = [[NSUUID UUID] UUIDString];
    [[[[[[[ClearBlade initSettingsWithBuilder] withSystemKey:APP_KEY withSystemSecret:APP_SECRET]
      withServerAddress:PLATFORM_ADDRESS]
      authenticateUserWithEmail:uid withPassword:@"password"]
     registerUser]
      withLoggingLevel:TEST_LOGGING_LEVEL]
     runSyncWithError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}

@end
