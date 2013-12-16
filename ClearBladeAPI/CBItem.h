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

@class CBItem;

/**
Callback for handling successful requests on CBItem objects
@param item The item that the request was called on
*/
typedef void (^CBItemSuccessCallback)(CBItem * item);

/**
Callback for handling failed requests on CBItem objects
@param item The item that the request was called on
@param error The error returned by the failed request
@param JSON The json returned by the request. Useful if the JSON failed to parse
*/
typedef void (^CBItemErrorCallback)(CBItem * item, NSError * error, id JSON);

/**
Class that represents an individual item from the platform
*/
@interface CBItem : NSObject
/**
A dictionary that holds the data that was stored in the platform. 
*/
@property (strong, nonatomic) NSMutableDictionary *data;
/**
A string holding the ID of the collection to which this item belongs
*/
@property (strong, nonatomic) NSString *collectionID;

/**
A string holding the ID of the item
*/
@property (strong, nonatomic) NSString *itemID;

/**
Creates an Item with data belonging to the collection with collectionID
@param inputData A dictionary that holds data for the item
@param collectionID The ID of the collection this item will belong to
@returns The newly created CBItem
*/
+(instancetype)itemWithData:(NSDictionary *)inputData withCollectionID:(NSString *)collectionID;

+(NSMutableArray *)arrayOfCBItemsFromArrayOfDictionaries:(NSArray *)itemArray withCollectionID:(NSString *)collectionID;

/**
Initializes the Item with data and sets the data and collectionID.
@param inputData A dictionary that holds data for the item
@param colID A string that holds the ID of the collection to which this item belongs 
@returns the newly created CBItem
*/
-(instancetype) initWithData: (NSDictionary *) inputData withCollectionID:(NSString *) colID;
/**
Saves any changes that have been made to the data property to the Platform
This will update the server
*/
-(void) saveWithSuccessCallback:(CBItemSuccessCallback)successCallback
              withErrorCallback:(CBItemErrorCallback)errorCallback;
/**
Pulls down any changes that have been made on the server to the item since being instantiated. 
This updates the data attribute to reflect the current state of the Item on the server
*/
-(void) refreshWithSuccessCallback:(CBItemSuccessCallback)successCallback
                 withErrorCallback:(CBItemErrorCallback)errorCallback;
/**
Deletes the Item on the server
This cannot be undone.
*/
-(void) removeWithSuccessCallback:(CBItemSuccessCallback)successCallback
                withErrorCallback:(CBItemErrorCallback)errorCallback;
/**
Gets an item out of the data attribute that matches the given string
@param key String used to find a value in the dictionary
@returns The id that is referenced by the value for the given key
*/
-(id) objectForKey:(NSString *)key;

-(void) setObject:(id)value forKey:(NSString *)key;

/**
Checks if all keys on both this CBItem and the other item are equal.
@param item The item to check against.
@returns true if the other item has all the same keys and values as this item.
*/
-(bool) isEqualToCBItem:(CBItem *)item;

@end
