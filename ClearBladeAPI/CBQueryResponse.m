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
    
    self.currentPageNumber = (NSNumber *)[dictionary objectForKey:@"CURRENTPAGE"];
    self.nextPageURL = [dictionary objectForKey:@"NEXTPAGEURL"];
    self.prevPageURL = [dictionary objectForKey:@"PREVPAGEURL"];
    self.totalCount = (NSNumber *)[dictionary objectForKey:@"TOTALCOUNT"];
    self.dataItems = [dictionary objectForKey:@"DATA"];
    
    return self;
}

@end
