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
    NSString *deviceToken = [token base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSDictionary *params = @{@"device-token": deviceToken,
                             @"type": @"apple",
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
    
}

+(NSString *)getAppId
{
    return [[NSBundle mainBundle] bundleIdentifier];
}

+(NSString *)parseDictionaryIntoAPSFormat:(NSDictionary *)dict
{
    NSMutableDictionary *parsedDict = [[NSMutableDictionary alloc] init];
    
    [parsedDict setObject:[[NSMutableDictionary alloc] init] forKey:@"aps"];
    
    for(NSString* key in dict){
        if ([key isEqualToString:@"alert"] || [key isEqualToString:@"badge"] || [key isEqualToString:@"sound"]) {
            [[parsedDict objectForKey:@"aps"] setObject:dict[key] forKey:key];
        }else{
            [parsedDict setObject:dict[key] forKey:key];
        }
    }
    
    NSLog(@"%@", parsedDict);
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:parsedDict options:0 error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}

@end
