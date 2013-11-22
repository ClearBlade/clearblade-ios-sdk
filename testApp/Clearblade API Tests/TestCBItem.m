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
#define DATE_COLUMN @"DateColumn"
#define BLOB_COLUMN @"BlobColumn"
#define BOOLEAN_COLUMN @"BooleanColumn"

@implementation TestCBItem
@dynamic stringColumn;
@dynamic intColumn;
@dynamic dateColumn;
@dynamic blobColumn;
@dynamic booleanColumn;

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

-(NSDate *)dateColumn {
    return [self objectForKey:DATE_COLUMN];
}
-(void)setDateColumn:(NSDate *)dateColumn {
    [self setObject:dateColumn forKey:DATE_COLUMN];
}

-(NSData *)blobColumn {
    return [self objectForKey:BLOB_COLUMN];
}
-(void)setBlobColumn:(NSData *)blobColumn {
    [self setObject:blobColumn forKey:BLOB_COLUMN];
}

-(bool)booleanColumn {
    return [[self objectForKey:BOOLEAN_COLUMN] boolValue];
}
-(void)setBooleanColumn:(bool)booleanColumn {
    [self setObject:@(booleanColumn) forKey:BOOLEAN_COLUMN];
}

+(instancetype)itemWithStringColumn:(NSString *)stringColumn
                      withIntColumn:(NSNumber *)intColumn
                     withDateColumn:(NSDate *)dateColumn
                     withBlobColumn:(NSData *)blobColumn
                  withBooleanColumn:(bool)booleanColumn {
    NSDictionary * itemData = @{ @"StringColumn": stringColumn,
                                 @"IntColumn": intColumn,
                                 @"DateColumn": dateColumn,
                                 @"BooleanColumn": @(booleanColumn) };
    return [TestCBItem itemWithData:itemData withCollectionID:@"5281350e8ab3a3224cac7d4d"];
}
@end
