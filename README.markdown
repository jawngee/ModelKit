#ModelKit

ModelKit is a simple to use model framework for Objective-C (Cocoa/iOS).  It allows you to write your model layer quickly and easily, managing persistence (local and network) for you.

ModelKit is under active development.  This README is both a design document and actual documentation.



##Creating a Model
Creating a model in ModelKit is as easy as you'd suspect:

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

* Properties that are prefixed with 'model' are ignored during serialization/deserializiton.  The **MKitModel** class has a number of properties with this prefix to manage state, etc.
* Properties that reference other subclasses of **MKitModel** should not use **retain** but should use **assign** instead.  This is because ModelKit uses the concept of contexts which retain the models, but more on that later.
* If a property of your objects is an array of **MKitModel** subclasses, you need to use the **MKitMutableModelArray** instead of **NSMutableArray** for the property.
* All models have the following properties:
  * **objectId** - A unique identifier for the object
  * **createdAt** - The date the object was created
  * **updatedAt** - The date the object was updated
  
###Model Serialization
Models can be serialized/deserialized to NSDictionary, as well as to JSON strings.  This is all automatic and requires no configuration on your end.

Serializing to a dictionary is as easy as:

    CSMPAuthor *author=[CSMPAuthor instanceWithId:@"001"];
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
   
###Model Serialization with JSON
This works exactly the same as serializing/deserializing to/from an NSDictionary with a few caveats.  JSON has no support for dates, binary data so ModelKit encodes the JSON slightly differently.

Using the above example, the serialized JSON would look like:

	{
	  "createdAt": {
	    "__type": "Date",
	    "iso": "2012-10-29T13:50:03+0700"
	  },
	  "model": "Author",
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

####What about circular references?

No problem.  When serializing, ModelKit tracks the models that it is serializing and creates pointers to models that it has already serialized.  Let's look at a very convoluted example:

	#import "MKitModel.h"
	
	@interface VeryConvolutedExample : MKitModel
	
	@property (assign, nonatomic) VeryConvolutedExample *circular;
	
	@end
	
And then later in the code:

	VeryConvolutedExample *example=[VeryConvolutedExample instanceWithId:@"0001"];
	example.circular=example;
	
	NSDictionary *serialized=[example serialize];
	
Now, let's look at the dictionary we serialized:

	{
	    createdAt = "2012-10-29 07:04:08 +0000";
	    model = VeryConvolutedExample;
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

##Contexts
ModelKit has a global context that stores all models you create, allowing your application access to all instances regardless of where in your code it's accessing it from.  This provides a variety of benefits:

* No duplication of object instances
* You can persist and load contexts to/from file
* You don't have to worry about managing memory as it relates to your models
* Global access to all model instances

Normally, you will never need to worry about contexts, but will need to follow some simple guidelines:

* Model instances you create should be auto released

Ok, 1 simple guideline.  Let's look at some examples:


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

We also leaked an object here because the newly created object wasn't assigned an **objectId** and is therefore unretrievable from the context.  You must assign an **objectId** for it to be accessible from the context.  The proper way to write this would be:

	-(void)someAction:(id)sender
	{
    	CSMPAuthor *author=[[[CSMPAuthor alloc] init] autorelease];
    	// do some stuff.
    	[author removeFromContext];
	}

Since we didn't assign an **objectId** for whatever reason, we'll want to make sure the model is released so we'll manually remove it from the context.

Once you assign an **objectId**, you can fetch that same instance later:

	-(void)someAction:(id)sender
	{
    	CSMPAuthor *author=[CSMPAuthor instanceWithId:@"0001"]; // this is already auto-released
    	author.name="Jon Gilkison";
    	author.email="jon@interfacelab.com";
	}
	
	-(void)someOtherAction:(id)sender
	{
		CSMPAuthor *author=[CSMPAuthor instanceWithId:@"0001"];
		if ([author.name isEqualToString:@"Jon Gilkison"])
			NSLog(@"Same instance.");
	}

###Removing a Model From The Context
Removing a model from a context is this simple:

    CSMPAuthor *author=[CSMPAuthor instanceWithId:@"0001"];
    [author removeFromContext];
   
###Multiple Contexts
There might be conditions where you want to create a temporary context, perhaps to load a bunch of temporary objects for processing.

	// Push a new context onto the context stack
    [MKitModelContext push]; 
    
    // Load up a bunch of objects…
    for(int i=0; i<100; i++)
    	[CSMPAuthor instanceWithId:[NSString stringWithFormat:@"%d",i]];
    	
    // Do our processing
    
    // Dump the context and it's associated objects
    [MKitModelContext pop];
    
In this example, we pushed a new context onto the context stack, created a bunch of objects and then popped the context off.

In a more complicated example, we can push a new context onto a stack, retain a reference to it, pop it off and then push it onto the stack again later:

	MKitModelContext *newContext=[[MKitModelContext push] retain];
	    
    // Load up a bunch of objects…
    for(int i=0; i<100; i++)
    	[CSMPAuthor instanceWithId:[NSString stringWithFormat:@"%d",i]];
    	
    // Do our processing
    
    // Dump the context and it's associated objects
    [MKitModelContext pop];
    
    // Do some other stuff
    
    // Restore our context:
    [newContext activate];
    
    // Create some more objects ...
    for(int i=0; i<100; i++)
    	[CSMPAuthor instanceWithId:[NSString stringWithFormat:@"%d",i]];
    	
    // Deactive the context
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
There will definitely be times when you don't want your model to ever be added to a context.  This is simple to acheive by adding the MKitNoContext protocol to your model:

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

	CSMPAuthor *author=[CSMPAuthor instanceWithId:@"001"];
	[author addToContext];
	
###Context Information
All contexts have two properties that tell you information about it:

* **contextSize** The size of the context in bytes.  This is a rough guesstimate and should not be relied on as fact.
* **contextCount** The number of objects currently stored in the context

You can use it:

	NSLog(@"Context Size: %d",[MKModelContext current].contextSize);
	NSLog(@"Context Count: %d",[MKModelContext current].contextCount);


## Tying to Backend Services
ModelKit was originally designed to replace Parse.com's iOS SDK.  Therefore, a primary goal of this framework is not only model persistance/management, but tying those models to a backend, either a PaaS like Parse or Kinvey, or your own custom REST solution.

More on this to come...



