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
#define CB_DEFAULT_LOGGING CB_LOG_WARN

static ClearBlade * _settings = nil;

@interface ClearBlade ()
-(instancetype)initWithAppKey:(NSString *)key
                withAppSecret:(NSString *)secret
            withServerAddress:(NSString *)serverAddress
         withMessagingAddress:(NSString *)messagingAddress
             withLoggingLevel:(CBLoggingLevel)loggingLevel;
@property (strong, nonatomic) NSNumber * nextID;
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

+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret {
    return [ClearBlade initSettingsWithAppKey:key withAppSecret:secret withLoggingLevel:CB_DEFAULT_LOGGING];
}
+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withLoggingLevel:(CBLoggingLevel)loggingLevel {
    return  [ClearBlade  initSettingsWithAppKey:key
                                  withAppSecret:secret
                              withServerAddress:CB_DEFAULT_PLATFORM_ADDRESS
                           withMessagingAddress:CB_DEFAULT_MESSAGING
                               withLoggingLevel:loggingLevel];
}

+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)address {
    return [ClearBlade initSettingsWithAppKey:key withAppSecret:secret withServerAddress:address withLoggingLevel:CB_DEFAULT_LOGGING];
}
+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)address withLoggingLevel:(CBLoggingLevel)loggingLevel {
    return [ClearBlade initSettingsWithAppKey:key
                                withAppSecret:secret
                            withServerAddress:address
                         withMessagingAddress:CB_DEFAULT_MESSAGING
                             withLoggingLevel:loggingLevel];
}

+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)address withMessagingAddress:(NSString *)messagingAddress {
    return [ClearBlade initSettingsWithAppKey:key
                                withAppSecret:secret
                            withServerAddress:address
                         withMessagingAddress:messagingAddress
                             withLoggingLevel:CB_DEFAULT_LOGGING];
}
+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)address withMessagingAddress:(NSString *)messagingAddress withLoggingLevel:(CBLoggingLevel)loggingLevel {
    @synchronized (_settings) {
        _settings = [[ClearBlade alloc] initWithAppKey:key
                                         withAppSecret:secret
                                     withServerAddress:address
                                  withMessagingAddress:messagingAddress
                                      withLoggingLevel:loggingLevel];
        return _settings;
    }
}

@synthesize appSecret = _appSecret;
@synthesize appKey = _appKey;
@synthesize serverAddress = _serverAddress;
@synthesize messagingAddress = _messagingAddress;
@synthesize nextID = _nextID;

-(instancetype)initWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)serverAddress withMessagingAddress:(NSString *)messagingAddress withLoggingLevel:(CBLoggingLevel)loggingLevel {
    self = [super init];
    if (self) {
        _appKey = key;
        _appSecret = secret;
        self.serverAddress = serverAddress;
        self.messagingAddress = messagingAddress;
        self.loggingLevel = loggingLevel;
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

-(void)logError:(NSString *)format, ... {
    if (self.loggingLevel >= CB_LOG_ERROR) {
        va_list arguments;
        va_start(arguments, format);
        NSLog(@"[ERROR] %@", [[NSString alloc] initWithFormat:format arguments:arguments]);
        va_end(arguments);
    }
}
-(void)logWarning:(NSString *)format, ... {
    if (self.loggingLevel >= CB_LOG_WARN) {
        va_list arguments;
        va_start(arguments, format);
        NSLog(@"[WARNING] %@", [[NSString alloc] initWithFormat:format arguments:arguments]);
        va_end(arguments);
    }
}
-(void)logDebug:(NSString *)format, ... {
    if (self.loggingLevel >= CB_LOG_DEBUG) {
        va_list arguments;
        va_start(arguments, format);
        NSLog(@"[DEBUG] %@", [[NSString alloc] initWithFormat:format arguments:arguments]);
        va_end(arguments);
    }
}
-(void)logExtra:(NSString *)format, ... {
    if (self.loggingLevel >= CB_LOG_EXTRA) {
        va_list arguments;
        va_start(arguments, format);
        NSLog(@"[EXTRA] %@", [[NSString alloc] initWithFormat:format arguments:arguments]);
        va_end(arguments);
    }
    
}
-(int)generateID {
    @synchronized (self.nextID) {
        int nextId = [self.nextID intValue];
        self.nextID = @(nextId + 1);
        return nextId;
    }
}

@end
