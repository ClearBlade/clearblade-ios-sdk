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
#define PLATFORM_ADDRESS @"https://platform.clearblade.com/api"
#else
#define APP_KEY @"eafb90aa0af4c396d4e9fbbbd24d"
#define APP_SECRET @"EAFB90AA0AB4AACFE9C2BBF7A7EE01"
#define TEST_COLLECTION @"f48591aa0ad0d9c0b3dac8f5a9a501"
#define PLATFORM_ADDRESS @"https://platform.clearblade.com/api"
#endif

@interface AsyncTestCase : XCTestCase
-(void)signalAsyncComplete:(NSString *)completionKey;

//Resets the key after it completes
-(void)waitForAsyncCompletion:(NSString *)completionKey;
@end
