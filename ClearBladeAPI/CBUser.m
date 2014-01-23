//
//  CBUser.m
//  CBAPI
//
//  Created by Tyler Dodge on 1/14/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import "CBUser.h"
#import "CBHTTPRequest.h"
#import "CBHTTPRequestResponse.h"

@interface CBUser ()
@property (strong, nonatomic) NSString * email;
@property (strong, nonatomic) NSString * authToken;
@end

@implementation CBUser
@synthesize email;
@synthesize authToken;


+(NSDictionary *)dictWithEmail:(NSString *)email withPassword:(NSString *)password {
    return @{@"email": email,
             @"password": password};
}
+(CBHTTPRequest *)authRequestWithEmail:(NSString *)email withPassword:(NSString *)password {
    return [CBHTTPRequest userRequestWithSettings:nil
                                       withMethod:@"POST"
                                     withAction:@"auth"
                                       withBody:[CBUser dictWithEmail:email withPassword:password]
                                    withHeaders:nil];
}

+(CBHTTPRequest *)authRequestWithAnonWithSettings:(ClearBlade *)settings {
    return [CBHTTPRequest userRequestWithSettings:settings
                                       withMethod:@"POST"
                                     withAction:@"anon"
                                       withBody:nil
                                    withHeaders:nil];
}

+(CBHTTPRequest *)regRequestWithEmail:(NSString *)email withPassword:(NSString *)password {
    return [CBHTTPRequest userRequestWithSettings:nil
                                       withMethod:@"POST"
                                     withAction:@"reg"
                                       withBody:[CBUser dictWithEmail:email withPassword:password]
                                    withHeaders:nil];
}

+(CBHTTPRequest *)checkRequestWithToken:(NSString *)authToken {
    return [CBHTTPRequest userRequestWithSettings:nil
                                       withMethod:@"POST"
                                     withAction:@"check"
                                       withBody:@{}
                                    withHeaders:@{@"ClearBlade-UserToken": authToken}];
}
+(CBHTTPRequest *)logoutRequestWithToken:(NSString *)authToken {
    return [CBHTTPRequest userRequestWithSettings:nil
                                       withMethod:@"POST"
                                     withAction:@"logout"
                                       withBody:@{}
                                    withHeaders:@{@"ClearBlade-UserToken": authToken}];
}

+(instancetype)authenticateUserWithEmail:(NSString *)email withPassword:(NSString *)password withError:(NSError *__autoreleasing *)error {
    NSData * response = [[CBUser authRequestWithEmail:email withPassword:password] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to authenticate user with email <%@> because of error <%@>", email, *error);
        return nil;
    }
    NSString * authToken = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
    CBUser * user = [CBUser authenticatedUserWithEmail:email withAuthToken:authToken];
    CBLogDebug(@"Authenticated user <%@>", user);
    return user;
}

+(instancetype)registerUserWithEmail:(NSString *)email withPassword:(NSString *)password withError:(NSError *__autoreleasing *)error {
    [[CBUser regRequestWithEmail:email withPassword:password] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to register user with email <%@> because of error <%@>", email, *error);
        return nil;
    }
    CBUser * user = [self authenticateUserWithEmail:email withPassword:password withError:error];
    CBLogDebug(@"Registered user <%@>", user);
    return user;
}

+(void)registerUserWithEmail:(NSString *)email
                withPassword:(NSString *)password
         withSuccessCallback:(CBUserSuccessCallback)successCallback
           withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[CBUser regRequestWithEmail:email withPassword:password] executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        CBLogDebug(@"Registered user with <%@>", email);
        [self authenticateUserWithEmail:email withPassword:password withSuccessCallback:successCallback withErrorCallback:errorCallback];
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        CBLogError(@"Failed to register user with email <%@> with error <%@>", email, error);
        if (errorCallback) {
            errorCallback(error);
        }
    }];
}

+(void)authenticateUserWithEmail:(NSString *)email
                    withPassword:(NSString *)password
             withSuccessCallback:(CBUserSuccessCallback)successCallback
               withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[self authRequestWithEmail:email withPassword:password] executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        NSString * authToken = response.responseString;
        CBUser * user = [CBUser authenticatedUserWithEmail:email withAuthToken:authToken];
        CBLogDebug(@"Authenticated user <%@>", user);
        if (successCallback) {
            successCallback(user);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        CBLogError(@"Failed to authenticate user with email <%@> with error <%@>", email, error);
        if (errorCallback) {
            errorCallback(error);
        }
    }];
}

+(CBUser *)anonymousUserWithSettings:(ClearBlade *)settings WithError:(NSError *__autoreleasing *)error {
    CBHTTPRequest * request = [CBUser authRequestWithAnonWithSettings:settings];
    NSData * response = [request executeWithError:error];
    if (*error) {
        [settings logError:@"Failed to authenticate anonymous user because of error <%@>", *error];
        return nil;
    }
    CBUser * user = [CBUser anonymousUserWithAuthToken:[[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding]];
    CBLogDebug(@"Authenticated user <%@>", user);
    return user;
}

+(void)anonymousUserWithSettings:(ClearBlade *)settings withSuccessCallback:(CBUserSuccessCallback)successCallback withErrorCallback:(CBUserErrorCallback)errorCallback {
    CBHTTPRequest * request = [self authRequestWithAnonWithSettings:settings];
    [request executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        NSString * authToken = response.responseString;
        CBLogDebug(@"User <%@> logged out", self);
        if (successCallback) {
            successCallback([CBUser anonymousUserWithAuthToken:authToken]);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        CBLogError(@"Failed to authenticate anonymous user with error <%@>", error);
        if (errorCallback) {
            errorCallback(error);
        }
    }];
}

+(instancetype)authenticatedUserWithEmail:(NSString *)email withAuthToken:(NSString *)authToken {
    CBUser * user = [[CBUser alloc] init];
    user.email = email;
    user.authToken = authToken;
    user.isAnonymous = false;
    return user;
}

+(instancetype)anonymousUserWithAuthToken:(NSString *)authToken {
    CBUser * user = [[CBUser alloc] init];
    user.isAnonymous = true;
    user.authToken = authToken;
    return user;
}

-(bool)checkIsValidWithServerWithError:(NSError *__autoreleasing *)error {
    NSData * data = [[CBUser checkRequestWithToken:self.authToken] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to check auth token of user <%@> because of error <%@>", self, *error);
        return nil;
    }
    NSString * response = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return [response boolValue];
}
-(void)checkIsValidWithServerWithCallback:(CBUserIsValidCallback)isValidCallback withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[CBUser checkRequestWithToken:self.authToken] executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        if (isValidCallback) {
            isValidCallback([response.responseString boolValue]);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        CBLogError(@"Failed to check auth token of user <%@> because of error <%@>", self, error);
        if (errorCallback) {
            errorCallback(error);
        }
    }];
}

-(bool)logOutWithError:(NSError *__autoreleasing *)error {
    [[CBUser logoutRequestWithToken:self.authToken] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to logout user <%@> because of error <%@>", self, error);
        return nil;
    }
    CBLogDebug(@"User <%@> logged out", self);
    return true;
}

-(void)logOutWithSuccessCallback:(void (^)())successCallback withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[CBUser logoutRequestWithToken:self.authToken] executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        CBLogDebug(@"User <%@> logged out", self);
        if (successCallback) {
            successCallback();
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        CBLogError(@"Failed to logout user <%@> because of error <%@>", self, error);
        if (errorCallback) {
            errorCallback(error);
        }
    }];
}

-(NSString *)description {
    if (self.isAnonymous) {
        return [NSString stringWithFormat:@"CBUser: Anonymous, AuthToken <%@>", self.authToken];
    } else {
        return [NSString stringWithFormat:@"CBUser: Email <%@>, AuthToken <%@>", self.email, self.authToken];
    }
}

@end
