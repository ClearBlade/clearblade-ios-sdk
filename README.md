iOS-API
=======


This is the API for communicating with the ClearBlade Platfrom from an iOS device

# API Reference


### Authenticating

There are multiple ways to authenticate with the platform. 

#### With the ClearBlade object

The most common way of authentication is to do so at initialization of the ClearBlade static object.

~~~objectivec
[ClearBlade initSettingsWithSystemKey:SYS_KEY
	    withSystemSecret:SYS_SECRET
	    withOptions:@{
			  CBSettingsOptionServerAddress:@"platform.clearblade.com"
			  CBSettingsOptionEmail:yourUserEmail
			  CBSettingsOptionPassword:yourPassword }
	   withSuccessCallback:^(ClearBlade* cb){
	   	NSLog(@"Yay we did it");
	   }];
~~~


#### Or you could create a object manually

~~~objectivec
[CBUser authenticateUserWithSettings:cb //ClearBlade object
	withEmail: MY_EMAIL
	withPassword: PASSWORD
	withSuccessCallback: ^(CBUser*){NSLog("whoo");}
	withErrorCallback: ^(NSError*){/*oh no!*/}];

or

[CBUser authenticateUserWithEmail: MY_EMAIL
	withPassword: PASSWORD
	withSuccessCallback: ^(CBUser*){NSLog("whoo");}
	withErrorCallback: ^(NSError*){/*oh no!*/}];
~~~

#### Or you can create an anonymous user

~~~objectivec
[CBUser anonymousUserWithSettings:cb //ClearBlade object
	WithError:&err];
~~~
### Calling Code Services

We provide a function for calling code services asynchronously.

~~~objectivec
[CBCode executeFunction @"myServiceName"
	withParams:@{@"myAwesomeParamName":@"dictionary value"}
	withSuccessCallback: ^(NSString* result){ NSLog(@"did it!");}
	withErrorCallback:^(NSError* err){/* oh no*/}];
~~~

### Getting Data

There is an interrelationship between the concepts of Collections, Items, and Queries in the iOS SDK. It is possible to access data via any of these mechanisms, we'll go through each of them and what they mean.


#### Item

An item roughly represents a row within a collection. The iOS api allows the developer to create, delete an item (or items) directly.

~~~objectivec
//Init the item with a dictionary
CBItem* itm = [CBItem itemWithData:@{@"rowname":@"rowvalue"}
	withCollectionID:MY_COLID];

//Save the item. Remember that the item's data must correspond to the
//columns in the collection
//An item can even correspond to a row in a collection stored in an integrated database
[itm saveWithSuccessCallback:^(CBItem*){NSLog(@"Whoo!");}
     ^(CBItem* item,NSError* err, id JSON){/*lots to do here*/}];
     //the JSON can be helpful if the json failed to parse for some reason


//refresh the item. perhaps other users are mutating the same row?!
[itm refreshWithSuccessCallback:^(CBitem){NSLog(@"Whoo!");}
     withErrorCallback:^(CBItem* item,NSError* err, id JSON){/*stuff*/}];
     //the item's contents have changed

//delete the item
//This only applies if you've refreshed the item, or have somehow populated the itemid somehow
[itm removeWithSuccessCallback:^(CBitem){NSLog(@"Whoo!");}
     withErrorCallback:^(CBItem* item,NSError* err, id JSON){/*stuff*/}];
~~~



#### Query

If you want to make a direct query to the data, you can just use a query object.

~~~objectivec

CBQuery* cbq = [CBQuery initWithCollectionID: MY_COLLECTION];

//however we can apply filters to this object, much like we can
//with the other platform SDKs
//let's say we want to find all "hair color" with value "brown"
[cbq equalTo:@"brown" for:@"hair color"]
//whose "age" is also 23
[cbq equalTo:[NSNumber numberWithInt:23] for:@"age"]
//now, if we want an OR on that query, then we apply another query to it
//so we want ("hair color" = "brown" AND "age" = 23) OR ("name" = "jim")
CBQuery* otherQuery = [CBQuery initWithCollectionID: MY_COLLECTION];
[otherQuery equalTo:@"jim" for:@"name"];
//and we apply the query to the first query
[cbq addQueryAsOrClauseUsingQuery: otherQuery];
//you can think of adding queries as creating an abstract syntax tree of your query. no confusion on operator precedence

//now we're ready to execute the query
//the first thing we'll do with it is a fetch, to get items
[cbq fetchWithSuccessCallback:^(CBQueryResponse* sr){/*stuff*/}
     withErrorCallback:^(NSError* err, __strong id JSON){/*stuff*/}];

//alternatively we can update a row or rows, depending on what the query matches
[cbq updateWithChanges:@{@"hair color":"green"}
     withSuccessCallback:^(CBQueryResponse* sr){/*stuff*/}
     withErrorCallback:^(NSError* err, __strong id JSON){/*stuff*/}];

//or even remove items
[cbq removeWithSuccessCallback:^(CBQueryResponse* sr){/*stuff*/}
     withErrorCallback:^(NSError* err, __strong id JSON){/*stuff*/}];
~~~

#### Collections

One can operate on collections, but they are very intertwined with queries. However, sometimes it is valuable to use collections themselves

~~~objectivec
CBCollection* col = [CBCollection collectionWithId:MY_COLLECTION];

//we can fetch the entire collection if we wish
[col fetchWithSuccessCallback:^(CBQueryResponse* sr){/**/}
     withErrorCallback:^(NSError* err, __strong id JSON){/**/}];


//or we can fetch with a query
CBQuery* qry = [CBQuery initWithCollectionID: MY_COLLECTION];
[cbq equalTo:@"brown" for:@"hair color"];

[col fetchWithQuery:qry
     withSuccessCallback:^(CBQueryResponse* sr){/**/}
     withErrorCallback:^(NSError* err, __strong id JSON){/**/}];

//or we can update with that query
[col updateWithQuery:qry
     withChanges: @{@"hair color": @"Puce"}
     withSuccessCallback:^(CBQueryResponse* sr){/**/}
     withErrorCallback:^(NSError* err, __strong id JSON){/**/}];

//or we can remove with a query
[col removeWithQuery:qry
     withSuccessCallback:^(CBQueryResponse* sr){/**/}
     withErrorCallback:^(NSError* err, __strong id JSON){/**/}];

//or finally we can create with info, assuming the columns and types match with the collection in the platform
[col createWithData:@{@"hair color":@"brown", @"name":@"john doe"}
     withSuccessCallback:^(CBQueryResponse* sr){/**/}
     withErrorCallback:^(NSError* err, __strong id JSON){/**/}];     

~~~

### Messaging

The iOS SDK uses the mosquitto MQTT messaging client. We expose a callback-based interface.


~~~objectivec
//we're going to assume you already have a setup ClearBlade client object.
//creating the object is quite easy

CBMessageClient* msgcli = [CBMessageClient client];

//here, one can supply a varying number of delegates to fire when messaging actions occur

// messageClientDidConnect:(CBMessageClient*) fires when the messaging client connects with the broker
//messageClientDidDisconnect:(CBMessageClient*) fires when the disconnection occurs, whether it is purposeful or not
//messageClient:(CBMessageClient*) didPublishToTopic:NSString* withMessage:CBMessage* fires whena  publish is sent to the broker
//messageClient:(CBMessageClient*) didReceiveMessage:(CBMessage*) fires whenever a message arrives. This applies to all topics.
//messageClient:(CBMessageClient*) didSubscribe:(NSString*)topic fires when a subscription succeeds
//messageClient:(CBMessageClient*) didUnsubscribe:(NSString*)topic fires when an unsubscribe succeedes
//messageClient:(CBMessageClient*) didFailToConnect:CBMessageClientConnectStatus fires whenever the client fails to connect, even on a reconnect attempt

//then connecting to the default host is fairly simple
[msgcli connect]

//if you have a custom host
[msgcli connectToHost: [NSURL URLWithString: MY_IP_ADDR]];

NSString* top = @"a/good/topic"

//subscribe to a topic
[msgcli subscribeToTopic:top];

//publish to a topic
[msgcli publishMessage:@"Greetz" toTopic:top];

//note that if we assigned a function to didReceiveMessage, it would fire when this message was received.

//unsubscribe now that we've gotten our message
[msgcli unsubscribeFromTopic:top];

//disconnect

[msgcli disconnect];
~~~

### Message history

If you wish to obtain the message history (and have the permissions to do so)

~~~objectivec
//This is a static method
NSError* err;
NSArray* res = [CBMessageClient getMessageHistoryOfTopic:top fromTime: [NSDate initWithTimeIntervalSinceNow:0] withCount:[NSNumber initWithInt:30] withError:err];
~~~

# QuickStart


### New xCode Project
Use xCode to create a new iOS project.  This project can target any desired set of iOS devices.

### Install Cocoapods

1. Within your Xcode project directory, open a terminal window and enter in the following commands:
	- [sudo] gem install cocoapods
	- $ pod setup

2. Add ClearBlade-API pod
	- Create a podfile for your project
		- Edit (vim, emaces, nano, etc) Podfile
	- Insert the following
		- pod 'ClearBlade-iOS-API'
	- Install the pod
		- $ pod install
	- Open the <code>.xcworkspace</code> file

From now you will open the file with the extension <code>.xcworkspace</code> instead of the project file
Open this from Finder or Xcode to start working on your app.

### Sample Calls

* To initialize the app call the class method
<code>[ClearBlade initSettingsWithAppKey:&lt;app key&gt; withAppSecret:&lt;app secret&gt;];</code>

* To fetch all from a collection
	* Initialize a collection<br>
<code>col = [CBCollection collectionWithID:@"&lt;collection ID&gt;"];</code>
	* Call the instance method <br><pre>
<code>col fetchWithSuccessCallback:^(CBQueryResponse *successfulResponse) {
      NSLog(@"%@", [(CBItem *)[successfulResponse.dataItems objectAtIndex:0] objectForKey:@"name"]);
      NSMutableString *str = [[NSMutableString alloc] init];
      for (int i = 0; i &lt; [successfulResponse.dataItems count]; i++) {
          [str appendFormat:@"%i: %@ \n", i, [[(CBItem *)[successfulResponse.dataItems objectAtIndex:i] data] description]];
      }
      NSLog(@"Str: %@", str);
  } withErrorCallback:^(NSError *err, id stuff) {
      NSLog(@â€%@â€, [err description]);
  }];</code></pre>


### Learn More

Try the iOS tutorial to learn more about the ClearBlade backend with examples for Objective C




Installation
------------

Use [CocoaPods](http://cocoapods.org/). Insert the following in your Podfile:

    pod 'ClearBlade-iOS-API'

With that in your Podfile, `pod install` should get everything ready for your
project.

Development Workflow
--------------------

All development should be done in feature branches with the naming convention: `feature-<issue#>-<issue description>`

* `master` contains only full releases
* `staging` contains release candidates to test on
* `develop` is code that is under development

For questions feel free to contact us (support@clearblade.com)
