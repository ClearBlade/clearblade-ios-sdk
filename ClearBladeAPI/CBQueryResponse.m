//
//  CBQueryResponse.m
//  CBAPI
//
//  Created by alex seubert on 3/19/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import "CBQueryResponse.h"
#import "CBItem.h"

@implementation CBQueryResponse

-(id)initWithDictionary:(NSDictionary *)dictionary
       withCollectionID:(NSString *)collectionID{
    self = [super init];
    
    self.currentPageNumber = (NSNumber *)[dictionary objectForKey:@"CURRENTPAGE"];
    self.nextPageURL = [dictionary objectForKey:@"NEXTPAGEURL"];
    self.prevPageURL = [dictionary objectForKey:@"PREVPAGEURL"];
    self.totalCount = (NSNumber *)[dictionary objectForKey:@"TOTAL"];
    NSMutableArray *convertedArray = [CBItem arrayOfCBItemsFromArrayOfDictionaries:[dictionary objectForKey:@"DATA"] withCollectionID:collectionID];
    self.dataItems = convertedArray;
    
    return self;
}

@end
