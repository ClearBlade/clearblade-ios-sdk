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

#define CBLogError(...) [[ClearBlade settings] logError:__VA_ARGS__,nil]
#define CBLogWarning(...) [[ClearBlade settings] logWarning:__VA_ARGS__,nil]
#define CBLogDebug(...) [[ClearBlade settings] logDebug:__VA_ARGS__,nil]
#define CBLogExtra(...) [[ClearBlade settings] logExtra:__VA_ARGS__,nil]

typedef enum {
    CB_LOG_NONE = 0,
    CB_LOG_ERROR = 1,
    CB_LOG_WARN = 2,
    CB_LOG_DEBUG = 3,
    CB_LOG_EXTRA = 4
} CBLoggingLevel;

@interface ClearBlade : NSObject

+(instancetype)settings;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                     withLoggingLevel:(CBLoggingLevel)loggingLevel;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                    withServerAddress:(NSString *)address;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                    withServerAddress:(NSString *)address
                     withLoggingLevel:(CBLoggingLevel)loggingLevel;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                    withServerAddress:(NSString *)address
                 withMessagingAddress:(NSString *)messagingAddress;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                    withServerAddress:(NSString *)address
                 withMessagingAddress:(NSString *)messagingAddress
                     withLoggingLevel:(CBLoggingLevel)loggingLevel;

@property (readonly, atomic) NSString * appKey;
@property (readonly, atomic) NSString * appSecret;
@property (readonly, atomic) NSString * serverAddress;
@property (readonly, atomic) NSURL * messagingAddress;

@property (atomic) CBLoggingLevel loggingLevel;
-(void)logError:(NSString *)error,...;
-(void)logWarning:(NSString *)warning,...;
-(void)logDebug:(NSString *)debug,...;
-(void)logExtra:(NSString *)extra,...;

-(int)generateID; //Unique id, only guaranteed to be unique for this Clearblade settings.

@end
