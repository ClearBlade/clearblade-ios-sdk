//
//  TestCBItem.m
//  testApp
//
//  Created by Tyler Dodge on 11/15/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import "TestCBItem.h"
#define STRING_COLUMN @"StringColumn"
#define INT_COLUMN @"IntColumn"

@implementation TestCBItem
@dynamic stringColumn;
@dynamic intColumn;

@dynamic stringColumnName;
@dynamic intColumnName;

-(NSString *)stringColumnName {
    return STRING_COLUMN;
}

-(NSString *)intColumnName {
    return INT_COLUMN;
}

-(NSString *)stringColumn {
    return [self objectForKey:STRING_COLUMN];
}
-(void)setStringColumn:(NSString *)stringColumn {
    [self setObject:stringColumn forKey:STRING_COLUMN];
}

-(NSNumber *)intColumn {
    return [self objectForKey:INT_COLUMN];
}
-(void)setIntColumn:(NSNumber *)intColumn {
    [self setObject:intColumn forKey:INT_COLUMN];
}

+(instancetype)itemWithStringColumn:(NSString *)stringColumn withIntColumn:(int)intColumn {
    TestCBItem * item = [[TestCBItem alloc] init];
    item.stringColumn = stringColumn;
    item.intColumn = @(intColumn);
    return item;
}
+(instancetype)itemFromCBItem:(CBItem *)item {
    TestCBItem * newItem = [TestCBItem itemWithStringColumn:[item objectForKey:STRING_COLUMN]
                                              withIntColumn:[[item objectForKey:INT_COLUMN] intValue]];
    newItem.itemID = item.itemID;
    return newItem;
}
@end
