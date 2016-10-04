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

#define TOKEN_APP_KEY @"c8e69eff0ab4cf90a8acf8fae204"
#define TOKEN_APP_SECRET @"C8E69EFF0AC0A798B9F7F3BB981E"

#define TEST_COLLECTION @"e889a4ab0ac69af5bbbba3ebfa2b"
#define AUTH_TEST_COLLECTION @"b6b1b0b10ac8beb08a9ed9f1cfd301"
#define PLATFORM_ADDRESS @"https://platform.clearblade.com/"
#define MESSAGING_ADDRESS @"tcp://messaging.clearblade.com"
#define TEST_LOGGING_LEVEL CB_LOG_DEBUG
#endif
#ifdef STAGING
#define APP_KEY @"a295bbba0ac2ed8bb09d87fcefa101"
#define APP_SECRET @"A295BBBA0AD0EBE088ECEBD1F626"
#define TEST_COLLECTION @"fa95bbba0aa294b5f6e8dcffafec01"

#define AUTH_APP_KEY @"92f4baba0abe9ae2e2e9d3b78c8001"
#define AUTH_APP_SECRET @"92F4BABA0A8CBFD6CFEA89E5FF42"
#define AUTH_TEST_COLLECTION @"eef4baba0ae888e7d8a08dfb9013"

#define PLATFORM_ADDRESS @"https://staging.clearblade.com/"
#define MESSAGING_ADDRESS @"tcp://ec2-54-82-138-91.compute-1.amazonaws.com:1883"
#define TEST_LOGGING_LEVEL CB_LOG_EXTRA
#endif
#ifdef RTP
#define APP_KEY @"e488a4ab0aea9fb4cc88dfa6ed36"
#define APP_SECRET @"E488A4AB0A98E1A4D0CBE2CDF626"

#define AUTH_APP_KEY @"d0ef9daf0acaebd9d581ce88df4a"
#define AUTH_APP_SECRET @"D0EF9DAF0ABAC098A0F6DF8D85AE01"

#define TEST_COLLECTION @"e889a4ab0ac69af5bbbba3ebfa2b"
#define AUTH_TEST_COLLECTION @"b6b1b0b10ac8beb08a9ed9f1cfd301"
#define PLATFORM_ADDRESS @"https://rtp.clearblade.com/"
#define MESSAGING_ADDRESS @"tcp://rtp.clearblade.com:1883"
#define TEST_LOGGING_LEVEL CB_LOG_EXTRA
#endif

@interface AsyncTestCase : XCTestCase
-(void)signalAsyncComplete:(NSString *)completionKey;

//Resets the key after it completes
-(void)waitForAsyncCompletion:(NSString *)completionKey;
@end

