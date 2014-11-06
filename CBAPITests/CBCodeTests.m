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
    [CBCode executeFunction:@"test" withParams:@{@"name":@"michael"} withSuccessCallback:^(NSString * response) {
        NSDictionary *json = [self parseJsonString:response];
        XCTAssertTrue([[json valueForKey:@"results"] isEqualToString:@"michael"], @"code response should equal value passed in");
        [self signalAsyncComplete:MAIN_COMPLETION];
    }withErrorCallback:^(NSError *error){
        XCTFail(@"Error executing cloudcode: <%@>", error);
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

- (void)testCloudCodeSync {
    NSError *error;
    NSString *response = [CBCode executeFunction:@"test" withParams:@{@"name":@"michael"} withError:error];
    
    if (error) {
        XCTFail(@"Error executing cloudcode sync: <%@>", error);
    }
    
    NSDictionary *json = [self parseJsonString:response];
    XCTAssertTrue([[json valueForKey:@"results"] isEqualToString:@"michael"], @"code sync response should equal value passed in");
}

-(NSDictionary *)parseJsonString:(NSString*)jsonString
{
    NSError *jsonError;
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:&jsonError];
    if (jsonError) {
        XCTFail(@"Error parsing response JSON: <%@>", jsonError);
        return nil;
    }
    return json;
}


@end
