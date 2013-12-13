/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "ClearBlade.h"

static ClearBlade * _settings = nil;

@interface ClearBlade ()
-(instancetype)initWithAppKey:(NSString *)key
                withAppSecret:(NSString *)secret
            withServerAddress:(NSString *)serverAddress
         withMessagingAddress:(NSString *)messagingAddress;
@end

@implementation ClearBlade

+(instancetype)settings {
    @synchronized (_settings) {
        if (!_settings) {
            NSLog(@"App Key and App Secret should be set before calling any ClearBlade APIs");
        }
        return _settings;
    }
}

+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)address {
    @synchronized (_settings) {
        _settings = [[ClearBlade alloc] initWithAppKey:key
                                         withAppSecret:secret
                                     withServerAddress:address
                                  withMessagingAddress:address];
        return _settings;
    }
}

+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret {
    @synchronized (_settings) {
        _settings = [[ClearBlade alloc] initWithAppKey:key
                                         withAppSecret:secret
                                     withServerAddress:CB_DEFAULT_PLATFORM_ADDRESS
                                  withMessagingAddress:CB_DEFAULT_MESSAGING];
        return _settings;
    }
}
+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)address withMessagingAddress:(NSString *)messagingAddress {
    @synchronized (_settings) {
        _settings = [[ClearBlade alloc] initWithAppKey:key
                                         withAppSecret:secret
                                     withServerAddress:address
                                  withMessagingAddress:messagingAddress];
        return _settings;
    }
}

@synthesize appSecret = _appSecret;
@synthesize appKey = _appKey;
@synthesize serverAddress = _serverAddress;
@synthesize messagingAddress = _messagingAddress;

-(instancetype)initWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)serverAddress withMessagingAddress:(NSString *)messagingAddress {
    self = [super init];
    if (self) {
        _appKey = key;
        _appSecret = secret;
        self.serverAddress = serverAddress;
        self.messagingAddress = messagingAddress;
    }
    return self;
}
-(void)setServerAddress:(NSString *)serverAddress {
    if (![serverAddress hasPrefix:@"http"]) {
        serverAddress = [@"https://" stringByAppendingString:serverAddress];
    }
    if (![serverAddress hasSuffix:@"/"]) {
        serverAddress = [serverAddress stringByAppendingString:@"/"];
    }
    _serverAddress = serverAddress;
}

-(void)setMessagingAddress:(NSString *)messagingAddress {
    @synchronized (_messagingAddress) {
        if ([messagingAddress hasPrefix:@"https"]) {
            messagingAddress = [@"tcp" stringByAppendingString:[messagingAddress substringFromIndex:@"https".length]];
        } else if ([messagingAddress hasPrefix:@"http"]) {
            messagingAddress = [@"tcp" stringByAppendingString:[messagingAddress substringFromIndex:@"http".length]];
        } else if (![messagingAddress hasPrefix:@"tcp"]) {
            messagingAddress = [@"tcp://" stringByAppendingString:messagingAddress];
        }
        _messagingAddress = [NSURL URLWithString:messagingAddress];
    }
}
-(NSURL *)messagingAddress {
    @synchronized (_messagingAddress) {
        return _messagingAddress;
    }
}

-(NSString *)description {
    return [NSString
            stringWithFormat:@"ClearBlade Settings: App Key <%@>, App Secret <%@>, Server Address <%@>, Messaging Address <%@>",
            self.appKey, self.appSecret, self.serverAddress, self.messagingAddress];
}

@end
