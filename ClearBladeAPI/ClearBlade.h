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
#import "ClearBladeSettingsBuilder.h"

#ifndef CB_DEFAULT_PLATFORM_ADDRESS
#define CB_DEFAULT_PLATFORM_ADDRESS @"https://platform.clearblade.com/api/"
#define CB_DEFAULT_MESSAGING @"https://messaging.clearblade.com"
#endif

#define CB_LOG_DIVIDER @"=============================================="

#define CBLogError(...) [[ClearBlade settings] logError:__VA_ARGS__,nil]
#define CBLogWarning(...) [[ClearBlade settings] logWarning:__VA_ARGS__,nil]
#define CBLogDebug(...) [[ClearBlade settings] logDebug:__VA_ARGS__,nil]
#define CBLogExtra(...) [[ClearBlade settings] logExtra:__VA_ARGS__,nil]

@class CBUser;
@class ClearBlade;

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
 @param key The System Key.
 @param secret The System Secret.
 @param error Is set if the ClearBlade settings fails to initialize
 @return The newly created Settings object
 */
+(instancetype)initSettingsSyncWithSystemKey:(NSString *)key
                            withSystemSecret:(NSString *)secret
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
