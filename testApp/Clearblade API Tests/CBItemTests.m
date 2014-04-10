//
//  CBItemTests.m
//  testApp
//
//  Created by Tyler Dodge on 12/13/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CBItem.h"
#import "AsyncTestCase.h"

@interface CBItemTests : AsyncTestCase

@end

@implementation CBItemTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

- (void)testEquals {
    CBItem * item = [CBItem itemWithData:@{@"One": @"one-response"} withCollectionID:TEST_COLLECTION];
    CBItem * emptyItem = [CBItem itemWithData:@{} withCollectionID:TEST_COLLECTION];
    CBItem * itemWithMoreKeys = [CBItem itemWithData:@{@"One": @"one-response"} withCollectionID:TEST_COLLECTION];
    XCTAssertFalse([item isEqualToCBItem:emptyItem], @"Item should not be equal to empty item");
    XCTAssertFalse([emptyItem isEqualToCBItem:item], @"Equivalence should be same bothe ways");
    XCTAssertTrue([item isEqualToCBItem:item], @"item should be equal to itself");
    XCTAssertTrue([item isEqualToCBItem:itemWithMoreKeys], @"Should be equal with the same keys");
    [itemWithMoreKeys setObject:@"Hello" forKey:@"other-key"];
    XCTAssertFalse([item isEqualToCBItem:itemWithMoreKeys], @"Should not be equal to object with more keys");
    XCTAssertFalse([itemWithMoreKeys isEqualToCBItem:item], @"Should not be equal to object with more keys");
}

-(void)testIgnoresItemIDIfNil {
    CBItem * item = [CBItem itemWithData:@{@"one": @"one-response"} withCollectionID:TEST_COLLECTION];
    CBItem * otherItem = [CBItem itemWithData:@{@"one": @"one-response"} withCollectionID:TEST_COLLECTION];
    XCTAssertTrue([item isEqualToCBItem:otherItem], @"Should equal when both item ids are nil");
    XCTAssertTrue([otherItem isEqualToCBItem:item], @"Should equal when both item ids are nil");
    item.itemID = @"1234";
    XCTAssertTrue([item isEqualToCBItem:otherItem], @"Should equal when one item id is nil");
    XCTAssertTrue([otherItem isEqualToCBItem:item], @"Should equal when one item id is nil");
    otherItem.itemID = @"12345";
    XCTAssertFalse([otherItem isEqualToCBItem:item], @"When both ids are set, should check if they are the same");
}

@end
