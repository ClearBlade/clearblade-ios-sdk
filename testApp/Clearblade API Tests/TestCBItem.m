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

+(NSString *)stringColumnName {
    return STRING_COLUMN;
}

+(NSString *)intColumnName {
    return INT_COLUMN;
}

-(NSString *)stringColumnName {
    return [TestCBItem stringColumnName];
}

-(NSString *)intColumnName {
    return [TestCBItem intColumnName];
}

-(NSString *)stringColumn {
    return [self objectForKey:self.stringColumnName];
}
-(void)setStringColumn:(NSString *)stringColumn {
    [self setObject:stringColumn forKey:self.stringColumnName];
}

-(NSNumber *)intColumn {
    return [self objectForKey:self.intColumnName];
}
-(void)setIntColumn:(NSNumber *)intColumn {
    [self setObject:intColumn forKey:self.intColumnName];
}

+(instancetype)itemWithStringColumn:(NSString *)stringColumn withIntColumn:(int)intColumn withCollectionID:(NSString *)collectionID {
    TestCBItem * item = [[TestCBItem alloc] init];
    item.stringColumn = stringColumn;
    item.intColumn = @(intColumn);
    item.collectionID = collectionID;
    return item;
}
+(instancetype)itemFromCBItem:(CBItem *)item {
    TestCBItem * newItem = [TestCBItem itemWithStringColumn:[item objectForKey:[TestCBItem stringColumnName]]
                                              withIntColumn:[[item objectForKey:[TestCBItem intColumnName]] intValue] withCollectionID:item.collectionID];
    newItem.itemID = item.itemID;
    return newItem;
}
@end
