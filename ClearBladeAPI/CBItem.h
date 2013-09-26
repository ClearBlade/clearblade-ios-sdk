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
Initializes the Item with data and sets the data and collectionID.
@param inputData A dictionary that holds data for the item
@param colID A string that holds the ID of the collection to which this item belongs 
@returns the newly created CBItem
*/
-(CBItem *) initWithData: (NSDictionary *) inputData collectionID:(NSString *) colID;
/**
Saves any changes that have been made to the data property to the Platform
This will update the server
*/
-(void) save;
/**
Pulls down any changes that have been made on the server to the item since being instantiated. 
This updates the data attribute to reflect the current state of the Item on the server
*/
-(void) refresh;
/**
Deletes the Item on the server
This cannot be undone.
*/
-(void) destroy;
/**
Gets an item out of the data attribute that matches the given string
@param key String used to find a value in the dictionary
@returns The id that is referenced by the value for the given key
*/
-(id) getValueFor: (NSString *)key;

@end
