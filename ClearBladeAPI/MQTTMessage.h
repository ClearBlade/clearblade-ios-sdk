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

@interface MQTTMessage : NSObject
{
    unsigned short mid;
    NSString *topic;
    NSString *payload;
    unsigned short payloadlen;
    unsigned short qos;
    BOOL retained;
}

/**
Message Id
*/
@property (readwrite, assign) unsigned short mid;
/**
String that represents the topic that the message was received on.
*/
@property (readwrite, retain) NSString *topic;
/**
String that represents the payload of the message
*/
@property (readwrite, retain) NSString *payload;
/**
Length of the payload
*/
@property (readwrite, assign) unsigned short payloadlen;
/**
Quality of service that the message was sent with
*/
@property (readwrite, assign) unsigned short qos;
/**
Flag for whether or not the message will be retained
*/
@property (readwrite, assign) BOOL retained;
/**
Initilizes new MQTTMessage
@returns a newly initialized MQTTMessage object
*/
-(id)init;

@end
