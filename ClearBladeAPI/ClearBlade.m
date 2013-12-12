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
-(instancetype)initWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)serverAddress;
@end

@implementation ClearBlade

+(instancetype)settings {
    if (!_settings) {
        NSLog(@"App Key and App Secret should be set before calling any ClearBlade APIs");
    }
    return _settings;
}

+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)address {
    _settings = [[ClearBlade alloc] initWithAppKey:key withAppSecret:secret withServerAddress:address];
    return _settings;
}

+(instancetype)initSettingsWithAppKey:(NSString *)key withAppSecret:(NSString *)secret {
    _settings = [[ClearBlade alloc] initWithAppKey:key withAppSecret:secret withServerAddress:CB_DEFAULT_PLATFORM_ADDRESS];
    return _settings;
}

@synthesize appSecret = _appSecret;
@synthesize appKey = _appKey;
@synthesize serverAddress = _serverAddress;

-(instancetype)initWithAppKey:(NSString *)key withAppSecret:(NSString *)secret withServerAddress:(NSString *)serverAddress {
    self = [super init];
    if (self) {
        _appKey = key;
        _appSecret = secret;
        self.serverAddress = serverAddress;
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



@end
