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
#import "CBHTTPRequestResponse.h"
#import "CBItem.h"
#import "ClearBlade.h"
#import "CBUser.h"
#define CBQUERY_EQ @"EQ"
#define CBQUERY_NEQ @"NEQ"
#define CBQUERY_GT @"GT"
#define CBQUERY_GTE @"GTE"
#define CBQUERY_LT @"LT"
#define CBQUERY_LTE @"LTE"
#define CBQUERY_REGEX @"RE"
#define CBQUERY_ASC @"ASC"
#define CBQUERY_DESC @"DESC"

@interface CBQuery ()
@property (strong, nonatomic) NSMutableDictionary *query;
@property (strong, nonatomic) NSMutableArray *OR;

-(NSDictionary *)dictionaryValuesToStrings:(NSDictionary *)dictionary;
@end

@implementation CBQuery

@synthesize OR = _OR;
@synthesize query = _query;
@synthesize collectionID = _collectionID;
@synthesize user = _user;

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

+(CBQuery *)queryWithCollectionName:(NSString *)collectionName {
    return [[CBQuery alloc] initWithCollectionName:collectionName];
}

-(CBQuery *) initWithCollectionName:(NSString *)colName {
    self = [super init];
    if (self) {
        self.collectionName = colName;
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
    return [self addFilterWithValue:value forKey:key inQueryParameter:CBQUERY_EQ];
}

-(CBQuery *) notEqualTo:(id)value for:(NSString *)key {
    return [self addFilterWithValue:value forKey:key inQueryParameter:CBQUERY_NEQ];
}

-(CBQuery *) greaterThan:(id)value for:(NSString *)key {
    return [self addFilterWithValue:value forKey:key inQueryParameter:CBQUERY_GT];
}

-(CBQuery *) lessThan:(id)value for:(NSString *)key {
    return [self addFilterWithValue:value forKey:key inQueryParameter:CBQUERY_LT];
}

-(CBQuery *) greaterThanEqualTo:(id)value for:(NSString *)key {
    return [self addFilterWithValue:value forKey:key inQueryParameter:CBQUERY_GTE];
}

-(CBQuery *) lessThanEqualTo:(id)value for:(NSString *)key {
    return [self addFilterWithValue:value forKey:key inQueryParameter:CBQUERY_LTE];
}

-(CBQuery *) matches:(NSString *)regex for:(NSString *)key {
    return [self addFilterWithValue:regex forKey:key inQueryParameter:CBQUERY_REGEX];
}


-(CBQuery *)ascendingOnColumn:(NSString *)column {
    return [self addSortWithDirection:CBQUERY_ASC forColumn:column];
}

-(CBQuery *)descendingOnColumn:(NSString *)column {
    return [self addSortWithDirection:CBQUERY_DESC forColumn:column];
}

-(CBQuery *)addQueryAsOrClauseUsingQuery:(CBQuery *)orQuery {
    if (!orQuery) {
        return self;
    }
    NSMutableArray *filterArray =  [self.query objectForKey:@"FILTERS"];
    [filterArray addObject:[[[orQuery query] objectForKey:@"FILTERS"] objectAtIndex:0]];
    return self;
}

-(CBQuery *)addSortWithDirection:(NSString *)direction forColumn:(NSString *)column {
    NSMutableArray *sortArray = [self.query objectForKey:@"SORT"];
    if (sortArray) {
        [sortArray addObject:@{direction: column}];
    } else {
        sortArray = [NSMutableArray arrayWithObject:@{direction: column}];
        [self.query setObject:sortArray forKey:@"SORT"];
    }
    return self;
}

-(CBQuery *)setPageNum:(NSNumber *)num {
    [self.query setObject:num forKey:@"PAGENUM"];
    return self;
}

-(CBQuery *)setPageSize:(NSNumber *)size {
    [self.query setObject:size forKey:@"PAGESIZE"];
    return self;
}

-(CBQuery *)addFilterWithValue:(id)value forKey:(NSString *)key inQueryParameter:(NSString *)parameter {
    //Log an error if an unsupported type is included, and return the unaltered query. If we attempt to continue with an unsupported class the app will crash
    if (![value isKindOfClass:[NSDate class]] &&
        ![value isKindOfClass:[NSString class]] &&
        ![value isKindOfClass:[NSNumber class]] &&
        ![value isKindOfClass:[NSArray class]] &&
        ![value isKindOfClass:[NSDictionary class]] &&
        ![value isKindOfClass:[NSNull class]]) {
        CBLogError(@"Type of value added to filter is not supported. Must be NSDate, NSString, NSNumber, NSArray, NSDictionary, or NSNull");
        return self;
    }
    NSMutableDictionary *query = self.query;
    NSMutableArray *filterArray = [query objectForKey:@"FILTERS"][0];
    //if the value is type NSDate we must convert to NSString, since NSJSONSerialization doesn't support NSDate
    if ([value isKindOfClass:[NSDate class]]) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss'Z'";
        value = [dateFormatter stringFromDate:value];
    }
    NSDictionary *keyValuePair = @{key: value};
    NSMutableArray *conditionArray = [NSMutableArray arrayWithObject:keyValuePair];
    if (!filterArray) {
        filterArray = [NSMutableArray arrayWithObject:[NSMutableArray arrayWithObject:@{parameter: conditionArray}]];
        [query setObject:filterArray forKey:@"FILTERS"];
    } else {
        NSMutableDictionary *parameterDict = [filterArray objectAtIndex:0];
        NSMutableArray *existingConditionArray = [parameterDict objectForKey:parameter];
        if (!existingConditionArray) {
            [parameterDict setObject:conditionArray forKey:parameter];
        } else {
            [existingConditionArray addObject:keyValuePair];
        }
    }
    return self;
}

-(CBHTTPRequest *)requestWithMethod:(NSString *)method withParameters:(NSDictionary *)parameters {
    if (self.collectionName != nil) {
        return [CBHTTPRequest requestWithCollectionName:method withCollectionName:self.collectionName withParameters:parameters withUser:self.user];
    } else {
        return [CBHTTPRequest requestWithMethod:method withCollection:self.collectionID withParameters:parameters withUser:self.user];
    }
}

-(CBUser *)user {
    if (!_user) {
        _user = [[ClearBlade settings] mainUser];
    }
    return _user;
}

-(void)executeRequest:(CBHTTPRequest *)apiRequest
  withSuccessCallback:(CBQuerySuccessCallback)successCallback
  withFailureCallback:(CBQueryErrorCallback)failureCallback {
    [apiRequest executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        NSError * error;
        NSDictionary *responseDict;
        CBQueryResponse *successResponse;
        if (response.response.statusCode != 200) {
            error = [NSError errorWithDomain:CBQUERY_NON_OK_ERROR  code:response.response.statusCode userInfo:nil];
        }
        if (!error) {
            responseDict = [NSJSONSerialization JSONObjectWithData:response.responseData options:0 error:&error];
            successResponse = [[CBQueryResponse alloc] initWithDictionary:responseDict withCollectionID:self.collectionID];
        }
        if (error) {
            if (failureCallback) {
                failureCallback([NSError errorWithDomain:response.responseString
                                                    code:response.response.statusCode
                                                userInfo:nil], response.responseData);
            }
            return;
        }
        if (successCallback) {
            successCallback(successResponse);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        if (failureCallback) {
            failureCallback(error, response.responseData);
        }
    }];
}

-(void) executeOperation:(CBHTTPRequest *)apiRequest
     withSuccessCallback:(CBOperationSuccessCallback)successCallback
     withFailureCallback:(CBQueryErrorCallback)failureCallback {
    [apiRequest executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        NSError * error;
        NSMutableArray *successResponse;
        if (response.response.statusCode != 200) {
            error = [NSError errorWithDomain:CBQUERY_NON_OK_ERROR  code:response.response.statusCode userInfo:nil];
        }
        if (!error) {
            // Since this is used for removals, updates, and inserts we know we will get back an array
            successResponse = [NSJSONSerialization JSONObjectWithData:response.responseData options:0 error:&error];
        }
        if (error) {
            if (failureCallback) {
                failureCallback([NSError errorWithDomain:response.responseString
                                                    code:response.response.statusCode
                                                userInfo:nil], response.responseData);
            }
            return;
        }
        if (successCallback) {
            successCallback(successResponse);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        if (failureCallback) {
            failureCallback(error, response.responseData);
        }
    }];
}

-(void) fetchWithSuccessCallback:(CBQuerySuccessCallback)successCallback
               withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSDictionary * parameters = nil;
    if (self.OR.count > 1 || self.query.count > 0) {
        parameters = @{@"query":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self fetchQuery]
                                                                                               options:0
                                                                                                 error:NULL]
                                                      encoding:NSUTF8StringEncoding]};
    }
    CBHTTPRequest *fetchRequest = [self requestWithMethod:@"GET" withParameters:parameters];
    [self executeRequest:fetchRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}

-(void) updateWithChanges:(NSMutableDictionary *)changes
      withSuccessCallback:(CBOperationSuccessCallback)successCallback
        withErrorCallback:(CBQueryErrorCallback)failureCallback {
    CBHTTPRequest *updateRequest = [self requestWithMethod:@"PUT" withParameters:nil];
    updateRequest.HTTPBody = [NSJSONSerialization dataWithJSONObject:@{@"query": [self operationQuery], @"$set": changes}
                                                             options:0
                                                               error:NULL];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [updateRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    CBLogDebug(@"Executing Update with %@ and changes %@", self, changes);
    [self executeOperation:updateRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
}


-(void) removeWithSuccessCallback:(CBOperationSuccessCallback)successCallback
                withErrorCallback:(CBQueryErrorCallback)failureCallback {
    NSString* jsonString = [[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:[self operationQuery]
                                                                                          options:0
                                                                                            error:NULL]
                                                 encoding:NSUTF8StringEncoding];
    CBHTTPRequest *removeRequest = [self requestWithMethod:@"DELETE" withParameters:@{@"query": jsonString}];
    CBLogDebug(@"Executing remove with %@", self);
    [self executeOperation:removeRequest withSuccessCallback:successCallback withFailureCallback:failureCallback];
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

// Generates a query for fetches
-(NSDictionary *)fetchQuery {
    return self.query;
}

// Generates a query for inserts, updates, and removes
-(NSArray *)operationQuery {
    NSMutableArray * finalOrArray = [NSMutableArray array];
    for (NSDictionary *orClause in [self.query objectForKey:@"FILTERS"]) {
        NSMutableArray * keyValuePairList = [NSMutableArray array];
        for (NSDictionary *or in orClause) {
            for (id key in or.keyEnumerator) {
                [keyValuePairList addObject:@{key:or[key]}];
            }
        }
        [finalOrArray addObject:keyValuePairList];
    }
    return finalOrArray;
}

-(void)insertItem:(CBItem *)item
intoCollectionWithID:(NSString *)collectionID
withSuccessCallback:(CBOperationSuccessCallback)successCallback
withErrorCallback:(CBQueryErrorCallback)errorCallback {
    item.collectionID = collectionID;
    CBHTTPRequest *insertRequest = [self requestWithMethod:@"POST" withParameters:nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:[self dictionaryValuesToStrings:item.data] options:0 error:NULL];
    [insertRequest setHTTPBody:jsonData];
    [insertRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [insertRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    //CBLogDebug(@"Inserting %@ into collection %@", item, collectionID);
    NSLog(@"Request: %@: Inserting %@ into collection %@", insertRequest, item, collectionID);
    [self executeOperation:insertRequest withSuccessCallback:successCallback withFailureCallback:errorCallback];
}

-(NSString *)description {
    NSString * whereClause = @"";
    bool isFirst = true;
    for (NSDictionary *orClause in [self.query objectForKey:@"FILTERS"]) {
        if (isFirst) {
            isFirst = false;
        } else if (orClause.count > 0) { //Want to ignore the situation where the last dictionary is empty
            whereClause = [whereClause stringByAppendingString:@" OR "];
        }
        for (NSMutableDictionary *or in orClause) {
            for (NSString *key in or.keyEnumerator) {
                NSString *operator = nil;
                if ([key isEqualToString:CBQUERY_EQ]) {
                    operator = @"=";
                } else if ([key isEqualToString:CBQUERY_NEQ]) {
                    operator = @"!=";
                } else if ([key isEqualToString:CBQUERY_GT]) {
                    operator = @">";
                } else if ([key isEqualToString:CBQUERY_GTE]) {
                    operator = @">=";
                } else if ([key isEqualToString:CBQUERY_LT]) {
                    operator = @"<";
                } else if ([key isEqualToString:CBQUERY_LTE]) {
                    operator = @"<=";
                } else if ([key isEqualToString:CBQUERY_REGEX]) {
                    operator = @"~";
                }
                bool isFirstFieldInAndBlock = true;
                for (NSDictionary * field in [or objectForKey:key]) {
                    if (isFirstFieldInAndBlock) {
                        isFirstFieldInAndBlock = false;
                    } else {
                        whereClause = [whereClause stringByAppendingString:@" AND "];
                    }
                    for (NSString * fieldName in field.keyEnumerator) {
                        whereClause = [whereClause stringByAppendingString:
                                       [NSString stringWithFormat:@"%@ %@ '%@'", fieldName, operator, [field objectForKey:fieldName]]];
                    }
                }
            }
        }
    }
    return [NSString stringWithFormat:@"Query: Collection ID <%@>, Where Clause <%@>", self.collectionID, whereClause];
}

@end
