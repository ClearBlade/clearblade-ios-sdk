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
#import "CBMessageClient.h"
#define CB_DEFAULT_LOGGING CB_LOG_WARN
#define CB_DEFAULT_QOS CBMessageClientQualityAtMostOnce
NSString * const CBSettingsOptionServerAddress = @"CBSettingsOptionServerAddress";
NSString * const CBSettingsOptionMessagingAddress = @"CBSettingsOptionMessagingAddress";
NSString * const CBSettingsOptionMessagingDefaultQOS = @"CBSettingsOptionMessagingDefaultQOS";
NSString * const CBSettingsOptionLoggingLevel = @"CBSettingsOptionLoggingLevel";
NSString * const CBSettingsOptionEmail = @"CBSettingsOptionEmail";
NSString * const CBSettingsOptionPassword = @"CBSettingsOptionPassword";
NSString * const CBSettingsOptionRegisterUser = @"CBSettingsOptionRegisterUser";
NSString * const CBSettingsOptionUseUser = @"CBSettingsOptionUseUser";

static ClearBlade * _settings = nil;

@interface ClearBlade ()
-(instancetype)initWithSystemKey:(NSString *)key withSystemSecret:(NSString *)secret withOptions:(NSDictionary *)options;
@property (strong, nonatomic) NSNumber * nextID;
@property (atomic) CBMessageClientQuality messagingDefaultQoS;
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

+(NSError *)validateOptions:(NSDictionary *)options {
    bool shouldRegister;
    if (options[CBSettingsOptionRegisterUser] == nil) {
        shouldRegister = false;
    }else {
        shouldRegister = [options[CBSettingsOptionRegisterUser] boolValue];
    }
    NSString * email = options[CBSettingsOptionEmail];
    NSString * password = options[CBSettingsOptionPassword];
    if (!email && password) {
        return [NSError errorWithDomain:@"Must provide both an email to authenticate. Only provided password" code:500 userInfo:nil];
    } else if (email && !password) {
        return [NSError errorWithDomain:@"Must provide both an password to authenticate. Only provided email" code:500 userInfo:nil];
    } else if (shouldRegister && !email) {
        return [NSError errorWithDomain:@"Cannot register anonymous user" code:500 userInfo:nil];
    }
    return nil;
}

+(instancetype)initSettingsSyncWithSystemKey:(NSString *)key withSystemSecret:(NSString *)secret withOptions:(NSDictionary *)options withError:(NSError *__autoreleasing *)returnedError {
    ClearBlade * settings = [[ClearBlade alloc] initWithSystemKey:key withSystemSecret:secret withOptions:options];
    NSError * error;
    if (!settings.mainUser) {
        
        bool shouldRegister;
        if (options[CBSettingsOptionRegisterUser] == nil) {
            shouldRegister = false;
        }else {
            shouldRegister = [options[CBSettingsOptionRegisterUser] boolValue];
        }
        
        NSString * email = options[CBSettingsOptionEmail];
        NSString * password = options[CBSettingsOptionPassword];
        error = [ClearBlade validateOptions:options];
        if (!error) {
            CBUser * user = nil;
            
            if (shouldRegister) {
                user = [CBUser registerUserWithSettings:settings withEmail:email withPassword:password withError:&error];
            } else if (email) {
                user = [CBUser authenticateUserWithSettings:settings withEmail:email withPassword:password withError:&error];
            } else {
                user = [CBUser anonymousUserWithSettings:settings WithError:&error];
            }
            if (!error) {
                settings.mainUser = user;
            }
        }
    }
    if (!error) {
        _settings = settings;
        return settings;
    } else {
        [settings logError:@"Failed initialization with error <%@>", returnedError];
        if (returnedError) {
            *returnedError = error;
        }
        return nil;
    }
}

+(void)initSettingsWithSystemKey:(NSString *)key
                withSystemSecret:(NSString *)secret withOptions:(NSDictionary *)options withSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback {
    ClearBlade * settings = [[ClearBlade alloc] initWithSystemKey:key withSystemSecret:secret withOptions:options];
    
    void (^successHandler)(CBUser *) = ^(CBUser * user) {
        settings.mainUser = user;
        _settings = settings;
        if (successCallback) {
            successCallback(settings);
        }
    };
    void (^errorHandler)(NSError *) = ^(NSError * error) {
        CBLogError(@"Failed to authenticate anonymous user with error <%@>", error);
        if (errorCallback) {
            errorCallback(error);
        }
    };
    
    if (!settings.mainUser) {
        bool shouldRegister;
        if (options[CBSettingsOptionRegisterUser] == nil) {
            shouldRegister = false;
        }else {
            shouldRegister = [options[CBSettingsOptionRegisterUser] boolValue];
        }
        NSString * email = options[CBSettingsOptionEmail];
        NSString * password = options[CBSettingsOptionPassword];
        NSError * error = [ClearBlade validateOptions:options];
        if (error) {
            if (errorHandler) {
                errorHandler(error);
            }
            return;
        }
        if (shouldRegister) {
            [CBUser registerUserWithSettings:settings
                                   withEmail:email
                                withPassword:password
                         withSuccessCallback:successHandler
                           withErrorCallback:errorHandler];
        } else if (email) {
            [CBUser authenticateUserWithSettings:settings
                                       withEmail:email
                                    withPassword:password
                             withSuccessCallback:successHandler
                               withErrorCallback:errorHandler];
        } else {
            [CBUser anonymousUserWithSettings:settings
                          withSuccessCallback:successHandler
                            withErrorCallback:errorHandler];
        }
        
    } else {
        successHandler(settings.mainUser);
    }
}

@synthesize systemSecret = _systemSecret;
@synthesize systemKey = _systemKey;
@synthesize serverAddress = _serverAddress;
@synthesize messagingAddress = _messagingAddress;
@synthesize messagingDefaultQoS = _messagingDefaultQoS;
@synthesize nextID = _nextID;

-(instancetype)initWithSystemKey:(NSString *)key withSystemSecret:(NSString *)secret withOptions:(NSDictionary *)options {
    self = [super init];
    if (self) {
        _systemKey = key;
        _systemSecret = secret;
        NSString * serverAddress = options[CBSettingsOptionServerAddress];
        NSString * messagingAddress = options[CBSettingsOptionMessagingAddress];
        NSNumber * loggingLevel = options[CBSettingsOptionLoggingLevel];
        NSNumber * defaultQoS = options[CBSettingsOptionMessagingDefaultQOS];
        CBUser * mainUser = options[CBSettingsOptionUseUser];
        if (serverAddress) {
            self.serverAddress = serverAddress;
        }
        
        if (messagingAddress) {
            self.messagingAddress = messagingAddress;
        }
        
        if (loggingLevel) {
            self.loggingLevel = [loggingLevel intValue];
        } else {
            self.loggingLevel = CB_DEFAULT_LOGGING;
        }
        
        if (defaultQoS) {
            self.messagingDefaultQoS = [defaultQoS intValue];
        } else {
            self.messagingDefaultQoS = CB_DEFAULT_QOS;
        }
        
        if (mainUser) {
            self.mainUser = mainUser;
        }
        
        
    }
    return self;
}
-(NSString *)serverAddress {
    @synchronized (_serverAddress) {
        if (!_serverAddress) {
            _serverAddress = CB_DEFAULT_PLATFORM_ADDRESS;
        }
        return _serverAddress;
    }
}
-(void)setServerAddress:(NSString *)serverAddress {
    @synchronized(_serverAddress) {
        if (![serverAddress hasPrefix:@"http"]) {
            serverAddress = [@"https://" stringByAppendingString:serverAddress];
        }
        if (![serverAddress hasSuffix:@"/"]) {
            serverAddress = [serverAddress stringByAppendingString:@"/"];
        }
        _serverAddress = serverAddress;
    }
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
        if (!_messagingAddress) {
            self.messagingAddress = CB_DEFAULT_MESSAGING;
        }
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