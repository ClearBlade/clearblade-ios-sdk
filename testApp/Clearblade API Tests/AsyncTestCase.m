//
//  AsyncTest.m
//  testApp
//
//  Created by Tyler Dodge on 11/15/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import "AsyncTestCase.h"

@interface AsyncTestCase ()
@property (strong, nonatomic) NSMutableDictionary * completionKeys;
@end

@implementation AsyncTestCase

-(bool)isKeyComplete:(NSString *)key {
    @synchronized (self.completionKeys) {
        return [[self.completionKeys objectForKey:key] boolValue];
    }
}
-(void)setKey:(NSString *)key withComplete:(bool)isComplete {
    @synchronized (self.completionKeys) {
        [self.completionKeys setObject:@(isComplete) forKey:key];
    }
}
-(void)setUp {
    [super setUp];
    self.completionKeys = [[NSMutableDictionary alloc] init];
}
-(void)signalAsyncComplete:(NSString *)completionKey {
    [self setKey:completionKey withComplete:true];
}
-(void)waitForAsyncCompletion:(NSString *)completionKey {
    while (![self isKeyComplete:completionKey]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    [self setKey:completionKey withComplete:false];
}
@end
