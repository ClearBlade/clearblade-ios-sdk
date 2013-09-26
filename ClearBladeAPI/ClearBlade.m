/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "ClearBlade.h"

static NSString *appKey;
static NSString *appSecret;

@implementation ClearBlade

+(NSString *)appKey {
    return appKey;
}

+(NSString *)appSecret {
    return appSecret;
}

+(void) initAppKey: (NSString *)key AppSecret: (NSString *)secret {
    appKey = key;
    appSecret = secret;
}
@end
