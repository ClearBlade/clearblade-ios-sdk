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

@interface CollectionViewController : UIViewController

@property (strong, nonatomic) IBOutlet UITextField *colID;
@property (strong, nonatomic) IBOutlet UITextView *display;
@property (strong, nonatomic) IBOutlet UITextField *createName;
@property (strong, nonatomic) IBOutlet UITextField *createAge;
@property (strong, nonatomic) IBOutlet UITextField *updateQuerKey;
@property (strong, nonatomic) IBOutlet UITextField *updateQuerVal;
@property (strong, nonatomic) IBOutlet UITextField *updateKey;
@property (strong, nonatomic) IBOutlet UITextField *updateVal;
@property (strong, nonatomic) IBOutlet UITextField *deleteQuerKey;
@property (strong, nonatomic) IBOutlet UITextField *deleteQuerVal;

@end
