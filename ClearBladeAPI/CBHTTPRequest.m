//
//  CBHTTPRequest.m
//  testApp
//
//  Created by Tyler Dodge on 12/3/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import "CBHTTPRequest.h"
#import "CBHTTPRequestResponse.h"
#import "CBUser.h"

@implementation CBHTTPRequest
@synthesize settings = _settings;
@synthesize user = _user;

+(instancetype)requestWithMethod:(NSString *)method withCollection:(NSString *)collectionID withParameters:(NSDictionary *)parameters withUser:(CBUser *)user {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:method
                                              withCollection:[@"api/v1/data/" stringByAppendingString:collectionID]
                                              withParameters:parameters
                                                    withUser:user];
}

+(instancetype)userRequestWithSettings:(ClearBlade *)settings
                            withMethod:(NSString *)method
                            withAction:(NSString *)action
                              withBody:(NSDictionary *)body
                           withHeaders:(NSDictionary *)headers {
    if (!settings) {
        settings = [ClearBlade settings];
    }
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:settings
                                                  withMethod:method
                                                  withAction:[@"api/v1/user/" stringByAppendingString:action]
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
    
    NSData * bodyData;
    if (body) {
        bodyData = [NSJSONSerialization dataWithJSONObject:body options:0 error:&error];
    }
    
    
    self = [super initWithURL:url];
    if (self) {
        self.settings = settings;
        for (id key in headers.keyEnumerator) {
            [self setValue:[headers objectForKey:key] forHTTPHeaderField:key];
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
    [self setValue:[settings systemKey] forHTTPHeaderField:@"ClearBlade-AppKey"];
    [self setValue:[settings systemSecret] forHTTPHeaderField:@"ClearBlade-AppSecret"];
    _settings = settings;
}
-(void)executeWithSuccessCallback:(CBHTTPRequestSuccessCallback)successCallback withErrorCallback:(CBHTTPRequestErrorCallback)errorCallback {
    void (^completionHandler)(NSURLResponse *, NSData *, NSError *) =^(NSURLResponse *response, NSData *data, NSError * connectionError) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        CBHTTPRequestResponse * requestResponse = [CBHTTPRequestResponse responseWithRequest:self
                                                                                withResponse:(NSHTTPURLResponse *)response
                                                                                    withData:data];
        [self.settings logExtra:@"Executed Request with Response\n%@\n\n", requestResponse];
        if (connectionError) {
            if (errorCallback) {
                errorCallback(requestResponse, connectionError);
            }
        } else if (httpResponse.statusCode != 200) {
            connectionError = [NSError errorWithDomain:[@"Unable to complete request because " stringByAppendingString:requestResponse.responseString]
                                                  code:httpResponse.statusCode
                                              userInfo:nil];
            if (errorCallback) {
                errorCallback(requestResponse, connectionError);
            }
        }
        if (connectionError) {
            return;
        }
        
        if (successCallback) {
            successCallback(requestResponse);
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
    CBHTTPRequestResponse * response = [CBHTTPRequestResponse responseWithRequest:self withResponse:requestResponse withData:requestData];
    [self.settings logExtra:@"Executed Request with Response\n%@\n\n", response];
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
