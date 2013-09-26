#import <Foundation/Foundation.h>
#import <CBAPI.h>

int main (int argc, char * argv[]) {
	@autoreleasepool {
		int numberOfTests = 8;
		__block NSMutableArray *flags = [[NSMutableArray alloc] init];
		for (int i = 0; i < numberOfTests; i++) {
			[flags addObject: [NSNumber numberWithBool:NO]];	
		}	
		NSLog(@"Tests starting....");
		//Collection Tests
		//================
		//
		[ClearBlade initAppKey: @"522743918ab3a32f2caee87e" AppSecret: @"0R9AALLIAP9UTCIA5KA6E5EUBPK08R"];
		CBCollection *col = [[CBCollection alloc] initWithCollectionID: @"5227487d8ab3a32f2caee87f"];
		[col fetchWithSuccessCallback: ^(NSMutableArray *stuff) {
			if (![[[stuff objectAtIndex:0] getValueFor:@"name"] isEqual: @"patrick"]) {
				NSLog(@"FALIED");
			} else {
				NSLog(@"PASSED");
			}
			[flags  replaceObjectAtIndex:0 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback:nil];
		CFRunLoopRun();
		__block NSString *itemId;
		NSMutableDictionary *newItem = [[NSMutableDictionary alloc] init];
		[newItem setValue:@"charlie" forKey: @"name"];
		[newItem setValue:@"22" forKey: @"age"];	
		[col createWithData: newItem WithSuccessCallback: ^(CBItem *item) {
	 		if(![[item getValueFor:@"name"] isEqual: @"charlie"]) {
				NSLog(@"FAILED");
			} else {
				itemId = [[NSString alloc] initWithString: [item getValueFor: @"itemId"]];
				NSLog(@"PASSED");
			}
			[flags  replaceObjectAtIndex:1 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback:nil];
		CFRunLoopRun();
		CBQuery *query = [[CBQuery alloc] initWithCollectionID: @"5227487d8ab3a32f2caee87f"];
		[query equalTo: itemId for: @"itemId"];
		NSMutableDictionary *changes = [[NSMutableDictionary alloc] init];
		[changes setValue: @"24" forKey: @"age"];
		[col updateWithQuery: query WithChanges: changes SuccessCallback: ^(CBItem *item) {
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback:nil];
		CFRunLoopRun();
		[col fetchWithQuery: query SuccessCallback: ^(NSMutableArray *stuff) {
 			if(![[[stuff objectAtIndex:0] getValueFor:@"name"] isEqual: @"charlie"]) {
				NSLog(@"FAILED");
			} else {
				NSLog(@"PASSED");
			}
 			[flags  replaceObjectAtIndex:2 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback:nil];
		CFRunLoopRun();
		[col removeWithQuery: query SuccessCallback: ^(NSMutableArray *stuff){
			if(![[[stuff objectAtIndex:0] getValueFor:@"name"] isEqual: @"charlie"]) {
				NSLog(@"FAILED");
			} else {
				NSLog(@"PASSED");
			}
 			[flags  replaceObjectAtIndex:3 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback: nil];
		CFRunLoopRun();	
		//Query Tests
		//===========
		//
		[col createWithData: newItem WithSuccessCallback: ^(CBItem *item) {
	 		if(![[item getValueFor:@"name"] isEqual: @"charlie"]) {
				NSLog(@"FAILED");
			} else {
				NSLog(@"PASSED");
			}
			[flags  replaceObjectAtIndex:4 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback:nil];
		CFRunLoopRun();
		CBQuery *testQuery = [[CBQuery alloc] initWithCollectionID: @"5227487d8ab3a32f2caee87f"];
		[[testQuery equalTo: @"charlie" for: @"name"] greaterThan: @"20" for: @"age"];
		[testQuery fetchWithSuccessCallback: ^(NSMutableArray *stuff) {
			if(![[[stuff objectAtIndex:0] getValueFor:@"name"] isEqual: @"charlie"]) {
				NSLog(@"FAILED");
			} else {
				NSLog(@"PASSED");
			}
 			[flags  replaceObjectAtIndex:5 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback: nil];
		CFRunLoopRun();
		[testQuery updateWithChanges: changes SuccessCallback: ^(NSMutableArray *stuff) {
		 	if(![[[stuff objectAtIndex:0] getValueFor:@"age"] isEqual: @"24"]) {
				NSLog(@"FAILED");
			} else {
				NSLog(@"PASSED");
			}
			[flags  replaceObjectAtIndex:6 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback: nil];
		CFRunLoopRun();
		[testQuery removeWithSuccessCallback: ^(NSMutableArray *stuff) {
			if(![[[stuff objectAtIndex:0] getValueFor:@"name"] isEqual: @"charlie"]) {
				NSLog(@"FAILED");
			} else {
				NSLog(@"PASSED");
			}
 			[flags  replaceObjectAtIndex:7 withObject:[NSNumber numberWithBool: YES]];
			CFRunLoopStop(CFRunLoopGetCurrent());
		} ErrorCallback: nil];
		CFRunLoopRun();

				
		while (true) {
			bool doneFlag = true;
			for (int i = 0; i < [flags count]; i++) {
				if(![[flags objectAtIndex: i] boolValue]) {
					doneFlag = false;	
				} else {
					continue;
				}
			}
			if (doneFlag) {
				NSLog(@"Tests done....");
				break;
			}
		}
	}
	return 0;
}
