/*******************************************************************************
 * Copyright 2013 ClearBlade, Inc
 * All rights reserved. This program and the accompanying materials
 * are made available under the terms of the Eclipse Public License v1.0
 * which accompanies this distribution, and is available at
 * http://www.eclipse.org/legal/epl-v10.html
 *
 * Any redistribution of this program in any form must include this copyright
 *******************************************************************************/

#import "MQTTViewController.h"
#import "CBMessageClient.h"

@interface MQTTViewController ()

@end

@implementation MQTTViewController {
    CBMessageClient *client;
    NSString *currentTopic;
}

@synthesize subSwitch;
@synthesize display;
@synthesize topic;
@synthesize messField;

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
    client = [[CBMessageClient alloc] init];
    [client setDelegate:self];
    
    [client connectToHost:[NSURL URLWithString:@"ec2-23-23-31-115.compute-1.amazonaws.com"]];
    
    display.layer.borderWidth = 1.0f;
    display.layer.borderColor = [[UIColor grayColor] CGColor];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
    [super touchesBegan:touches withEvent:event];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)subSwitchChanged:(id)sender {
    if( self.subSwitch.on) {
        [client subscribeToTopic:topic.text];
        currentTopic = topic.text;
        NSLog(@"ON");
    } else {
        NSLog(@"OFF");
    }
}

-(IBAction)pubButton {
    if (![currentTopic isEqual: topic.text]) {
        currentTopic = topic.text;
    }
    [client publishMessage:messField.text toTopic:currentTopic];
    
}

- (void) didConnect:(NSUInteger)code {
    NSLog(@"CONNECTED");
}
- (void) didDisconnect {
    NSLog(@"DISCONNECTED");
}

-(void)messageClient:(CBMessageClient *)client didReceiveMessage:(CBMessage *)message {
    NSString *oldMessages = [NSString stringWithString:display.text];
    display.text = [NSString stringWithFormat:@"%@\n--------------------------------------------------------\n%@",
                    message.payloadText, oldMessages];
}

-(void)messageClient:(CBMessageClient *)client didPublish:(NSString *)message {
    NSLog(@"Published: %@", message);
}

@end
