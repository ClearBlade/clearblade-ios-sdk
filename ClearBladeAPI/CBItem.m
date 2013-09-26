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

@synthesize collectionID;
@synthesize data;

-(CBItem *) initWithData: (NSMutableDictionary *) inputData collectionID:(NSString *) colID {
    self = [super init];
    collectionID = colID;
    data = inputData;
    return self;
}

-(id) getValueFor:(NSString *)key {
    return [data objectForKey:key];
}

-(void) save {
    if ([data objectForKey:@"itemId"]) {
        CBQuery *query = [[CBQuery alloc] initWithCollectionID:collectionID];
        [query updateWithChanges:data SuccessCallback:^(NSMutableArray *stuff) {
	data = [[stuff objectAtIndex:0] data];
        } ErrorCallback:nil];
    } else {
        CBCollection *col = [[CBCollection alloc] initWithCollectionID: collectionID];
        [col createWithData:data WithSuccessCallback:^(CBItem *item) {
            data = [item data];
        } ErrorCallback:nil];
    }
}

-(void) refresh {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:collectionID];
    [query equalTo:[self getValueFor:@"itemId"] for:@"itemId"];
    [query fetchWithSuccessCallback:^(NSMutableArray *stuff) {
        data = [(CBItem *)[stuff objectAtIndex:0] data];
    } ErrorCallback:nil];
}

-(void) destroy {
    CBQuery *query = [[CBQuery alloc] init];
    [query equalTo:[self getValueFor:@"itemId"] for:@"itemId"];
    [query removeWithSuccessCallback:^(NSMutableArray *stuff) {
        NSLog(@"Removed: %@", [[[stuff objectAtIndex:0] data] description]);
    } ErrorCallback:nil];
}

@end
