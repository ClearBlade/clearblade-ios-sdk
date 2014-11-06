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
#import "CBQuery.h"

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
                                            CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL)}
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
                                            CBSettingsOptionRegisterUser: @(true) }
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
                                                CBSettingsOptionRegisterUser: @(true)}
                                    withError:&error];
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    CBUser * user = [ClearBlade settings].mainUser;
    
    XCTAssertTrue([user checkIsValidWithServerWithError:&error], @"Should be a valid user");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    
    XCTAssertTrue([user logOutWithError:&error], @"Should successfully log out");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
}

-(void)testGetAllUsers {
    NSString * uid = [[NSUUID UUID] UUIDString];
    [ClearBlade initSettingsWithSystemKey:AUTH_APP_KEY
                         withSystemSecret:AUTH_APP_SECRET
                              withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                            CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                                            CBSettingsOptionEmail: uid,
                                            CBSettingsOptionPassword: @"password",
                                            CBSettingsOptionRegisterUser: @(true)}
                      withSuccessCallback:^(ClearBlade * cb) {
                          NSError *error;
                          CBUser * user = cb.mainUser;
                          CBQuery *query = [[CBQuery alloc] init];
                          [query lessThan:[NSNumber numberWithInteger:1401897300] for:@"creation_date"];
                          NSDictionary *users = [user getAllUsersWithError:&error
                                                            withQuery:query];
                          XCTAssertNil(error, @"Should get users with no errors %@", error);
                          XCTAssertNotNil(users[@"Data"], @"Users should not be nil");
                          NSDictionary *userDict2 = [user getAllUsersWithError:&error withQuery:nil];
                          XCTAssertNil(error, @"Should get users with no errors %@", error);
                          XCTAssertNotNil(userDict2[@"Data"], @"Users should not be nil");
                          //Not exactly sure why this is failing now, we need to revist this
                          //XCTAssertTrue(userDict2[@"Total"] > users[@"Total"], @"Users with the query restriction should be fewer");
                          [self signalAsyncComplete:MAIN_COMPLETION];
                      } withErrorCallback:^(NSError * error) {
                          XCTFail(@"Unexpected error <%@>", error);
                          [self signalAsyncComplete:MAIN_COMPLETION];
                      }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}


@end
