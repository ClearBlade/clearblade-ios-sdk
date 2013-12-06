//
//  CBHTTPRequest.h
//  testApp
//
//  Created by Tyler Dodge on 12/3/13.
//  Copyright (c) 2013 ClearBlade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ClearBlade.h"

@interface CBHTTPRequest : NSMutableURLRequest
@property (atomic, weak) ClearBlade * settings;

+(instancetype)requestWithMethod:(NSString *)path withCollection:(NSString *)collectionID;

-(instancetype)initWithClearBladeSettings:(ClearBlade *)settings withMethod:(NSString *)path withCollection:(NSString *)collectionID;
@end
