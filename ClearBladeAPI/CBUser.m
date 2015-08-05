//
//  CBUser.m
//  CBAPI
//
//  Created by Tyler Dodge on 1/14/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import "CBUser.h"
#import "CBQuery.h"
#import "CBHTTPRequest.h"
#import "CBHTTPRequestResponse.h"

#define CB_AUTH_TOKEN_KEY @"user_token"
#define CB_CHECK_AUTH_TOKEN_KEY @"is_authenticated"

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
+(CBHTTPRequest *)authRequestWithSettings:(ClearBlade *)settings withEmail:(NSString *)email withPassword:(NSString *)password {
    return [CBHTTPRequest userRequestWithSettings:settings
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

+(CBHTTPRequest *)regRequestWithSettings:(ClearBlade *)settings withEmail:(NSString *)email withPassword:(NSString *)password {
    return [CBHTTPRequest userRequestWithSettings:settings
                                       withMethod:@"POST"
                                       withAction:@"reg"
                                         withBody:[CBUser dictWithEmail:email withPassword:password]
                                      withHeaders:nil];
}

+(CBHTTPRequest *)checkRequestWithSettings:(ClearBlade *)settings withToken:(NSString *)authToken {
    return [CBHTTPRequest userRequestWithSettings:settings
                                       withMethod:@"POST"
                                       withAction:@"checkauth"
                                         withBody:@{}
                                      withHeaders:@{@"ClearBlade-UserToken": authToken}];
}
+(CBHTTPRequest *)logoutRequestWithSettings:(ClearBlade *)settings withToken:(NSString *)authToken {
    return [CBHTTPRequest userRequestWithSettings:settings
                                       withMethod:@"POST"
                                       withAction:@"logout"
                                         withBody:@{}
                                      withHeaders:@{@"ClearBlade-UserToken": authToken}];
}
+(CBHTTPRequest *)getUserInfoRequestWithSettings:(ClearBlade *)settings withToken:(NSString *)authToken {
    return [CBHTTPRequest userRequestWithSettings:settings
                                       withMethod:@"GET"
                                       withAction:@"info"
                                         withBody:nil
                                      withHeaders:@{@"ClearBlade-UserToken":authToken}];
}
+(CBHTTPRequest *)setUserInfoRequestWithSettings:(ClearBlade *)settings withInfo:(NSDictionary *)userInfo withToken:(NSString *)authToken {
    return [CBHTTPRequest userRequestWithSettings:settings
                                       withMethod:@"PUT"
                                       withAction:@"info"
                                         withBody:userInfo
                                      withHeaders:@{@"ClearBlade-UserToken":authToken}];
}
+(CBHTTPRequest *)getAllUserInfoRequestWithSettings:(ClearBlade *)settings
                                          withToken:(NSString *)authToken
                                          withQuery:(CBQuery *)query
{
    return [CBHTTPRequest userRequestWithSettings:settings
                                       withMethod:@"GET"
                                       withAction:@""
                                         withBody:nil
                                      withHeaders:@{@"ClearBlade-UserToken":authToken}
                                        withQuery:query];
}

+(instancetype)authenticateUserWithEmail:(NSString *)email withPassword:(NSString *)password withError:(NSError *__autoreleasing *)error {
    return [self authenticateUserWithSettings:[ClearBlade settings]
                                    withEmail:email
                                 withPassword:password
                                    withError:error];
}
+(instancetype)authenticateUserWithSettings:(ClearBlade *)settings
                                  withEmail:(NSString *)email
                               withPassword:(NSString *)password
                                  withError:(NSError *__autoreleasing *)error {
    NSData * response = [[CBUser authRequestWithSettings:settings withEmail:email withPassword:password] executeWithError:error];
    if (*error) {
        [settings logError:@"Failed to authenticate user with email <%@> because of error <%@>", email, *error];
        return nil;
    }
    NSString * authToken = [CBUser parseTokenResponse:response];
    CBUser * user = [CBUser authenticatedUserWithEmail:email withAuthToken:authToken];
    [settings logDebug:@"Authenticated user <%@>", user];
    return user;
}

+(instancetype)registerUserWithEmail:(NSString *)email withPassword:(NSString *)password withError:(NSError *__autoreleasing *)error {
    return [self registerUserWithSettings:[ClearBlade settings] withEmail:email withPassword:password withError:error];
}

+(instancetype)registerUserWithSettings:(ClearBlade *)settings
                              withEmail:(NSString *)email
                           withPassword:(NSString *)password
                              withError:(NSError *__autoreleasing *)error {
    [[CBUser regRequestWithSettings:settings withEmail:email withPassword:password] executeWithError:error];
    if (*error) {
        [settings logError:@"Failed to register user with email <%@> because of error <%@>", email, *error];
        return nil;
    }
    CBUser * user = [self authenticateUserWithSettings:settings withEmail:email withPassword:password withError:error];
    [settings logDebug:@"Registered user <%@>", user];
    return user;
}

+(void)registerUserWithEmail:(NSString *)email
                withPassword:(NSString *)password
         withSuccessCallback:(CBUserSuccessCallback)successCallback
           withErrorCallback:(CBUserErrorCallback)errorCallback {
    [self registerUserWithSettings:[ClearBlade settings]
                         withEmail:email
                      withPassword:password
               withSuccessCallback:successCallback
                 withErrorCallback:errorCallback];
}
+(NSString *)parseTokenResponse:(NSData *)tokenResponse {
    NSError * error;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:tokenResponse options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        CBLogError(@"Unexpected error while parsing auth token <%@>", error);
        return nil;
    }
    return [json objectForKey:CB_AUTH_TOKEN_KEY];
}
+(bool)parseCheckAuthResponse:(NSData *)response {
    NSError * error;
    NSDictionary * json = [NSJSONSerialization JSONObjectWithData:response options:NSJSONReadingAllowFragments error:&error];
    if (error) {
        CBLogError(@"Unexpected error while parsing check auth response <%@>", error);
        return nil;
    }
    return [[json objectForKey:CB_CHECK_AUTH_TOKEN_KEY] boolValue];
}
+(void)registerUserWithSettings:(ClearBlade *)settings
                      withEmail:(NSString *)email
                   withPassword:(NSString *)password
            withSuccessCallback:(CBUserSuccessCallback)successCallback
              withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[CBUser regRequestWithSettings:settings withEmail:email withPassword:password] executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        [settings logDebug:@"Registered user with <%@>", email];
        [self authenticateUserWithSettings:settings withEmail:email withPassword:password withSuccessCallback:successCallback withErrorCallback:errorCallback];
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        [settings logError:@"Failed to register user with email <%@> with error <%@>", email, error];
        if (errorCallback) {
            errorCallback(error);
        }
    }];
    
}

+(void)authenticateUserWithEmail:(NSString *)email
                    withPassword:(NSString *)password
             withSuccessCallback:(CBUserSuccessCallback)successCallback
               withErrorCallback:(CBUserErrorCallback)errorCallback {
    [self authenticateUserWithSettings:[ClearBlade settings] withEmail:email withPassword:password withSuccessCallback:successCallback withErrorCallback:errorCallback];
}

+(void)authenticateUserWithSettings:(ClearBlade *)settings
                          withEmail:(NSString *)email
                       withPassword:(NSString *)password
                withSuccessCallback:(CBUserSuccessCallback)successCallback
                  withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[self authRequestWithSettings:settings withEmail:email withPassword:password] executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        NSString * authToken = [CBUser parseTokenResponse:response.responseData];
        CBUser * user = [CBUser authenticatedUserWithEmail:email withAuthToken:authToken];
        [settings logDebug:@"Authenticated user <%@>", user];
        if (successCallback) {
            successCallback(user);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        [settings logError:@"Failed to authenticate user with email <%@> with error <%@>", email, error];
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
    NSString * authToken = [CBUser parseTokenResponse:response];
    CBUser * user = [CBUser anonymousUserWithAuthToken:authToken];
    [settings logDebug:@"Authenticated user <%@>", user];
    return user;
}

+(void)anonymousUserWithSettings:(ClearBlade *)settings withSuccessCallback:(CBUserSuccessCallback)successCallback withErrorCallback:(CBUserErrorCallback)errorCallback {
    CBHTTPRequest * request = [self authRequestWithAnonWithSettings:settings];
    [request executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        NSString * authToken = [CBUser parseTokenResponse:response.responseData];
        [settings logDebug:@"User <%@> logged out", self];
        if (successCallback) {
            successCallback([CBUser anonymousUserWithAuthToken:authToken]);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        [settings logError:@"Failed to authenticate anonymous user with error <%@>", error];
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
    NSData * data = [[CBUser checkRequestWithSettings:[ClearBlade settings] withToken:self.authToken] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to check auth token of user <%@> because of error <%@>", self, *error);
        return nil;
    }
    return [CBUser parseCheckAuthResponse:data];
}

-(void)checkIsValidWithServerWithCallback:(CBUserIsValidCallback)isValidCallback withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[CBUser checkRequestWithSettings:[ClearBlade settings] withToken:self.authToken]
     executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
         if (isValidCallback) {
             isValidCallback([CBUser parseCheckAuthResponse:response.responseData]);
         }
     } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
         CBLogError(@"Failed to check auth token of user <%@> because of error <%@>", self, error);
         if (errorCallback) {
             errorCallback(error);
         }
     }];
}

-(NSDictionary *)getCurrentUserInfoWithError:(NSError *__autoreleasing *)error {
    NSData *data = [[CBUser getUserInfoRequestWithSettings:[ClearBlade settings] withToken:self.authToken] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to get user info of user <%@> because of error <%@>", self, *error);
    }
    NSDictionary *userInfo = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if (*error) {
        CBLogError(@"Failed to parse user info of user <%@> because of error <%@>", self, *error);
    }
    return userInfo;
}

-(NSDictionary *)getAllUsersWithError:(NSError *__autoreleasing *)error
                       withQuery:(CBQuery *)query
{
    NSData *data = [[CBUser getAllUserInfoRequestWithSettings:[ClearBlade settings] withToken:self.authToken withQuery:query] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to get all users because of error <%@>", *error);
    }
    NSDictionary *userInfoDict = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:error];
    if (*error) {
        CBLogError(@"Failed to parse all users call because of error <%@>", *error);
    }
    return userInfoDict;
}

-(void)setCurrentUserInfoWithDict:(NSDictionary *)userInfo withError:(NSError *__autoreleasing *)error {
    [[CBUser setUserInfoRequestWithSettings:[ClearBlade settings] withInfo:userInfo withToken:self.authToken] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to set user info of user <%@> because of error <%@>", self, *error);
    }
}

-(bool)logOutWithError:(NSError *__autoreleasing *)error {
    [[CBUser logoutRequestWithSettings:[ClearBlade settings] withToken:self.authToken] executeWithError:error];
    if (*error) {
        CBLogError(@"Failed to logout user <%@> because of error <%@>", self, error);
        return nil;
    }
    CBLogDebug(@"User <%@> logged out", self);
    return true;
}

-(void)logOutWithSuccessCallback:(void (^)())successCallback withErrorCallback:(CBUserErrorCallback)errorCallback {
    [[CBUser logoutRequestWithSettings:[ClearBlade settings] withToken:self.authToken]
     executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
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
