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
struct mosquitto_message;
/**
 Holds all data for an individual message from MQTT
*/
@interface CBMessage : NSObject

/**
Creates a message with the given topic and text
@param topic A string with the topic name
@param text A string with the payload text or message
@return The created message
*/
+(instancetype)messageWithTopic:(NSString *)topic withPayloadText:(NSString *)text;

/**
Creates a message with the given topic and text
@param topic A string with the topic name
@param data A NSData object that represents the payload of the message
@return The created message
*/
+(instancetype)messageWithTopic:(NSString *)topic withPayloadData:(NSData *)data;

/**
Creates a message from a mosquitto_message struct
@param message The mosquitto_message struct to convert from
@return The created message
*/
+(instancetype)messageFromMosquittoMessage:(const struct mosquitto_message *)message;

/** The message's topic */
@property(strong, nonatomic) NSString * topic;

/** The Payload Text (This is generated from payloadData */
@property(strong, nonatomic) NSString * payloadText;

/** The Payload Text as a data object */
@property(strong, nonatomic) NSData * payloadData;

/**
Initiates a message using a mosquitto_message struct
@param message The mosquitto_message struct used to initialize the CBMessage
@return The initialized CBMessage
*/
-(instancetype)initWithMosquittoMessage:(const struct mosquitto_message *)message;

/**
Initiates a message using a topic and message string
@param topic A string with the topic name
@param text A string with the payload text or message
@return The created message
*/
-(instancetype)initWithTopic:(NSString *)topic withPayloadText:(NSString *)text;

/**
Initiates a message using a topic and message data
@param topic A string with the topic name
@param data A NSData object with the payload
@return The created message
*/
-(instancetype)initWithTopic:(NSString *)topic withPayloadData:(NSData *)data;
@end
