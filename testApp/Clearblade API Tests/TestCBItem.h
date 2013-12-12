//
//  TestCBItem.h
//  testApp
//
//  Created by Tyler Dodge on 11/15/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import "CBItem.h"

@interface TestCBItem : CBItem
+(instancetype)itemWithStringColumn:(NSString *)stringColumn withIntColumn:(int)intColumn;
@property (nonatomic) NSString *stringColumn;
@property (nonatomic) NSNumber *intColumn;
@property (nonatomic, readonly) NSString * stringColumnName;
@property (nonatomic, readonly) NSString * intColumnName;
@end
