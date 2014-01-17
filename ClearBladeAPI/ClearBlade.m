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
#import "CBUser.h"
#define CB_DEFAULT_LOGGING CB_LOG_WARN

@class ClearBladeSettingsBuilderImpl;

static ClearBlade * _settings = nil;

@interface ClearBlade ()
-(instancetype)initWithAppKey:(NSString *)key
                withAppSecret:(NSString *)secret
            withServerAddress:(NSString *)serverAddress
         withMessagingAddress:(NSString *)messagingAddress
                     withMainUser:(CBUser *)user
             withLoggingLevel:(CBLoggingLevel)loggingLevel;
@property (strong, nonatomic) NSNumber * nextID;
@end

@interface ClearBladeSettingsBuilderImpl : NSObject <ClearBladeSettingsBuilder>
-(instancetype)initWithSettingsPointer:(ClearBlade *__strong*)settingsPointer;
@property ClearBlade *__strong * settingsPointer;
@property (strong, nonatomic) NSString * appKey;
@property (strong, nonatomic) NSString * appSecret;
@property (strong, nonatomic) NSString * serverAddress;
@property (strong, nonatomic) NSString * messagingAddress;
@property (strong, nonatomic) CBUser * mainUser;
@property (strong, nonatomic) NSNumber * loggingLevelNumber;
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

+(instancetype)initSettingsSyncWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withError:(NSError *__autoreleasing *)error {
    return [[[ClearBlade initSettingsWithBuilder] withAppKey:key withAppSecret:secret] runSyncWithError:error];
}
+(void)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                  withSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback
                    withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback {
    [[[ClearBlade initSettingsWithBuilder] withAppKey:key withAppSecret:secret]
     runWithSuccessCallback:successCallback withErrorCallback:errorCallback];
}

+(id<ClearBladeSettingsBuilder>)initSettingsWithBuilder {
    return [[ClearBladeSettingsBuilderImpl alloc] initWithSettingsPointer:&_settings];
}

@synthesize appSecret = _appSecret;
@synthesize appKey = _appKey;
@synthesize serverAddress = _serverAddress;
@synthesize messagingAddress = _messagingAddress;
@synthesize nextID = _nextID;

-(instancetype)initWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)serverAddress withMessagingAddress:(NSString *)messagingAddress withMainUser:(CBUser *)user withLoggingLevel:(CBLoggingLevel)loggingLevel {
    self = [super init];
    if (self) {
        _appKey = key;
        _appSecret = secret;
        self.serverAddress = serverAddress;
        self.messagingAddress = messagingAddress;
        self.loggingLevel = loggingLevel;
        self.mainUser = user;
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



@implementation ClearBladeSettingsBuilderImpl
@synthesize settingsPointer = _settingsPointer;
@synthesize appKey = _appKey;
@synthesize appSecret = _appSecret;
@synthesize serverAddress = _serverAddress;
@synthesize messagingAddress = _messagingAddress;
@synthesize mainUser = _mainUser;
@synthesize loggingLevelNumber = _loggingLevelNumber;

-(instancetype)initWithSettingsPointer:(ClearBlade *__strong*)settingsPointer {
    self = [super init];
    if (self) {
        self.settingsPointer = settingsPointer;
    }
    return self;
}
-(instancetype)withAppKey:(NSString *)appKey withAppSecret:(NSString *)appSecret {
    self.appKey = appKey;
    self.appSecret = appSecret;
    return self;
}
-(instancetype)withServerAddress:(NSString *)serverAddress {
    self.serverAddress = serverAddress;
    return self;
}
-(instancetype)withMessagingAddress:(NSString *)messagingAddress {
    self.messagingAddress = messagingAddress;
    return self;
}

-(instancetype)withMainUser:(CBUser *)mainUser {
    self.mainUser = mainUser;
    return self;
}

-(instancetype)withLoggingLevel:(CBLoggingLevel)loggingLevel {
    self.loggingLevelNumber = @(loggingLevel);
    return self;
}
-(NSString *)serverAddress {
    if (!_serverAddress) {
        _serverAddress = CB_DEFAULT_PLATFORM_ADDRESS;
    }
    return _serverAddress;
}
-(NSString *)messagingAddress {
    if (!_messagingAddress) {
        _messagingAddress = CB_DEFAULT_MESSAGING;
    }
    return _messagingAddress;
}
-(CBLoggingLevel)loggingLevel {
    if (!self.loggingLevelNumber) {
        self.loggingLevelNumber = @(CB_DEFAULT_LOGGING);
    }
    return (CBLoggingLevel)[self.loggingLevelNumber intValue];
}

-(void)runWithSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback
            withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback {
    NSError * error;
    if (![self validateAppKeyAndAppSecretWithError:&error]) {
        CBLogError(@"Failed to init ClearBlade Settings with error <%@>", error);
        if (errorCallback) {
            errorCallback(error);
        }
    } else if (!self.mainUser) {
        [CBUser anonymousUserWithSuccessCallback:^(CBUser * user) {
            self.mainUser = user;
            ClearBlade * settings = [self createClearBladeSettings];
            if (successCallback) {
                successCallback(settings);
            }
        } withErrorCallback:^(NSError * error) {
            CBLogError(@"Failed to authenticate anonymous user with error <%@>", error);
            if (errorCallback) {
                errorCallback(error);
            }
        }];
    } else {
        ClearBlade * settings = [self createClearBladeSettings];
        if (successCallback) {
            successCallback(settings);
        }
    }
    
}

-(bool)validateAppKeyAndAppSecretWithError:(NSError **)error {
    if (!self.appKey) {
        *error = [NSError errorWithDomain:@"App Key must be set to authenticate with server" code:1 userInfo:nil];
        return false;
    }
    else if (!self.appSecret) {
        *error = [NSError errorWithDomain:@"App Secret must be set to authenticate with server" code:2 userInfo:nil];
        return false;
    }
    return true;
}


-(ClearBlade *)createClearBladeSettings {
    @synchronized(*self.settingsPointer) {
        return *self.settingsPointer = [[ClearBlade alloc] initWithAppKey:self.appKey
                                                            withAppSecret:self.appSecret
                                                        withServerAddress:self.serverAddress
                                                     withMessagingAddress:self.messagingAddress
                                                             withMainUser:self.mainUser
                                                         withLoggingLevel:self.loggingLevel];
    }
}


-(ClearBlade *)runSyncWithError:(NSError **)error {
    if ([self validateAppKeyAndAppSecretWithError:error] && !self.mainUser) {
        self.mainUser = [CBUser anonymousUserWithError:error];
    }
    
    if (*error) {
        return nil;
    }
    return [self createClearBladeSettings];
}
@end