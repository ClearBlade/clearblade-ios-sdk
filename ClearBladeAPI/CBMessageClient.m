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

@interface CBMessageClient ()
-(void)handleConnect:(CBMessageClientConnectStatus)status;
-(void)handleDisconnect;
-(void)handleMessage:(CBMessage *)message;
-(void)handlePublish:(NSString *)topic;
-(void)handleSubscribe:(NSString *)topic;
-(void)handleUnsubscribe:(NSString *)topic;
@property (nonatomic) struct mosquitto * client;
@property (strong, atomic) NSMutableDictionary * topics;
@property (strong, nonatomic) NSThread * clientThread;
@property (strong, atomic) NSNumber * isConnectedContainer;
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
        default:
            NSLog(@"Unexpected Connection Response %d", connectionResponse);
            break;
    }
}
static void CBMessageClient_onMessage(struct mosquitto * mosq, void * voidClient, const struct mosquitto_message * message) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    [client handleMessage:[CBMessage messageFromMosquittoMessage:message]];
}
static void CBMessageClient_onSubscribe(struct mosquitto * mosq, void * voidClient, int mid, int qos, const int * qos_list) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    NSString * topic = [client.topics objectForKey:@(mid)];
    [client handleSubscribe:topic];
}
static void CBMessageClient_onUnsubscribe(struct mosquitto * mosq, void * voidClient, int mid) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    NSString * topic = [client.topics objectForKey:@(mid)];
    [client handleUnsubscribe:topic];
}
static void CBMessageClient_onDisconnect(struct mosquitto * mosq, void * voidClient, int id) {
    CBMessageClient * client = (__bridge CBMessageClient *)voidClient;
    [client handleDisconnect];
}
static void CBMessageClient_onLog(struct mosquitto * mosq, void * voidClient, int mid, const char * text) {
    NSLog(@"%s", text);
}

@implementation CBMessageClient
@synthesize client = _client;
@synthesize delegate = _delegate;
@synthesize clientThread = _clientThread;
@synthesize topics = _topics;
@synthesize isConnectedContainer = _isConnectedContainer;
@synthesize host = _host;

@dynamic isConnected;

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

-(NSMutableDictionary *)topics {
    @synchronized (_topics) {
        if (!_topics) {
            _topics = [[NSMutableDictionary alloc] init];
        }
        return _topics;
    }
}

-(void)setTopics:(NSMutableDictionary *)topics {
    @synchronized (_topics) {
        _topics = topics;
    }
}

-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
}
-(void)finalize {
    if (self.isConnected) {
        [self disconnect];
    }
}

-(void)connect {
    [self connectToHost:[[ClearBlade settings] messagingAddress]];
}

-(void)disconnect {
    if (self.isConnected) {
        mosquitto_disconnect(self.client);
        mosquitto_destroy(self.client);
        
        //The thread should finish up after disconnecting anyway, this is to avoid trying to start with it again.
        self.clientThread = nil;
    }
}
-(struct mosquitto *)client {
    if (!_client) {
        _client = mosquitto_new(NULL, YES, (__bridge void *)(self));
        mosquitto_connect_callback_set(_client, CBMessageClient_onConnect);
        mosquitto_message_callback_set(_client, CBMessageClient_onMessage);
        mosquitto_subscribe_callback_set(_client, CBMessageClient_onSubscribe);
        mosquitto_unsubscribe_callback_set(_client, CBMessageClient_onUnsubscribe);
        mosquitto_disconnect_callback_set(_client, CBMessageClient_onDisconnect);
        mosquitto_log_callback_set(_client, CBMessageClient_onLog);
    }
    return _client;
}
-(void)subscribeToTopic:(NSString *)topic {
    @synchronized(self.topics) {
        int messageId;
        mosquitto_subscribe(self.client, &messageId, [topic cStringUsingEncoding:NSUTF8StringEncoding] , 0);
        [self.topics setObject:topic forKey:@(messageId)];
    }
}
-(void)publishMessage:(NSString *)message toTopic:(NSString *)topic {
    @synchronized(self.topics) {
        int messageId;
        mosquitto_publish(self.client, &messageId, [topic cStringUsingEncoding:NSUTF8StringEncoding],
                          message.length, [message cStringUsingEncoding:NSUTF8StringEncoding],
                          0, true);
    }
}
-(void)connectToHost:(NSURL *)hostName {
    mosquitto_username_pw_set(self.client,
                              [[[ClearBlade settings] appKey] cStringUsingEncoding:NSUTF8StringEncoding],
                              [[[ClearBlade settings] appSecret] cStringUsingEncoding:NSUTF8StringEncoding]);
    int port;
    if (hostName.port == nil) {
        port = 1883;
    } else {
        port = [hostName.port intValue];
    }
    int response = mosquitto_connect(self.client, [hostName.host cStringUsingEncoding:NSUTF8StringEncoding], port, 5);
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
    mosquitto_loop_forever(self.client, 100, 1000);
}
-(void)handleConnect:(CBMessageClientConnectStatus)status {
    id<CBMessageClientDelegate> delegate = self.delegate;
    self.isConnectedContainer = @(true);
    
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
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didReceiveMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didReceiveMessage:message];
        });
    }
}
-(void)handlePublish:(NSString *)topic {
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didPublishToTopic:withMessage:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CBMessage * message = [CBMessage messageWithTopic:topic withPayloadText:@""];
            [delegate messageClient:self didPublishToTopic:topic withMessage:message];
        });
    }
}
-(void)handleUnsubscribe:(NSString *)topic {
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didUnsubscribe:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            CBMessage * message = [CBMessage messageWithTopic:topic withPayloadText:@""];
            [delegate messageClient:self didPublishToTopic:topic withMessage:message];
        });
    }
    
}
-(void)handleSubscribe:(NSString *)topic {
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didSubscribe:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didSubscribe:topic];
        });
    }
    
}
-(void)handleDisconnect {
    id<CBMessageClientDelegate> delegate = self.delegate;
    
    self.isConnectedContainer = false;
    
    if ([delegate respondsToSelector:@selector(messageClientDidDisconnect:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClientDidDisconnect:self];
        });
    }
}

-(NSString *)description {
    if (self.isConnected) {
        return [NSString stringWithFormat:@"CBMessageClient: Connected to Host <%@>", self.host];
    } else {
        return @"CBMessageClient: Not connected to a server";
    }
}

@end
