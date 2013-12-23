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
#define PROD
#ifdef PROD
#define APP_KEY @"f2f5f8aa0aba8bc7e4bdcd8ef142"
#define APP_SECRET @"F2F5F8AA0AB4F2C4A4E1C387F3F801"
#define TEST_COLLECTION @"8ef2a3ab0aecbfaf9abec4c7f9e701"
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
