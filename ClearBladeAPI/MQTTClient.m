/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "MQTTClient.h"
#import "mosquitto.h"



@implementation MQTTClient

@synthesize host;
@synthesize port;
@synthesize username;
@synthesize password;
@synthesize keepAlive;
@synthesize cleanSession;
@synthesize delegate;



static void on_connect(struct mosquitto *mosq, void *obj, int rc)
{
    MQTTClient* client = (__bridge MQTTClient*)obj;
    [[client delegate] didConnect:(NSUInteger)rc];

}

static void on_disconnect(struct mosquitto *mosq, void *obj, int rc)
{
    MQTTClient* client = (__bridge MQTTClient*)obj;
    [[client delegate] didDisconnect];
}

static void on_publish(struct mosquitto *mosq, void *obj, int message_id)
{
    MQTTClient* client = (__bridge MQTTClient*)obj;
    [[client delegate] didPublish:(NSUInteger)message_id];
}

static void on_message(struct mosquitto *mosq, void *obj, const struct mosquitto_message *message)
{
    MQTTMessage *mosq_msg = [[MQTTMessage alloc] init];
    mosq_msg.topic = [NSString stringWithUTF8String: message->topic];
    mosq_msg.payload = [[NSString alloc] initWithBytes:message->payload
                                                 length:message->payloadlen
                                               encoding:NSUTF8StringEncoding];
    MQTTClient* client = (__bridge MQTTClient*)obj;
    
    //[[client delegate] didReceiveMessage:payload topic:topic];
    [[client delegate] didReceiveMessage:mosq_msg];

}

static void on_subscribe(struct mosquitto *mosq, void *obj, int message_id, int qos_count, const int *granted_qos)
{
    MQTTClient* client = (__bridge MQTTClient*)obj;
    // FIXME: implement this
    [[client delegate] didSubscribe:message_id grantedQos:nil];
}

static void on_unsubscribe(struct mosquitto *mosq, void *obj, int message_id)
{
    MQTTClient* client = (__bridge MQTTClient*)obj;
    [[client delegate] didUnsubscribe:message_id];
}


// Initialize is called just before the first object is allocated
+ (void)initialize {
    mosquitto_lib_init();
}

+ (NSString*)version {
    int major, minor, revision;
    mosquitto_lib_version(&major, &minor, &revision);
    return [NSString stringWithFormat:@"%d.%d.%d", major, minor, revision];
}

- (MQTTClient*) initWithClientId: (NSString*) clientId {
    if ((self = [super init])) {
        const char* cstrClientId = [clientId cStringUsingEncoding:NSUTF8StringEncoding];
        [self setHost: nil];
        [self setPort: 1883];
        [self setKeepAlive: 60];
        [self setCleanSession: YES]; //NOTE: this isdisable clean to keep the broker remember this client
        
        mosq = mosquitto_new(cstrClientId, cleanSession, (__bridge void *)(self));
        mosquitto_connect_callback_set(mosq, on_connect);
        mosquitto_disconnect_callback_set(mosq, on_disconnect);
        mosquitto_publish_callback_set(mosq, on_publish);
        mosquitto_message_callback_set(mosq, on_message);
        mosquitto_subscribe_callback_set(mosq, on_subscribe);
        mosquitto_unsubscribe_callback_set(mosq, on_unsubscribe);
        timer = nil;
    }
    return self;
}


- (void) connect {
    const char *cstrHost = [host cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cstrUsername = NULL, *cstrPassword = NULL;
    
    if (username)
        cstrUsername = [username cStringUsingEncoding:NSUTF8StringEncoding];
    
    if (password)
        cstrPassword = [password cStringUsingEncoding:NSUTF8StringEncoding];
    
    // FIXME: check for errors
    mosquitto_username_pw_set(mosq, cstrUsername, cstrPassword);
    
    mosquitto_connect(mosq, cstrHost, port, keepAlive);
    
    // Setup timer to handle network events
    // FIXME: better way to do this - hook into iOS Run Loop select() ?
    // or run in seperate thread?
    timer = [NSTimer scheduledTimerWithTimeInterval:0.01 // 10ms
                                             target:self
                                           selector:@selector(loop:)
                                           userInfo:nil
                                            repeats:YES];
}

- (void) connectToHost: (NSString*)aHost {
    [self setHost:aHost];
    [self connect];
}

- (void) reconnect {
    mosquitto_reconnect(mosq);
}

- (void) disconnect {
    mosquitto_disconnect(mosq);
}

- (void) loop: (NSTimer *)timer {
    mosquitto_loop(mosq, 1, 1);
}


- (void)setWill: (NSString *)payload toTopic:(NSString *)willTopic withQos:(NSUInteger)willQos retain:(BOOL)retain;
{
    const char* cstrTopic = [willTopic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[payload cStringUsingEncoding:NSUTF8StringEncoding];
    size_t cstrlen = [payload lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    mosquitto_will_set(mosq, cstrTopic, cstrlen, cstrPayload, willQos, retain);
}


- (void)clearWill
{
    mosquitto_will_clear(mosq);
}


- (void)publishString: (NSString *)payload toTopic:(NSString *)topic withQos:(NSUInteger)qos retain:(BOOL)retain {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    const uint8_t* cstrPayload = (const uint8_t*)[payload cStringUsingEncoding:NSUTF8StringEncoding];
    size_t cstrlen = [payload lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
    mosquitto_publish(mosq, NULL, cstrTopic, cstrlen, cstrPayload, qos, retain);
    
}



- (void)subscribe: (NSString *)topic {
    [self subscribe:topic withQos:0];
}

- (void)subscribe: (NSString *)topic withQos:(NSUInteger)qos {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_subscribe(mosq, NULL, cstrTopic, qos);
}

- (void)unsubscribe: (NSString *)topic {
    const char* cstrTopic = [topic cStringUsingEncoding:NSUTF8StringEncoding];
    mosquitto_unsubscribe(mosq, NULL, cstrTopic);
}


- (void) setMessageRetry: (NSUInteger)seconds
{
    mosquitto_message_retry_set(mosq, (unsigned int)seconds);
}

- (void) dealloc {
    if (mosq) {
        mosquitto_destroy(mosq);
        mosq = NULL;
    }
    
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
    
}

// FIXME: how and when to call mosquitto_lib_cleanup() ?

@end
