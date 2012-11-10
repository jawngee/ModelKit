#ModelKit

ModelKit is a simple to use model framework for Objective-C (Cocoa/iOS).  It allows you to write your model layer quickly and easily, managing persistence (local and network) for you.

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

###Documentation

In addition to the Doxygen generated documentation included in the repo, more in-depth information can be found on the github wiki.

####Wiki Documentation
* [About ModelKit](https://github.com/jawngee/ModelKit/wiki/About-ModelKit)
  * [What It Is](https://github.com/jawngee/ModelKit/wiki/About-ModelKit#wiki-What)
  * [What It Provides](https://github.com/jawngee/ModelKit/wiki/About-ModelKit#wiki-Provides)
* [Installation Guide](https://github.com/jawngee/ModelKit/wiki/Installation-Guide)
* [Working With Models](https://github.com/jawngee/ModelKit/wiki/Working-With-Models)
	* [Model Conventions](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-Conventions)
	* [Serialization/De-Serialization](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-Serialization)
	* [JSON](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-JSON)
	* [Referencing Other Models as Properties](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-Referencing)
		* [Circular References](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-Circular)
	* [Getting Properties and/or Changed Properties](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-Properties)
	* [Model Property Change Notifications](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-Changes)
	* [Geo Points and Location Data](https://github.com/jawngee/ModelKit/wiki/Working-With-Models#wiki-GeoPoints)
* [Contexts](https://github.com/jawngee/ModelKit/wiki/Contexts)
	* [Fetching Models](https://github.com/jawngee/ModelKit/wiki/Contexts#wiki-Fetching)
	* [Removing a Model From The Context](https://github.com/jawngee/ModelKit/wiki/Contexts#wiki-Removing)
	* [Multiple Contexts](https://github.com/jawngee/ModelKit/wiki/Contexts#wiki-Multiple)
	* [Persisting Contexts](https://github.com/jawngee/ModelKit/wiki/Contexts#wiki-Persisting)
	* [Clearing Contexts](https://github.com/jawngee/ModelKit/wiki/Contexts#wiki-Clearing)
	* [No Context Models](https://github.com/jawngee/ModelKit/wiki/Contexts#wiki-NoContext)
	* [Context Information](https://github.com/jawngee/ModelKit/wiki/Contexts#wiki-Information)
* [Querying Models](https://github.com/jawngee/ModelKit/wiki/Querying-Models)
* [Backend Services](https://github.com/jawngee/ModelKit/wiki/Backend-Services)
	* [Setting Up The Service](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Setup)
	* [Making Your Models Usable With The Service](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Setup)
	* [Saving and Updating](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Saving)
	* [Deleting Models](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Deleting)
	* [Fetching a Models Data](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Fetching)
	* [Querying](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Querying)
	* [Users](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Users)
		* [Determining If Logged In](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-LoggedIn)
		* [Signing Up](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-SignUp)
		* [Logging In](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-LoggingIn)
		* [Logging Out](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-LoggingOut)
		* [Forgotten Password](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-ForgotPassword)
	* [Files](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Files)
		* [Uploading a File](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Uploading)
		* [Uploading Batches](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Batches)
		* [Associating with Models](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-AssociatingFiles)
		* [Deleting Files](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-DeletingFiles)
	* [Calling Backend Code](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-BackendCode)
	* [Synchronizing](https://github.com/jawngee/ModelKit/wiki/Backend-Services#wiki-Syncing)
