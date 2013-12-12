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
#import "CBHTTPRequest.h"
#import "CBItem.h"
#import "ClearBlade.h"

@interface CBQuery ()
-(NSDictionary *)dictionaryValuesToStrings:(NSDictionary *)dictionary;
@end

@implementation CBQuery

@synthesize OR = _OR;
@synthesize query = _query;
@synthesize collectionID = _collectionID;

+(CBQuery *)queryWithCollectionID:(NSString *)collectionID {
    return [[CBQuery alloc] initWithCollectionID:collectionID];
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

-(CBQuery *) equalTo:(id)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"EQ"];
    return self;
}

-(CBQuery *) notEqualTo:(id)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"NEQ"];
}

-(CBQuery *) greaterThan:(NSNumber *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"GT"];
}

-(CBQuery *) lessThan:(NSNumber *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"LT"];
}

-(CBQuery *) greaterThanEqualTo:(NSNumber *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"GTE"];
}

-(CBQuery *) lessThanEqualTo:(NSNumber *)value for:(NSString *)key {
    return [self addParameterWithValue:value forKey:key inQueryParameter:@"LTE"];
}

-(CBQuery *) addParameterWithValue:(id)value forKey:(NSString *)key inQueryParameter:(NSString *)parameter {
    NSMutableDictionary * query = self.query;
    NSDictionary * keyValuePair = [self dictionaryValuesToStrings:@{key: value}];
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
    return [CBHTTPRequest requestWithMethod:method withCollection:self.collectionID withParameters:parameters];
}

-(void)executeRequest:(NSURLRequest *)apiRequest
  withSuccessCallback:(CBQuerySuccessCallback)successCallback
  withFailureCallback:(CBQueryErrorCallback)failureCallback {
    void (^completionHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse * response, NSData * data, NSError * error) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response; //response will always be NSHTTPURLResponse
        NSURLRequest * request = apiRequest;
        
        id JSON;
        if (!error && httpResponse.statusCode != 200) {
            error = [NSError errorWithDomain:CBQUERY_NON_OK_ERROR  code:httpResponse.statusCode userInfo:nil];
        }
        if (!error) {
            JSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
        }
        NSString * text = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        if (error) {
            if (failureCallback) {
                failureCallback(error, data);
            }
            return;
        }
        NSMutableArray * responseItems = [NSMutableArray array];
        if ([JSON isKindOfClass:[NSDictionary class]]) {
            responseItems = @[JSON].mutableCopy;
        } else {
            responseItems = JSON;
        }
        NSMutableArray * itemArray = [CBItem arrayOfCBItemsFromArrayOfDictionaries:responseItems withCollectionID:self.collectionID];
        if (successCallback) {
            successCallback(itemArray);
        }
    };
    
    [NSURLConnection sendAsynchronousRequest:apiRequest
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:completionHandler];
}

-(void) fetchWithSuccessCallback:(CBQuerySuccessCallback)successCallback
               withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self fullQuery]
                                                                                          options:0
                                                                                            error:NULL]
                                                 encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *fetchRequest = [self requestWithMethod:@"GET" withParameters:@{@"query": jsonString}];
    [self executeRequest:fetchRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}

-(void) updateWithChanges:(NSMutableDictionary *)changes
      withSuccessCallback:(CBQuerySuccessCallback)successCallback
        withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSMutableURLRequest *updateRequest = [self requestWithMethod:@"PUT" withParameters:nil];
    updateRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"query": [self fullQuery], @"$set": changes}
                                                             options:0
                                                               error:NULL];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self executeRequest:updateRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}


-(void) removeWithSuccessCallback:(CBQuerySuccessCallback)successCallback
                withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self fullQuery]
                                                                                          options:0
                                                                                            error:NULL]
                                                 encoding:NSUTF8StringEncoding];
    NSMutableURLRequest *removeRequest = [self requestWithMethod:@"DELETE" withParameters:@{@"query": jsonString}];
    [self executeRequest:removeRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}

-(NSDictionary *)dictionaryValuesToStrings:(NSDictionary *)dictionary {
    NSMutableDictionary * stringDictionary = [NSMutableDictionary dictionary];
    for (id key in dictionary.keyEnumerator) {
        id value = [dictionary objectForKey:key];
        if (![value isKindOfClass:[NSNumber class]]) {
            value = [value description];
        }
        [stringDictionary setObject:value forKey:key];
    }
    return stringDictionary;
}
-(NSArray *)fullQuery {
    NSMutableArray * finalOrArray = [NSMutableArray array];
    for (NSDictionary * orClause in self.OR) {
        NSMutableArray * keyValuePairList = [NSMutableArray array];
        for (id key in orClause.keyEnumerator) {
            [keyValuePairList addObject:@{key:orClause[key]}];
        }
        [finalOrArray addObject:keyValuePairList];
    }
    return finalOrArray;
}
-(void)insertItem:(CBItem *)item
withSuccessCallback:(CBQuerySuccessCallback)successCallback
  withErrorCallback:(CBQueryErrorCallback)errorCallback {
    NSMutableURLRequest *insertRequest = [self requestWithMethod:@"POST" withParameters:nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self dictionaryValuesToStrings:item.data] options:0 error:NULL];
    [insertRequest setHTTPBody:jsonData];
    [insertRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [insertRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [self executeRequest:insertRequest withSuccessCallback:successCallback withFailureCallback:errorCallback];
}

@end
