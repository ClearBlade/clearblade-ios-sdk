/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBItem.h"
#import "CBQuery.h"
#import "CBCollection.h"
#define CBITEM_ID_KEY @"item_id"

@implementation CBItem

@synthesize collectionID = _collectionID;
@synthesize data = _data;
@dynamic itemID;

+(NSMutableArray *)arrayOfCBItemsFromArrayOfDictionaries:(NSArray *)itemArray withCollectionID:(NSString *)collectionID {
    NSMutableArray * destinationArray = [NSMutableArray array];
    if ([itemArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary * item in itemArray) {
            [destinationArray addObject:[CBItem itemWithData:item withCollectionID:collectionID]];
        }
    } else {
        [destinationArray addObject:[CBItem itemWithData:(NSDictionary *)itemArray withCollectionID:collectionID]];
    }
    return destinationArray;
}

+(CBItem *)itemWithData:(NSDictionary *)inputData withCollectionID:(NSString *)collectionID {
    return [[CBItem alloc] initWithData:inputData.mutableCopy withCollectionID:collectionID];
}

-(CBItem *) initWithData: (NSMutableDictionary *) inputData withCollectionID:(NSString *) colID {
    self = [super init];
    self.collectionID = colID;
    self.data = inputData;
    return self;
}

-(NSString *)itemID {
    return [self.data objectForKey:CBITEM_ID_KEY];
}
-(void)setItemID:(NSString *)itemID {
    [self.data setObject:itemID forKey:CBITEM_ID_KEY];
}


-(void) saveWithSuccessCallback:(CBItemSuccessCallback)successCallback
              withErrorCallback:(CBItemErrorCallback)errorCallback {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.collectionID];
    if (self.itemID) {
        [query updateWithChanges:self.data
             withSuccessCallback:[self handleSuccessCallback:successCallback]
               withErrorCallback:[self handleErrorCallback:errorCallback]];
    } else {
        [query insertItem:self
      withSuccessCallback:[self handleSuccessCallback:successCallback]
        withErrorCallback:[self handleErrorCallback:errorCallback]];
    }
}

-(CBQuerySuccessCallback)handleSuccessCallback:(CBItemSuccessCallback)successCallback {
    return ^(NSMutableArray *foundItems) {
        self.data = (NSMutableDictionary *)[(CBItem *)[foundItems objectAtIndex:0] data];
        if (successCallback) {
            successCallback(self);
        }
    };
}
-(CBQueryErrorCallback)handleErrorCallback:(CBItemErrorCallback)errorCallback {
    return ^(NSError * error, id JSON) {
        if (errorCallback) {
            errorCallback(self, error, JSON);
        }
    };
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Parent Collection <%@>, Payload Dictionary %@", self.collectionID, self.data];
}

-(void) refreshWithSuccessCallback:(CBItemSuccessCallback)successCallback
                 withErrorCallback:(CBItemErrorCallback)errorCallback {
    if ([self validateWithErrorCallback:errorCallback]) {
        CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.collectionID];
        [query equalTo:self.itemID for:CBITEM_ID_KEY];
        [query fetchWithSuccessCallback:[self handleSuccessCallback:successCallback]
                      withErrorCallback:[self handleErrorCallback:errorCallback]];
    }
}

-(void) removeWithSuccessCallback:(CBItemSuccessCallback)successCallback
                withErrorCallback:(CBItemErrorCallback)errorCallback {
    if ([self validateWithErrorCallback:errorCallback]) {
        CBQuery *query = [[CBQuery alloc] init];
        [query equalTo:self.itemID for:CBITEM_ID_KEY];
        [query removeWithSuccessCallback:[self handleSuccessCallback:successCallback]
                       withErrorCallback:[self handleErrorCallback:errorCallback]];
    }
   
}

-(bool)validateWithErrorCallback:(CBItemErrorCallback)errorCallback {
    NSError * error;
    if (!self.itemID) {
        error = [NSError errorWithDomain:@"Item ID must be set to refresh / remove." code:0 userInfo:nil];
    }
    if (error) {
        if (errorCallback) {
            errorCallback(self, error, nil);
        }
        return false;
    }
    return true;
}

-(id)objectForKey:(NSString *)key {
    return [self.data objectForKey:key];
}

-(void)setObject:(id)value forKey:(NSString *)key {
    [self.data setObject:value forKey:key];
}

-(bool)isEqualToCBItem:(CBItem *)item {
    if (item.data.count != self.data.count) {
        return false;
    }
    
    for (id key in self.data) {
        if (![[self.data objectForKey:key] isEqual:[item.data objectForKey:key]]) {
            return false;
        }
    }
    return true;
}

@end
