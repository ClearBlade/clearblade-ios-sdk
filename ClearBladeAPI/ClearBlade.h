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


@interface ClearBlade : NSObject

+(instancetype)settings;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                    withServerAddress:(NSString *)address;

+(instancetype)initSettingsWithAppKey:(NSString *)key
                        withAppSecret:(NSString *)secret
                    withServerAddress:(NSString *)address
                 withMessagingAddress:(NSString *)messagingAddress;

@property (readonly, atomic) NSString * appKey;
@property (readonly, atomic) NSString * appSecret;
@property (readonly, atomic) NSString * serverAddress;
@property (readonly, atomic) NSURL * messagingAddress;


@end
