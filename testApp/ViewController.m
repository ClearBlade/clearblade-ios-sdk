/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "ViewController.h"
#import "CBAPI.h"

@interface ViewController ()

@end

@implementation ViewController {
    CBCollection *col;
    CBQuery *query;
}

@synthesize key;
@synthesize secret;

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    col = [[CBCollection alloc] initWithCollectionID:@"a2d5c0a60a98f1e9ffe9aed686d001"];
    query = [[CBQuery alloc] initWithCollectionID:@"a2d5c0a60a98f1e9ffe9aed686d001"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if ([key.text isEqualToString:@""] || [secret.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Initialized"
                                                        message:@"You must enter your key and secret to move on."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];

        return NO;
    } else {
        [ClearBlade initAppKey:key.text AppSecret:secret.text];
        return YES;
    }
}



@end
