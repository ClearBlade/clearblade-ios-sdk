/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import <UIKit/UIKit.h>
#import "MQTTClient.h"

@interface MQTTViewController : UIViewController <MQTTClientDelegate>

@property (strong, nonatomic) IBOutlet UITextField *topic;
@property (strong, nonatomic) IBOutlet UISwitch *subSwitch;
@property (strong, nonatomic) IBOutlet UITextView *display;
@property (strong, nonatomic) IBOutlet UITextField *messField;


@end
