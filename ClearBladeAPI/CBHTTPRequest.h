//
//  CBHTTPRequest.h
//  testApp
//
//  Created by Tyler Dodge on 12/3/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClearBlade.h"
#import "CBQuery.h"

@class CBHTTPRequestResponse;

typedef void (^CBHTTPRequestSuccessCallback)(CBHTTPRequestResponse *);
typedef void (^CBHTTPRequestErrorCallback)(CBHTTPRequestResponse *, NSError *);


@interface CBHTTPRequest : NSMutableURLRequest
@property (atomic, weak) ClearBlade * settings;
@property (atomic, weak) CBUser * user;
@property (atomic, strong) NSString * action;

+(instancetype)requestWithMethod:(NSString *)method withCollection:(NSString *)collectionID withParameters:(NSDictionary *)parameters withUser:(CBUser *)user;

+(instancetype)userRequestWithSettings:(ClearBlade *)settings
                            withMethod:(NSString *)method
                            withAction:(NSString *)action
                              withBody:(NSDictionary *)body
                           withHeaders:(NSDictionary *)headers;

+(instancetype)userRequestWithSettings:(ClearBlade *)settings
                            withMethod:(NSString *)method
                            withAction:(NSString *)action
                              withBody:(NSDictionary *)body
                           withHeaders:(NSDictionary *)headers
                             withQuery:(CBQuery *)query;

+(instancetype)codeRequestWithName:(NSString *)name
                     withParamters:(NSDictionary *)params;

+(instancetype)messageHistoryRequestWithSettings:(ClearBlade *)settings
                                      withMethod:(NSString *)method
                                      withAction:(NSString *)action
                                 withQueryString:(NSString *)queryString;

+(instancetype)pushRequestWithAction:(NSString *)action
                           withMthod:(NSString *)method
                          withParams:(NSDictionary *)params;

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings withMethod:(NSString *)path withCollection:(NSString *)collectionID withParameters:(NSDictionary *)params withUser:(CBUser *)user;

-(NSData *)executeWithError:(NSError **)error;
-(void)executeWithSuccessCallback:(CBHTTPRequestSuccessCallback)successCallback withErrorCallback:(CBHTTPRequestErrorCallback)errorCallback;
@end
