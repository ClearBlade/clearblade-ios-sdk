//
//  CBUserTests.m
//  CBAPI
//
//  Created by Tyler Dodge on 1/22/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "CBUser.h"


@interface CBUserTests : AsyncTestCase

@end

@implementation CBUserTests

-(void)testAnonAuthentication {
    NSError * error;
    [ClearBlade initSettingsSyncWithSystemKey:APP_KEY withSystemSecret:APP_SECRET
                                  withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                                CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                                                CBSettingsOptionAllowUnsignedCerts: @(YES)}
                                    withError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    CBUser * user = [ClearBlade settings].mainUser;
    
    XCTAssertTrue([user checkIsValidWithServerWithError:&error], @"Should be a valid user");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    
    XCTAssertTrue([user logOutWithError:&error], @"Should successfully log out");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}

-(void)testAnonAuthenticationAsync {
    [ClearBlade initSettingsWithSystemKey:APP_KEY
                         withSystemSecret:APP_SECRET
                              withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                            CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                                            CBSettingsOptionAllowUnsignedCerts: @(YES)}
                      withSuccessCallback:^(ClearBlade * cb) {
                          CBUser * user = cb.mainUser;
                          [user checkIsValidWithServerWithCallback:^(bool isValid) {
                              XCTAssertTrue(isValid, @"User should be valid");
                              [user logOutWithSuccessCallback:^() {
                                  [self signalAsyncComplete:MAIN_COMPLETION];
                              } withErrorCallback:^(NSError * error) {
                                  XCTFail(@"Unexpected error <%@>", error);
                                  [self signalAsyncComplete:MAIN_COMPLETION];
                              }];
                          } withErrorCallback:^(NSError * error) {
                              XCTFail(@"Unexpected error <%@>", error);
                              [self signalAsyncComplete:MAIN_COMPLETION];
                          }];
                      } withErrorCallback:^(NSError * error) {
                          XCTFail(@"Unexpected error <%@>", error);
                          [self signalAsyncComplete:MAIN_COMPLETION];
                      }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}
-(void)testRegisterAuthenticationAsync {
    NSString * uid = [[NSUUID UUID] UUIDString];
    [ClearBlade initSettingsWithSystemKey:AUTH_APP_KEY
                         withSystemSecret:AUTH_APP_SECRET
                              withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                            CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                                            CBSettingsOptionEmail: uid,
                                            CBSettingsOptionPassword: @"password",
                                            CBSettingsOptionRegisterUser: @(true),
                                            CBSettingsOptionAllowUnsignedCerts: @(YES)}
                      withSuccessCallback:^(ClearBlade * cb) {
                          CBUser * user = cb.mainUser;
                          [user checkIsValidWithServerWithCallback:^(bool isValid) {
                              XCTAssertTrue(isValid, @"User should be valid");
                              [user logOutWithSuccessCallback:^() {
                                  [self signalAsyncComplete:MAIN_COMPLETION];
                              } withErrorCallback:^(NSError * error) {
                                  XCTFail(@"Unexpected error <%@>", error);
                                  [self signalAsyncComplete:MAIN_COMPLETION];
                              }];
                          } withErrorCallback:^(NSError * error) {
                              XCTFail(@"Unexpected error <%@>", error);
                              [self signalAsyncComplete:MAIN_COMPLETION];
                          }];
                      } withErrorCallback:^(NSError * error) {
                          XCTFail(@"Unexpected error <%@>", error);
                          [self signalAsyncComplete:MAIN_COMPLETION];
                      }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

-(void)testRegisterAuthentication {
    NSError * error;
    NSString * uid = [[NSUUID UUID] UUIDString];
    [ClearBlade initSettingsSyncWithSystemKey:AUTH_APP_KEY withSystemSecret:AUTH_APP_SECRET
                                  withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                                CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                                                CBSettingsOptionEmail: uid,
                                                CBSettingsOptionPassword: @"password",
                                                CBSettingsOptionRegisterUser: @(true),
                                                CBSettingsOptionAllowUnsignedCerts: @(YES)}
                                    withError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    CBUser * user = [ClearBlade settings].mainUser;
    
    XCTAssertTrue([user checkIsValidWithServerWithError:&error], @"Should be a valid user");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    
    XCTAssertTrue([user logOutWithError:&error], @"Should successfully log out");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}


@end
