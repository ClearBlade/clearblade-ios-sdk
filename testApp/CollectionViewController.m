/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "CollectionViewController.h"
#import "CBAPI.h"

@interface CollectionViewController ()

@end

@implementation CollectionViewController

@synthesize colID = _colID;
@synthesize display = _display;
@synthesize createAge = _createAge;
@synthesize createName = _createName;
@synthesize updateQuerKey = _updateQuerKey;
@synthesize updateQuerVal = _updateQuerVal;
@synthesize updateKey = _updateKey;
@synthesize updateVal = _updateVal;
@synthesize deleteQuerKey = _deleteQuerKey;
@synthesize deleteQuerVal = _deleteQuerVal;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
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

-(IBAction) fetchClicked {
    if ([self.colID.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Initialized"
                                                        message:@"You must enter your collection ID in order to fetch."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        CBCollection *col = [[CBCollection alloc] initWithCollectionID:self.colID.text];
        [col fetchWithSuccessCallback:^(NSMutableArray *stuff) {
            NSLog(@"%@", [(CBItem *)[stuff objectAtIndex:0] getValueFor:@"name"]);
            NSMutableString *str = [[NSMutableString alloc] init];
            for (int i = 0; i < (int)stuff.count; i++) {
                [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
            }
            NSLog(@"Str: %@", str);
            self.display.text = str;
        } ErrorCallback:^(NSError *err, id stuff) {
            self.display.text = [err description];
        }];
    }
}

-(IBAction) createClicked {
    if ([self.colID.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Initialized"
                                                        message:@"You must enter your collection ID in order to fetch."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        CBCollection *col = [[CBCollection alloc] initWithCollectionID:self.colID.text];
        NSMutableDictionary *createData = [[NSMutableDictionary alloc] init];
        [createData setValue:self.createName.text forKey:@"name"];
        [createData setValue:self.createAge.text forKey:@"age"];
        [col createWithData:createData WithSuccessCallback:^(CBItem *item) {
            self.display.text = [NSString stringWithFormat:@"NewStuff: %@", [[item data] description] ];
        } ErrorCallback:nil];
    }
}

-(IBAction) updateClicked {
    if ([self.colID.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Initialized"
                                                        message:@"You must enter your collection ID in order to fetch."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        CBCollection *col = [[CBCollection alloc] initWithCollectionID:self.colID.text];
        CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.colID.text];
        [query equalTo:self.updateQuerVal.text for:self.updateQuerKey.text];
        NSMutableDictionary *changes = [[NSMutableDictionary alloc] init];
        [changes setObject:self.updateVal.text forKey:self.updateKey.text];
        [col updateWithQuery:query WithChanges:changes SuccessCallback:^(NSMutableArray *stuff) {
            NSLog(@"%@", [(CBItem *)[stuff objectAtIndex:0] getValueFor:@"name"]);
            NSMutableString *str = [[NSMutableString alloc] init];
            for (uint i = 0; i < [stuff count]; i++) {
                [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
            }
            NSLog(@"Str: %@", str);
            self.display.text = str;
        } ErrorCallback:^(NSError *err, id JSON) {
            NSLog(@"%@", err);
            NSLog(@"%@", [JSON description]);
        }];
    }
}

-(IBAction) deleteClicked {
    if ([self.colID.text isEqualToString:@""]){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Initialized"
                                                        message:@"You must enter your collection ID in order to fetch."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        CBCollection *col = [[CBCollection alloc] initWithCollectionID:self.colID.text];
        CBQuery *query = [[CBQuery alloc] initWithCollectionID:self.colID.text];
        [query equalTo:self.deleteQuerVal.text for:self.deleteQuerKey.text];
        [col removeWithQuery:query SuccessCallback:^(NSMutableArray *stuff) {
            NSMutableString *str = [[NSMutableString alloc] init];
            for (uint i = 0; i < [stuff count]; i++) {
                [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[stuff objectAtIndex:i] data] description]];
            }
            NSLog(@"Str: %@", str);
            self.display.text = str;
        } ErrorCallback:nil];
    }
}

@end
