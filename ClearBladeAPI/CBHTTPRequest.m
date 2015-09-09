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
#import "CBQuery.h"

@implementation CBHTTPRequest
@synthesize settings = _settings;
@synthesize user = _user;

+(instancetype)requestWithMethod:(NSString *)method withCollection:(NSString *)collectionID withParameters:(NSDictionary *)parameters withUser:(CBUser *)user {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:method
                                              withCollection:[@"api/v/1/data/" stringByAppendingString:collectionID]
                                              withParameters:parameters
                                                    withUser:user];
}

+(instancetype)requestWithCollectionName:(NSString *)method withCollectionName:(NSString *)collectionName withParameters:(NSDictionary *)parameters withUser:(CBUser *)user {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:method
                                              withCollection:[NSString stringWithFormat:@"api/v/1/collection/%@/%@", [[ClearBlade settings] systemKey],collectionName]
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
                                                  withAction:[@"api/v/1/user/" stringByAppendingString:action]
                                                    withBody:body
                                                 withHeaders:headers];
}

+(instancetype)userRequestWithSettings:(ClearBlade *)settings
                            withMethod:(NSString *)method
                            withAction:(NSString *)action
                              withBody:(NSDictionary *)body
                           withHeaders:(NSDictionary *)headers
                             withQuery:(CBQuery *)query {
    if (!settings) {
        settings = [ClearBlade settings];
    }

    return [[CBHTTPRequest alloc] initWithClearBladeSettings:settings
                                                  withMethod:method
                                                  withAction:[@"api/v/1/user" stringByAppendingString:action]
                                                    withBody:body
                                                 withHeaders:headers
                                                   withQuery:query];
}

+(instancetype)messageHistoryRequestWithSettings:(ClearBlade *)settings
                                      withMethod:(NSString *)method
                                      withAction:(NSString *)action
                                 withQueryString:(NSString *)queryString {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:@"GET"
                                                  withAction:[NSString stringWithFormat:@"api/v/1/message/%@", [[ClearBlade settings] systemKey]]
                                             withQueryString:queryString
                                                    withUser:[[ClearBlade settings] mainUser]];
}

+(instancetype)codeRequestWithName:(NSString *)name
                     withParamters:(NSDictionary *)params {
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:@"POST"
                                                  withAction:[NSString stringWithFormat:@"api/v/1/code/%@/%@",[[ClearBlade settings] systemKey],name]
                                              withParameters:params
                                                    withUser:[[ClearBlade settings] mainUser]];
}

+(instancetype)pushRequestWithAction:(NSString *)action
                           withMthod:(NSString *)method
                          withParams:(NSDictionary *)params
{
    return [[CBHTTPRequest alloc] initWithClearBladeSettings:[ClearBlade settings]
                                                  withMethod:method
                                                  withAction:[[NSString stringWithFormat:@"api/v/1/push/%@", [[ClearBlade settings] systemKey]] stringByAppendingString:action]
                                              withParameters:params
                                                    withUser:[[ClearBlade settings] mainUser]];
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
                          withQueryString:(NSString *)queryString
                                 withUser:(CBUser *)user {
    NSString *urlString = [NSString stringWithFormat:@"%@%@?%@", [settings serverAddress], action, queryString];
    NSURL *url = [NSURL URLWithString:urlString];
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

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings
                               withMethod:(NSString *)method
                               withAction:(NSString *)action
                                 withBody:(NSDictionary *)body
                              withHeaders:(NSDictionary *)headers
                                withQuery:(CBQuery *)query {
    NSDictionary *paramDict = [query fetchQuery];
    NSURL *url;
    if ([paramDict count] != 0) {
        NSDictionary *parameters = @{@"query":[[NSString alloc] initWithData:[NSJSONSerialization dataWithJSONObject:paramDict
                                                                                                             options:0
                                                                                                               error:NULL]
                                                                    encoding:NSUTF8StringEncoding]};
        
        NSString *queryString = [self encodeQuery:parameters[@"query"]];
        NSString *paramString = [NSString stringWithFormat:@"%@?query=%@", action, queryString];
        url = [NSURL URLWithString:[[settings serverAddress] stringByAppendingString:paramString]];
    } else {
        url = [NSURL URLWithString:[[settings serverAddress] stringByAppendingString:action]];
    }
    self = [super initWithURL:url];
    for (id key in headers.keyEnumerator) {
        [self setValue:[headers objectForKey:key] forHTTPHeaderField:key];
    }
    return self;
}

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings
                               withMethod:(NSString *)method
                               withAction:(NSString *)action
                           withParameters:(NSDictionary *)params
                                 withUser:(CBUser *)user {
    
    NSURL * url = [[NSURL URLWithString:[settings serverAddress]] URLByAppendingPathComponent:action];
    NSError * error = nil;
    
    NSData * bodyData;
    if (params) {
        bodyData = [NSJSONSerialization dataWithJSONObject:params options:0 error:&error];
    }
    
    self = [super initWithURL:url];
    if (self) {
        self.HTTPMethod = method;
        self.HTTPBody = bodyData;
        self.settings = settings;
        self.user = user;
        if (error) {
            CBLogWarning(@"Request <%@> failed to initialize body <%@> with error <%@>", self, params, error);
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
    [self setValue:[settings systemKey] forHTTPHeaderField:@"ClearBlade-SystemKey"];
    [self setValue:[settings systemSecret] forHTTPHeaderField:@"ClearBlade-SystemSecret"];
    _settings = settings;
}
-(void)executeWithSuccessCallback:(CBHTTPRequestSuccessCallback)successCallback withErrorCallback:(CBHTTPRequestErrorCallback)errorCallback {
    void (^completionHandler)(NSURLResponse *, NSData *, NSError *) =^(NSURLResponse *response, NSData *data, NSError * connectionError) {
        NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *)response;
        CBHTTPRequestResponse * requestResponse = [CBHTTPRequestResponse responseWithRequest:self
                                                                                withResponse:(NSHTTPURLResponse *)response
                                                                                    withData:data];
        NSLog(@"Executed Request with Response\n%@\n\n", requestResponse);
        if (connectionError) {
            if (errorCallback) {
                errorCallback(requestResponse, connectionError);
            }
        } else if (httpResponse.statusCode != 200 && httpResponse.statusCode != 202) {
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
    NSLog(@"Executed Request with Response\n%@\n\n", response);
    [self.settings logExtra:@"Executed Request with Response\n%@\n\n", response];
    if (requestError) {
        *error = requestError;
    } else if (requestResponse.statusCode != 200 && requestResponse.statusCode != 202) {
        *error = [NSError errorWithDomain:@"Request failed because of statusCode" code:requestResponse.statusCode userInfo:nil];
    } else {
        return requestData;
    }
    return nil;
}

@end
