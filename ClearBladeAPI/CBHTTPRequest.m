//
//  CBHTTPRequest.m
//  testApp
//
//  Created by Tyler Dodge on 12/3/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import "CBHTTPRequest.h"
#import "CBUser.h"

@implementation CBHTTPRequest
@synthesize settings = _settings;
@synthesize user = _user;

+(instancetype)requestWithMethod:(NSString *)method withCollection:(NSString *)collectionID withParameters:(NSDictionary *)parameters withUser:(CBUser *)user {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:method
                                              withCollection:collectionID
                                              withParameters:parameters
                                                    withUser:user];
}

+(instancetype)userRequestWithMethod:(NSString *)method
                          withAction:(NSString *)action
                            withBody:(NSDictionary *)body
                         withHeaders:(NSDictionary *)headers {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:method
                                                  withAction:action
                                                    withBody:body
                                                 withHeaders:headers];
}

-(NSString *)encodeQuery:(NSString *)query {
    //http://stackoverflow.com/questions/3423545/objective-c-iphone-percent-encode-a-string
    NSMutableString * output = [NSMutableString string];
    const unsigned char * source = (const unsigned char *)[query UTF8String];
    unsigned long sourceLen = strlen((const char *)source);
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
                           withParameters:(NSDictionary *)params
                                 withUser:(CBUser *)user {
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
        self.user = user;
    }
    return self;
}

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings
                               withMethod:(NSString *)method
                               withAction:(NSString *)action
                                 withBody:(NSDictionary *)body
                              withHeaders:(NSDictionary *)headers {
    NSURL * url = [[NSURL URLWithString:[settings serverAddress]] URLByAppendingPathComponent:action];
    NSError * error = nil;
    NSData * bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    
    
    self = [super initWithURL:url];
    if (self) {
        self.settings = settings;
        for (id key in headers.keyEnumerator) {
            [self setValue:key forKey:[headers objectForKey:key]];
        }
        self.HTTPMethod = method;
        self.HTTPBody = bodyData;
        if (error) {
            CBLogWarning(@"Request <%@> failed to initialize body <%@> with error <%@>", self, body, error);
        }
    }
    return self;
}

-(CBUser *)user {
    @synchronized (_user) {
        return _user;
    }
}
-(void)setUser:(CBUser *)user {
    @synchronized (_user) {
        _user = user;
        [self setValue:[user authToken] forHTTPHeaderField:@"ClearBlade-UserToken"];
    }
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
    [self setValue:[settings appKey] forHTTPHeaderField:@"ClearBlade-AppKey"];
    [self setValue:[settings appSecret] forHTTPHeaderField:@"ClearBlade-AppSecret"];
    _settings = settings;
}
-(void)executeWithSuccessCallback:(CBHTTPRequestSuccessCallback)successCallback withErrorCallback:(CBHTTPRequestErrorCallback)errorCallback {
    void (^completionHandler)(NSURLResponse *, NSData *, NSError *) =^(NSURLResponse *response, NSData *data, NSError * connectionError) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        if (connectionError) {
            if (errorCallback) {
                errorCallback(connectionError);
            }
        } else if (httpResponse.statusCode != 200) {
            connectionError = [NSError errorWithDomain:@"Unable to complete request because of status code"
                                                  code:httpResponse.statusCode
                                              userInfo:nil];
            if (errorCallback) {
                errorCallback(connectionError);
            }
        }
        if (connectionError) {
            return;
        }
        
        if (successCallback) {
            successCallback(data);
        }
    };
    [NSURLConnection sendAsynchronousRequest:self
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:completionHandler];
}

-(NSData *)executeWithError:(NSError *__autoreleasing *)error {
    NSHTTPURLResponse * requestResponse = nil;
    NSError * requestError = nil;
    NSData * requestData = [NSURLConnection sendSynchronousRequest:self returningResponse:&requestResponse error:&requestError];
    if (requestError) {
        *error = requestError;
    } else if (requestResponse.statusCode != 200) {
        *error = [NSError errorWithDomain:@"Request failed because of statusCode" code:requestResponse.statusCode userInfo:nil];
    } else {
        return requestData;
    }
    return nil;
}

@end
