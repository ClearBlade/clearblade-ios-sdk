//
//  CBMessage.h
//  Chat
//
//  Created by Tyler Dodge on 10/30/13.
//  Copyright (c) 2013 Tyler Dodge. All rights reserved.
//

#import <Foundation/Foundation.h>
struct mosquitto_message;
@interface CBMessage : NSObject
@property(strong, nonatomic) NSString * topic;
@property(strong, nonatomic) NSString * payloadText;
@property(strong, nonatomic) NSData * payloadData;
+(CBMessage *)messageFromMosquittoMessage:(const struct mosquitto_message *)message;
-(id)initWithMosquittoMessage:(const struct mosquitto_message *)message;
@end
