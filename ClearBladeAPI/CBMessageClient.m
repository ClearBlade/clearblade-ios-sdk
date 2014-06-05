/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBMessageClient.h"
#include "mosquitto.h"
#import "ClearBlade.h"
#import "CBUser.h"

@interface CBMessageClient ()
-(void)handleConnect:(CBMessageClientConnectStatus)status;
-(void)handleDisconnect;
-(void)handleMessage:(CBMessage *)message;
-(void)handlePublish:(CBMessage *)message;
-(void)handleSubscribe:(NSString *)topic;
-(void)handleUnsubscribe:(NSString *)topic;

-(int)addItemToMessageQueue:(id)item;
-(id)removeItemFromMessageQueue:(int)index;

-(void)addTopicToSubscribeList:(NSString *)topic;
-(void)removeTopicFromSubscribeList:(NSString *)topic;

@property (nonatomic) struct mosquitto * client;
@property (strong, nonatomic) NSObject * clientLock;

@property (strong, nonatomic) NSMutableSet * topicList;
@property (strong, nonatomic) NSMutableDictionary * messageQueue;

@property (strong, nonatomic) NSThread * clientThread;
@property (strong, atomic) NSNumber * isConnectedContainer;
@property (atomic) CBMessageClientQuality qos;
@property (nonatomic) bool tryingToReconnect;
@property (nonatomic) bool plannedDisconnect;
@end
/* * 0 - success
 * * 1 - connection refused (unacceptable protocol version)
 * * 2 - connection refused (identifier rejected)
 * * 3 - connection refused (broker unavailable)
 */
static void CBMessageClient_onConnect(struct mosquitto * mosq, void * voidClient, int connectionResponse) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    switch (connectionResponse) {
        case 0:
            [client handleConnect:CBMessageClientConnectSuccess];
            break;
        case 1:
            [client handleConnect:CBMessageClientConnectErrorProtocol];
            break;
        case 2:
            [client handleConnect:CBMessageClientConnectInvalidAppSecret];
            break;
        case 3:
            [client handleConnect:CBMessageClientConnectUnavailable];
            break;
        case MOSQ_ERR_CONN_REFUSED:
            [client handleConnect:CBMessageClientConnectRefused];
            break;
        default:
            CBLogError(@"Unexpected Connection Response %d", connectionResponse);
            break;
    }
}
static void CBMessageClient_onMessage(struct mosquitto * mosq, void * voidClient, const struct mosquitto_message * message) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    [client handleMessage:[CBMessage messageFromMosquittoMessage:message]];
}
static void CBMessageClient_onSubscribe(struct mosquitto * mosq, void * voidClient, int mid, int qos, const int * qos_list) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    NSString * topic = [client removeItemFromMessageQueue:mid];
    [client addTopicToSubscribeList:topic];
    [client handleSubscribe:topic];
}
static void CBMessageClient_onUnsubscribe(struct mosquitto * mosq, void * voidClient, int mid) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    NSString * topic = [client removeItemFromMessageQueue:mid];
    [client removeTopicFromSubscribeList:topic];
    [client handleUnsubscribe:topic];
}
static void CBMessageClient_onDisconnect(struct mosquitto * mosq, void * voidClient, int id) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    [client handleDisconnect];
}
static void CBMessageClient_onLog(struct mosquitto * mosq, void * voidClient, int mid, const char * text) {
    CBLogExtra(@"%s", text);
}
static void CBMessageClient_onPublish(struct mosquitto * mosq, void *voidClient, int mid) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    CBMessage * message = [client removeItemFromMessageQueue:mid];
    [client handlePublish:message];
}

@implementation CBMessageClient
@synthesize client = _client;
@synthesize clientLock = _clientLock;
@synthesize delegate = _delegate;
@synthesize clientThread = _clientThread;
@synthesize topics = _topics;
@synthesize isConnectedContainer = _isConnectedContainer;
@synthesize host = _host;
@synthesize qos = _qos;
@synthesize reconnectOnDisconnect = _reconnectOnDisconnect;

@dynamic isConnected;


-(NSObject *)clientLock {
    if (!_clientLock) {
        _clientLock = [[NSObject alloc] init];
    }
    return _clientLock;
}

-(NSArray *)topics {
    @synchronized (self.topicList) {
        return self.topicList.allObjects.copy;
    }
}

-(NSURL *)host {
    if (self.isConnected) {
        @synchronized (_host) {
            return _host;
        }
    }
    return nil;
}

-(void)setHost:(NSURL *)host {
    @synchronized (_host) {
        _host = host;
    }
}


-(bool)isConnected {
    return [self.isConnectedContainer boolValue];
}


+(instancetype)client {
    return [[CBMessageClient alloc] init];
}

-(id)init {
    self = [super init];
    if (self) {
        self.reconnectOnDisconnect = true;
    }
    return self;
}
-(void)finalize {
    if (self.isConnected) {
        [self disconnect];
    }
    @synchronized (self.clientLock) {
        mosquitto_destroy(self.client);
    }
}

-(void)connect {
    [self connectToHost:[[ClearBlade settings] messagingAddress]];
}

-(void)connectWithQoS:(CBMessageClientQuality)qos {
    [self connectToHost:[[ClearBlade settings] messagingAddress] withQoS:qos];
}

-(void)disconnect {
    self.plannedDisconnect = true;
    @synchronized (self.clientLock) {
        if (self.isConnected) {
            mosquitto_disconnect(self.client);
            
            //The thread should finish up after disconnecting anyway, this is to avoid trying to start with it again.
            self.clientThread = nil;
        }
    }
}

-(struct mosquitto *)client {
    if (!_client) {
        NSString * clientID = [NSString stringWithFormat:@"MosquittoClient_%d", [[ClearBlade settings] generateID]];
        _client = mosquitto_new([clientID cStringUsingEncoding:NSUTF8StringEncoding], YES, (__bridge void *)(self));
        mosquitto_connect_callback_set(_client, CBMessageClient_onConnect);
        mosquitto_message_callback_set(_client, CBMessageClient_onMessage);
        mosquitto_subscribe_callback_set(_client, CBMessageClient_onSubscribe);
        mosquitto_publish_callback_set(_client, CBMessageClient_onPublish);
        mosquitto_unsubscribe_callback_set(_client, CBMessageClient_onUnsubscribe);
        mosquitto_disconnect_callback_set(_client, CBMessageClient_onDisconnect);
        mosquitto_log_callback_set(_client, CBMessageClient_onLog);
    }
    return _client;
}
-(void)subscribeToTopic:(NSString *)topic {
    CBLogDebug(@"Message Client subscribing to topic %@", topic);
    @synchronized (self.clientLock) {
        int messageId = [self addItemToMessageQueue:topic];
        mosquitto_subscribe(self.client, &messageId, [topic cStringUsingEncoding:NSUTF8StringEncoding] , self.qos);
    }
}
-(void)unsubscribeFromTopic:(NSString *)topic {
    CBLogDebug(@"Message Client unsubscribing from topic %@", topic);
    @synchronized (self.clientLock) {
        int messageId = [self addItemToMessageQueue:topic];
        mosquitto_unsubscribe(self.client, &messageId, [topic cStringUsingEncoding:NSUTF8StringEncoding]);
    }
}

-(void)publishMessage:(NSString *)message toTopic:(NSString *)topic {
    CBLogDebug(@"Message client publishing message <%@> to topic <%@>", message, topic);
    @synchronized (self.clientLock) {
        int messageId;
        [self addItemToMessageQueue:[CBMessage messageWithTopic:topic withPayloadText:message]];
        mosquitto_publish(self.client, &messageId, [topic cStringUsingEncoding:NSUTF8StringEncoding],
                          (int)message.length, [message cStringUsingEncoding:NSUTF8StringEncoding],
                          self.qos, true);
    }
}
-(void)connectToHost:(NSURL *)hostName {
    [self connectToHost:hostName withQoS:[[ClearBlade settings] messagingDefaultQoS]];
}
-(void)connectToHost:(NSURL *)hostName withQoS:(CBMessageClientQuality)qos {
    int response;
    self.host = hostName;
    self.qos = qos;
    @synchronized (self.clientLock) {
        mosquitto_username_pw_set(self.client,
                                  [[[ClearBlade settings] mainUser].authToken cStringUsingEncoding:NSUTF8StringEncoding],
                                  [[[ClearBlade settings] systemSecret] cStringUsingEncoding:NSUTF8StringEncoding]);
        int port;
        if (hostName.port == nil) {
            port = 1883;
        } else {
            port = [hostName.port intValue];
        }
        CBLogDebug(@"Connecting mosquitto client to %@", hostName);
        response = mosquitto_connect(self.client, [hostName.host cStringUsingEncoding:NSUTF8StringEncoding], port, 60);
    }
    id<CBMessageClientDelegate> delegate = self.delegate;
    switch (response) {
        case MOSQ_ERR_SUCCESS:
            [self.clientThread start];
            break;
        case MOSQ_ERR_INVAL:
            if ([delegate respondsToSelector:@selector(messageClient:didFailToConnect:)]) {
                [delegate messageClient:self didFailToConnect:CBMessageClientConnectMalformedURL];
            }
            break;
        case MOSQ_ERR_ERRNO:
            if ([delegate respondsToSelector:@selector(messageClient:didFailToConnect:)]) {
                CBMessageClientConnectStatus status = CBMessageClientConnectErrnoSet;
                if (errno == 2) { //No File found
                    status = CBMessageClientConnectServerNotFound;
                }
                [delegate messageClient:self didFailToConnect:status];
            }
            break;
        default:
            break;
    }
}
-(NSThread *)clientThread {
    if (!_clientThread) {
        _clientThread = [[NSThread alloc] initWithTarget:self selector:@selector(runClientInBackground:) object:nil];
    }
    return _clientThread;
}
-(void)runClientInBackground:(id)empty {
    do {
        mosquitto_loop(self.client, 1000, 1000);
    } while  (self.isConnected);
}
-(void)handleConnect:(CBMessageClientConnectStatus)status {
    id<CBMessageClientDelegate> delegate = self.delegate;
    self.isConnectedContainer = @(true);
    self.tryingToReconnect = false;
    CBLogDebug(@"Mosquitto client connected to %@", self.host);
    dispatch_async(dispatch_get_main_queue(), ^{
        if (status == CBMessageClientConnectSuccess) {
            if ([delegate respondsToSelector:@selector(messageClientDidConnect:)]) {
                [delegate messageClientDidConnect:self];
            }
        } else {
            if ([delegate respondsToSelector:@selector(messageClient:didFailToConnect:)]) {
                [delegate messageClient:self didFailToConnect:status];
            }
        }
    });
}
-(void)handleMessage:(CBMessage *)message {
    CBLogDebug(@"Mosquitto client received %@", message);
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didReceiveMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didReceiveMessage:message];
        });
    }
}
-(void)handlePublish:(CBMessage *)message {
    CBLogDebug(@"Mosquitto client published %@", message);
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didPublishToTopic:withMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didPublishToTopic:message.topic withMessage:message];
        });
    }
}
-(void)handleUnsubscribe:(NSString *)topic {
    CBLogDebug(@"Mosquitto client unsubscribed from topic %@", topic);
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didUnsubscribe:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didUnsubscribe:topic];
        });
    }
    
}
-(void)handleSubscribe:(NSString *)topic {
    CBLogDebug(@"Mosquitto client subscribed to topic %@", topic);
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didSubscribe:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didSubscribe:topic];
        });
    }
    
}
-(void)handleDisconnect {
    CBLogDebug(@"Mosquitto client disconnected from host %@", self.host);
    id<CBMessageClientDelegate> delegate = self.delegate;
    
    if(!self.tryingToReconnect){
        if ([delegate respondsToSelector:@selector(messageClientDidDisconnect:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate messageClientDidDisconnect:self];
            });
        }
    }
    if (self.reconnectOnDisconnect && !self.plannedDisconnect) {
        self.tryingToReconnect = true;
        [self tryReconnect];
        sleep(5);
    } else{
        self.isConnectedContainer = false;
        self.topicList = nil;
        self.clientThread = nil;
        if ([delegate respondsToSelector:@selector(messageClientDidDisconnect:)]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [delegate messageClientDidDisconnect:self];
            });
        }
    }
}

-(void)tryReconnect {
    id<CBMessageClientDelegate> delegate = self.delegate;
    @synchronized (self.clientLock) {
        int resp = mosquitto_reconnect(self.client);
        switch (resp) {
            case MOSQ_ERR_SUCCESS:
                //this doesn't mean we successfully connected in libmosquitto, so we do nothing
                //on_connect callback will be called if reconnect is successful
                break;
            case MOSQ_ERR_INVAL:
                if ([delegate respondsToSelector:@selector(messageClient:didFailToConnect:)]) {
                    [delegate messageClient:self didFailToConnect:CBMessageClientConnectMalformedURL];
                }
                break;
            case MOSQ_ERR_ERRNO:
                if ([delegate respondsToSelector:@selector(messageClient:didFailToConnect:)]) {
                    CBMessageClientConnectStatus status = CBMessageClientConnectErrnoSet;
                    if (errno == 2) { //No File found
                        status = CBMessageClientConnectServerNotFound;
                    }
                    [delegate messageClient:self didFailToConnect:status];
                }
                break;
            default:
                break;
        }
    }}

-(NSString *)description {
    if (self.isConnected) {
        return [NSString stringWithFormat:@"CBMessageClient: Connected to Host <%@>", self.host];
    } else {
        return @"CBMessageClient: Not connected to a server";
    }
}
-(NSMutableDictionary *)messageQueue {
    if (!_messageQueue) {
        _messageQueue = [NSMutableDictionary dictionary];
    }
    return _messageQueue;
}
-(NSMutableSet *)topicList {
    if (!_topicList) {
        _topicList = [NSMutableSet set];
    }
    return _topicList;
}
-(int)addItemToMessageQueue:(id)item {
    @synchronized (self.messageQueue) {
        int index = mosquitto_mid_peek(self.client);
        [self.messageQueue setObject:item forKey:@(index)];
        return index;
    }
}
-(id)removeItemFromMessageQueue:(int)index {
    @synchronized (self.messageQueue) {
        id item = [self.messageQueue objectForKey:@(index)];
        [self.messageQueue removeObjectForKey:@(index)];
        return item;
    }
}
-(void)addTopicToSubscribeList:(NSString *)topic {
    @synchronized (self.topicList) {
        [self.topicList addObject:topic];
    }
}
-(void)removeTopicFromSubscribeList:(NSString *)topic {
    @synchronized (self.topicList) {
        [self.topicList removeObject:topic];
    }
}
@end
