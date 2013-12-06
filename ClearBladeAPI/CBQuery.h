/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import <Foundation/Foundation.h>
#import "CBItem.h"

#define CBQUERY_NON_OK_ERROR @"Received Non 200 status from server"

/**
Callback for handling successful queries
@param foundItems array of CBItems that match the query
*/
typedef void (^CBQuerySuccessCallback)(NSMutableArray * foundItems);

/**
Callback for handling failed queries
@param error The error that caused the query to fail
@param JSON The json response from the query. Useful if the JSON failed to parse.
*/
typedef void (^CBQueryErrorCallback)(NSError * error, __strong id JSON);

/**
Class representing a query that can be used in operations on Platform
*/
@interface CBQuery : NSObject
/**
A dictonary that holds the keys and values that make up the query
*/
@property (strong, nonatomic) NSMutableDictionary *query;
/**
An array of query objects that is used when you create an or statement and combine two queries.
*/
@property (strong, nonatomic) NSMutableArray *OR;
/**
The string that represent the ID of the collection that will be queried
*/
@property (strong, nonatomic) NSString *collectionID;

/**
Creates a query object that will operate on the collection with the collectionID

*/
+(CBQuery *)queryWithCollectionID:(NSString *)collectionID;
/**
Initializes the query object and sets the collectionID
@param colID A string that is set as collectionID
@return the newly instantiated CBQuery Object
*/
-(CBQuery *) initWithCollectionID: (NSString *) colID;
/**
Sets the collection ID attribute
@param colID A string that will be set as the Collection ID
*/
-(void) setCollectionID:(NSString *) colID;
/**
Fetches from a collection all of the items that match the query that is sent. 
@param successCallback A callback block that handles the returned data
@param failureCallback A callback block that handles errors returned
*/
-(void) fetchWithSuccessCallback:(CBQuerySuccessCallback)successCallback
               withErrorCallback:(CBQueryErrorCallback)failureCallback;
/**
Updates on the platform all the items that match the query sent
@param changes A dictoinary of all the changes that will be applied to the items that match the query
@param successCallback A callback block that handles the returned data
@param failureCallback A callback block that handles the errors returned
*/
-(void) updateWithChanges:(NSDictionary *)changes
      withSuccessCallback:(CBQuerySuccessCallback)successCallback
        withErrorCallback:(CBQueryErrorCallback)failureCallback;

/**
Inserts the object into the collection. Ignores any query parameters
@param item The item to be inserted into the collection
@param successCallback A callback block that handles the return data
@param errorCallback A callback block that handles the errors returned
*/
-(void) insertItem:(CBItem *)item
withSuccessCallback:(CBQuerySuccessCallback)successCallback
 withErrorCallback:(CBQueryErrorCallback)errorCallback;

/**
Remove from the platform all of the items that match the query sent
@param successCallback A callback block that handles the returned data
@param failureCallback A callback block that handles the errors returned
*/
-(void) removeWithSuccessCallback:(CBQuerySuccessCallback)successCallback
                withErrorCallback:(CBQueryErrorCallback)failureCallback;
/**
Creates an equality clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) equalTo: (NSString *) value for: (NSString *)key;
/**
Creates an inequality clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) notEqualTo: (NSString *) value for: (NSString *)key;
/**
Creates a greater than clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) greaterThan: (NSString *) value for: (NSString *)key;
/**
Creates a less than clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) lessThan: (NSString *) value for: (NSString *)key;
/**
Creates a greater than or equal to clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) greaterThanEqualTo: (NSString *) value for: (NSString *)key;
/**
Creates a less than or equal to clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) lessThanEqualTo: (NSString *) value for: (NSString *)key;

@end
