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
            if ([item isKindOfClass:[NSString class]]) { //Assumes strings are just item_ids
                [destinationArray addObject:[CBItem itemWithData:@{CBITEM_ID_KEY: item } withCollectionID:collectionID]];
            } else {
                [destinationArray addObject:[CBItem itemWithData:item withCollectionID:collectionID]];
            }
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
    for (NSString * key in inputData.keyEnumerator) {
        self.data[key.lowercaseString] = inputData[key];
    }
    return self;
}

-(NSString *)itemID {
    return [self.data objectForKey:CBITEM_ID_KEY];
}
-(void)setItemID:(NSString *)itemID {
    [self.data setObject:itemID forKey:CBITEM_ID_KEY];
}

-(NSMutableDictionary *)data {
    if (!_data) {
        _data = [NSMutableDictionary dictionary];
    }
    return _data;
}


-(void) saveWithSuccessCallback:(CBItemSuccessCallback)successCallback
              withErrorCallback:(CBItemErrorCallback)errorCallback {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.collectionID];
    CBLogDebug(@"Saving %@", self);
    if (self.itemID) {
        [[query equalTo:self.itemID for:CBITEM_ID_KEY] updateWithChanges:self.data
             withSuccessCallback:[self handleSuccessSaveCallback:successCallback]
               withErrorCallback:[self handleErrorCallback:errorCallback]];
    } else {
        [query insertItem:self
     intoCollectionWithID:self.collectionID
      withSuccessCallback:[self handleSuccessSaveCallback:successCallback]
        withErrorCallback:[self handleErrorCallback:errorCallback]];
    }
}

-(CBQuerySuccessCallback)handleSuccessCallback:(CBItemSuccessCallback)successCallback {
    return ^(CBQueryResponse *successResponse) {
        if (successResponse.dataItems.count == 1) {
            NSString * newID = [successResponse.dataItems[0] objectForKey:CBITEM_ID_KEY];
            self.itemID = newID;
        }
        if (successCallback) {
            successCallback(self);
        }
    };
}

-(void) dumpTheDict:(NSDictionary *)dict {
    NSLog(@"DICTIONARY:");
    for (NSString *key in dict) {
        NSLog(@"\t%@: %@", key, [dict objectForKey:key]);
    }
}

-(CBOperationSuccessCallback)handleSuccessSaveCallback:(CBItemSuccessCallback)successCallback {
    return ^(NSMutableArray *successResponse) {
        if ([[successResponse class] isSubclassOfClass:[NSDictionary class]]) {
            [self dumpTheDict:(NSDictionary *)successResponse];
        }
        if (successResponse.count > 0) {
            NSString * newID = [successResponse valueForKey:CBITEM_ID_KEY];
            self.itemID = newID;
        }
        if (successCallback) {
            successCallback(self);
        }
    };
}

-(CBOperationSuccessCallback)handleSuccessDeleteCallback:(CBItemSuccessCallback)successCallback {
    return ^(NSMutableArray *successResponse) {
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
    return [NSString stringWithFormat:@"CBItem: Parent Collection <%@>, Payload Dictionary %@", self.collectionID, self.data];
}

-(void) refreshWithSuccessCallback:(CBItemSuccessCallback)successCallback
                 withErrorCallback:(CBItemErrorCallback)errorCallback {
    CBLogDebug(@"Refreshing %@", self);
    if ([self validateWithErrorCallback:errorCallback]) {
        CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.collectionID];
        [query equalTo:self.itemID for:CBITEM_ID_KEY];
        [query fetchWithSuccessCallback:[self handleSuccessCallback:successCallback]
                      withErrorCallback:[self handleErrorCallback:errorCallback]];
    }
}

-(void) removeWithSuccessCallback:(CBItemSuccessCallback)successCallback
                withErrorCallback:(CBItemErrorCallback)errorCallback {
    CBLogDebug(@"Removing %@", self);
    if ([self validateWithErrorCallback:errorCallback]) {
        CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.collectionID];
        [query equalTo:self.itemID for:CBITEM_ID_KEY];
        [query removeWithSuccessCallback:[self handleSuccessDeleteCallback:successCallback]
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
    return [self.data objectForKey:key.lowercaseString];
}

-(void)setObject:(id)value forKey:(NSString *)key {
    [self.data setObject:value forKey:key.lowercaseString];
}

-(bool)isEqualToCBItem:(CBItem *)item {
    bool ignoreItemID = false;
    unsigned long selfCount = self.data.count;
    unsigned long otherCount = item.data.count;
    if (item.itemID == nil) {
        otherCount += 1;
        ignoreItemID = true;
    }
    if (self.itemID == nil) {
        selfCount += 1;
        ignoreItemID = true;
    }
    if (selfCount != otherCount) {
        return false;
    }
    
    for (id key in self.data) {
        if (ignoreItemID && [key isEqualToString:CBITEM_ID_KEY]) {
            //skip if it's an item id
        }
        else if (![[self.data objectForKey:key] isEqual:[item.data objectForKey:key]]) {
            return false;
        }
    }
    return true;
}

@end
