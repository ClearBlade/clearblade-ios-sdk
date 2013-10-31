//
//  CBMessageClient.m
//  Chat
//
//  Created by Tyler Dodge on 10/30/13.
//  Copyright (c) 2013 Tyler Dodge. All rights reserved.
//

#import "CBMessageClient.h"
#import "mosquitto.h"
#import "ClearBlade.h"

@interface CBMessageClient ()
-(void)handleConnect:(CBMessageClientConnectStatus)status;
-(void)handleDisconnect;
-(void)handleMessage:(CBMessage *)message;
-(void)handlePublish:(NSString *)topic;
-(void)handleSubscribe:(NSString *)topic;
-(void)handleUnsubscribe:(NSString *)topic;
@property (nonatomic) struct mosquitto * client;
@property (strong, nonatomic) NSMutableDictionary * topics;
@property (strong, nonatomic) NSThread * clientThread;
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
            [client handleConnect:CBMessageClientConnectRefusedConnection];
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
-(NSMutableDictionary *)topics {
    if (!_topics) {
        _topics = [[NSMutableDictionary alloc] init];
    }
    return _topics;
}
-(id)init {
    self = [super init];
    if (self) {
    }
    return self;
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
    if (hostName.host == nil) {
        hostName = [NSURL URLWithString:[@"tcp://" stringByAppendingString:[hostName absoluteString]]];
    }
    mosquitto_username_pw_set(self.client,
                              [[ClearBlade appKey] cStringUsingEncoding:NSUTF8StringEncoding],
                              "D6D48AA70A96CAB8E89AFBB394F601");
    mosquitto_connect(self.client, [hostName.host cStringUsingEncoding:NSUTF8StringEncoding], [hostName.port intValue], 5);
    [self.clientThread start];
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
    if ([delegate respondsToSelector:@selector(messageClient:didConnect:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didConnect:status];
        });
    }
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
    if ([delegate respondsToSelector:@selector(messageClient:didPublish:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didPublish:topic];
        });
    }
}
-(void)handleUnsubscribe:(NSString *)topic {
    id<CBMessageClientDelegate> delegate = self.delegate;
    if ([delegate respondsToSelector:@selector(messageClient:didUnsubscribe:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClient:self didPublish:topic];
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
    if ([delegate respondsToSelector:@selector(messageClientDidDisconnect:)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [delegate messageClientDidDisconnect:self];
        });
    }
}
                                
@end
