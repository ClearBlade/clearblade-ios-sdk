//
//  CBQueryTests.m
//  testApp
//
//  Created by Tyler Dodge on 11/11/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "TestCBItem.h"
#import "CBAPI.h"
#define STRING_COLUMN @"StringColumn"
#define MAIN_COMPLETION @"main"
//#define PROD
#ifdef PROD
#define APP_KEY @"eafb90aa0af4c396d4e9fbbbd24d"
#define APP_SECRET @"EAFB90AA0AB4AACFE9C2BBF7A7EE01"
#define TEST_COLLECTION @"5281350e8ab3a3224cac7d4d"
#define PLATFORM_ADDRESS @"https://platform.clearblade.com/api"
#else
#define APP_KEY @"eafb90aa0af4c396d4e9fbbbd24d"
#define APP_SECRET @"EAFB90AA0AB4AACFE9C2BBF7A7EE01"
#define TEST_COLLECTION @"f48591aa0ad0d9c0b3dac8f5a9a501"
#define PLATFORM_ADDRESS @"https://platform.clearblade.com/api"
#endif

@interface CBQueryTests : AsyncTestCase
@property (strong, nonatomic) CBQuery * defaultQuery;

@end

@implementation CBQueryTests

- (void)setUp {
    [super setUp];
    [ClearBlade initSettingsWithAppKey:APP_KEY withAppSecret:APP_SECRET withServerAddress:PLATFORM_ADDRESS];
    self.defaultQuery = [CBQuery queryWithCollectionID:TEST_COLLECTION];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testSingleArgumentFetch {
    TestCBItem * item = [TestCBItem itemWithStringColumn:@"TEST"
                                           withIntColumn:5];
    item.collectionID = TEST_COLLECTION;
    [[[CBQuery queryWithCollectionID:item.collectionID] equalTo:@(5) for:item.intColumnName] removeWithSuccessCallback:^(NSArray * items) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [item saveWithSuccessCallback:^(CBItem *item) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(CBItem *item, NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [self.defaultQuery equalTo:@"TEST" for:STRING_COLUMN];
    
    [self.defaultQuery fetchWithSuccessCallback:^(NSMutableArray * array) {
        XCTAssertTrue([array count] == 1, @"Should be single response to equal to Test One");
        XCTAssertTrue([item isEqualToCBItem:[array objectAtIndex:0]], @"Should be item inserted");
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self.defaultQuery removeWithSuccessCallback:^(NSMutableArray * array) {
        XCTAssertTrue([array count] == 1, @"Should be single item removed");
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

@end
