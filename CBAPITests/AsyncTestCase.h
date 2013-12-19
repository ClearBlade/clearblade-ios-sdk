//
//  AsyncTest.h
//  testApp
//
//  Created by Tyler Dodge on 11/15/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <XCTest/XCTest.h>
#define STRING_COLUMN @"StringColumn"
#define MAIN_COMPLETION @"main"
//#define PROD
#ifdef PROD
#define APP_KEY @"eafb90aa0af4c396d4e9fbbbd24d"
#define APP_SECRET @"EAFB90AA0AB4AACFE9C2BBF7A7EE01"
#define TEST_COLLECTION @"5281350e8ab3a3224cac7d4d"
#define PLATFORM_ADDRESS @"http://platform.clearblade.com/api"
#define MESSAGING_ADDRESS @"https://messaging.clearblade.com"
#define TEST_LOGGING_LEVEL CB_LOG_DEBUG
#else
#define APP_KEY @"dc9c9aab0ac4c38faef581eda3dc01"
#define APP_SECRET @"DC9C9AAB0AD8FEE6B5EBFBA787C401"
#define TEST_COLLECTION @"929d9aab0aaee2b7f9e4f8eae149"
#define PLATFORM_ADDRESS @"http://localhost:8080/api"
#define MESSAGING_ADDRESS @"localhost"
#define TEST_LOGGING_LEVEL CB_LOG_DEBUG
#endif

@interface AsyncTestCase : XCTestCase
-(void)signalAsyncComplete:(NSString *)completionKey;

//Resets the key after it completes
-(void)waitForAsyncCompletion:(NSString *)completionKey;
@end
