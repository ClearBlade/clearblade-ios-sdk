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
#define AUTH_TEST_COLLECTION @"b6b1b0b10ac8beb08a9ed9f1cfd301"
#define PLATFORM_ADDRESS @"https://platform.clearblade.com/"
#define MESSAGING_ADDRESS @"tcp://messaging.clearblade.com"
#define TEST_LOGGING_LEVEL CB_LOG_EXTRA
#endif
#ifdef STAGING
#define APP_KEY @"e0b7e9b40a9680e8cababef6fcdc01"
#define APP_SECRET @"E0B7E9B40AF0EDD9A9E0EAB7CC72"
#define TEST_COLLECTION @"9eeae9b40ae4c1a5f293aacc9133"

#define AUTH_APP_KEY @"b6b7e9b40ab0dab8d0f6fcd5d0a501"
#define AUTH_APP_SECRET @"B6B7E9B40A9EF89ED4BBE0C8B0C001"
#define AUTH_TEST_COLLECTION @"d0eae9b40abc8eafe7b3b9aa8e31"

#define PLATFORM_ADDRESS @"https://staging.clearblade.com/"
#define MESSAGING_ADDRESS @"tcp://staging.clearblade.com"
#define TEST_LOGGING_LEVEL CB_LOG_EXTRA
#endif
#ifdef RTP
#define APP_KEY @"a08f98b40ac8c29680eece8ce051"
#define APP_SECRET @"A08F98B40A82E1BEFBB48FC0BC44"

#define AUTH_APP_KEY @"f48f98b40ad6aecc98ceb49ab72e"
#define AUTH_APP_SECRET @"F48F98B40A8ACB979FFD88888DC701"

#define TEST_COLLECTION @"d89098b40a8cc5fbf597d2a7c90f"
#define AUTH_TEST_COLLECTION @"b49098b40ad0938aa9c8a9f8f7ff01"
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
