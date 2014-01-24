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

static ClearBlade * _settings = nil;

@interface ClearBlade ()
-(instancetype)initWithSystemKey:(NSString *)key
                withSystemSecret:(NSString *)secret
            withServerAddress:(NSString *)serverAddress
         withMessagingAddress:(NSString *)messagingAddress
                     withMainUser:(CBUser *)user
             withLoggingLevel:(CBLoggingLevel)loggingLevel;
@property (strong, nonatomic) NSNumber * nextID;
@end

@interface ClearBladeSettingsBuilderImpl : NSObject <ClearBladeSettingsBuilder>
-(instancetype)initWithSettingsPointer:(ClearBlade *__strong*)settingsPointer;
@property ClearBlade *__strong * settingsPointer;
@property (strong, nonatomic) NSString * systemKey;
@property (strong, nonatomic) NSString * systemSecret;
@property (strong, nonatomic) NSString * serverAddress;
@property (strong, nonatomic) NSString * messagingAddress;
@property (strong, nonatomic) CBUser * mainUser;
@property (strong, nonatomic) NSNumber * loggingLevelNumber;
@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * password;
@property (nonatomic) bool shouldRegister;
@end

@implementation ClearBlade


+(instancetype)settings {
    @synchronized (_settings) {
        if (!_settings) {
            NSLog(@"System Key and System Secret should be set before calling any ClearBlade APIs");
        }
        return _settings;
    }
}

+(instancetype)initSettingsSyncWithSystemKey:(NSString *)key withSystemSecret:(NSString *)secret withError:(NSError *__autoreleasing *)error {
    return [[[ClearBlade initSettingsWithBuilder] withSystemKey:key withSystemSecret:secret] runSyncWithError:error];
}
+(void)initSettingsWithSystemKey:(NSString *)key
                        withSystemSecret:(NSString *)secret
                  withSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback
                    withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback {
    [[[ClearBlade initSettingsWithBuilder] withSystemKey:key withSystemSecret:secret]
     runWithSuccessCallback:successCallback withErrorCallback:errorCallback];
}

+(id<ClearBladeSettingsBuilder>)initSettingsWithBuilder {
    return [[ClearBladeSettingsBuilderImpl alloc] initWithSettingsPointer:&_settings];
}

@synthesize systemSecret = _systemSecret;
@synthesize systemKey = _systemKey;
@synthesize serverAddress = _serverAddress;
@synthesize messagingAddress = _messagingAddress;
@synthesize nextID = _nextID;

-(instancetype)initWithSystemKey:(NSString *)key withSystemSecret:(NSString *)secret withServerAddress:(NSString *)serverAddress withMessagingAddress:(NSString *)messagingAddress withMainUser:(CBUser *)user withLoggingLevel:(CBLoggingLevel)loggingLevel {
    self = [super init];
    if (self) {
        _systemKey = key;
        _systemSecret = secret;
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
            stringWithFormat:@"ClearBlade Settings: System Key <%@>, System Secret <%@>, Server Address <%@>, Messaging Address <%@>",
            self.systemKey, self.systemSecret, self.serverAddress, self.messagingAddress];
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
@synthesize systemKey = _systemKey;
@synthesize systemSecret = _systemSecret;
@synthesize serverAddress = _serverAddress;
@synthesize messagingAddress = _messagingAddress;
@synthesize mainUser = _mainUser;
@synthesize loggingLevelNumber = _loggingLevelNumber;
@synthesize email = _email;
@synthesize password = _password;
@synthesize shouldRegister = _shouldRegister;

-(instancetype)initWithSettingsPointer:(ClearBlade *__strong*)settingsPointer {
    self = [super init];
    if (self) {
        self.settingsPointer = settingsPointer;
    }
    return self;
}
-(instancetype)withSystemKey:(NSString *)systemKey withSystemSecret:(NSString *)systemSecret {
    self.systemKey = systemKey;
    self.systemSecret = systemSecret;
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

-(instancetype)authenticateUserWithEmail:(NSString *)email withPassword:(NSString *)password {
    self.email = email;
    self.password = password;
    return self;
}

-(instancetype)registerUser {
    self.shouldRegister = YES;
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
    if (![self validateSystemKeyAndSystemSecretWithError:&error]) {
        CBLogError(@"Failed to init ClearBlade Settings with error <%@>", error);
        if (errorCallback) {
            errorCallback(error);
        }
    } else if (!self.mainUser) {
        ClearBlade * settings = [self createClearBladeSettings];
        if (self.email) {
            void (^successHandler)(CBUser *) = ^(CBUser * user) {
                settings.mainUser = user;
                *self.settingsPointer = settings;
                if (successCallback) {
                    successCallback(*self.settingsPointer);
                }
            };
            void (^errorHandler)(NSError *) = ^(NSError * error) {
                CBLogError(@"Failed to authenticate anonymous user with error <%@>", error);
                if (errorCallback) {
                    errorCallback(error);
                }
            };
            if (self.shouldRegister) {
                [CBUser registerUserWithSettings:settings
                                       withEmail:self.email
                                    withPassword:self.password
                             withSuccessCallback:successHandler
                               withErrorCallback:errorHandler];
            } else {
                [CBUser authenticateUserWithSettings:settings
                                       withEmail:self.email
                                    withPassword:self.password
                             withSuccessCallback:successHandler
                               withErrorCallback:errorHandler];
            }
        } else {
            [CBUser anonymousUserWithSettings:settings withSuccessCallback:^(CBUser * user) {
                settings.mainUser = user;
                *self.settingsPointer = settings;
                if (successCallback) {
                    successCallback(settings);
                }
            } withErrorCallback:^(NSError * error) {
                CBLogError(@"Failed to authenticate anonymous user with error <%@>", error);
                if (errorCallback) {
                    errorCallback(error);
                }
            }];
        }
    } else {
        ClearBlade * settings = [self createClearBladeSettings];
        if (successCallback) {
            successCallback(settings);
        }
    }
    
}

-(bool)validateSystemKeyAndSystemSecretWithError:(NSError **)error {
    if (!self.systemKey) {
        if (error) {
            *error = [NSError errorWithDomain:@"System Key must be set to authenticate with server" code:1 userInfo:nil];
        }
        return false;
    }
    else if (!self.systemSecret) {
        if (error) {
            *error = [NSError errorWithDomain:@"System Secret must be set to authenticate with server" code:2 userInfo:nil];
        }
        return false;
    }
    return true;
}


-(ClearBlade *)createClearBladeSettings {
    return [[ClearBlade alloc] initWithSystemKey:self.systemKey
                                withSystemSecret:self.systemSecret
                            withServerAddress:self.serverAddress
                         withMessagingAddress:self.messagingAddress
                                 withMainUser:self.mainUser
                             withLoggingLevel:self.loggingLevel];
}


-(ClearBlade *)runSyncWithError:(NSError **)error {
    ClearBlade * settings = [self createClearBladeSettings];
    if ([self validateSystemKeyAndSystemSecretWithError:error]) {
        if (self.email) {
            if (self.shouldRegister) {
                settings.mainUser = [CBUser registerUserWithSettings:settings
                                                           withEmail:self.email
                                                        withPassword:self.password
                                                           withError:error];
            } else {
                settings.mainUser = [CBUser authenticateUserWithSettings:settings
                                                               withEmail:self.email
                                                            withPassword:self.password
                                                               withError:error];
            }
        } else {
            settings.mainUser = [CBUser anonymousUserWithSettings:settings WithError:error];
        }
    }
    
    if (*error) {
        return nil;
    }
    *self.settingsPointer = settings;
    return settings;
}

@end