//
//  CBQueryResponse.m
//  CBAPI
//
//  Created by alex seubert on 3/19/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import "CBQueryResponse.h"

@implementation CBQueryResponse

-(id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];
    
    self.currentPageNumber = (NSNumber *)[dictionary objectForKey:@"currentPageNum"];
    self.nextPageURL = [dictionary objectForKey:@"nextPageUrl"];
    self.prevPageURL = [dictionary objectForKey:@"prevPageUrl"];
    self.totalCount = (NSNumber *)[dictionary objectForKey:@"totalCount"];
    self.dataItems = [dictionary objectForKey:@"data"];
    
    return self;
}

@end
