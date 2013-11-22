/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBMessage.h"
#include "mosquitto.h"

@implementation CBMessage
@dynamic payloadText;
@synthesize payloadData = _payloadData;
@synthesize topic = _topic;

+(instancetype)messageWithTopic:(NSString *)topic withPayloadText:(NSString *)text {
    return [[CBMessage alloc] initWithTopic:topic withPayloadText:text];
}

+(instancetype)messageWithTopic:(NSString *)topic withPayloadData:(NSData *)data {
    return [[CBMessage alloc] initWithTopic:topic withPayloadData:data];
}

+(CBMessage *)messageFromMosquittoMessage:(const struct mosquitto_message *)message {
    return [[CBMessage alloc] initWithMosquittoMessage:message];
}


-(id)initWithMosquittoMessage:(const struct mosquitto_message *)message {
    self = [super init];
    if (self) {
        self.topic = [NSString stringWithUTF8String:message->topic];
        self.payloadData = [NSData dataWithBytes:message->payload length:message->payloadlen];
    }
    return self;
}
-(instancetype)initWithTopic:(NSString *)topic withPayloadText:(NSString *)text {
    self = [super init];
    if (self) {
        self.topic = topic;
        self.payloadText = text;
    }
    return self;
}
-(instancetype)initWithTopic:(NSString *)topic withPayloadData:(NSData *)data {
    self = [super init];
    if (self) {
        self.topic = topic;
        self.payloadData = data;
    }
    return self;
}
-(NSString *)payloadText {
    return [[NSString alloc] initWithData:self.payloadData encoding:NSUTF8StringEncoding];
}
-(void)setPayloadText:(NSString *)payloadText {
    _payloadData = [payloadText dataUsingEncoding:NSUTF8StringEncoding];
}
@end
