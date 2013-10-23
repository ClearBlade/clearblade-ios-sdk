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

@implementation CBQuery

@synthesize OR;
@synthesize query;
@synthesize collectionID;

-(CBQuery *) initWithCollectionID:(NSString *)colID {
    self = [super init];
    query = [[NSMutableDictionary alloc] init];
    OR = [[NSMutableArray alloc] init];
    
    collectionID = colID;
    return self;
}

-(void) setCollectionID:(NSString *) colID {
    collectionID = colID;
}

-(CBQuery *) equalTo:(NSString *)value for:(NSString *)key {
    if (!([query objectForKey:@"EQ"])) {
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *eqArr = [[NSMutableArray alloc] init];
        [eqDict setObject:value forKey:key];
        [eqArr addObject:eqDict];
        [query setObject:eqArr forKey:@"EQ"];
    } else {
        NSMutableArray *eqArr = [query objectForKey:@"EQ"];
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        [eqDict setValue:value forKey:key];
        [eqArr addObject:eqDict];
    }
    return self;
}

-(CBQuery *) notEqualTo:(NSString *)value for:(NSString *)key {
    if (!([query objectForKey:@"NEQ"])) {
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *eqArr = [[NSMutableArray alloc] init];
        [eqDict setObject:value forKey:key];
        [eqArr addObject:eqDict];
        [query setObject:eqArr forKey:@"NEQ"];
    } else {
        NSMutableArray *eqArr = [query objectForKey:@"NEQ"];
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        [eqDict setValue:value forKey:key];
        [eqArr addObject:eqDict];
    }
    return self;
}

-(CBQuery *) greaterThan:(NSString *)value for:(NSString *)key {
    if (!([query objectForKey:@"GT"])) {
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *eqArr = [[NSMutableArray alloc] init];
        [eqDict setObject:value forKey:key];
        [eqArr addObject:eqDict];
        [query setObject:eqArr forKey:@"GT"];
    } else {
        NSMutableArray *eqArr = [query objectForKey:@"GT"];
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        [eqDict setValue:value forKey:key];
        [eqArr addObject:eqDict];
    }
    return self;
}

-(CBQuery *) lessThan:(NSString *)value for:(NSString *)key {
    if (!([query objectForKey:@"LT"])) {
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *eqArr = [[NSMutableArray alloc] init];
        [eqDict setObject:value forKey:key];
        [eqArr addObject:eqDict];
        [query setObject:eqArr forKey:@"LT"];
    } else {
        NSMutableArray *eqArr = [query objectForKey:@"LT"];
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        [eqDict setValue:value forKey:key];
        [eqArr addObject:eqDict];
    }
    return self;
}

-(CBQuery *) greaterThanEqualTo:(NSString *)value for:(NSString *)key {
    if (!([query objectForKey:@"GTE"])) {
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *eqArr = [[NSMutableArray alloc] init];
        [eqDict setObject:value forKey:key];
        [eqArr addObject:eqDict];
        [query setObject:eqArr forKey:@"GTE"];
    } else {
        NSMutableArray *eqArr = [query objectForKey:@"GTE"];
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        [eqDict setValue:value forKey:key];
        [eqArr addObject:eqDict];
    }
    return self;
}

-(CBQuery *) lessThanEqualTo:(NSString *)value for:(NSString *)key {
    if (!([query objectForKey:@"LTE"])) {
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        NSMutableArray *eqArr = [[NSMutableArray alloc] init];
        [eqDict setObject:value forKey:key];
        [eqArr addObject:eqDict];
        [query setObject:eqArr forKey:@"LTE"];
    } else {
        NSMutableArray *eqArr = [query objectForKey:@"LTE"];
        NSMutableDictionary *eqDict = [[NSMutableDictionary alloc] init];
        [eqDict setValue:value forKey:key];
        [eqArr addObject:eqDict];
    }
    return self;
}

-(void) fetchWithSuccessCallback: (void (^)(NSMutableArray *))successCallback  ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    if([OR count] < 1) {
        [OR addObject:query];
    }
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-23-23-31-115.compute-1.amazonaws.com:8080"]];
    [client setAppKey:[ClearBlade appKey] AppSecret:[ClearBlade appSecret]];
    NSString *path = [NSString stringWithFormat:@"api/%@", collectionID];
    NSMutableArray *metaQuery = [[NSMutableArray alloc] initWithObjects:OR, nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:metaQuery options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] init];
    [queryParam setValue:jsonString forKey:@"query"];
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:path parameters:queryParam];
    NSLog(@"Request: %@", [request description]);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *arrayOfItems;
        if (JSON == NULL) {
            arrayOfItems = [[NSMutableArray alloc] init];
        } else {
            NSLog(@"DATA: %@", [JSON description]);
            NSMutableArray *arr = [NSMutableArray arrayWithArray:JSON];
            arrayOfItems = [[NSMutableArray alloc]init];
            int c = [arr count];
            for (int i = 0; i < c; i++) {
                for (id key in arr[i]) {
                    NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
                    for (id secondKey in [arr[i] objectForKey:key]) {
                        [newdict setObject:[[arr[i] objectForKey:key] objectForKey:secondKey] forKey:secondKey];
                    }
                    CBItem *newItem = [[CBItem alloc] initWithData: newdict collectionID:collectionID];
                    [arrayOfItems addObject:newItem];
                }
            }
        }
        successCallback(arrayOfItems);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failureCallback(error, JSON);
    }];
    [operation start];
}

-(void) updateWithChanges:(NSMutableDictionary *)changes SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    if([OR count] < 1) {
        [OR addObject:query];
    }
    NSMutableArray *metaQuery = [[NSMutableArray alloc] initWithObjects:OR, nil];
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-23-23-31-115.compute-1.amazonaws.com:8080"]];
    [client setAppKey:[NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]]];
    NSString *path = [NSString stringWithFormat:@"api/%@", collectionID];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    [data setObject:metaQuery forKey:@"query"];
    [data setObject:changes forKey:@"$set"];
    NSMutableURLRequest *request = [client requestWithMethod:@"PUT" path:path parameters:nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
		NSMutableArray *arr = [NSMutableArray arrayWithArray:JSON];
        NSMutableArray *arrayOfItems = [[NSMutableArray alloc]init];
        for (int i = 0; i < [arr count]; i++) {
			NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
            for (id key in arr[i]) {
				[newdict setObject:[arr[i] objectForKey: key] forKey: key];
			}
			CBItem *newItem = [[CBItem alloc] initWithData: newdict collectionID:collectionID];
			[arrayOfItems addObject:newItem];
        }
        successCallback(arrayOfItems);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failureCallback(error, JSON);
    }];
    [operation start];
}


-(void) removeWithSuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    if([OR count] < 1) {
        [OR addObject:query];
    }
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-23-23-31-115.compute-1.amazonaws.com:8080"]];
    [client setAppKey:[NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]]];
    NSString *path = [NSString stringWithFormat:@"api/%@", collectionID];
    NSMutableArray *metaQuery = [[NSMutableArray alloc] initWithObjects:OR, nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:metaQuery options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] init];
    [queryParam setValue:jsonString forKey:@"query"];
    NSMutableURLRequest *request = [client requestWithMethod:@"DELETE" path:path parameters:queryParam];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSMutableArray *arr = [NSMutableArray arrayWithArray:JSON];
        NSMutableArray *arrayOfItems = [[NSMutableArray alloc]init];
        for (int i = 0; i < [arr count]; i++) {
            for (id key in arr[i]) {
                NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
                for (id secondKey in [arr[i] objectForKey:key]) {
                    [newdict setObject:[[arr[i] objectForKey:key] objectForKey:secondKey] forKey:secondKey];
                }
                CBItem *newItem = [[CBItem alloc] initWithData: newdict collectionID:collectionID];
                [arrayOfItems addObject:newItem];
            }
        }
        successCallback(arrayOfItems);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failureCallback(error, JSON);
    }];
    [operation start];
}


@end
