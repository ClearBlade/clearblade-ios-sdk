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
#import "CBQuery.h"
#import "CBAPI.h"
/**
Class for dealing with ClearBlade Platform Collections.
*/
@interface CBCollection : NSObject
/**
The string that represents the collection ID.
*/
@property (strong, nonatomic) NSString *collectionID;
/**
Initialize a new CBCollection object
@param colID The string that will be used to identify the collection on the server
@returns a newly initialized object
*/
-(id) initWithCollectionID: (NSString *)colID;
/**
Fetches the entire collection from the Platform. The returned data will be returned to the block you provide
@param successCallback Callback Block to handle successfully returned data
@param failureCallback Callback Block to handle errors returned
*/
-(void) fetchWithSuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback;
/**
Fetches all data from the collection that matches a particular query
@param query A CBQuery object that defines what you want returned from the Platform
@param successCallback Callback Block to handle successfully returned data
@param failureCallback Callback Block to handle errors returned
*/
-(void) fetchWithQuery: (CBQuery*) query SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback;
/**
Creates a new Item in the collection in the Platform. This creates a new item on the server.
@param data A Dictionary that contains the object that you want the item in the platform to represent
@param successCallback Callback Block to handle successfully returned data
@param failureCallback Callback Block to handle errors returned
*/
-(void) createWithData: (NSMutableDictionary *)data WithSuccessCallback: (void (^)(CBItem *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback;
/**
Updates an item or a set of items on the Platform that match the given query.
@param query A CBQuery object that defines what you want updated on the Platform
@param changes A Dictionary containing all of the changes that you want to make on items that match the query.
@param successCallback Callback Block to handle successfully returned data
@param failureCallback Callback Block to handle errors returned
*/
-(void) updateWithQuery: (CBQuery *) query WithChanges:(NSMutableDictionary *)changes SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback;
/**
Removes an item or a set of items on the Platform that match the given query.
@param query A CBQuery object that defines what you want removed from the Platform
@param successCallback Callback Block to handle successfully returned data
@param failureCallback Callback Block to handle errors returned
*/
-(void) removeWithQuery: (CBQuery*) query SuccessCallback: (void (^)(NSMutableArray *))successCallback ErrorCallback: (void (^)(NSError *, __strong id))failureCallback;

@end
