//
//  CBCode.h
//  CBAPI
//
//  Created by Michael Sprague on 6/11/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CBCODE_NON_OK_ERROR @"Received Non 200 status from server"

@interface CBCode : NSObject

typedef void (^CBCodeSuccessCallback)(NSString *result);

typedef void (^CBCodeErrorCallback)(NSError * error);

+(void)executeFunction:(NSString *)function withParams:(NSDictionary *)params withSuccessCallback:(CBCodeSuccessCallback)successCallback withErrorCallback:(CBCodeErrorCallback)failureCallback;

@end