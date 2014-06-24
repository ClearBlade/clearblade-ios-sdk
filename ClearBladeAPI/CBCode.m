//
//  CBCode
//  CBAPI
//
//  Created by Michael Sprague on 6/11/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import "CBCode.h"
#import "CBHTTPRequest.h"
#import "CBHTTPRequestResponse.h"

@implementation CBCode

+(void) executeFunction:(NSString *)function withParams:(NSDictionary *)params withSuccessCallback:(CBCodeSuccessCallback)successCallback withErrorCallback:(CBCodeErrorCallback)failureCallback{
    CBHTTPRequest *apiRequest = [CBHTTPRequest codeRequestWithName:function withParamters:params];
    
    [apiRequest executeWithSuccessCallback:^(CBHTTPRequestResponse * response) {
        NSError * error;
        if (response.response.statusCode != 200) {
            error = [NSError errorWithDomain:CBCODE_NON_OK_ERROR code:response.response.statusCode userInfo:nil];
        }
        if(error){
            if(failureCallback){
                failureCallback([NSError errorWithDomain:response.responseString
                                                    code:response.response.statusCode
                                                userInfo:nil]);
            }
            return;
        }
        if (successCallback){
            successCallback([response responseString]);
        }
    } withErrorCallback:^(CBHTTPRequestResponse * response, NSError * error) {
        if (failureCallback) {
            failureCallback(error);
        }
    }];
}
@end
