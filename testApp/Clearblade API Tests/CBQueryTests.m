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
#define APP_KEY @"5277bd628ab3a37ce7f6f061"
#define APP_SECRET @"0D2N19VB3FPYJYEBSOI4LVG6M97PKX"
#define TEST_COLLECTION @"5281350e8ab3a3224cac7d4d"
#define PLATFORM_ADDRESS @"http://platform.clearblade.com/api"
#else
#define APP_KEY @"dce6d3a80af0e3afbed1818992c201"
#define APP_SECRET @"D6D48AA70A96CAB8E89AFBB394F601"
#define TEST_COLLECTION @"e89be8a80a889ebefba8e5fde032"
#define PLATFORM_ADDRESS @"http://162.209.79.118/api/"
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
                                           withIntColumn:@(5)
                                          withDateColumn:[NSDate date]
                                          withBlobColumn:[NSData data]
                                       withBooleanColumn:true];
    [[CBQuery queryWithCollectionID:item.collectionID] removeWithSuccessCallback:^(NSArray * items) {
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
