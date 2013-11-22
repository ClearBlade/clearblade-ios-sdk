//
//  TestCBItem.h
//  testApp
//
//  Created by Tyler Dodge on 11/15/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import "CBItem.h"

@interface TestCBItem : CBItem
+(instancetype)itemWithStringColumn:(NSString *)stringColumn
                      withIntColumn:(NSNumber *)intColumn
                     withDateColumn:(NSDate *)dateColumn
                     withBlobColumn:(NSData *)blobColumn
                  withBooleanColumn:(bool)booleanColumn;
@property (nonatomic) NSString *stringColumn;
@property (nonatomic) NSNumber *intColumn;
@property (nonatomic) NSDate *dateColumn;
@property (nonatomic) NSData *blobColumn;
@property (nonatomic) bool booleanColumn;
@end
