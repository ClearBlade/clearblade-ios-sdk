//
//  AsyncTest.h
//  testApp
//
//  Created by Tyler Dodge on 11/15/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CBHTTPRequest.h"
#define STRING_COLUMN @"stringcolumn"
#define MAIN_COMPLETION @"main"
#define PROD
#ifdef PROD
#define APP_KEY @"e488a4ab0aea9fb4cc88dfa6ed36"
#define APP_SECRET @"E488A4AB0A98E1A4D0CBE2CDF626"

#define AUTH_APP_KEY @"d0ef9daf0acaebd9d581ce88df4a"
#define AUTH_APP_SECRET @"D0EF9DAF0ABAC098A0F6DF8D85AE01"

#define TEST_COLLECTION @"e889a4ab0ac69af5bbbba3ebfa2b"
#define PLATFORM_ADDRESS @"https://platform.clearblade.com/"
#define MESSAGING_ADDRESS @"tcp://messaging.clearblade.com"
#define TEST_LOGGING_LEVEL CB_LOG_EXTRA
#else
#define APP_KEY @"f4fd8cae0aa48e90d9d6d483a80e"
#define APP_SECRET @"F4FD8CAE0AF09BD7EBF8F590A9BB01"

#define AUTH_APP_KEY @"a2f59daf0a9edbf180f5c389b76e"
#define AUTH_APP_SECRET @"A2F59DAF0ACCD5F9ECBBCB9BF22E"

#define TEST_COLLECTION @"84fe8cae0a96d5d8afefc79786e201"
#define PLATFORM_ADDRESS @"https://rtp.clearblade.com/"
#define MESSAGING_ADDRESS @"tcp://rtp.clearblade.com:1883"
#define TEST_LOGGING_LEVEL CB_LOG_EXTRA
#endif

@interface AsyncTestCase : XCTestCase
-(void)signalAsyncComplete:(NSString *)completionKey;

//Resets the key after it completes
-(void)waitForAsyncCompletion:(NSString *)completionKey;
@end

@interface NSURLRequest (HttpsIgnore)
+(bool)allowsAnyHTTPSCertificateForHost:(NSString *)host;
@end

@implementation NSURLRequest (HttpsIgnore)
+(bool)allowsAnyHTTPSCertificateForHost:(NSString *)host {
    return YES;
}
@end
