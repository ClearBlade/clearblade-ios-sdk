//
//  CBPush.m
//  CBAPI
//
//  Created by Michael on 8/28/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import "CBPush.h"
#import "CBHTTPRequest.h"

@implementation CBPush

+(void)addCurrentUserDeviceToken:(NSData *)token withErrorCallback:(CBPushErrorCallback)errorCallback
{
    NSDictionary *params = @{@"device-token": [token base64EncodedDataWithOptions:0],
                                 @"type": "apple",
                                 @"appid": [self getAppId]};
    
    CBHTTPRequest *apiRequest = [CBHTTPRequest pushRequestWithAction:@"/ids" withMthod:@"POST" withParams:params];
    
    [apiRequest executeWithSuccessCallback:^(CBHTTPRequestResponse *response) {
       //noop on success
    } withErrorCallback:^(CBHTTPRequestResponse *response, NSError *error) {
        if (errorCallback) {
            errorCallback(error);
        }
    }];
    
}

+(void)sendPushWithDictionary:(NSDictionary *)dictionary toUsers:(NSArray *)users withErrorCallback:(CBPushErrorCallback)errorCallback
{
    
    NSDictionary *params = @{@"cbids": users,
                             @"apple-message": [self parseDictionaryIntoAPSFormat:dictionary],
                             @"appid": [self getAppId]};
    
    CBHTTPRequest *apiRequest = [CBHTTPRequest pushRequestWithAction:@"" withMthod:@"POST" withParams:params];
    
    [apiRequest executeWithSuccessCallback:^(CBHTTPRequestResponse *response) {
        //noop on success
    } withErrorCallback:^(CBHTTPRequestResponse *response, NSError *error) {
        if (errorCallback) {
            errorCallback(error);
        }
    }];
    
    /*
     {
     cbids: [cbids..,]
     apple-message string,
     android-message string,
     windows-message string,
     delivery-date: int64,
     appid:string
     }
*/
}

+(NSString *)getAppId
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+(NSDictionary *)parseDictionaryIntoAPSFormat:(NSDictionary *)dict
{
    
    NSMutableDictionary *parsedDict;
    
    [parsedDict setValue:[[NSMutableDictionary init] alloc] forKey:@"aps"];
    
    for(NSString* key in dict){
        if ([key isEqualToString:@"alert"] || [key isEqualToString:"badge"] || [key isEqualToString:@"sound"]) {
            [[parsedDict objectForKey:@"aps"] setObject:dict[key] forKey:key];
        }else{
            [parsedDict setObject:dict[key] forKey:key];
        }
    }
    
    return parsedDict;
    /*
     {
     "aps" : {
     "alert" : "You got your emails.",
     "badge" : 9,
     "sound" : "bingbong.aiff"
     },
     "acme1" : "bar",
     "acme2" : 42
     }
     */
}

@end
