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
#import "CBMessage.h"
@class CBMessageClient;

typedef enum {
    /** The server does not recognize the app secret provided to message client through [Clearblade settings] */
    CBMessageClientConnectInvalidAppSecret,
    
    /** The server did not follow expected protocol. Server might not exist, or it might be on the wrong port. */
    CBMessageClientConnectErrorProtocol,
    
    /** The message broker cannot handle anymore connections */
    CBMessageClientConnectUnavailable,
    
    /** The url given is malformed */
    CBMessageClientConnectMalformedURL,
    
    /** A system level error happend, you can check errno to find the reason */
    CBMessageClientConnectErrnoSet,
    
    /** Could not connect to the server on that port. Usually means you're using the wrong port, or the wrong server */
    CBMessageClientConnectServerNotFound,
    
    /** The message client connected successfully */
    CBMessageClientConnectSuccess
} CBMessageClientConnectStatus;

@protocol CBMessageClientDelegate <NSObject>
/**
Delegate selector to handle when a message client successfully connects.
@param client The client that connected
*/
@optional -(void)messageClientDidConnect:(CBMessageClient *)client;

/**
Delegate selector to handle when a message client disconnects.
@param client The client that disconnected
*/
@optional -(void)messageClientDidDisconnect:(CBMessageClient *)client;

/**
Delegate selector to handle when a message client publishes a message.
@param client The client that published a message
@param topic The topic the client published to
@param message The message that the client sent to the topic
*/
@optional -(void)messageClient:(CBMessageClient *)client
             didPublishToTopic:(NSString *)topic
                   withMessage:(CBMessage *)message;

/**
Delegate selector to handle when a message client receives a message.
@param client The client that received a message
@param message The message that the client received
*/
@optional -(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message;

/**
Delegate selector to handle when a message client subscribes to a topic.
@param client The client that subscribed to a topic
@param topic The topic the client subscribed to
*/
@optional -(void)messageClient:(CBMessageClient *)client didSubscribe:(NSString *)topic;

/**
Delegate selector to handle when a message client unsubscribes to a topic
@param client The client that unsubscribed to a topic
@param topic The topic that the client unsubscribed from
*/
@optional -(void)messageClient:(CBMessageClient *)client didUnsubscribe:(NSString *)topic;

/**
Delegate selector to handle when a message client fails to connect to the server
@param client The message client that failed to connect
@param reason The reason why the client could not connect
 */
@optional -(void)messageClient:(CBMessageClient *)client didFailToConnect:(CBMessageClientConnectStatus)reason;
@end

@interface CBMessageClient : NSObject

/** Creates a new CBMessageClient instance. */
+(instancetype)client;

/** The delegate that will handle all events from message client */
@property (weak, atomic) id<CBMessageClientDelegate> delegate;

/** Whether or not this message client is connected to a host */
@property (atomic, readonly) bool isConnected;

/** The host that this client is connected to. */
@property (atomic, readonly) NSURL * host;

/** The list of topics this client is currently subscribed to */
@property (atomic, readonly) NSArray * topics;

/** Connects the client to the default host, specified in [ClearBlade settings] */
-(void)connect;

/** Disconnects the client from it's current server */
-(void)disconnect;

/**
Connects the client to the host at the specified url.
@param hostName The URL to connect to. The URL should be of the format tcp://address.
*/
-(void)connectToHost:(NSURL *)hostName;

/**
Publishs the message client a message to the specified topic.
@param message The message to send
@param topic The topic to send the message to
*/
-(void)publishMessage:(NSString *)message toTopic:(NSString *)topic;

/**
Subscribes the message client to a topic
@param topic The topic the message client connected to
*/
-(void)subscribeToTopic:(NSString *)topic;

/**
Unsubscribes the message client to a topic
@param topic The topic to unsubscribe from
*/
-(void)unsubscribeFromTopic:(NSString *)topic;
@end
