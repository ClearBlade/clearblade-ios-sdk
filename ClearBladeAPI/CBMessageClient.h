//
//  CBMessageClient.h
//  Chat
//
//  Created by Tyler Dodge on 10/30/13.
//  Copyright (c) 2013 Tyler Dodge. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBMessage.h"
@class CBMessageClient;

typedef enum {
    CBMessageClientConnectRefusedConnection,
    CBMessageClientConnectErrorProtocol,
    CBMessageClientConnectUnavailable, //Connection unavailable
    CBMessageClientConnectSuccess
} CBMessageClientConnectStatus;

@protocol CBMessageClientDelegate <NSObject>
@optional -(void)messageClient:(CBMessageClient *)client didConnect:(CBMessageClientConnectStatus)status;
@optional -(void)messageClientDidDisconnect:(CBMessageClient *)client;
@optional -(void)messageClient:(CBMessageClient *)client didPublish:(NSString *)message;
@optional -(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message;
@optional -(void)messageClient:(CBMessageClient *)client didSubscribe:(NSString *)topic;
@optional -(void)messageClient:(CBMessageClient *)client didUnsubscribe:(NSString *)topic;
@optional -(void)messageClient:(CBMessageClient *)client didFailToConnect:(CBMessageClientConnectStatus)reason;
@end

@interface CBMessageClient : NSObject
-(void)connectToHost:(NSURL *)hostName;
@property (weak, atomic) id<CBMessageClientDelegate> delegate;
-(void)publishMessage:(NSString *)message toTopic:(NSString *)topic;
-(void)subscribeToTopic:(NSString *)topic;
@end
