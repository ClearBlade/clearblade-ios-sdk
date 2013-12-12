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

+(instancetype)requestWithMethod:(NSString *)method withCollection:(NSString *)collectionID withParameters:(NSDictionary *)parameters {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:method
                                              withCollection:collectionID
                                              withParameters:parameters];
}

-(NSString *)encodeQuery:(NSString *)query {
    //http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[query UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"%20"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings
                               withMethod:(NSString *)method
                           withCollection:(NSString *)collectionID
                           withParameters:(NSDictionary *)params {
    NSString * paramString = params[@"query"];
    if (paramString) {
        NSString * query = [self encodeQuery:paramString];
        paramString = [NSString stringWithFormat:@"%@%@?query=%@", [settings serverAddress], collectionID, query];
    } else {
        paramString = [NSString stringWithFormat:@"%@%@", [settings serverAddress], collectionID];
    }
    NSURL * url = [NSURL URLWithString:paramString];
    
    self = [super initWithURL:url];
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
                                    }];
    _settings = settings;
}

@end
