/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CBHTTPClient.h"

@implementation CBHTTPClient

@synthesize baseURL;

-(void) setUrl: (NSString *) URL {
    baseURL = [NSURL URLWithString:URL];
}

-(void) setAppKey: (NSString *) key AppSecret: (NSString *) secret {
    [self setDefaultHeader:@"ClearBlade-AppKey" value:key];
    [self setDefaultHeader:@"ClearBlade-AppSecret" value:secret];
}

@end
