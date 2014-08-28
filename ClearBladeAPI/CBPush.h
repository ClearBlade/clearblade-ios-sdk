//
//  CBPush.h
//  CBAPI
//
//  Created by Michael on 8/28/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CBPush : NSObject

typedef void (^CBPushErrorCallback)(NSError * error);

+(void)addCurrentUserDeviceToken:(NSData *)token withErrorCallback:(CBPushErrorCallback)errorCallback;
+(void)sendPushWithDictionary:(NSDictionary *)dictionary toUsers:(NSArray *)users withErrorCallback:(CBPushErrorCallback)errorCallback;

@end
