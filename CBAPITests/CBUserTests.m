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

-(void)testAuthentication {
    NSError * error;
    [[[[ClearBlade initSettingsWithBuilder] withAppKey:APP_KEY withAppSecret:APP_SECRET]
      withLoggingLevel:TEST_LOGGING_LEVEL]
     runSyncWithError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}

@end
