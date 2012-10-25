//
//  COModelContext.h
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COModel;

/**
 * The model context is a global storage mechanism for models so that your
 * application isn't littered with different instances of the same model.
 *
 * There is always one active context, but you can create "layers" of them
 * for specific purposes by calling the push and pop static class methods.
 */
@interface COModelContext : NSObject
{
    NSMutableArray *newStack;
    NSMutableDictionary *classCache;
}

#pragma mark - Class Methods - Stack Management

/**
 * Returns the current context
 * @return The current context
 */
+(COModelContext *)current;

/**
 * Pops the current context off the stack.  If this is the last context, nothing happens
 * @return The current context
 */
+(COModelContext *)pop;

/**
 * Pushes a new context on top of the stack
 * @return The new context
 */
+(COModelContext *)push;

#pragma mark - Class Methods - Model Management

/**
 * Removes the model from any contexts
 * @param model The model to remove
 */
+(void)removeFromAnyContext:(COModel *)model;


#pragma mark - Model Management

/**
 * Adds the model to the context
 * @param model The model to add
 */
-(void)addToContext:(COModel *)model;

/**
 * Removes the model from the context
 * @param model The model to remove
 * @result YES if removed, NO if not.
 */
-(BOOL)removeFromContext:(COModel *)model;

/**
 * Retrieves a model from the context based on id and class
 * @param objId The object id of the model
 * @param modelClass The class of the model
 * @return The model, if found, nil if not.
 */
-(COModel *)modelForId:(NSString *)objId andClass:(Class)modelClass;

@end
