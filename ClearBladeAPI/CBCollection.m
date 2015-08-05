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
#import "ClearBlade.h"
#import "CBItem.h"
#import "CBHTTPRequestResponse.h"
#import "CBHTTPRequest.h"

@implementation CBCollection
@synthesize collectionID = _collectionID;

+(CBCollection *)collectionWithID:(NSString *)collectionID {
    return [[CBCollection alloc] initWithCollectionID:collectionID];
}

-(id) initWithCollectionID:(NSString *)colID {
    self = [super init];
    
    self.collectionID = colID;
    return self;
}

-(void) fetchWithSuccessCallback:(CBQuerySuccessCallback)successCallback
               withErrorCallback:(CBQueryErrorCallback)failureCallback {
    [[CBQuery queryWithCollectionID:self.collectionID] fetchWithSuccessCallback:successCallback
                                                              withErrorCallback:failureCallback];
}

-(void) fetchWithQuery:(CBQuery *) query
   withSuccessCallback:(CBQuerySuccessCallback) successCallback
     withErrorCallback:(CBQueryErrorCallback) failureCallback {
    query.collectionID = self.collectionID;
    [query fetchWithSuccessCallback:successCallback withErrorCallback:failureCallback];
}

-(void) createWithData:(NSMutableDictionary *)data
   withSuccessCallback:(CBItemSuccessCallback)successCallback
     withErrorCallback:(CBItemErrorCallback)failureCallback {
    CBItem * item = [CBItem itemWithData:data withCollectionID:self.collectionID];
    [item saveWithSuccessCallback:successCallback withErrorCallback:failureCallback];
}

-(void) updateWithQuery:(CBQuery *) query
            withChanges:(NSMutableDictionary *)changes
    withSuccessCallback:(CBOperationSuccessCallback)successCallback
      withErrorCallback:(CBQueryErrorCallback)failureCallback {
    query.collectionID = self.collectionID;
    [query updateWithChanges:changes withSuccessCallback:successCallback withErrorCallback:failureCallback];
}

-(void) removeWithQuery:(CBQuery *)query
    withSuccessCallback:(CBOperationSuccessCallback)successCallback
      withErrorCallback:(CBQueryErrorCallback)failureCallback {
    query.collectionID = self.collectionID;
    [query removeWithSuccessCallback:successCallback withErrorCallback:failureCallback];
}


+(NSDictionary*)fetchCollectionColumns:(ClearBlade*)cb withUser:(CBUser *)user withCollectionID:(NSString*)colid{
    NSError*__autoreleasing e;
    NSData* d;
    NSDictionary* dict;
    NSString* ep = [NSString stringWithFormat:@"/api/v/2/data/%@/columns", colid];
    //is this correct?!
    CBHTTPRequest* req = [CBHTTPRequest alloc];
    req = [req initWithClearBladeSettings: cb withMethod:@"GET" withUser:user withEndpoint:ep];
    d = [req executeWithError:&e];
    if(e){
        //todo: log errors here
        return nil;
    }else{
        dict = [NSJSONSerialization JSONObjectWithData:d options:0 error:&e];
        if(e){
            return nil;
        }else{
            return dict;
        }
    }
}


+(NSInteger) fetchCollectionCount: (ClearBlade*)cb
                 withCollectionID:(NSString*)colid
                         withUser:(CBUser*)user
                        withQuery:(CBQuery*)qry{
    
    NSString* ep;
    NSDictionary* dict;
    NSError*__autoreleasing e;
    CBHTTPRequest* req = [CBHTTPRequest alloc];
    NSData* d;
    if(qry){
        NSDictionary* parameters = [qry fetchQuery];
        if([parameters count] != 0){
            NSDictionary* params = @{@"query":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:parameters options:0 error:&e] encoding:NSUTF8StringEncoding]};
            if(e){
                //log?
                return -1;
            }

            NSString* queryString = [req encodeQuery:params[@"query"]];
            ep = [NSString stringWithFormat:@"/api/v/2/%@/data/count?query=%@", colid, queryString];
                                     
        }else{
            //simpler to duplicate the work than to restructure the code
            ep = [NSString stringWithFormat:@"/api/v/2/%@/data/count", colid];
        }
    }else{
        ep = [NSString stringWithFormat:@"/api/v/2/%@/data/count", colid];
    }
    req = [req initWithClearBladeSettings: cb withMethod:@"GET" withUser:user withEndpoint:ep];
    d = [req executeWithError:&e];
    if (e){ return -1; }
    dict = [NSJSONSerialization JSONObjectWithData:d options:0 error:&e];
    if(e){return -1; }
    return (NSInteger)dict[@"count"];
}



-(NSString *)description {
    return [NSString stringWithFormat:@"Collection with ID <%@>", self.collectionID];
}
@end
