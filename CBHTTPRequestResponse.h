//
//  CBHTTPRequestResponse.h
//  CBAPI
//
//  Created by Tyler Dodge on 1/22/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CBHTTPRequest;

@interface CBHTTPRequestResponse : NSObject
@property (strong, nonatomic) CBHTTPRequest * request;
@property (strong, nonatomic) NSHTTPURLResponse * response;
@property (strong, nonatomic) NSData * responseData;
@property (strong, nonatomic) NSString * responseString;

+(instancetype)responseWithRequest:(CBHTTPRequest *)request withResponse:(NSHTTPURLResponse *)response withData:(NSData *)data;
@end
