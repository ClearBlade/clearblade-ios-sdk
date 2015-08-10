//
//  CBCollectionTest.m
//  CBAPI
//
//  Created by pyg on 8/10/15.
//  Copyright (c) 2015 Clearblade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "CBUser.h"
#import "CBCollection.h"

@interface CBCollectionTest : XCTestCase

@end

@implementation CBCollectionTest


- (void)setUp
{
    [super setUp];
    NSError* err;
    [ClearBlade initSettingsSyncWithSystemKey:APP_KEY withSystemSecret:APP_SECRET withOptions:@{CBSettingsOptionServerAddress:PLATFORM_ADDRESS} withError:&err];
    XCTAssertNil(err,@"Error is not nil in setting up");
    [ClearBlade settings].mainUser =  [CBUser anonymousUserWithSettings:[ClearBlade settings] WithError:&err];
    XCTAssertNil(err,@"Error is not nil in setting up");
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

/*
- (void)testFetchCollectionCount{
    CBCollection* col = [CBCollection collectionWithID:TEST_COLLECTION ];
    NSError* err;
    NSInteger i = [col fetchCollectionCount:nil withError:&err];
    XCTAssert(i >= 0,@"i was not a good value");
    XCTAssertNil(err,@"Error was not nil");
}
*/

-(void)testGetColumns{
    CBCollection* col = [CBCollection collectionWithID:TEST_COLLECTION];
    NSError* err;
    NSArray* dict = [col fetchCollectionColumns:&err];
    XCTAssertNotNil(dict,@"array was nil");
    XCTAssertNil(err,@"error was not nil");
}


@end
