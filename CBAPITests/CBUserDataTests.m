//
//  CBUserDataTests.m
//  CBAPI
//
//  Created by alex seubert on 3/4/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AsyncTestCase.h"
#import "CBUser.h"
#import "CBAPI.h"
#import "TestCBItem.h"

@interface CBUserDataTests : AsyncTestCase
@property (strong, nonatomic) CBQuery * defaultQuery;
@end

@implementation CBUserDataTests

- (void)setUp
{
    [super setUp];
    NSString * uid = [[NSUUID UUID] UUIDString];
    [ClearBlade initSettingsWithSystemKey:AUTH_APP_KEY
                         withSystemSecret:AUTH_APP_SECRET
                              withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS,
                                            CBSettingsOptionLoggingLevel: @(TEST_LOGGING_LEVEL),
                                            CBSettingsOptionEmail: uid,
                                            CBSettingsOptionPassword: @"password",
                                            CBSettingsOptionRegisterUser: @(true) }
                      withSuccessCallback:^(ClearBlade * cb) {
                          XCTAssertTrue(cb, @"Got a thing.");
                          [self signalAsyncComplete:MAIN_COMPLETION];
                      } withErrorCallback:^(NSError * error) {
                          XCTFail(@"Unexpected error <%@>", error);
                          [self signalAsyncComplete:MAIN_COMPLETION];
                      }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    self.defaultQuery = [CBQuery queryWithCollectionID:AUTH_TEST_COLLECTION];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)insertItem:(CBItem *)item {
    [[CBQuery queryWithCollectionID:item.collectionID] insertItem:item
                                             intoCollectionWithID:AUTH_TEST_COLLECTION
                                              withSuccessCallback:^(NSMutableArray *successResponse) {
                                                  [self signalAsyncComplete:MAIN_COMPLETION];
                                              } withErrorCallback:^(NSError * error, id JSON) {
                                                  XCTFail(@"Unexpected error %@", error);
                                                  [self signalAsyncComplete:MAIN_COMPLETION];
                                              }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

- (void)removeItemWithStringColumn:(NSString *)stringColumn {
    [[[CBQuery queryWithCollectionID:AUTH_TEST_COLLECTION] equalTo:stringColumn for:[TestCBItem stringColumnName]]
     removeWithSuccessCallback:^(NSMutableArray *data) {
         [self signalAsyncComplete:MAIN_COMPLETION];
     } withErrorCallback:^(NSError * error, id JSON) {
         XCTFail(@"Unexpected error %@", error);
         [self signalAsyncComplete:MAIN_COMPLETION];
     }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

- (void)testMultipleReturnedFetchWithUser {
    NSMutableArray * items = [NSMutableArray array];
    [self removeItemWithStringColumn:@"TEST"];
    for (int i = 0; i < 5; i++) {
        TestCBItem * nextItem = [TestCBItem itemWithStringColumn:@"TEST" withIntColumn:i withCollectionID:AUTH_TEST_COLLECTION];
        [self insertItem:nextItem];
        [items addObject:nextItem];
        [[[CBQuery queryWithCollectionID:AUTH_TEST_COLLECTION] equalTo:@"TEST" for:[TestCBItem stringColumnName]]
         fetchWithSuccessCallback:^(CBQueryResponse *successResponse) {
             bool isItemInArray[successResponse.dataItems.count];

             for (CBItem * item in successResponse.dataItems) {
                 TestCBItem * testItem = [TestCBItem itemFromCBItem:item];
                 for (int isItemIndex = 0; isItemIndex < items.count; isItemIndex++) {
                     if ([[items objectAtIndex:isItemIndex] isEqualToCBItem:testItem]) {
                         isItemInArray[isItemIndex] = true;
                     }
                 }
             }
             NSMutableSet * itemIdSet = [NSMutableSet set];
             for (int isItemIndex = 0; isItemIndex < successResponse.dataItems.count; isItemIndex++) {
                 XCTAssertTrue(isItemInArray[isItemIndex], @"%@ should be in fetch return: %@",
                               [items objectAtIndex:isItemIndex], items);
                 NSString * itemId = [[successResponse.dataItems objectAtIndex:isItemIndex] itemID];
                 XCTAssertTrue([itemId isKindOfClass:[NSString class]],
                               @"Item id should be a string, received a %@", [itemId class]);
                 XCTAssertFalse([itemIdSet containsObject:itemId], @"item id %@ returned multiple times", itemId);
                 if (itemId) {
                     [itemIdSet addObject:itemId];
                 }
             }
             [self signalAsyncComplete:MAIN_COMPLETION];
         } withErrorCallback:^(NSError *error, id JSON) {
             XCTFail(@"Unexpected error %@", error);
             [self signalAsyncComplete:MAIN_COMPLETION];
         }];
        [self waitForAsyncCompletion:MAIN_COMPLETION];
    }

    [self removeItemWithStringColumn:@"TEST"];
}

- (void)testSingleArgumentFetchAsUser {
    [self removeItemWithStringColumn:@"TEST"];
    TestCBItem * item = [TestCBItem itemWithStringColumn:@"TEST"
                                           withIntColumn:5 withCollectionID:AUTH_TEST_COLLECTION];

    [item saveWithSuccessCallback:^(CBItem *item) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(CBItem *item, NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];

    [self.defaultQuery equalTo:@"TEST" for:STRING_COLUMN];

    [self.defaultQuery fetchWithSuccessCallback:^(CBQueryResponse *successResponse) {
        XCTAssertTrue([successResponse.dataItems count] == 1, @"Should be single response to equal to Test One");
        if (successResponse.dataItems.count == 1) {
            CBItem * otherItem = [TestCBItem itemFromCBItem:[successResponse.dataItems objectAtIndex:0]];
            XCTAssertTrue([item isEqualToCBItem:otherItem], @"Should be item inserted");
        }
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self removeItemWithStringColumn:@"TEST"];
}

- (void)testFailRemoveAfterLogout {
    NSError * error;
    CBUser * user = [ClearBlade settings].mainUser;

    // Logout before making a request
    XCTAssertTrue([user logOutWithError:&error], @"Should successfully log out");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    [[[CBQuery queryWithCollectionID:AUTH_TEST_COLLECTION] equalTo:@"TEST" for:[TestCBItem stringColumnName]]
     removeWithSuccessCallback:^(NSMutableArray *data) {
         XCTFail(@"Should not be allowed to insert item");
         [self signalAsyncComplete:MAIN_COMPLETION];
     } withErrorCallback:^(NSError * error, id JSON) {
         XCTAssertTrue(error, @"Threw expected error %@", error);
         [self signalAsyncComplete:MAIN_COMPLETION];
     }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

-(void)testFailInsertAfterLogout {
    NSError * error;
    CBUser * user = [ClearBlade settings].mainUser;

    // Logout before making a request
    XCTAssertTrue([user logOutWithError:&error], @"Should successfully log out");
    XCTAssertNil(error, @"Should initialize with no errors %@", error);
    TestCBItem * item = [TestCBItem itemWithStringColumn:@"TEST"
                                           withIntColumn:5 withCollectionID:AUTH_TEST_COLLECTION];

    [item saveWithSuccessCallback:^(CBItem *item) {
        XCTFail(@"Should not be allowed to insert item");
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(CBItem *item, NSError * error, id JSON) {
        XCTAssertTrue(error, @"Threw expected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}
@end
