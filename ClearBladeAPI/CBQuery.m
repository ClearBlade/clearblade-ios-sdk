/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBQuery.h"
#import "CBHTTPClient.h"
#import <AFNetworking/AFNetworking.h>
#import "CBItem.h"
#import "ClearBlade.h"

@interface CBQuery ()
-(CBHTTPClient *)clientForCollectionID:(NSString *)collectionID;
@end

@implementation CBQuery

@synthesize OR = _OR;
@synthesize query = _query;
@synthesize collectionID = _collectionID;

+(CBQuery *)queryWithCollectionID:(NSString *)collectionID {
    return [[CBQuery alloc] initWithCollectionID:collectionID];
}

-(CBHTTPClient *)clientForCollectionID:(NSString *)collectionID {
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://platform.clearblade.com"]];
    [client setAppKey:[NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]]];
    return client;
}

-(CBQuery *) initWithCollectionID:(NSString *)colID {
    self = [super init];
    if (self) {
        self.collectionID = colID;
    }
    return self;
}

-(NSMutableDictionary *)query {
    if (!_query) {
        _query = [[NSMutableDictionary alloc] init];
    }
    return _query;
}
-(NSMutableArray *)OR {
    if (!_OR) {
        _OR = [NSMutableArray arrayWithObject:self.query];
    }
    return _OR;
}
-(void) setCollectionID:(NSString *) colID {
    _collectionID = colID;
}

-(CBQuery *) equalTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"EQ"];
    return self;
}

-(CBQuery *) notEqualTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"NEQ"];
}

-(CBQuery *) greaterThan:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"GT"];
}

-(CBQuery *) lessThan:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"LT"];
}

-(CBQuery *) greaterThanEqualTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"GTE"];
}

-(CBQuery *) lessThanEqualTo:(NSString *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"LTE"];
}

-(CBQuery *) addParameterWithValue:(NSString *)value forKey:(NSString *)key inQueryParameter:(NSString *)parameter {
    NSMutableDictionary * query = self.query;
    NSDictionary * keyValuePair = @{key: value};
    NSMutableArray * parameterArray = [query objectForKey:parameter];
    if (parameterArray) {
        [parameterArray addObject:keyValuePair];
    } else {
        parameterArray = [NSMutableArray arrayWithObject:keyValuePair];
        [query setObject:parameterArray forKey:parameter];
    }
    return self;
}

-(NSMutableURLRequest *)requestWithMethod:(NSString *)method withParameters:(NSDictionary *)parameters {
    NSString * path = [NSString stringWithFormat:@"api/%@", self.collectionID];
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://platform.clearblade.com"]];
    [client setAppKey:[ClearBlade appKey] AppSecret:[ClearBlade appSecret]];
    return [client requestWithMethod:method path:path parameters:parameters];
}

-(void)executeRequest:(NSURLRequest *)apiRequest
  withSuccessCallback:(void (^)(NSMutableArray *))successCallback
  withFailureCallback:(void (^)(NSError *, __strong id))failureCallback {
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:apiRequest
                                                                                        success:^(NSURLRequest *request, NSHTTPURLResponse * response, id JSON) {
        NSMutableArray * itemArray = [CBItem arrayOfCBItemsFromArrayOfDictionaries:JSON withCollectionID:self.collectionID];
        if (successCallback) {
            successCallback(itemArray);
        }
    } failure:^(NSURLRequest * request, NSHTTPURLResponse * response, NSError * error, id JSON) {
        if (failureCallback) {
            failureCallback(error, JSON);
        }
    }];
    [operation start];
}

-(void) fetchWithSuccessCallback: (void (^)(NSMutableArray *))successCallback  ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[self.OR] options:0 error:nil]
                                                 encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *fetchRequest = [self requestWithMethod:@"GET" withParameters:@{@"query": jsonString}];
    [self executeRequest:fetchRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}

-(void) updateWithChanges:(NSMutableDictionary *)changes SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    NSMutableURLRequest *updateRequest = [self requestWithMethod:@"PUT" withParameters:nil];
    updateRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"query": @[self.OR], @"$set": changes}
                                                             options:0
                                                               error:nil];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self executeRequest:updateRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}


-(void) removeWithSuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:@[self.OR] options:0 error:nil]
                                                 encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *removeRequest = [self requestWithMethod:@"DELETE" withParameters:@{@"query": jsonString}];
    [self executeRequest:removeRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}

@end
