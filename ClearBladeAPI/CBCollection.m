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

@synthesize collectionID;

-(id) initWithCollectionID:(NSString *)colID {
    self = [super init];
    
    collectionID = colID;
    return self;
}

-(void) fetchWithSuccessCallback: (void (^)(NSMutableArray *))successCallback  ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-23-23-31-115.compute-1.amazonaws.com:8080"]];
    [client setAppKey: [NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]] ];
    NSString *path = [NSString stringWithFormat:@"api/%@", collectionID];
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:path parameters:nil];
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"DATA: %@", [JSON description]);
        NSMutableArray *arr = [NSMutableArray arrayWithArray:JSON];
        NSMutableArray *arrayOfItems = [[NSMutableArray alloc]init];
        for (int i = 0; i < [arr count]; i++) {
            NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
            for (id key in arr[i]) {
               [newdict setObject:[arr[i] objectForKey:key] forKey:key];
            }
            CBItem *newItem = [[CBItem alloc] initWithData: newdict collectionID: collectionID];
            [arrayOfItems addObject:newItem];
            
        }
        successCallback(arrayOfItems);
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failureCallback(error, JSON);
    }];
    [operation start];
}

-(void) fetchWithQuery: (CBQuery *) query SuccessCallback: (void (^)(NSMutableArray *)) successCallback  ErrorCallback: (void (^)(NSError *, __strong id)) failureCallback {
    if([query.OR count] < 1) {
        [query.OR addObject:query.query];
    }
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-23-23-31-115.compute-1.amazonaws.com:8080"]];
    [client setAppKey:[NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]]];
    NSString *path = [NSString stringWithFormat:@"api/%@", collectionID];
    NSMutableArray *metaQuery = [[NSMutableArray alloc] initWithObjects:query.OR, nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:metaQuery options:0 error:nil];
    NSString* jsonString = [[NSString alloc] initWithBytes:[jsonData bytes] length:[jsonData length] encoding:NSUTF8StringEncoding];
    NSMutableDictionary *queryParam = [[NSMutableDictionary alloc] init];
    [queryParam setValue:jsonString forKey:@"query"];
    NSMutableURLRequest *request = [client requestWithMethod:@"GET" path:path parameters:queryParam];
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

-(void) createWithData: (NSMutableDictionary *)data WithSuccessCallback: (void (^)(CBItem *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-23-23-31-115.compute-1.amazonaws.com:8080"]];
    [client setAppKey:[NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]]];
    NSString *path = [NSString stringWithFormat:@"api/%@", collectionID];
    NSMutableURLRequest *request = [client requestWithMethod:@"POST" path:path parameters:nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:data options:0 error:nil];
    [request setHTTPBody:jsonData];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    NSLog(@"Request: %@", [request description]);
    NSLog(@"Request: %@", [data description]);
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//        NSMutableArray *arr = [NSMutableArray arrayWithArray:JSON];
//        NSMutableArray *arrayOfItems = [[NSMutableArray alloc]init];
//        for (int i = 0; i < [arr count]; i++) {
//            for (id key in arr[i]) {
//                NSMutableDictionary *newdict = [[NSMutableDictionary alloc] init];
//                for (id secondKey in [arr[i] objectForKey:key]) {
//                    [newdict setObject:[[arr[i] objectForKey:key] objectForKey:secondKey] forKey:secondKey];
//                }
//                CBItem *newItem = [[CBItem alloc] initWithData: newdict collectionID:collectionID];
//                [arrayOfItems addObject:newItem];
//            }
//        }
        CBItem *newItem = [[CBItem alloc] initWithData:JSON collectionID:collectionID];
        successCallback(newItem);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        failureCallback(error, JSON);
    }];
    [operation start];
}

-(void) updateWithQuery: (CBQuery *) query WithChanges:(NSMutableDictionary *)changes SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    if([query.OR count] < 1) {
        [query.OR addObject:query.query];
    }
    NSMutableArray *metaQuery = [[NSMutableArray alloc] initWithObjects:[query OR], nil];
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
		NSLog(@"%@", [JSON description]);
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

-(void) removeWithQuery: (CBQuery*) query SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback {
    if([query.OR count] < 1) {
        [query.OR addObject:query.query];
    }
    CBHTTPClient *client = [[CBHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://ec2-23-23-31-115.compute-1.amazonaws.com:8080"]];
    [client setAppKey:[NSString stringWithFormat:@"%@", [ClearBlade appKey]] AppSecret:[NSString stringWithFormat:@"%@", [ClearBlade appSecret]]];
    NSString *path = [NSString stringWithFormat:@"api/%@", collectionID];
    NSMutableArray *metaQuery = [[NSMutableArray alloc] initWithObjects:query.OR, nil];
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
