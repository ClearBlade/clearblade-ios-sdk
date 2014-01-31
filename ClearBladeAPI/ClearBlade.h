/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import <Foundation/Foundation.h>

#ifndef CB_DEFAULT_PLATFORM_ADDRESS
#define CB_DEFAULT_PLATFORM_ADDRESS @"https://platform.clearblade.com/"
#define CB_DEFAULT_MESSAGING @"https://messaging.clearblade.com"
#endif

#define CB_LOG_DIVIDER @"=============================================="

#define CBLogError(...) [[ClearBlade settings] logError:__VA_ARGS__,nil]
#define CBLogWarning(...) [[ClearBlade settings] logWarning:__VA_ARGS__,nil]
#define CBLogDebug(...) [[ClearBlade settings] logDebug:__VA_ARGS__,nil]
#define CBLogExtra(...) [[ClearBlade settings] logExtra:__VA_ARGS__,nil]

@class CBUser;
@class ClearBlade;

typedef enum {
    /** CBAPI does not log anything under this level */
    CB_LOG_NONE = 0,
    
    /** CBAPI only logs errors under this level */
    CB_LOG_ERROR = 1,
    
    /** CBAPI logs warnings and errors under this level */
    CB_LOG_WARN = 2,
    
    /** CBAPI logs debug lines, warnings, and errors under this level */
    CB_LOG_DEBUG = 3,
    
    /** CBAPI logs everything under this level */
    CB_LOG_EXTRA = 4
} CBLoggingLevel;

typedef enum {
    /** The client will send and forget it's messages */
   CBMessageClientQualityAtMostOnce = 0,
    
    /** The client will send the message until it has been delivered at least once*/
   CBMessageClientQualityAtLeastOnce = 1,
    
    /** The client will make sure the message is received only once*/
   CBMessageClientQualityExactlyOnce = 2
} CBMessageClientQuality;

/**
 Callback for handling successful initialization of the Clearblade API
 @param ClearBlade The newly initialized settings
 */
typedef void (^ClearBladeSettingsSuccessCallback)(ClearBlade *);

/**
 Callback for handling failed initialization of the ClearBlade API
 @param error The error that caused the initialization to fail
 */
typedef void (^ClearBladeSettingsErrorCallback)(NSError *);

/**
 Option key for setting the server address in ClearBlade settings
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionServerAddress;

/**
 Option key for setting the messaging address in ClearBlade settings
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionMessagingAddress;

/**
 Option key for setting the default quality of service for messaging in ClearBlade settings
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionMessagingDefaultQOS;

/**
 Option key for setting the logging level
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionLoggingLevel;

/**
 Option key for setting an email to authenticate with.
 Will use this instead of attempting to authenticate as an anonymous user,
 CBSettingsOptionPassword must be set or initialization will fail.
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionEmail;

/**
 Option key for setting a password to authenticate with.
 If CBSettingsOptionEmail isn't set, initialization will fail.
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionPassword;

/**
 Option key for making it so before authenticating the user, it attempts
 to register them first. Requires CBSettingsOptionEmail and CBSettingsOptionPassword to be set,
 otherwise initialize will fail.
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionRegisterUser;

/**
 Option key for presenting an already authenticated user to the about to be initialized ClearBlade settings
 */
FOUNDATION_EXPORT NSString * const CBSettingsOptionUseUser;

/**
 Encapsulates all the global configuration for the ClearBlade API
 */
@interface ClearBlade : NSObject

/**
 The global settings used by queries by default
 */
+(instancetype)settings;

/**
 Initializes settings synchronously with default settings.
 Also initializes with an anonymous user.
 @param key The System Key.
 @param secret The System Secret.
 @param error Is set if the ClearBlade settings fails to initialize
 @return The newly created Settings object
 */
+(instancetype)initSettingsSyncWithSystemKey:(NSString *)key
                            withSystemSecret:(NSString *)secret
                                 withOptions:(NSDictionary *)options
                                withError:(NSError **)error;

/**
 Initializes settings asynchronously with default settings.
 Also initializes with an anonymous user.
 @param key The System Key.
 @param secret The System Secret.
 @param successCallback The callback for when settings successfully initializes.
 @param errorCallback The callback for when settings fails to initialize for whatever reason
*/
+(void)initSettingsWithSystemKey:(NSString *)key
                withSystemSecret:(NSString *)secret
                     withOptions:(NSDictionary *)options
          withSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback
            withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback;

/**
 The System Key used throughout the API
 */
@property (readonly, atomic) NSString * systemKey;

/**
 The System Secret used throughout the API
 */
@property (readonly, atomic) NSString * systemSecret;

/**
 The Address for the Platform Data service
 */
@property (readonly, atomic) NSString * serverAddress;

/**
 The Address for the Platform messaging service
 */
@property (readonly, atomic) NSURL * messagingAddress;

/**
 The Default quality of service to use for messaging clients
 */
@property (readonly, atomic) CBMessageClientQuality messagingDefaultQoS;

/**
 The Main User of the app. Can be modified at runtime to change main users
 */
@property (strong, atomic) CBUser * mainUser;

/**
 The Logging level the API uses. Defaults to CB_LOG_WARN
 */
@property (atomic) CBLoggingLevel loggingLevel;

/**
 Logs an error as filtered by the loggingLevel setting
 */
-(void)logError:(NSString *)error,...;

/**
 Logs a warning as filtered by the loggingLevel setting
 */
-(void)logWarning:(NSString *)warning,...;

/**
 Logs a debug statement as filtered by the loggingLevel setting
 */
-(void)logDebug:(NSString *)debug,...;


/**
 Logs a extra data as filtered by the loggingLevel setting
 */
-(void)logExtra:(NSString *)extra,...;

/**
 Generates an ID that's guaranteed to be unique for this instance of ClearBlade Settings
 */
-(int)generateID;

@end
