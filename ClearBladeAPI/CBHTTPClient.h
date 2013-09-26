/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import <AFNetworking/AFNetworking.h>
/**
Class used for making REST calls to the platform.
This is a subclass of AFHTTPClient
*/
@interface CBHTTPClient : AFHTTPClient
/**
NSURL that holds the url that the Client will use
*/
@property (strong, nonatomic) NSURL *baseURL;
/**
Sets the baseUrl property that will be used by the client to communicate with the platform
@param URL Tht NSURL that is set as the baseURL
*/
-(void) setUrl: (NSString *) URL;
/**
Sets that AppKey and AppSecret that get attached to the request headers for all requests to the platform
@param key The app key that is used to identify the app being used
@param secret The app secret that is used to authenticate the app being used
*/
-(void) setAppKey: (NSString *) key AppSecret: (NSString *) secret;

@end
