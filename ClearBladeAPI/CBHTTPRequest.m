//
//  CBHTTPRequest.m
//  testApp
//
//  Created by Tyler Dodge on 12/3/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import "CBHTTPRequest.h"

@implementation CBHTTPRequest
@synthesize settings = _settings;

+(instancetype)requestWithMethod:(NSString *)method withCollection:(NSString *)collectionID {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings] withMethod:method withCollection:collectionID];
}

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings withMethod:(NSString *)method withCollection:(NSString *)collectionID {
    self = [super initWithURL:[[settings serverAddress] URLByAppendingPathComponent:collectionID]];
    if (self) {
        self.HTTPMethod = method;
        self.settings = settings;
    }
    return self;
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
    [self setAllHTTPHeaderFields:@{ @"ClearBlade-AppKey": [settings appKey],
                                    @"ClearBlade-AppSecret": [settings appSecret],
                                    @"Accept": @"application/json" }];
    _settings = settings;
}

@end
