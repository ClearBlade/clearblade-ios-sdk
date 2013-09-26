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
#import "MQTTMessage.h"

@protocol MQTTClientDelegate
/**
Method that gets called upon successful connection
@param code NSUInteger that represents the connection code
*/
- (void) didConnect: (NSUInteger)code;
/**
Method that gets called when the client gets disconnected from the host
*/
- (void) didDisconnect;
/**
Method that gets called when the client publishes
@param messageId NSUInteger that represents the message ID
*/
- (void) didPublish: (NSUInteger)messageId;
/**
Method that gets called when the client receives a message
@param mqtt_msg MQTTMessage that is returned to the client
*/
- (void) didReceiveMessage: (MQTTMessage*)mqtt_msg;
/**
Method that gets called upon subscription
@param messageId Id of the message that was sent
@param qos The Quality of service at which messages will be received
*/
- (void) didSubscribe: (NSUInteger)messageId grantedQos:(NSArray*)qos;
/**
Method that gets called when the client unsubscribes
@param messageId ID of the message sent upon unsubscribe
*/
- (void) didUnsubscribe: (NSUInteger)messageId;

@end


@interface MQTTClient : NSObject {
    struct mosquitto *mosq;
    NSString *host;
    unsigned short port;
    NSString *username;
    NSString *password;
    unsigned short keepAlive;
    BOOL cleanSession;
    
    NSTimer *timer;
}
/**
The string that holds the host address.
*/
@property (readwrite,retain) NSString *host;
/**
The port number of the host.
*/
@property (readwrite,assign) unsigned short port;
/**
The string that holds the username of the client.
*/
@property (readwrite,retain) NSString *username;
/**
The string that holds the password of the client.
*/
@property (readwrite,retain) NSString *password;
/**
The amount of time to keep alive
*/
@property (readwrite,assign) unsigned short keepAlive;
/**
Boolean to flag a clean session.
*/
@property (readwrite,assign) BOOL cleanSession;
/**
Pointer to the delegate object that will handle messages when received.
*/
@property (readwrite,assign) id<MQTTClientDelegate> delegate;


+ (void) initialize;
+ (NSString*) version;

/**
Initalize a new MQTTClient object with a clientID
@param clientId String that represents the client ID
@returns a newly initialized MQTTClient
*/
- (MQTTClient*) initWithClientId: (NSString *)clientId;
/**
Sets how often the message will retry.
@param seconds NSUInteger that represent the amount of time between retries.
*/
- (void) setMessageRetry: (NSUInteger)seconds;
/**
Connects to the host designated if the host has already been set.
*/
- (void) connect;
/**
Connects to the given host.
@param host String that represents the host address.
*/
- (void) connectToHost: (NSString*)host;
/**
Disconnect from the host and establish a new connection.
*/
- (void) reconnect;
/**
Disconnect from the host.
*/
- (void) disconnect;
/**
Message to be sent upon disconnect
@param payload String that holds the message to be sent
@param willTopic String that represents the topic to which the Will message is sent
@param willQos NSUInteger that represents the quality of service level that the message will be sent with
@param retain BOOL that flags the message to be retained or not
*/
- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
/**
Clears the will that was set with setWill().
*/
- (void)clearWill;
/**
Publishes a string to the host on a given topic
@param payload String that holds the message to be sent
@param topic String that represents the topic to which the message is sent
@param qos NSUInteger that represents the quality of service level that the message will be sent with
@param retain BOOL that flags the message to be retained or not
*/
- (void)publishString: (NSString *)payload toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain;
/**
Subscribes to the given topic to receive messages sent to that topic
@param topic String that represents the topic to be listened on
*/
- (void)subscribe: (NSString *)topic;
/**
Subscribes to the given topic to receive messages sent to that topic with the given QOS
@param topic String that represents the topic to be listened on
@param qos NSUInteger that represents the quality of service level that the message will be recieved with
*/
- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos;
/**
Unsubscibes from the given topic
@param topic String that represents the topic from which to be unsubscribed
*/
- (void)unsubscribe: (NSString *)topic;


// This is called automatically when connected
- (void) loop: (NSTimer *)timer;

@end
