/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBHTTPClient.h"

@implementation CBHTTPClient
@synthesize settings = _settings;

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings {
    self = [super initWithBaseURL:[settings serverAddress]];
    if (self) {
        self.settings = settings;
    }
    return self;
}

-(NSMutableURLRequest *)requestWithMethod:(NSString *)method path:(NSString *)path parameters:(NSDictionary *)parameters {
    ClearBlade * settings = self.settings;
    return [super requestWithMethod:method
                               path:[settings fullServerAddressWithPath:path].path
                         parameters:parameters];
}

-(ClearBlade *)settings {
    ClearBlade * settingsRef = _settings;
    @synchronized (settingsRef) {
        if (!settingsRef) {
            [self setSettings:[ClearBlade settings]];
        }
    }
    return settingsRef;
}

-(void)setSettings:(ClearBlade *)settings {
    [self setDefaultHeader:@"ClearBlade-AppKey" value:[settings appKey]];
    [self setDefaultHeader:@"ClearBlade-AppSecret" value:[settings appSecret]];
    _settings = settings;
}

@end
