//
//  CBHTTPRequest.h
//  testApp
//
//  Created by Tyler Dodge on 12/3/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClearBlade.h"

typedef void (^CBHTTPRequestSuccessCallback)(NSData *);
typedef void (^CBHTTPRequestErrorCallback)(NSError *);

@interface CBHTTPRequest : NSMutableURLRequest
@property (atomic, weak) ClearBlade * settings;
@property (atomic, weak) CBUser * user;

+(instancetype)requestWithMethod:(NSString *)method withCollection:(NSString *)collectionID withParameters:(NSDictionary *)parameters withUser:(CBUser *)user;

+(instancetype)userRequestWithMethod:(NSString *)method withAction:(NSString *)action withBody:(NSDictionary *)body withHeaders:(NSDictionary *)headers;

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings withMethod:(NSString *)path withCollection:(NSString *)collectionID withParameters:(NSDictionary *)params withUser:(CBUser *)user;

-(NSData *)executeWithError:(NSError **)error;
-(void)executeWithSuccessCallback:(CBHTTPRequestSuccessCallback)successCallback withErrorCallback:(CBHTTPRequestErrorCallback)errorCallback;
@end
