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

@implementation CBItem

@synthesize collectionID = _collectionID;
@synthesize data = _data;

+(NSMutableArray *)arrayOfCBItemsFromArrayOfDictionaries:(NSArray *)itemArray withCollectionID:(NSString *)collectionID {
    NSMutableArray * destinationArray = [NSMutableArray array];
    for (NSDictionary * item in itemArray) {
        [destinationArray addObject:[CBItem itemWithData:item withCollectionID:collectionID]];
    }
    return destinationArray;
}

+(CBItem *)itemWithData:(NSDictionary *)inputData withCollectionID:(NSString *)collectionID {
    return [[CBItem alloc] initWithData:inputData withCollectionID:collectionID];
}

-(CBItem *) initWithData: (NSMutableDictionary *) inputData withCollectionID:(NSString *) colID {
    self = [super init];
    self.collectionID = colID;
    self.data = inputData;
    return self;
}

-(id) getValueFor:(NSString *)key {
    return [self.data objectForKey:key];
}

-(void) save {
    if ([self.data objectForKey:@"itemId"]) {
        CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.collectionID];
        [query updateWithChanges:self.data SuccessCallback:^(NSMutableArray *stuff) {
            self.data = (NSMutableDictionary *)[(CBItem *)[stuff objectAtIndex:0] data];
        } ErrorCallback:nil];
    } else {
        CBCollection *col = [[CBCollection alloc] initWithCollectionID: self.collectionID];
        [col createWithData:self.data WithSuccessCallback:^(CBItem *item) {
            self.data = [item data];
        } ErrorCallback:nil];
    }
}

-(NSString *)description {
    return [NSString stringWithFormat:@"Parent Collection <%@>, Payload Dictionary %@", self.collectionID, self.data];
}

-(void) refresh {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.collectionID];
    [query equalTo:[self getValueFor:@"itemId"] for:@"itemId"];
    [query fetchWithSuccessCallback:^(NSMutableArray *stuff) {
        self.data = [(CBItem *)[stuff objectAtIndex:0] data];
    } ErrorCallback:nil];
}

-(void) destroy {
    CBQuery *query = [[CBQuery alloc] init];
    [query equalTo:[self getValueFor:@"itemId"] for:@"itemId"];
    [query removeWithSuccessCallback:^(NSMutableArray *stuff) {
        NSLog(@"Removed: %@", [[(CBItem *)[stuff objectAtIndex:0] data] description]);
    } ErrorCallback:nil];
}

@end
