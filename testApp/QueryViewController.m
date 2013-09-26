/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "QueryViewController.h"
#import "CBAPI.h"

@interface QueryViewController ()

@end

@implementation QueryViewController

@synthesize operationPicker;
@synthesize colID;
@synthesize display;
@synthesize fetchKey;
@synthesize fetchVal;
@synthesize updateKey;
@synthesize updateQuerKey;
@synthesize updateQuerVal;
@synthesize updateVal;
@synthesize removeKey;
@synthesize removeVal;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    display.layer.borderWidth = 1.0f;
    display.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) fetchClick {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:colID.text];
    int num = operationPicker.selectedSegmentIndex;
    switch(num) {
        case 0:
            [query equalTo:fetchVal.text for:fetchKey.text];
            break;
        case 1:
            [query notEqualTo:fetchVal.text for:fetchKey.text];
            break;
        case 2:
            [query greaterThan:fetchVal.text for:fetchKey.text];
            break;
        case 3:
            [query lessThan:fetchVal.text for:fetchKey.text];
            break;
        case 4:
            [query greaterThanEqualTo:fetchVal.text for:fetchKey.text];
            break;
        case 5:
            [query lessThanEqualTo:fetchVal.text for:fetchKey.text];
            break;
        default:
            [query equalTo:fetchVal.text for:fetchKey.text];
            break;
    }
    [query fetchWithSuccessCallback:^(NSMutableArray *stuff) {
        NSLog(@"%@", [(CBItem *)[stuff objectAtIndex:0] getValueFor:@"name"]);
        NSMutableString *str = [[NSMutableString alloc] init];
        for (int i = 0; i < [stuff count]; i++) {
            [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
        }
        NSLog(@"Str: %@", str);
        display.text = str;
    } ErrorCallback:nil];
}

-(IBAction) updateClick {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:colID.text];
    int num = operationPicker.selectedSegmentIndex;
    switch(num) {
        case 0:
            [query equalTo:updateQuerVal.text for:updateQuerKey.text];
            break;
        case 1:
            [query notEqualTo:updateQuerVal.text for:updateQuerKey.text];
            break;
        case 2:
            [query greaterThan:updateQuerVal.text for:updateQuerKey.text];
            break;
        case 3:
            [query lessThan:updateQuerVal.text for:updateQuerKey.text];
            break;
        case 4:
            [query greaterThanEqualTo:updateQuerVal.text for:updateQuerKey.text];
            break;
        case 5:
            [query lessThanEqualTo:updateQuerVal.text for:updateQuerKey.text];
            break;
        default:
            [query equalTo:updateQuerVal.text for:updateQuerKey.text];
            break;
    }
    NSMutableDictionary *changes = [[NSMutableDictionary alloc] init];
    [changes setObject:updateVal.text forKey:updateKey.text];
    [query updateWithChanges:changes SuccessCallback:^(NSMutableArray *stuff) {
        NSMutableString *str = [[NSMutableString alloc] init];
        for (int i = 0; i < [stuff count]; i++) {
            [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
        }
        NSLog(@"Str: %@", str);
        display.text = str;
    } ErrorCallback:nil];

}

-(IBAction) removeClick {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:colID.text];
    int num = operationPicker.selectedSegmentIndex;
    switch(num) {
        case 0:
            [query equalTo:removeVal.text for:removeKey.text];
            break;
        case 1:
            [query notEqualTo:removeVal.text for:removeKey.text];
            break;
        case 2:
            [query greaterThan:removeVal.text for:removeKey.text];
            break;
        case 3:
            [query lessThan:removeVal.text for:removeKey.text];
            break;
        case 4:
            [query greaterThanEqualTo:removeVal.text for:removeKey.text];
            break;
        case 5:
            [query lessThanEqualTo:removeVal.text for:removeKey.text];
            break;
        default:
            [query equalTo:removeVal.text for:removeKey.text];
            break;
    }
    [query removeWithSuccessCallback:^(NSMutableArray *stuff) {
        NSMutableString *str = [[NSMutableString alloc] init];
        for (int i = 0; i < [stuff count]; i++) {
            [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
        }
        NSLog(@"Str: %@", str);
        display.text = str;
    } ErrorCallback:nil];
}

@end
