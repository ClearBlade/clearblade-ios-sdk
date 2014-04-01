//
//  CBHTTPConnection.h
//  CBAPI
//
//  Created by Tyler Dodge on 3/24/14.
//  Copyright (c) 2014 Clearblade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CBAPI.h"

@interface CBHTTPConnection : NSObject <NSURLConnectionDelegate, NSURLConnectionDataDelegate>
+(void)sendAsynchronousRequest:(NSURLRequest *)request
                  withSettings:(ClearBlade *)settings
         withCompletionHandler:(void (^)(NSURLResponse *, NSData *, NSError *))completionHandler;

+(NSData *)sendSynchronousRequest:(NSURLRequest *)request
                 withSettings:(ClearBlade *)settings
                 withResponse:(NSURLResponse **)response
                    withError:(NSError **)error;
@end
