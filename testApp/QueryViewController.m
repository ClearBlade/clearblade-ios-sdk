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

@synthesize operationPicker = _operationPicker;
@synthesize colID = _colID;
@synthesize display = _display;
@synthesize fetchKey = _fetchKey;
@synthesize fetchVal = _fetchVal;
@synthesize updateKey = _updateKey;
@synthesize updateQuerKey = _updateQuerKey;
@synthesize updateQuerVal = _updateQuerVal;
@synthesize updateVal = _updateVal;
@synthesize removeKey = _removeKey;
@synthesize removeVal = _removeVal;

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
    
    self.display.layer.borderWidth = 1.0f;
    self.display.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction) fetchClick {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.colID.text];
    int num = self.operationPicker.selectedSegmentIndex;
    switch(num) {
        case 0:
            [query equalTo:self.fetchVal.text for:self.fetchKey.text];
            break;
        case 1:
            [query notEqualTo:self.fetchVal.text for:self.fetchKey.text];
            break;
        case 2:
            [query greaterThan:self.fetchVal.text for:self.fetchKey.text];
            break;
        case 3:
            [query lessThan:self.fetchVal.text for:self.fetchKey.text];
            break;
        case 4:
            [query greaterThanEqualTo:self.fetchVal.text for:self.fetchKey.text];
            break;
        case 5:
            [query lessThanEqualTo:self.fetchVal.text for:self.fetchKey.text];
            break;
        default:
            [query equalTo:self.fetchVal.text for:self.fetchKey.text];
            break;
    }
    [query fetchWithSuccessCallback:^(NSMutableArray *stuff) {
        //NSLog(@"%@", [(CBItem *)[stuff objectAtIndex:0] getValueFor:@"name"]);
        NSMutableString *str = [[NSMutableString alloc] init];
        for (uint i = 0; i < [stuff count]; i++) {
            [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
        }
        NSLog(@"Str: %@", str);
        self.display.text = str;
    } ErrorCallback:nil];
}

-(IBAction) updateClick {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.colID.text];
    int num = self.operationPicker.selectedSegmentIndex;
    switch(num) {
        case 0:
            [query equalTo:self.updateQuerVal.text for:self.updateQuerKey.text];
            break;
        case 1:
            [query notEqualTo:self.updateQuerVal.text for:self.updateQuerKey.text];
            break;
        case 2:
            [query greaterThan:self.updateQuerVal.text for:self.updateQuerKey.text];
            break;
        case 3:
            [query lessThan:self.updateQuerVal.text for:self.updateQuerKey.text];
            break;
        case 4:
            [query greaterThanEqualTo:self.updateQuerVal.text for:self.updateQuerKey.text];
            break;
        case 5:
            [query lessThanEqualTo:self.updateQuerVal.text for:self.updateQuerKey.text];
            break;
        default:
            [query equalTo:self.updateQuerVal.text for:self.updateQuerKey.text];
            break;
    }
    NSMutableDictionary *changes = [[NSMutableDictionary alloc] init];
    [changes setObject:self.updateVal.text forKey:self.updateKey.text];
    [query updateWithChanges:changes SuccessCallback:^(NSMutableArray *stuff) {
        NSMutableString *str = [[NSMutableString alloc] init];
        for (uint i = 0; i < [stuff count]; i++) {
            [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
        }
        NSLog(@"Str: %@", str);
        self.display.text = str;
    } ErrorCallback:nil];

}

-(IBAction) removeClick {
    CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.colID.text];
    int num = self.operationPicker.selectedSegmentIndex;
    switch(num) {
        case 0:
            [query equalTo:self.removeVal.text for:self.removeKey.text];
            break;
        case 1:
            [query notEqualTo:self.removeVal.text for:self.removeKey.text];
            break;
        case 2:
            [query greaterThan:self.removeVal.text for:self.removeKey.text];
            break;
        case 3:
            [query lessThan:self.removeVal.text for:self.removeKey.text];
            break;
        case 4:
            [query greaterThanEqualTo:self.removeVal.text for:self.removeKey.text];
            break;
        case 5:
            [query lessThanEqualTo:self.removeVal.text for:self.removeKey.text];
            break;
        default:
            [query equalTo:self.removeVal.text for:self.removeKey.text];
            break;
    }
    [query removeWithSuccessCallback:^(NSMutableArray *stuff) {
        NSMutableString *str = [[NSMutableString alloc] init];
        for (uint i = 0; i < [stuff count]; i++) {
            [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
        }
        NSLog(@"Str: %@", str);
        self.display.text = str;
    } ErrorCallback:nil];
}

@end
