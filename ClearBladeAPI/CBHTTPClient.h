/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import <AFNetworking/AFNetworking.h>
#import "ClearBlade.h"
/**
Class used for making REST calls to the platform.
This is a subclass of AFHTTPClient
*/
@interface CBHTTPClient : AFHTTPClient

@property (atomic, weak) ClearBlade * settings;

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings;

@end
