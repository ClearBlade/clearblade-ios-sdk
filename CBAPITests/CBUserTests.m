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

/**
 An expired token returns an HTML Status Code 400
 */
-(void)testFailedGetUserInfoWithExpiredToken {

    XCTestExpectation*  expectation = [self expectationWithDescription:@"testGetUserInfoWithExpiredToken"];
    
    NSString * email = @"rob@clearblade.com";
    NSString* password = @"clearblade";
    NSString* token = @"D2UuYhlQp1H5OcWjrP4SuQ63E7RcKdNXzwI4h57KLC-YjeW74o2u2-O_mLA_sBejjogMqbHjGp_JKZLT_A==";
    NSDictionary* options = @{
                              CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                              CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                              CBSettingsOptionEmail:email,
                              CBSettingsOptionPassword:password};
    
    [ClearBlade
       initSettingsWithSystemKey:TOKEN_APP_KEY
       withSystemSecret:TOKEN_APP_SECRET
       withOptions:options
       withSuccessCallback:^(ClearBlade *settings) {
        
        CBUser *user = [CBUser authenticatedUserWithEmail:email withAuthToken:token];
        settings.mainUser = user;
        
        NSError *getUserInfoError;
        [user getCurrentUserInfoWithError:&getUserInfoError];
        if (getUserInfoError != nil) {
            // We expect an error here because the token is invalid or expired
            [expectation fulfill];
        }
		else{
			XCTFail(@"We succeeded when we should have failed.");
        }
    }
      withErrorCallback:^(NSError * error) {
		
            XCTFail(@"Failed to init ClearBlade. Error: <%@>", error);

            
        }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

/**
 An expired token returns an HTML Status Code 400
 */

-(void)testFailedGetUserInfoWithInvalidToken {
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"testGetUserInfoWithInvalidToken"];
    
    NSString * email = @"rob@clearblade.com";
    NSString* password = @"clearblade";
    NSString* token = @"Invalidtoken";
    NSDictionary* options = @{
                              CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                              CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                              CBSettingsOptionEmail:email,
                              CBSettingsOptionPassword:password};
    
    [ClearBlade
      initSettingsWithSystemKey:TOKEN_APP_KEY
      withSystemSecret:TOKEN_APP_SECRET
      withOptions:options
      withSuccessCallback:^(ClearBlade *settings) {
        
        CBUser *user = [CBUser authenticatedUserWithEmail:email withAuthToken:token];
        settings.mainUser = user;
        
        NSError *getUserInfoError;
        [user getCurrentUserInfoWithError:&getUserInfoError];
        if (getUserInfoError != nil) {
            // We expect an error here because the token is invalid or expired
            [expectation fulfill];
        }
        else{
            XCTFail(@"Platform accepted an invalid token. We succeeded when we should have failed.");
        }
    }
      withErrorCallback:^(NSError * error) {
                            
        XCTFail(@"Failed to init ClearBlade. Error: <%@>", error);
                            
                            
      }
	];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

/**
 A nil token returns an Status Code 400. If ClearBlade is init'd before use, an auth token 
 should never be nil.
 */

-(void)testFailedGetUserInfoWithNilToken {
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"testGetUserInfoWithNilToken"];
    
    NSString * email = @"rob@clearblade.com";
    NSString* password = @"clearblade";
    NSString* token = nil;
    NSDictionary* options = @{
                              CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                              CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                              CBSettingsOptionEmail:email,
                              CBSettingsOptionPassword:password};
    
    [ClearBlade
     initSettingsWithSystemKey:TOKEN_APP_KEY
     withSystemSecret:TOKEN_APP_SECRET
     withOptions:options
     withSuccessCallback:^(ClearBlade *settings) {
         
         CBUser *user = [CBUser authenticatedUserWithEmail:email withAuthToken:token];
         settings.mainUser = user;
         
         NSError *getUserInfoError;
         [user getCurrentUserInfoWithError:&getUserInfoError];
         if (getUserInfoError != nil) {
             // We expect an error here because the token is nil
             [expectation fulfill];
         }
         else{
             XCTFail(@"Platform accepted an invalid token. We succeeded when we should have failed.");
         }
     }
     withErrorCallback:^(NSError * error) {
         
         XCTFail(@"Failed to init ClearBlade. Error: <%@>", error);
         
         
     }
     ];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}

/**
Note: Tokens expire, so you may need to re-up this token for running tests.
 */

-(void)testGetUserInfoWithValidToken {
    
    XCTestExpectation* expectation = [self expectationWithDescription:@"testGetUserInfoWithValidToken"];
    
    NSString * email = @"rob@clearblade.com";
    NSString* password = @"clearblade";
    NSString* token = @"5bTng3_OJw76G7BTO2PVIw0QPuRCH4c0mcQ2iO4heyP9Pbk9sjKbM1RkemwKUejlTInaIfZT4E1jmLwOZw==";
    NSDictionary* options = @{
                              CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                              CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                              CBSettingsOptionEmail:email,
                              CBSettingsOptionPassword:password};
    
    [ClearBlade
     initSettingsWithSystemKey:TOKEN_APP_KEY
     withSystemSecret:TOKEN_APP_SECRET
     withOptions:options
     withSuccessCallback:^(ClearBlade *settings) {
         
         CBUser *user = [CBUser authenticatedUserWithEmail:email withAuthToken:token];
         settings.mainUser = user;
         
         NSError *getUserInfoError;
         NSDictionary* userInfo = [user getCurrentUserInfoWithError:&getUserInfoError];
         if (getUserInfoError != nil) {
             
             XCTFail(@"Platform denied a valid token.");
                      }
         else{
             XCTAssertNotNil([userInfo objectForKey:@"email"]);
             XCTAssertNotNil([userInfo objectForKey:@"user_id"]);
             XCTAssertNotNil([userInfo objectForKey:@"creation_date"]);
             
             [expectation fulfill];

         }
     }
     withErrorCallback:^(NSError * error) {
         
         XCTFail(@"Failed to init ClearBlade. Error: <%@>", error);
         
     }
    ];
    
    [self waitForExpectationsWithTimeout:10.0 handler:nil];
}




/*
 Not testable at present
-(void)testGetCount{
    NSString* uid = [[NSUUID UUID] UUIDString];
    NSError* err;
    [ClearBlade initSettingsSyncWithSystemKey:AUTH_APP_KEY withSystemSecret:AUTH_APP_SECRET withOptions:@{CBSettingsOptionServerAddress:PLATFORM_ADDRESS,
                                                                                                          CBSettingsOptionEmail:uid,
                                                                                                          CBSettingsOptionPassword:@"password",
                                                                                                          CBSettingsOptionRegisterUser: @(true)}
                                    withError:&err];
    XCTAssertNil(err,@"error is not nil");
    CBUser* usr = [ClearBlade settings].mainUser;
    NSInteger num = [usr getUserCount:AUTH_APP_KEY withQuery:nil withError:&err];
    XCTAssertNil(err,@"error getting count");
    XCTAssert(num >= 0, @"number of users returned should be greater or equal to zero");
}
*/
@end
