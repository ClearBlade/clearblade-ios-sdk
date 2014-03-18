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
#import "CBUser.h"

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
The string that represent the ID of the collection that will be queried
*/
@property (strong, nonatomic) NSString *collectionID;

/**
 The user that is making the query. It defaults to [Clearblade settings].mainUser.
 */
@property (strong, nonatomic) CBUser *user;

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
@param collectionID The ID of the collection to insert the item into
@param successCallback A callback block that handles the return data
@param errorCallback A callback block that handles the errors returned
*/
-(void) insertItem:(CBItem *)item
intoCollectionWithID:(NSString *)collectionID
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
-(CBQuery *) equalTo: (id) value for: (NSString *)key;
/**
Creates an inequality clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) notEqualTo: (id) value for: (NSString *)key;
/**
Creates a greater than clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) greaterThan: (NSNumber *) value for: (NSString *)key;
/**
Creates a less than clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) lessThan: (NSNumber *) value for: (NSString *)key;
/**
Creates a greater than or equal to clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) greaterThanEqualTo:(NSNumber *) value for: (NSString *)key;
/**
Creates a less than or equal to clause and adds it to the query
@param value A string that gets set as the value for the given key
@param key A string that is used as the key for the given value
@return The query with the new clause added
*/
-(CBQuery *) lessThanEqualTo: (NSNumber *) value for: (NSString *)key;
/**
Adds an Or Clause to the query. This makes it so all previous clauses
are placed to the leftside of the OR, and now all future clauses will 
be added to the rightside of the OR. 
This edits the query in place, so it's returning the same object
 
Or clauses are the topmost section of a query, so any Or clause that's added
will be to the top. Below is how this maps to SQL

CBQuery Example:
[[[[[[CBQuery queryWithCollectionID] equalTo:@"value1" for:@"key1"] 
                                     startNextOrClause]
                                     equalTo:@"value2" for:@"key2"]
                                     equalTo:@"value3" for:@"key3"]
                                     startNextOrClause]
                                     equalTo:@"value4" for @"key4"]
SQL Example
WHERE "key1" = "value1" OR "key2" = "value2" AND "key3" = "value3" OR "key4" = "value4"
 
@return This query with the new Or clause
*/
-(CBQuery *) startNextOrClause;
/**
Adds another CBQuery as an OR clause. This allows you to create two
separate CBQuery objects to then OR together.
@param orQuery A CBQuery to be OR'd to the calling CBQuery.
 
Example:
CBQuery *firstQuery = [CBQuery queryWithCollectionID:@"f28faaa10a8ca5a5f2f5acd297cc01"]
[firstQuery equalTo:@"value1" for:@"key1"]
[firstQuery equalTo:@"value2" for:@"key2"]
CBQuery *secondQuery = [CBQuery queryWithCollectionID:@"f28faaa10a8ca5a5f2f5acd297cc01"]
[secondQuery equalTo@"value3" for:@"key3"]
CBQuery *thirdQuery = [firstQuery addQueryAsOrClauseUsingQuery:secondQuery]

In the example, thirdQuery would be equivalent to this SQL:
 WHERE "key1" = "value1" AND "key2" = "value2" OR "key3" = "value3"
*/
-(CBQuery *)addQueryAsOrClauseUsingQuery:(CBQuery *)orQuery;

@end
