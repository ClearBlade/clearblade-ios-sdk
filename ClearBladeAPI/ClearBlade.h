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
#define CB_DEFAULT_PLATFORM_ADDRESS @"https://platform.clearblade.com/api/"
#define CB_DEFAULT_MESSAGING @"https://messaging.clearblade.com"
#endif

#define CB_LOG_DIVIDER @"=============================================="

#define CBLogError(...) [[ClearBlade settings] logError:__VA_ARGS__,nil]
#define CBLogWarning(...) [[ClearBlade settings] logWarning:__VA_ARGS__,nil]
#define CBLogDebug(...) [[ClearBlade settings] logDebug:__VA_ARGS__,nil]
#define CBLogExtra(...) [[ClearBlade settings] logExtra:__VA_ARGS__,nil]

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

@class CBUser;
@class ClearBlade;

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
 Protocol for building ClearBladeSettings piecemeal. Does not actually initialize
 the settings until either runWithSuccessCallback:withErrorCallback: or runSyncWithError
 is called. Once either is called and completed, it sets the global [ClearBlade settings] to the newly initialized
 ClearBlade object. AppKey and AppSecret must be set before running.
 */
@protocol ClearBladeSettingsBuilder

/**
 Sets the appKey and appSecret for ClearBlade settings
 @param appKey The System Key to authenticate with
 @param appSecret The secret key to authenticate with
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withAppKey:(NSString *)appKey withAppSecret:(NSString *)appSecret;

/**
 Sets the target server address for ClearBlade Platform Data
 @param serverAddress The target server address
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withServerAddress:(NSString *)serverAddress;

/**
 Sets the target messaging address for ClearBlade Platform Messaging
 @param messagingAddress The target messaging server address
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withMessagingAddress:(NSString *)messagingAddress;

/**
 Sets the logging level for ClearBlade settings
 @param loggingLevel The new level for logging
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withLoggingLevel:(CBLoggingLevel)loggingLevel;

/**
 Sets the main user for ClearBlade settings. This should only be a user with
 token and loaded from save data, because authenticating a user is not available
 until after ClearBlade settings are set.
 @param mainUser The new mainUser
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withMainUser:(CBUser *)mainUser;

/**
 Executes the Settings builder with the settings given asynchronously. If mainUser
 is not set, it will request an anonymous token for future requests.
 @param successCallback The callback if all goes well
 @param errorCallback The callback if the initialization fails
 */
-(void)runWithSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback
            withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback;

/**
 Executes the Settings builder with the settings given synchronously. If mainUser
 is not set, it will request an anonymous token for future requests.
 @param error This error will be set if it fails to initialize the new ClearBlade settings
 @return The newly created ClearBlade settings.
 */
-(ClearBlade *)runSyncWithError:(NSError **)error;
@end

/**
 Encapsulates all the global configuration for the ClearBlade API
 */
@interface ClearBlade : NSObject

/**
 The global settings used by queries by default
 */
+(instancetype)settings;

/**
 Creates a settings builder for configuring the settings object
 */
+(id<ClearBladeSettingsBuilder>)initSettingsWithBuilder;

/**
 Initializes settings synchronously with default settings.
 Also initializes with an anonymous user.
 @param key The App Key.
 @param secret The App Secret.
 @param error Is set if the ClearBlade settings fails to initialize
 @return The newly created Settings object
 */
+(instancetype)initSettingsSyncWithAppKey:(NSString *)key
                            withAppSecret:(NSString *)secret
                                withError:(NSError **)error;

/**
 Initializes settings asynchronously with default settings.
 Also initializes with an anonymous user.
 @param key The App Key.
 @param secret The App Secret.
 @param successCallback The callback for when settings successfully initializes.
 @param errorCallback The callback for when settings fails to initialize for whatever reason
*/
+(void)initSettingsWithAppKey:(NSString *)key
                withAppSecret:(NSString *)secret
          withSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback
            withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback;

/**
 The App Key used throughout the API
 */
@property (readonly, atomic) NSString * appKey;

/**
 The App Secret used throughout the API
 */
@property (readonly, atomic) NSString * appSecret;

/**
 The Address for the Platform Data service
 */
@property (readonly, atomic) NSString * serverAddress;

/**
 The Address for the Platform messaging service
 */
@property (readonly, atomic) NSURL * messagingAddress;

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
