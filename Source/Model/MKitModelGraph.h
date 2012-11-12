//
//  MKitModelGraph.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKitModel;

/**
 * The model graph is a global storage mechanism for models so that your
 * application isn't littered with different instances of the same model.
 *
 * There is always one active graph, but you can create "layers" of them
 * for specific purposes by calling the push and pop static class methods.
 */
@interface MKitModelGraph : NSObject
{
    NSMutableDictionary *modelStack;    /**< Dictionary of models keyed by modelId */
    NSMutableDictionary *classCache;    /**< Dictionary of models classified by thier objectId and class */
    
    NSUInteger graphSize;             /**< The rough estimate of the size of the graph */
    NSUInteger graphCount;            /**< The number of items stored in the graph */
}

@property (readonly) NSUInteger graphSize;
@property (readonly) NSUInteger graphCount;

#pragma mark - Class Methods - Stack Management

/**
 * Returns the current graph
 * @return The current graph
 */
+(MKitModelGraph *)current;

/**
 * Pops the current graph off the stack.  If this is the last graph, nothing happens
 * @return The current graph
 */
+(MKitModelGraph *)pop;

/**
 * Pushes a new graph on top of the stack
 * @return The new graph
 */
+(MKitModelGraph *)push;

/**
 * Clears all graphs
 */
+(void)clearAllGraphs;

#pragma mark - Persistence

/**
 * Saves the graph to a binary plist.
 * @param file The name of the file to save to
 * @param error The error generated, if any
 * @return YES if succesful, NO if not.
 */
-(BOOL)saveToFile:(NSString *)file error:(NSError **)error;

/**
 * Loads the graph from a binary plist.
 * @param file The name of the file to load from
 * @param error The error generated, if any
 * @return YES if succesful, NO if not.
 */
-(BOOL)loadFromFile:(NSString *)file error:(NSError **)error;


#pragma mark - Class Methods - Model Management

/**
 * Removes the model from any graphs
 * @param model The model to remove
 */
+(void)removeFromAnyContext:(MKitModel *)model;


#pragma mark - Activation

/**
 * Makes this graph the active graph
 */
-(void)activate;

/**
 * Deactivates this graph
 */
-(void)deactivate;

/**
 * Clears the current graph
 */
-(void)clear;

#pragma mark - Model Management

/**
 * Adds the model to the graph
 * @param model The model to add
 */
-(void)addToContext:(MKitModel *)model;

/**
 * Removes the model from the graph
 * @param model The model to remove
 * @result YES if removed, NO if not.
 */
-(BOOL)removeFromContext:(MKitModel *)model;

/**
 * Retrieves a model from the graph based on id and class
 * @param objId The object id of the model
 * @param modelClass The class of the model
 * @return The model, if found, nil if not.
 */
-(MKitModel *)modelForObjectId:(NSString *)objId andClass:(Class)modelClass;

/**
 * Retrieves a model from the graph based on the model id
 * @param modelId The model id of the model
 * @return The model, if found, nil if not.
 */
-(MKitModel *)modelForModelId:(NSString *)modelId;

/**
 * Queries the graph for models of a specific class matching a supplied predicate.
 * @param predicate The predicate to filter with
 * @param modelClass The model class to filter on
 * @return An array of models filtered with the predicate
 */
-(NSArray *)queryWithPredicate:(NSPredicate *)predicate forClass:(Class)modelClass;

@end
