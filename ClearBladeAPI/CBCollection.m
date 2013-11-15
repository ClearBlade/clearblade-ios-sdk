/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBCollection.h"
#import "CBHTTPClient.h"
#import <AFNetworking/AFNetworking.h>
#import "ClearBlade.h"
#import "CBItem.h"

@implementation CBCollection {
    CBHTTPClient *cbClient;
}

@synthesize collectionID = _collectionID;

+(CBCollection *)collectionWithID:(NSString *)collectionID {
    return [[CBCollection alloc] initWithCollectionID:collectionID];
}

-(id) initWithCollectionID:(NSString *)colID {
    self = [super init];
    
    self.collectionID = colID;
    return self;
}

-(void) fetchWithSuccessCallback: (void (^)(NSMutableArray *))successCallback  ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    [[CBQuery queryWithCollectionID:self.collectionID] fetchWithSuccessCallback:successCallback ErrorCallback:failureCallback];
}

-(void) fetchWithQuery: (CBQuery *) query SuccessCallback: (void (^)(NSMutableArray *)) successCallback  ErrorCallback: (void (^)(NSError *, __strong id)) failureCallback {
    query.collectionID = self.collectionID;
    [query fetchWithSuccessCallback:successCallback ErrorCallback:failureCallback];
}

-(void) createWithData: (NSMutableDictionary *)data WithSuccessCallback: (void (^)(CBItem *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://platform.clearblade.com"]];
    [client setAppKey:[NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]]];
    NSString *path = [NSString stringWithFormat:@"api/%@", self.collectionID];
    NSMutableURLRequest *createRequest = [client requestWithMethod:@"POST" path:path parameters:nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    [createRequest setHTTPBody:jsonData];
    [createRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [createRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:createRequest
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        CBItem *newItem = [[CBItem alloc] initWithData:JSON withCollectionID:self.collectionID];
        successCallback(newItem);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failureCallback(error, JSON);
    }];
    [operation start];
}

-(void) updateWithQuery: (CBQuery *) query WithChanges:(NSMutableDictionary *)changes SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    query.collectionID = self.collectionID;
    [query updateWithChanges:changes SuccessCallback:successCallback ErrorCallback:failureCallback];
}

-(void) removeWithQuery: (CBQuery*) query SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    query.collectionID = self.collectionID;
    [query removeWithSuccessCallback:successCallback ErrorCallback:failureCallback];
}

@end
