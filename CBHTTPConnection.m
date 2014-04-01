//
//  CBHTTPConnection.m
//  CBAPI
//
//  Created by Tyler Dodge on 3/24/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import "CBHTTPConnection.h"
#import <Foundation/Foundation.h>

@interface CBHTTPConnection ()
@property (strong, nonatomic) void (^completionHandler)(NSURLResponse *, NSData *, NSError *);
@property (strong, nonatomic) NSMutableData * data;
@property (strong, nonatomic) NSURLResponse * response;
@property (weak, nonatomic) ClearBlade * settings;
@end
@implementation CBHTTPConnection
@synthesize completionHandler = _completionHandler;
@synthesize data = _data;

+(void)sendAsynchronousRequest:(NSURLRequest *)request
                  withSettings:(ClearBlade *)settings
         withCompletionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))completionHandler {
    CBHTTPConnection * connectionDelegate = [[CBHTTPConnection alloc] initWithRequest:request
                                                        withCompletionHandler:completionHandler
                                                                         withSettings:settings];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:
                                    request delegate:connectionDelegate];
    [connection start];
}


+(NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 withSettings:(ClearBlade *)settings
                 withResponse:(NSURLResponse * __autoreleasing *)response
                    withError:(NSError  * __autoreleasing *)error {
    dispatch_semaphore_t waitSemaphore = dispatch_semaphore_create(0);
    __block NSError * lambdaError = nil;
    __block NSURLResponse * lambdaResponse;
    void (^completionHandler)(NSURLResponse *, NSData *, NSError *) = ^(NSURLResponse * completeResponse, NSData *completeData, NSError *completeError) {
        lambdaResponse = completeResponse;
        lambdaError = completeError;
        dispatch_semaphore_signal(waitSemaphore);
    };
    CBHTTPConnection * connectionDelegate = [[CBHTTPConnection alloc] initWithRequest:request withCompletionHandler:completionHandler withSettings:settings];
    NSURLConnection * connection = [[NSURLConnection alloc] initWithRequest:request
                                                                   delegate:connectionDelegate];
    [connection start];
    NSRunLoop * runLoop = [NSRunLoop currentRunLoop];
    while (dispatch_semaphore_wait(waitSemaphore, DISPATCH_TIME_NOW) && [runLoop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]) {
    }
    if (error != NULL) {
        *error = lambdaError;
    }
    if (response != NULL) {
        *response = lambdaResponse;
    }
    return connectionDelegate.data;
}

-(void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.response = response;
}


-(instancetype)initWithRequest:(NSURLRequest *)request
         withCompletionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))completionHandler
                  withSettings:(ClearBlade *)settings
{
    self = [super init];
    if (self) {
         //synchronous version will be able to use a semaphore to block.
        self.completionHandler = completionHandler;
        self.settings = settings;
    }
    return self;
}


-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.data appendData:data];
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.completionHandler(self.response, self.data, nil);
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    self.completionHandler(self.response, self.data, error);
}

-(BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return YES;
}

-(void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
}

-(NSMutableData *)data {
    if (!_data) {
        _data = [NSMutableData data];
    }
    return _data;
}

@end
