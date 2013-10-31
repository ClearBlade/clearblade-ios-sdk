//
//  CBMessage.m
//  Chat
//
//  Created by Tyler Dodge on 10/30/13.
//  Copyright (c) 2013 Tyler Dodge. All rights reserved.
//

#import "CBMessage.h"
#import "mosquitto.h"

@implementation CBMessage
@dynamic payloadText;
-(id)initWithMosquittoMessage:(const struct mosquitto_message *)message {
    self = [super init];
    if (self) {
        self.topic = [NSString stringWithUTF8String:message->topic];
        self.payloadData = [NSData dataWithBytes:message->payload length:message->payloadlen];
    }
    return self;
}
-(NSString *)payloadText {
    return [[NSString alloc] initWithData:self.payloadData encoding:NSUTF8StringEncoding];
}
-(void)setPayloadText:(NSString *)payloadText {
    _payloadData = [payloadText dataUsingEncoding:NSUTF8StringEncoding];
}
+(CBMessage *)messageFromMosquittoMessage:(const struct mosquitto_message *)message {
    return [[CBMessage alloc] initWithMosquittoMessage:message];
}
@end
