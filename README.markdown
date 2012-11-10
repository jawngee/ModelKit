#ModelKit

ModelKit is a simple to use model framework for Objective-C (Cocoa/iOS).  It allows you to write your model layer quickly and easily, managing persistence (local and network) for you.

ModelKit is under active development and, as such, should probably not be used for production.

##About ModelKit
Before we jump into the how-to, it's important to understand what ModelKit is and isn't:

###What Is It?
ModelKit was built to solve a few problems I consistently run into developing iPhone software.  Namely:

* Persisting the model graph
* Integrating with a backend web service or BaaS (Backend as a Service) like Parse
* If using a backend, allowing the application to work offline.

I do a lot of consulting and inherit a lot of projects that use CoreData to store all of the data they pull off their JSON based REST-esque API.  It is invariably a giant convoluted mess for what should be such a simple task.  Need to upgrade a CoreData schema?  Yeah, no thanks.

ModelKit could be considered CoreData-lite since it does most things that CoreData does.  It attempts to accomplish these things in the simplest way possible.  Therefore, it might not cover all the edge cases that CoreData does, nor does it ever intend to.

The other reason I needed something like ModelKit was to cover the holes in the iOS SDKs for certain BaaS services.  While these SDKs are generally good for simple things like saving game scores, the more complicated your needs get, the bigger the holes they develop and the more boilerplate you end up writing.  Since they typically aren't open sourced, you are left in the dark if you run head first into a wall.

###What Does It Provide?
ModelKit gives you:

* A framework for building mildly complicated object graphs
* Persisting those graphs to local storage
* Querying the graph
* Tying the graph to a BaaS or your own custom backend REST API
* User system (backend)
* File uploads (backend)
* Push notifications (backend)
* Running custom backend code (backend)
* Simplistic and optimistic syncing (backend)

###How Do I Install It?

I will write more in-depth installation notes in the future.

For now, just do a recursive check out of this git repo and check out the example application for pointers on getting it setup.



##Working With Models
Creating a model in ModelKit is as easy as you'd hope for:

    #import "MKitModel.h"
    
    @interface CSMPAuthor : MKitModel
    
    @property (copy, nonatomic) NSString *name;
    @property (copy, nonatomic) NSString *email;
    @property (retain, nonatomic) NSDate *birthday;
    @property (assign, nonatomic) NSInteger age;
    @property (assign, nonatomic) BOOL displayEmail;
    @property (copy, nonatomic) NSString *avatarURL;
    
    @end

That's all you have to do.  

There are, however, a few conventions you'll need to follow and a few concepts you'll want to understand before getting full use out of ModelKit.

###Model Conventions
ModelKit makes heavy use of the Objective-C runtime to take care of all the boilerplate one would normally have to do to support serialization, persistence, etc.

* Properties that are prefixed with **'model'** are ignored during serialization/de-serialization.  The **MKitModel** class has a number of properties with this prefix to manage state, etc.
* Properties that reference other subclasses of **MKitModel** should not use **retain** but should use **assign** instead.  This is because ModelKit uses the concept of contexts which retain the models, but more on that later.
* If a property of your objects is an array of **MKitModel** subclasses, you need to use the **MKitMutableModelArray** instead of **NSMutableArray** for the property.
* All models have the following properties:
  * **modelId** - A unique identifier for the object that model kit uses internally.
  * **objectId** - A unique identifier for the object that is application specific.  If you are using a service like Parse, you typically will not set this directly, but let the service set it for you.  If you are using local persistence only, feel free to use this how you see fit.
  * **createdAt** - The date the object was created
  * **updatedAt** - The date the object was updated
  
###Model Serialization
Models can be serialized/deserialized to NSDictionary, as well as to JSON strings.  This is all automatic and requires no configuration on your end.

Serializing to a dictionary is as easy as:

    CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"001"];
    author.email=@"jon@interfacelab.com";
    author.name=@"Jon Gilkison";
    author.age=39;
    author.displayEmail=YES;
    author.avatarURL=@"https://secure.gravatar.com/avatar/819b112459b48de1e3ea08128b8e5479";
    
    NSDictionary *serialized=[author serialize];
    
The resulting dictionary would look like:

	{
	    createdAt = "2012-10-29 06:44:01 +0000";
	    model = Author;
	    modelId = AAAA-AAAA-AAAA-AAAA;
	    objectId = 001;
	    properties =     {
	        age = 39;
	        avatarURL = "https://secure.gravatar.com/avatar/819b112459b48de1e3ea08128b8e5479";
	        birthday = "<null>";
	        displayEmail = 1;
	        email = "jon@interfacelab.com";
	        name = "Jon Gilkison";
	    };
	    updatedAt = "2012-10-29 06:44:01 +0000";
	}

Deserializing back into an object is just as easy:

    CSMPAuthor *author=[CSMPAuthor instanceWithDictionary:serialized];
    
There is a caveat though.  If you look at the signature for the serialize method for MKitModel:

	-(id)serialize;
	
You see how it returns an **id**?  Serialize will actually return either an NSDictionary or an NSArray of NSDictionary depending on a few factors:

* If your model contains model properties or arrays of models, serialize will return an array containing all of the different models it discovered while serializing.  The first dictionary in this array will be the original model you were serializing.  It does this to flatten out references and to allow circular references.  You can read more on that below.
* If your model **does not** contain model properties or arrays of models, then serialize will return an NSDictionary.



   
###Model Serialization with JSON
This works exactly the same as serializing/deserializing to/from an NSDictionary with a few caveats.  JSON has no support for dates, binary data so ModelKit encodes the JSON slightly differently.

Using the above example, the serialized JSON would look like:

	{
	  "createdAt": {
	    "__type": "Date",
	    "iso": "2012-10-29T13:50:03+0700"
	  },
	  "model": "Author",
	  "modelId": "AAAA-AAAA-AAAA-AAAA",
	  "objectId": "001",
	  "properties": {
	    "age": 39,
	    "avatarURL": "https://secure.gravatar.com/avatar/819b112459b48de1e3ea08128b8e5479",
	    "birthday": null,
	    "displayEmail": 1,
	    "email": "jon@interfacelab.com",
	    "name": "Jon Gilkison"
	  },
	  "updatedAt": {
	    "__type": "Date",
	    "iso": "2012-10-29T13:50:03+0700"
	  }
	}

Again, as with normal serialization, if your model contains model properties or properties that are arrays of models, the JSON returned will be an array instead of an object.  Read the next section for more information as to why.

###Referencing Other Models as Properties
This was mentioned in the caveats, but is worth mentioning in more detail.

It won't be uncommon that you'll want to reference other models as a property of your model.  For example, let's look at what a blog post model would look like:

	#import "MKitModel.h"
	#import "CSMPAuthor.h"
	
	@interface CSMPPost : MKitModel
	
	@property (assign, nonatomic) CSMPAuthor *author;
	@property (copy, nonatomic) NSString *title;
	@property (copy, nonatomic) NSString *body;
	
	@end

Notice that CSMPAuthor model is a property, pointing to the author that wrote the post.  Pay close attention to the property access specifier though and notice that it is **assign** and not **retain**.  This is because there is a global context that retains all of the models you create.  We'll talk more about that in detail later, but it's important to know that these properties should always be **assign** otherwise you will leak objects like crazy.

If you are storing an array of models in your model, you'll want to use **MKitMutableModelArray**.  Because the context retains any models created, MKitMutableModelArray only retains weak references

####What about circular references?

No problem.  When serializing, ModelKit tracks the models that it is serializing and creates pointers to models that it has already serialized.  Let's look at a very convoluted example:

	#import "MKitModel.h"
	
	@interface VeryConvolutedExample : MKitModel
	
	@property (assign, nonatomic) VeryConvolutedExample *circular;
	
	@end
	
And then later in the code:

	VeryConvolutedExample *example=[VeryConvolutedExample instanceWithObjectId:@"0001"];
	example.circular=example;
	
	NSDictionary *serialized=[example serialize];
	
Now, let's look at the dictionary we serialized:

	{
	    createdAt = "2012-10-29 07:04:08 +0000";
	    model = VeryConvolutedExample;
	    modelId = AAAA-AAAA-AAAA-AAAA;
	    objectId = 0001;
	    properties =     {
	        circular =         {
	            "__type" = ModelPointer;
	            model = VeryConvolutedExample;
	            objectId = 0001;
	        };
	    };
	    updatedAt = "2012-10-29 07:04:08 +0000";
	}

Here's the JSON example:

	{
	  "createdAt": {
	    "__type": "Date",
	    "iso": "2012-10-29T14:04:58+0700"
	  },
	  "model": "VeryConvolutedExample",
	  "modelId": "AAAA-AAAA-AAAA-AAAA",
	  "objectId": "0001",
	  "properties": {
	    "circular": {
	      "__type": "ModelPointer",
	      "model": "VeryConvolutedExample",
	      "objectId": "0001"
	    }
	  },
	  "updatedAt": {
	    "__type": "Date",
	    "iso": "2012-10-29T14:04:58+0700"
	  }
	}

The **ModelPointer** type tells the serializer/deserializer that this a pointer to another object that has already been serialized in the same dictionary.  ModelKit will automatically take care of these references for you.

So circular reference your heart out, just make sure your properties are **assign** and not **retain**.

###Getting Properties and/or Changed Properties
You may have the case where your serialization format is different than how ModelKit serializes by default.  You can easily grab the properties of any object as a dictionary, even grabbing only the properties that have been changed.  Let's look at an example:

    CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"001"];
    author.email=@"jon@interfacelab.com";
    author.name=@"Jon Gilkison";
    author.age=39;
    author.displayEmail=YES;
    author.avatarURL=@"https://secure.gravatar.com/avatar/819b112459b48de1e3ea08128b8e5479";
    
    NSDictionary *properties=[author properties];

Here we've grabbed all of the properties of the object.  Here's what that dictionary will look like:

	{
	    email = "jon@interfacelab.com";
	    name = "Jon Gilkison";
	    age = 39;
	    displayEmail = YES;
	    avatarURL = @"https://secure.gravatar.com/avatar/819b112459b48de1e3ea08128b8e5479";
	}

Now what about the case where we only want the properties that have been changed?  Nearly the same thing:

    CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"001"];  // exists already
    
    // going to change the email and name only
    author.email=@"jon@interfacelab.com";
    author.name=@"Jon Gilkison";
    
    NSDictionary *changes=author.modelChanges;

And the dictionary:

	{
	    email = "jon@interfacelab.com";
	    name = "Jon Gilkison";
	}

You can reset the changes by calling **resetChanges** on the model:

	[author resetChanges];
	
###Model Property Change Notifications
Whenever a property of a model is changed, the model will broadcast a notification: **MKitModelPropertyChangedNotification**.  You can the add observers for this notification and update your UI as the model is changed:

	-(void)viewDidLoad
	{
		self.author=[CSMPAuthor instanceWithId:@"001"];	
	    [[NSNotificationCenter defaultCenter] addObserver:self
	                                             selector:@selector(authorChanged:)
	                                                 name:MKitModelPropertyChangedNotification
	                                               object:self.author];
	}
	
	-(void)viewDidUnload
	{
		// Don't forget to unregister!
	    [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
	
	-(void)authorChanged:(NSNotification *)notification
	{
		if (notification.userInfo==nil)
		{
			NSLog(@"Entire model changed!");
			
			[self.author.modelChanges enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		        NSLog(@"%@ = %@",key,obj);
		    }];
		}
		else
		{
			id prop=notification.userInfo[@"keyPath"];
			id oldVal=notification.userInfo[NSKeyValueChangeOldKey];
			id newVal=notification.userInfo[NSKeyValueChangeNewKey];
			NSLog(@"Property: %@  Old: %@   New: %@", prop,oldVal,newVal);
		}
	}
	
What if you are changing a whole slew of properties at once?  You can suspend notifications until your finished by calling **beginChanges** and **endChanges** on the model:

	-(void)viewDidLoad
	{
		self.author=[CSMPAuthor instanceWithId:@"001"];	
	    [[NSNotificationCenter defaultCenter] addObserver:self
	                                             selector:@selector(authorChanged:)
	                                                 name:MKitModelPropertyChangedNotification
	                                               object:self.author];
	}
	
	-(void)viewDidUnload
	{
		// Don't forget to unregister!
	    [[NSNotificationCenter defaultCenter] removeObserver:self];
	}
	
	-(void)changeLots:(id)sender
	{
		[self.author beginChanges];

		self.author.email="whutwhut@interfacelab.com";
		self.author.name="Joe Blow";
		self.author.age=29;
		self.author.displayEmail=NO;
		
		[self.author endChanges];
	}
	
	-(void)authorChanged:(NSNotification *)notification
	{
		if (notification.userInfo==nil)
		{
			NSLog(@"Entire model changed!");
			
			[self.author.modelChanges enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
		        NSLog(@"%@ = %@",key,obj);
		    }];
		}
		else
		{
			id prop=notification.userInfo[@"keyPath"];
			id oldVal=notification.userInfo[NSKeyValueChangeOldKey];
			id newVal=notification.userInfo[NSKeyValueChangeNewKey];
			NSLog(@"Property: %@  Old: %@   New: %@", prop,oldVal,newVal);
		}
	}



##Contexts
ModelKit has a global context that stores all models you create, allowing your application access to all instances regardless of where in your code it's accessing it from.  This provides a variety of benefits:

* No duplication of object instances
* You can persist and load contexts to/from file
* You don't have to worry about managing memory as it relates to your models
* Global access to all model instances

Normally, you will never need to worry about contexts, but will need to follow some simple guidelines:

* Model instances you create should be auto released

Ok, 1 simple guideline.  So that's easy, right?

Let's look at some examples:


	-(void)someAction:(id)sender
	{
    	CSMPAuthor *author=[[CSMPAuthor alloc] init];
    	// do some stuff.
	}

In this example, we just leaked an object because we didn't autorelease it.  This is the proper way:

	-(void)someAction:(id)sender
	{
    	CSMPAuthor *author=[[[CSMPAuthor alloc] init] autorelease];
    	// do some stuff.
	}

You might think that because we're autoreleasing the object that it will be released once we exit this method.  This is not the case as the model context retains all models created.  So, in a way, this model could be considered leaked if it is not your intention to ever use it again.

If we wanted to release the model the proper way to write this would be:

	-(void)someAction:(id)sender
	{
    	CSMPAuthor *author=[[[CSMPAuthor alloc] init] autorelease];
    	// do some stuff.
    	[author removeFromContext];
	}

Calling **removeFromContext** insures that the model is removed from the context.

###Fetching Models

You can fetch a model at a later stage by requesting it from the context again.  You can do this using the model's **modelId** or by its **objectId**.

To do this "manually" using the context:

	-(void)createModelAction:(id)sender
	{
    	CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"0001"]; // this is already auto-released
    	author.name="Jon Gilkison";
    	author.email="jon@interfacelab.com";
	}
	
	-(void)fetchModelAction:(id)sender
	{
		CSMPAuthor *author=(CSMPAuthor *)[[MKitModelContext current] modelForObjectId:@"0001" andClass:[CSMPAuthor class]];
	}
	
Now, you're never going to do it this way.  The better way is:
	

	-(void)someAction:(id)sender
	{
    	CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"0001"]; // this is already auto-released
    	author.name="Jon Gilkison";
    	author.email="jon@interfacelab.com";
	}
	
	-(void)someOtherAction:(id)sender
	{
		CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"0001"];
		if ([author.name isEqualToString:@"Jon Gilkison"])
			NSLog(@"Same instance.");
	}
	
The **instanceWithObjectId** and **instanceWithModelId** class methods always first check the context for an existing model with matching id and return that instance instead of creating a new one.  If it can't find one, it'll create a new instance, add it to the context and then return it.

###Removing a Model From The Context
Removing a model from a context is this simple:

    CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"0001"];
    [author removeFromContext];
   
You'll need to be careful here because if any object has this object as a property, because it's a weak reference, you'll crash your application.
   
###Multiple Contexts
There might be conditions where you want to create a temporary context, perhaps to load a bunch of temporary objects for processing.

	// Push a new context onto the context stack
    [MKitModelContext push]; 
    
    // Load up a bunch of objects…
    for(int i=0; i<100; i++)
    	[CSMPAuthor instanceWithObjectId:[NSString stringWithFormat:@"%d",i]];
    	
    // Do our processing
    
    // Dump the context and it's associated objects
    [MKitModelContext pop];
    
In this example, we pushed a new context onto the context stack, created a bunch of objects and then popped the context off.

In a more complicated example, we can push a new context onto a stack, retain a reference to it, pop it off and then push it onto the stack again later:

	MKitModelContext *newContext=[[MKitModelContext push] retain];
	    
    // Load up a bunch of objects…
    for(int i=0; i<100; i++)
    	[CSMPAuthor instanceWithObjectId:[NSString stringWithFormat:@"%d",i]];
    	
    // Do our processing
    
    // Dump the context and it's associated objects
    [MKitModelContext pop];
    
    // Do some other stuff
    
    // Restore our context:
    [newContext activate];
    
    // Create some more objects ...
    for(int i=0; i<100; i++)
    	[CSMPAuthor instanceWithObjectId:[NSString stringWithFormat:@"%d",i]];
    	
    // Deactivate the context
    [newContext deactivate];
    
    // Release it to destroy it
    [newContext release];
    
It's important to know that there can only be one context active at a time.  If a background thread is creating objects at the same time as the above code is running, those objects created in the background will exist in the current thread.  This is a big TODO.

###Persisting Contexts
You can store an entire context to file, as well as restore it at a later time:

	[[MKitModelContext current] writeToFile:@"/tmp/persisted.plist" error:nil];
	
You can then restore it:

	[[MKitModelContext current] loadFromFile:@"/tmp/persisted.plist" error:nil];
	
This makes it super simple to save your entire object graph on application exit and restore it the exact same point when you launch the application again.

###Clearing Contexts
You can reset the entire context system:

	[MKitModelContext clearAllContexts];
	
Or, just clear one of them:

	[[MKitModelContext current] clear];
	
This will remove all objects from the context, releasing them.

###No Context Models
There will definitely be times when you don't want your model to ever be added to a context.  This is simple to achieve by adding the MKitNoContext protocol to your model:

    #import "MKitModel.h"
    
    @interface CSMPAuthor : MKitModel<MKitNoContext>
    
    @property (copy, nonatomic) NSString *name;
    @property (copy, nonatomic) NSString *email;
    @property (retain, nonatomic) NSDate *birthday;
    @property (assign, nonatomic) NSInteger age;
    @property (assign, nonatomic) BOOL displayEmail;
    @property (copy, nonatomic) NSString *avatarURL;
    
    @end

Any instances of this object will not be added to the context ever, unless you do so manually:

	CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"001"];
	[author addToContext];
	
###Context Information
All contexts have two properties that tell you information about it:

* **contextSize** The size of the context in bytes.  This is a rough guesstimate and should not be relied on as fact.
* **contextCount** The number of objects currently stored in the context

You can use it:

	NSLog(@"Context Size: %d",[MKModelContext current].contextSize);
	NSLog(@"Context Count: %d",[MKModelContext current].contextCount);
	
## Model Querying
ModelKit provides an interface for querying both the context and your backend services for models.  Both methods are exactly the same, though some caveats for backend services exist and will be discussed further in the documentation.

Let's take a look:

	-(void)someAction:(id)sender
	{
		MKitModelQuery *query=[CSMPAuthor query];
		
		// Let's find all authors between the ages of 24 to 35
		[query key:@"age" condition:KeyBetween value:@[@(24),@(35)]];
		
		NSDictionary *result=[query execute:nil];
		NSArray *found=[result objectForKey:MKitQueryResultKey];
		for(CSMPAuthor *author in found)
			NSLog(@"Author %@ is %d",author.name,author.age);
	}
	
That's a pretty simple example, but we can do more complicated queries using different conditions.  Below is a list of conditions that the query supports:

Condition|Meaning
---------|---------
KeyEquals | == 
KeyNotEqual | !=
KeyGreaterThanEqual | >= 
KeyGreaterThan | >
KeyLessThan | <
KeyLessThanEqual | <= 
KeyIn | The value for the key is in an array of values
KeyNotIn | The value for the key is not in an array of values
KeyExists | The key value is not nil
KeyNotExist | The key value is nil
KeyWithin | The key value is within the range of two values
KeyBeginsWith | The key value begins with a string value
KeyEndsWith | The key value ends with a string value
KeyLike | The key value contains the string

Queries are always AND and subqueries are not supported.  Support for OR and subqueries is planned however.

## Tying to Backend Services
ModelKit was originally designed to replace Parse.com's iOS SDK.  Therefore, a primary goal of this framework is not only model persistence/management, but tying those models to a backend, either a BaaS like Parse or Kinvey, or your own custom REST solution.

Currently, ModelKit supports Parse through their REST API.

### Setting Up The Service
Setting up the service is pretty simple.  In the code for your application launch:

	[MKitServiceManager setupService:@"Parse" withKeys:@{@"AppID":PARSE_APP_ID,@"RestKey":PARSE_REST_KEY}];
    


### Making Your Models Usable With The Service
To use your models with Parse, simply make them subclasses of MKitParseModel:

	@interface CSMPAuthor : MKitParseModel
    
    @property (copy, nonatomic) NSString *name;
    @property (copy, nonatomic) NSString *email;
    @property (retain, nonatomic) NSDate *birthday;
    @property (assign, nonatomic) NSInteger age;
    @property (assign, nonatomic) BOOL displayEmail;
    @property (copy, nonatomic) NSString *avatarURL;
    
    @end

If you were to use this straight away, you'd notice in the Parse data browser that your classes are named **CSMPAuthor**.  If this is not what you want, you can change this behavior by doing the following in your implementation:

	@implementation CSMPAuthor
	
	+(void)load
	{
	    [self register];
	}
	
	+(NSString *)modelName
	{
	    return @"Author";
	}
	
	@end

Two things are happening here.  When you override **+(NSString \*)modelName** you are telling the system the name of the class you want to use for Parse.  With this overridden, after you save your model, in the Parse data browser you would then see a class **Author** instead of **CSMPAuthor**.

If you do override **+(NSString \*)modelName**, you'll also need to override **+(void)load** and call **[self register];** to make sure that your custom model name is registered with your model class so that when data returned from Parse is -well- parsed, that the correct model types are created.

### Saving and Updating
Saving models to Parse is as simple as can be.  You have two choices, synchronous and asynchronous.  Let's look at synchronous first:

	-(void)someAction:(id)sender
	{
		CSMPAuthor *author=[CSMPAuthor instance];
		author.email=@"jon@interfacelab.com";
	    author.name=@"Jon Gilkison";
	    author.age=39;
	    author.displayEmail=YES;
	    author.avatarURL=@"https://secure.gravatar.com/avatar/819b112459b48de1e3ea08128b8e5479";
	    
	    NSError *error=nil;
	    if (![author save:&error])
	    	NSLog(@"Oops: %@",error);
	    else
	    	NSLog(@"Saved!");
	}
	
That was easy, but there is a problem.  Synchronous saving will block the thread while it waits for the request to be sent to Parse and then wait for Parse to send a response.  This is fine if you're running this in a background thread, but in your main thread, this will block your UI and make your app unresponsive.

Asynchronous is better:

	-(void)someAction:(id)sender
	{
	    CSMPAuthor *author=[CSMPAuthor instance];
	    author.email=@"jon@interfacelab.com";
	    author.name=@"Jon Gilkison";
	    author.age=39;
	    author.displayEmail=YES;
	    author.avatarURL=@"https://secure.gravatar.com/avatar/819b112459b48de1e3ea08128b8e5479";
	    
	    [author saveInBackground:^(BOOL succeeded, NSError *error) {
	       if (!succeeded)
	           NSLog(@"OOPS %@",error);
	        else
	            NSLog(@"Saved!");
	    }];
	}

The save will now happen in the background and your main thread can keep on trucking.

What about updating?  The **save** method creates and updates automatically, so you'll call it whether you are creating a new object or updating an existing one.

One thing to note is that if your model has model properties or a property that's an array of models, those models will automatically be saved or updated if needed, no need to do it one by one yourself.

### Deleting
This works the same way as saving.  Synchronously:

	-(void)someAction:(id)sender
	{
		CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"as322DdddzJ"];
	    
	    NSError *error=nil;
		if (![author delete:&error])
	    	NSLog(@"Oops: %@",error);
	    else
	    	NSLog(@"Deleted!");
	}


Asynchronously:

	-(void)someAction:(id)sender
	{
		CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"as322DdddzJ"];
	    
	    [author deleteInBackground:^(BOOL succeeded, NSError *error) {
	       if (!succeeded)
	           NSLog(@"OOPS %@",error);
	        else
	            NSLog(@"Deleted!");
	    }];
	}

### Fetching
There will be instances where models don't have all their data from Parse.  This could be the result from a query or by creating an instance with a known parse **objectId**.  To know if you need to fetch this data, you can inspect the **modelState** property and if it's equal to **ModelStateNeedsData** then that is a sure sign you need to get to fetching.

And just like saving and deleting:

	-(void)someAction:(id)sender
	{
		CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"as322DdddzJ"];
	    
	    if (author.modelState==ModelStateNeedsData)
	    {
	    	NSError *error=nil;
			if (![author fetch:&error])
	    		NSLog(@"Oops: %@",error);
	    	else
	    		NSLog(@"fetched!");
	    }
	}


Asynchronously:

	-(void)someAction:(id)sender
	{
		CSMPAuthor *author=[CSMPAuthor instanceWithObjectId:@"as322DdddzJ"];
	    
	    if (author.modelState==ModelStateNeedsData)
	    {
		    [author fetchInBackground:^(BOOL succeeded, NSError *error) {
		       if (!succeeded)
		           NSLog(@"OOPS %@",error);
		        else
		            NSLog(@"Fetched!");
		    }];
		}
	}


### Querying
Querying works exactly the same as described in the section above, except that instead of using NSPredicates to query the context, you are generating web requests to Parse.  Otherwise, the interface and usage is exactly the same.

But what if you want to query the context?  Maybe your user doesn't have an internet connection or you just want to search locally.  **MKServiceModel**, which **MKParseModel** subclasses, has a static class method called **contextQuery**.  Using this will query the context instead of the backend service:

	-(void)someAction:(id)sender
	{
		MKitModelQuery *query=[CSMPAuthor contextQuery];
		
		// Let's find all authors between the ages of 24 to 35
		[query key:@"age" condition:KeyBetween value:@[@(24),@(35)]];
		
		NSDictionary *result=[query execute:nil];
		NSArray *found=[result objectForKey:MKitQueryResultKey];
		for(CSMPAuthor *author in found)
			NSLog(@"Author %@ is %d",author.name,author.age);
	}

### GeoPoints
ModelKit includes some primitive geolocation features, specifically allowing you to associate latitude and longitude with a model and the the ability to query your model graph based on distance from one model to the other.  This works locally or with a backend.

The class that provides this functionality is **MKitGeoPoint**.  **MKitGeoPoint** is not a model, so you should not treat it as such, but it can be, should be, used as a property on a model.  Let's look an example:

	@interface SavedLocation : MKitModel
	
	@property (retain, nonatomic) MKitGeoPoint *location;
	@property (copy, nonatomic) NSString *name;
	@property (assign, nonatomic) NSInteger checkIns;
	
	@end
	
In this simple example, we have a **SavedLocation** model that has an **MKitGeoPoint** to store the actual lat/lon of the location, as well as its name and the number of times people have checked in there.

#### Querying Based on Location

Now storing latitude/longitude would not be interesting if we couldn't query on it to find other models within a certain distance of a given point.  Let's say our user is standing in the center of District 1 in Saigon, Vietnam.  We have several SavedLocation models already saved and want to find the ones that are nearest to where he's standing.  That query would look something like:

	MKitModelQuery *q=[SavedLocation query];
	
	// let's find everything within 250 meters of where we are standing in Saigon
	[q key:@"location" withinDistance:250/1000.0 ofPoint:[MKitGeoPoint geoPointWithLatitude:10.76529079 andLongitude:106.69060779]];
	
	NSDictionary *result=[q execute:nil];
	
	NSLog(@"We found %d places.",[result[MKitQueryItemCountKey] integerValue]);

Note that some backends might not support this.  Parse currently does and ModelKit's features are 1:1 with Parse.  When performing the query using Parse's backend, it works exactly the same.  Kinvey also supports this as well.

### Users

ModelKit provides a working User model out of the box.  Note the user only works with a backend service because it wouldn't make any sense if your data was always local.  Duh.

If you are familiar with **PFUser** from the Parse iOS SDK, it works almost identically, except that you can subclass it and add your own properties to it.

The Parse user class is **MKitParseUser**, which is a subclass of **MKitParseModel** that implements the **MKitServiceUser** protocol.  Because it's a model, everything you can do with that you can do with **MKitParseModel**.

#### Determining If The Current User Is Logged In
You can check to see if the current user is logged in by calling the **currentUser** static method:

	if ([MKitParseUser currentUser])
	{
		// Logged In!
	}



#### Signing Up
Signing up your users for your application is straight forward.  As with saving/deleting/fetching, it can be done synchronously or asynchronously depending on your needs.  Synchronously:


	-(void)signUpTouched:(id)sender
	{
	    NSError *error=nil;
	    BOOL result=[MKitParseUser signUpWithUserName:@"bob" email:@"bob@somewhere.com" password:@"password" error:&error];
	    if (!result)
	        NSLog(@"ERROR: %@",error);
    }
    
Asynchronously:

	-(void)signUpTouched:(id)sender
	{
		[MKitParseUser signUpInBackgroundWithUserName:@"bob"
		                                            email:@"bob@somewhere.com""
		                                         password:@"password"
		                                      resultBlock:^(id object, NSError *error) {
		                                          if (error)
		                                              NSLog(@"ERROR: %@", error);
		                                      }];
	}
	
Once the user is signed up, that user will be logged in.  There is no need to log them in.

#### Logging In

	-(void)signUpTouched:(id)sender
	{
	    [MKitParseUser logInInBackgroundWithUserName:@"bob"
	                                         password:@"password"
	                                      resultBlock:^(id object, NSError *error) {
	                                         if (error)
	                                        	  NSLog(@"ERROR: %@",error);
	                                      }];
	}
	
Logging in will keep the user logged in forever, the user session never expires.

#### Logging Out


	-(void)logOutTouched:(id)sender
	{
		[[MKitParseUser currentUser] logOut];
	}
	

#### Forgotten Password?

	-(void)forgotPasswordTouched:(id)sender
	{
	    [MKitParseUser requestPasswordResetInBackgroundForEmail:@"bob@somewhere.com"
                                                    resultBlock:^(BOOL succeeded, NSError *error) {
                                                        if (error)
                                                            NSLog(@"ERROR: %@",error);
                                           }];

	}



### Files

ModelKit also provides a mechanism to upload files to your backend and associating those files with your users.  Like users, this feature requires a backend integration and is not available for local models.

**MKitParseFile** subclasses **MKitServiceFile**, but it is important to note that it is not a subclass of any model and should not be treated like a model.  In other words, you cannot add properties to it.  But what if that is what you want to do?  For example, let's say you want to model a Photograph.  You would create a Photograph model and have MKitParseFile as property of that model that points to the file.  Read more about this below because there are some **important** caveats.

#### Uploading Files
Uploading files is very simple and supports synchronous and asynchronous operation.  I will only demonstrate asynchronous:

    MKitParseFile *p=[MKitParseFile fileWithFile:[[NSBundle mainBundle] pathForResource:@"image2" ofType:@"jpeg"]];
    [p saveInBackgroundWithProgress:^(float progress) {
        NSLog(@"%f",progress);
    }
                        resultBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded)
                                NSLog(@"%@",p.url);
                            else
                                NSLog(@"ERORR: %@",error);
                        }];

You are not limited to uploading an existing file, you can upload an NSData instance as well.  This is a convoluted example, but you get the point:


    NSData *data=[NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"image2" ofType:@"jpeg"]
                                        options:NSDataReadingMappedAlways
                                          error:nil];
    MKitParseFile *p=[MKitParseFile fileWithData:data name:@"image2.jpeg" contentType:@"image/jpeg"];
    [p saveInBackgroundWithProgress:^(float progress) {
        NSLog(@"%f",progress);
    }
                        resultBlock:^(BOOL succeeded, NSError *error) {
                            if (succeeded)
                                NSLog(@"%@",p.url);
                            else
                                NSLog(@"ERORR: %@",error);
                        }];
                        
Once the upload has successfully completed, the **url** and **name** properties will be populated with values returned from the server.  **url** will be a valid URL to the uploaded resource and **name** will contain the backend's unique name for the file.


#### Uploading Batches
ModelKit provides the **MKitMutableFileArray** class which allows you to easily do batch uploading (and is useful as an array of files property on a model).  It's a subclass of **NSMutableArray** so you can cast it up the chain no problem.  Here's an example of a batch upload:

    MKitMutableFileArray *files=[MKitMutableFileArray array];
    
    // Add 10 files to the array to upload
    for(int i=0; i<10; i++)
        [files addObject:[MKitParseFile fileWithFile:[[NSBundle mainBundle] pathForResource:@"image2" ofType:@"jpeg"]]];
    
    [files uploadInBackgroundWithProgress:^(NSInteger current, NSInteger total, float currentProgress, float totalProgress) {
        NSLog(@"File %d of %d - Progress %f - Total Progress %f",current,total, currentProgress, totalProgress);
    } resultBlock:^(BOOL succeeded, NSError *error) {
        NSLog(@"Finished");
    }];




#### Associating With Models

You can use **MKitParseFile** as a property of an model, but there are some things you must know:

* You must **retain** the property, not **assign** as you would do for a model property
* The file must be uploaded to the backend before saving your model to the backend.  Failure to do so will raise an exception.

With those two things in mind, here's a model with a file as a property:

	#import "ModelKit.h"
    
    @interface CSMPPhoto : MKitParseModel
    
    @property (assign, nonatomic) MKitParseUser *owner;
	@property (retain, nonatomic) MKitParseFile *photo;
	    
    @end


#### Deleting Files
Like models, you can simply call **delete** on the file to delete it.  Unless you are using Parse.  If you are using Parse, Parse requires you to use the MasterKey to delete files from the backend.  Therefore, it is not possible to delete them with ModelKit.

However, if you delete a model that has a file as a property, you can clean out "unused" files in the Parse data dashboard.



### Calling Backend Code
TBD

### Offline and Syncing
TBD

