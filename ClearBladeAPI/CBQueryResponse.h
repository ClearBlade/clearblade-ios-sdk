//
//  CBQueryResponse.h
//  CBAPI
//
//  Created by alex seubert on 3/19/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBQueryResponse : NSObject
@property NSNumber *currentPageNumber;
@property NSString *nextPageURL;
@property NSString *prevPageURL;
@property NSNumber *totalCount;
@property NSMutableArray *dataItems;

-(id)initWithDictionary:(NSDictionary *)dictionary;
@end
