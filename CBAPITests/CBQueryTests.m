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

@interface CBQueryTests : AsyncTestCase
@property (strong, nonatomic) CBQuery * defaultQuery;

@end

@implementation CBQueryTests

- (void)setUp {
    [super setUp];
    NSError * error;
    [ClearBlade initSettingsSyncWithSystemKey:APP_KEY
                             withSystemSecret:APP_SECRET
                                  withOptions:@{CBSettingsOptionServerAddress: PLATFORM_ADDRESS}
                                    withError:&error];
    self.defaultQuery = [CBQuery queryWithCollectionID:TEST_COLLECTION];
}

- (void)tearDown {
    [super tearDown];
}

-(void)testQueryDescription {
    CBQuery * query = [CBQuery queryWithCollectionID:TEST_COLLECTION];
    NSString * expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <>", TEST_COLLECTION];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Empty query should have this format");
    expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <key1 = 'value1'>", TEST_COLLECTION];
    [query equalTo:@"value1" for:@"key1"];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Single argument query should have this format");
    
    expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <key1 = 'value1' AND key2 = 'value2'>", TEST_COLLECTION];
    [query equalTo:@"value2" for:@"key2"];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Two argument query should have this format");
    [query addQueryAsOrClauseUsingQuery:nil];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Empty or clause should be ignored");
    CBQuery *query2 = [CBQuery queryWithCollectionID:TEST_COLLECTION];
    [query2 equalTo:@"value3" for:@"key3"];
    [query addQueryAsOrClauseUsingQuery:query2];
    expectedFormat = [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <key1 = 'value1' AND key2 = 'value2' OR key3 = 'value3'>", TEST_COLLECTION];
    XCTAssertTrue([[query description] isEqualToString:expectedFormat], @"Query with or clause should have this format");
}

- (void)insertItem:(CBItem *)item {
    [[CBQuery queryWithCollectionID:item.collectionID] insertItem:item
                                             intoCollectionWithID:TEST_COLLECTION
                                              withSuccessCallback:^(NSMutableArray *successResponse) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

- (void)removeItemWithStringColumn:(NSString *)stringColumn {
    [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:stringColumn for:[TestCBItem stringColumnName]]
     removeWithSuccessCallback:^(NSMutableArray *successResponse) {
         [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

- (void)testMultipleReturnedFetch {
    NSMutableArray * items = [NSMutableArray array];
    [self removeItemWithStringColumn:@"TEST"];
    for (int i = 0; i < 5; i++) {
        TestCBItem * nextItem = [TestCBItem itemWithStringColumn:@"TEST" withIntColumn:i withCollectionID:TEST_COLLECTION];
        [self insertItem:nextItem];
        [items addObject:nextItem];
        [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:@"TEST" for:[TestCBItem stringColumnName]]
         fetchWithSuccessCallback:^(CBQueryResponse *successResponse) {
             bool isItemInArray[items.count];
             
             NSMutableArray *foundItems = successResponse.dataItems;
             for (CBItem * item in foundItems) {
                 TestCBItem * testItem = [TestCBItem itemFromCBItem:item];
                 for (int isItemIndex = 0; isItemIndex < items.count; isItemIndex++) {
                     if ([[items objectAtIndex:isItemIndex] isEqualToCBItem:testItem]) {
                         isItemInArray[isItemIndex] = true;
                     }
                 }
             }
             NSMutableSet * itemIdSet = [NSMutableSet set];
             for (int isItemIndex = 0; isItemIndex < foundItems.count; isItemIndex++) {
                 XCTAssertTrue(isItemInArray[isItemIndex], @"%@ should be in fetch return: %@",
                               [items objectAtIndex:isItemIndex], items);
                 NSString * itemId = [[foundItems objectAtIndex:isItemIndex] itemID];
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

- (void)testSingleArgumentFetch {
    [self removeItemWithStringColumn:@"TEST"];
    TestCBItem * item = [TestCBItem itemWithStringColumn:@"TEST"
                                           withIntColumn:5 withCollectionID:TEST_COLLECTION];
    
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

- (void)testSingleArgumentFetchWithPagination {
    [self removeItemWithStringColumn:@"TEST"];
    TestCBItem * item = [TestCBItem itemWithStringColumn:@"TEST"
                                           withIntColumn:5 withCollectionID:TEST_COLLECTION];
    TestCBItem * item2 = [TestCBItem itemWithStringColumn:@"TEST"
                                            withIntColumn:6 withCollectionID:TEST_COLLECTION];
    
    [item saveWithSuccessCallback:^(CBItem *item) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(CBItem *item, NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [item2 saveWithSuccessCallback:^(CBItem *item) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(CBItem *item, NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [self.defaultQuery equalTo:@"TEST" for:STRING_COLUMN];
    [self.defaultQuery setPageSize:[NSNumber numberWithInt:1]];
    [self.defaultQuery setPageNum:[NSNumber numberWithInt:1]];
    
    [self.defaultQuery fetchWithSuccessCallback:^(CBQueryResponse *successResponse) {
        XCTAssertTrue([successResponse.dataItems count] == 1, @"Should be single response to equal to Test One");
        if (successResponse.dataItems.count == 1) {
            CBItem * otherItem = [TestCBItem itemFromCBItem:[successResponse.dataItems objectAtIndex:0]];
            XCTAssertTrue([[item.data objectForKey:@"stringcolumn"] isEqualToString:[otherItem.data objectForKey:@"stringcolumn"]]);
        }
        XCTAssertTrue([successResponse.totalCount intValue] == 2);
        XCTAssertTrue([successResponse.currentPageNumber intValue] == 1);
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError * error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    [self removeItemWithStringColumn:@"TEST"];
}

- (void)testRemoval {
    NSArray * items = @[[TestCBItem itemWithStringColumn:@"TEST_REMOVE"
                                           withIntColumn:5 withCollectionID:TEST_COLLECTION],
                        [TestCBItem itemWithStringColumn:@"TEST_REMOVE"
                                           withIntColumn:6 withCollectionID:TEST_COLLECTION],
                        [TestCBItem itemWithStringColumn:@"TEST_REMOVE"
                                           withIntColumn:7 withCollectionID:TEST_COLLECTION]];

    [self removeItemWithStringColumn:@"TEST_REMOVE"];

    for (TestCBItem * item in items) {
        [self insertItem:item];
    }

    [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:@"TEST_REMOVE" for:[TestCBItem stringColumnName]]
     fetchWithSuccessCallback:^(CBQueryResponse *successResponse) {
         XCTAssertTrue(successResponse.dataItems.count == items.count, @"All items should be in the collection");
         [self signalAsyncComplete:MAIN_COMPLETION];
     } withErrorCallback:^(NSError * error, id JSON) {
         XCTFail(@"Threw unexpected error %@", error);
         [self signalAsyncComplete:MAIN_COMPLETION];
     }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];

    [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:@"TEST_REMOVE" for:[TestCBItem stringColumnName]]
     removeWithSuccessCallback:^(NSMutableArray *successResponse) {
         XCTAssertTrue(successResponse.count == 3, @"Should remove 3 items");
         [self signalAsyncComplete:MAIN_COMPLETION];
     } withErrorCallback:^(NSError * error, id JSON) {
         XCTFail(@"Threw unexpected error %@", error);
         [self signalAsyncComplete:MAIN_COMPLETION];
     }];

    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:@"TEST_REMOVE" for:[TestCBItem stringColumnName]]
     fetchWithSuccessCallback:^(CBQueryResponse *successResponse) {
         XCTAssertTrue(successResponse.dataItems.count == 0, @"All items should be removed");
         [self signalAsyncComplete:MAIN_COMPLETION];
     } withErrorCallback:^(NSError * error, id JSON) {
         XCTFail(@"Threw unexpected error %@", error);
         [self signalAsyncComplete:MAIN_COMPLETION];
     }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
}

-(void)testUpdate {
    TestCBItem * item = [TestCBItem itemWithStringColumn:@"TEST_UPDATE" withIntColumn:0 withCollectionID:TEST_COLLECTION];
    [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:@"TEST_UPDATE" for:item.stringColumnName] removeWithSuccessCallback:^(NSMutableArray *successResponse) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError *error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:@"TEST_UPDATE" for:item.stringColumnName]
     updateWithChanges:@{item.intColumnName: @(25)} withSuccessCallback:^(NSMutableArray *successResponse) {
         XCTFail(@"Should fail if the item does not exist");
         [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError *error, id JSON) {
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
    
    [self insertItem:item];
    [[[CBQuery queryWithCollectionID:TEST_COLLECTION] equalTo:@"TEST_UPDATE" for:item.stringColumnName]
     updateWithChanges:@{item.intColumnName: @(25)} withSuccessCallback:^(NSMutableArray *successResponse) {
         XCTAssertTrue(successResponse.count == 1, @"Should only be one item");
         if (successResponse.count == 1) {
             XCTAssertTrue([[[successResponse firstObject] objectForKey:item.stringColumnName] isEqualToString:@"TEST_UPDATE"],
                           @"String Column should be TEST_UPDATE");
             XCTAssertTrue([[[successResponse firstObject] objectForKey:item.intColumnName] isEqualToNumber:@(25)] , @"Int Column should be 25");
         }
         [self signalAsyncComplete:MAIN_COMPLETION];
    } withErrorCallback:^(NSError *error, id JSON) {
        XCTFail(@"Threw unexpected error %@", error);
        [self signalAsyncComplete:MAIN_COMPLETION];
    }];
    [self waitForAsyncCompletion:MAIN_COMPLETION];
}

@end
