//
//  MKitModelContext.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKitModel;

/**
 * The model context is a global storage mechanism for models so that your
 * application isn't littered with different instances of the same model.
 *
 * There is always one active context, but you can create "layers" of them
 * for specific purposes by calling the push and pop static class methods.
 */
@interface MKitModelContext : NSObject
{
    NSMutableDictionary *modelStack;
    NSMutableDictionary *classCache;
    
    NSUInteger contextSize;
    NSUInteger contextCount;
}

@property (readonly) NSUInteger contextSize;
@property (readonly) NSUInteger contextCount;

#pragma mark - Class Methods - Stack Management

/**
 * Returns the current context
 * @return The current context
 */
+(MKitModelContext *)current;

/**
 * Pops the current context off the stack.  If this is the last context, nothing happens
 * @return The current context
 */
+(MKitModelContext *)pop;

/**
 * Pushes a new context on top of the stack
 * @return The new context
 */
+(MKitModelContext *)push;

/**
 * Clears all contexts
 */
+(void)clearAllContexts;

#pragma mark - Persistence

/**
 * Saves the context to a binary plist.
 * @param file The name of the file to save to
 * @param error The error generated, if any
 * @return YES if succesful, NO if not.
 */
-(BOOL)saveToFile:(NSString *)file error:(NSError **)error;

/**
 * Loads the context from a binary plist.
 * @param file The name of the file to load from
 * @param error The error generated, if any
 * @return YES if succesful, NO if not.
 */
-(BOOL)loadFromFile:(NSString *)file error:(NSError **)error;


#pragma mark - Class Methods - Model Management

/**
 * Removes the model from any contexts
 * @param model The model to remove
 */
+(void)removeFromAnyContext:(MKitModel *)model;


#pragma mark - Activation

/**
 * Makes this context the active context
 */
-(void)activate;

/**
 * Deactivates this context
 */
-(void)deactivate;

/**
 * Clears the current context
 */
-(void)clear;

#pragma mark - Model Management

/**
 * Adds the model to the context
 * @param model The model to add
 */
-(void)addToContext:(MKitModel *)model;

/**
 * Removes the model from the context
 * @param model The model to remove
 * @result YES if removed, NO if not.
 */
-(BOOL)removeFromContext:(MKitModel *)model;

/**
 * Retrieves a model from the context based on id and class
 * @param objId The object id of the model
 * @param modelClass The class of the model
 * @return The model, if found, nil if not.
 */
-(MKitModel *)modelForObjectId:(NSString *)objId andClass:(Class)modelClass;

@end
