//
//  ClearBladeSettingsBuilder.h
//  CBAPI
//
//  Created by Tyler Dodge on 1/23/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ClearBlade;
@class CBUser;

typedef enum {
    /** CBAPI does not log anything under this level */
    CB_LOG_NONE = 0,
    
    /** CBAPI only logs errors under this level */
    CB_LOG_ERROR = 1,
    
    /** CBAPI logs warnings and errors under this level */
    CB_LOG_WARN = 2,
    
    /** CBAPI logs debug lines, warnings, and errors under this level */
    CB_LOG_DEBUG = 3,
    
    /** CBAPI logs everything under this level */
    CB_LOG_EXTRA = 4
} CBLoggingLevel;

/**
 Callback for handling successful initialization of the Clearblade API
 @param ClearBlade The newly initialized settings
 */
typedef void (^ClearBladeSettingsSuccessCallback)(ClearBlade *);

/**
 Callback for handling failed initialization of the ClearBlade API
 @param error The error that caused the initialization to fail
 */
typedef void (^ClearBladeSettingsErrorCallback)(NSError *);

/**
 Protocol for building ClearBladeSettings piecemeal. Does not actually initialize
 the settings until either runWithSuccessCallback:withErrorCallback: or runSyncWithError
 is called. Once either is called and completed, it sets the global [ClearBlade settings] to the newly initialized
 ClearBlade object. SystemKey and SystemSecret must be set before running.
 */
@protocol ClearBladeSettingsBuilder

/**
 Sets the appKey and appSecret for ClearBlade settings
 @param appKey The System Key to authenticate with
 @param appSecret The secret key to authenticate with
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withSystemKey:(NSString *)systemKey withSystemSecret:(NSString *)systemSecret;

/**
 Sets the target server address for ClearBlade Platform Data
 @param serverAddress The target server address
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withServerAddress:(NSString *)serverAddress;

/**
 Sets the target messaging address for ClearBlade Platform Messaging
 @param messagingAddress The target messaging server address
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withMessagingAddress:(NSString *)messagingAddress;

/**
 Sets the logging level for ClearBlade settings
 @param loggingLevel The new level for logging
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withLoggingLevel:(CBLoggingLevel)loggingLevel;

/**
 Sets the main user for ClearBlade settings. This should only be a user with
 token and loaded from save data, because authenticating a user is not available
 until after ClearBlade settings are set.
 @param mainUser The new mainUser
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)withMainUser:(CBUser *)mainUser;

/**
 Sets an email and password to authenticate with for ClearBlade settings.
 Use this if you do not want to authenticate as an anonymous user
 @param email The email of the user you wish to authenticate
 @param password The password of the user you wish to authenticate
 @return The ClearBladeSettingsBuilder to be used for additional settings
 */
-(instancetype)authenticateUserWithEmail:(NSString *)email withPassword:(NSString *)password;

/**
 Tells the settings to register the user before authenticating.
 @return The ClearBladeSettingsBuilder to be used for additional settings
*/
-(instancetype)registerUser;

/**
 Executes the Settings builder with the settings given asynchronously. If mainUser
 is not set, it will request an anonymous token for future requests.
 @param successCallback The callback if all goes well
 @param errorCallback The callback if the initialization fails
 */
-(void)runWithSuccessCallback:(ClearBladeSettingsSuccessCallback)successCallback
            withErrorCallback:(ClearBladeSettingsErrorCallback)errorCallback;

/**
 Executes the Settings builder with the settings given synchronously. If mainUser
 is not set, it will request an anonymous token for future requests.
 @param error This error will be set if it fails to initialize the new ClearBlade settings
 @return The newly created ClearBlade settings.
 */
-(ClearBlade *)runSyncWithError:(NSError **)error;
@end
