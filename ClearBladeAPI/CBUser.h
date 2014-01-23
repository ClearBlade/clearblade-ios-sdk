//
//  CBUser.h
//  CBAPI
//
//  Created by Tyler Dodge on 1/14/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBUser;
@class ClearBlade;

/**
 Used whenever user creation is successful.
 @param user The user that was created
 */
typedef void (^CBUserSuccessCallback)(CBUser *);

/**
 Used whenever user creation fails
 @param error The error that caused user creation to fail.
 */
typedef void (^CBUserErrorCallback)(NSError *);

/**
 Used for checks against whether or not the user token is valid
 @param isValid True if the user token is valid, false otherwise
 */
typedef void (^CBUserIsValidCallback)(bool);

/**
 Represents a user authenticated into the platform. Can be used directly on requests, or can be applied globally to requests
 using [[ClearBlade settings] setMainUser:]
 */
@interface CBUser : NSObject

/**
 Creates an anonymous user with the specified auth token. This does not communicate with the server in any way to validate 
 the token.
 @param authToken The authorization token to use
 @return A User object with an anonymous user using the specified authToken
 */
+(instancetype)anonymousUserWithAuthToken:(NSString *)authToken;

/**
 Creates a named user with the specified email and auth token. This does not communicate with the server in any way to validate
 the token, or the email. Currently there is not a way to verify that the email is attached to the authToken, but you can verify
 that the authToken at least is valid through the selector checkIsValidWithServerSyncWithError:
 @param Email The email the user has
 @param authToken The auth token associated with that email
 @return A User object with the specified email and authToken.
 */
+(instancetype)authenticatedUserWithEmail:(NSString *)email withAuthToken:(NSString *)authToken;

/**
 Authenticates a user with the specified email and password. It retrieves the user's token from the server synchronously,
 and does not store the password locally.
 @param email The email to create the user with
 @param password The password to use
 @param error A pointer to the error if there was an issue authenticating the user.
 @return The newly created user
 */
+(instancetype)authenticateUserWithEmail:(NSString *)email
                            withPassword:(NSString *)password
                               withError:(NSError **)error;

/**
 Registers a user with the specified email and password. It retrieves the user's token from the server synchronously,
 and does not store the password locally.
 @param email The email to create the user with
 @param password The password to use
 @param error A pointer to the error if there was an issue registering the user.
 @return The newly created user
 */
+(instancetype)registerUserWithEmail:(NSString *)email
                        withPassword:(NSString *)password
                           withError:(NSError **)error;

/**
 Authenticates a user with the specified email and password. It retrieves the user's token from the server asynchronously and 
 calls the callback once the user is authenticated, and does not store the password locally.
 @param email The email to create the user with
 @param password The password to use
 @param successCallback The callback that handles a successful authentication
 @param errorCallback The callback that handles a failed authentication
 @return The newly created user
 */
+(void)authenticateUserWithEmail:(NSString *)email
                    withPassword:(NSString *)password
             withSuccessCallback:(CBUserSuccessCallback)successCallback
               withErrorCallback:(CBUserErrorCallback)errorCallback;

/**
 Registers a user with the specified email and password. It retrieves the user's token from the server asynchronously and
 calls the callback once the user is authenticated, and does not store the password locally.
 @param email The email to create the user with
 @param password The password to use
 @param successCallback The callback that handles a successful register
 @param errorCallback The callback that handles a failed register
 @return The newly created user
 */
+(void)registerUserWithEmail:(NSString *)email
                withPassword:(NSString *)password
                withSuccessCallback:(CBUserSuccessCallback)successCallback
           withErrorCallback:(CBUserErrorCallback)errorCallback;

/**
 Requests an anonynomous user token from the server synchronously.
 @param settings The ClearBlade settings object to use. If nil, will just use the default address
 @param error Set if there's any issue with requesting the user token.
 @return The newly created anonymous user.
 */
+(CBUser *)anonymousUserWithSettings:(ClearBlade *)settings WithError:(NSError **)error;

/**
 Request an anonymous user token from the server asynchronously.
 @param settings The ClearBlade settings object to use. If nil, will just use the default address
 @param SuccessCallback Called with the user when the anonymous user is successfully created from the server
 @param ErrorCallback Called if any issue while creating the anonymous user arrises.
 */
+(void)anonymousUserWithSettings:(ClearBlade *)settings withSuccessCallback:(CBUserSuccessCallback)successCallback withErrorCallback:(CBUserErrorCallback)errorCallback;

/**
 Checks if the user token is still valid with server synchronously. Error is only set if there is an issue communicating with
 the server
 @param error The error if there's an issue communicating with server
 @return True if the server thinks it's a valid token, false if the server thinks it is not.
 */
-(bool)checkIsValidWithServerWithError:(NSError **)error;

/**
 Checks if the user token is still valid with server asynchronously. Error callback is only called if there is an issue communicating
 with the server
 @param isValidCallback Has a true boolean if the server thinks it's a valid token, false if the server thinks it is not
 @param errorCallback Only called if there is an issue communicating with the server
 */
-(void)checkIsValidWithServerWithCallback:(CBUserIsValidCallback)isValidCallback withErrorCallback:(CBUserErrorCallback)errorCallback;

/**
 Logs the user with the token out of the server synchronously.
 @param error If there's any error logging the user out, including if the user's token is already logged out
 @return Returns true if there's no error
*/
-(bool)logOutWithError:(NSError **)error;

/**
 Logs the user with the token out of the server asynchronously.
 @param SuccessCallback Called if the user is logged out successfully.
 @param ErrorCallback Called if there is any error logging the user out, including if the user's token is already logged out
 */
-(void)logOutWithSuccessCallback:(void (^)())successCallback withErrorCallback:(CBUserErrorCallback)errorCallback;

/**
 Is true if the user has no email or password, and is just an anonymous token from the server
 */
@property (atomic) BOOL isAnonymous;

/**
 The email identifying the user
 */
@property (strong, nonatomic, readonly) NSString * email;

/**
 The token from the server used to identify the user in requests
 */
@property (strong, nonatomic, readonly) NSString * authToken;
@end
