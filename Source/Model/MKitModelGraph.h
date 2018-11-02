//
//  MKitModelGraph.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKitModel;

/** Default graph */
extern NSString * const MKitModelGraphDefault;

/**
 * The model graph is a global storage mechanism for models so that your
 * application isn't littered with different instances of the same model.
 *
 * There is always one active graph, but you can create "layers" of them
 * for specific purposes by calling the push and pop static class methods.
 */
@interface MKitModelGraph : NSObject<NSCoding>
{
    NSMutableDictionary *modelStack;    /**< Dictionary of models keyed by modelId */
    NSMutableDictionary *classCache;    /**< Dictionary of models classified by thier objectId and class */
    
    NSUInteger size;             /**< The rough estimate of the size of the graph */
    NSUInteger objectCount;      /**< The number of items stored in the graph */
}

@property (readonly) NSUInteger size;
@property (readonly) NSUInteger objectCount;
@property (readonly) NSMutableDictionary *classCache;

#pragma mark - Class Methods - Stack Management

/**
 * Returns the default graph
 * @return The default graph
 */
+(MKitModelGraph *)defaultGraph;

/**
 * Returns a named graph
 * @param name The name of the graph
 * @return The named graph
 */
+(MKitModelGraph *)graphNamed:(NSString *)name;


/**
 * Removes a graph
 * @param graph The graph to remove
 */
+(void)removeGraph:(MKitModelGraph *)graph;

#pragma mark -- Multi graph

/**
 * Pushes the current model graph to the top of the stack for the current thread.  Should always pair with pop.
 */
-(void)push;

/**
 * Returns the current model graph for the current thread
 */
+(MKitModelGraph *)current;

/**
 * Pops the current graph for the thread off the stack
 */
+(void)popCurrent;

/**
 * Pops the current graph for the thread off the stack
 */
-(void)pop;

/**
 * Removes the current graph from the system
 */
-(void)remove;

#pragma mark - Persistence

/**
 * Saves all graphs to a file
 * @param file The name of the file to save to
 * @param error The error generated, if any
 * @return YES if succesful, NO if not.
 */
+(BOOL)saveAllToFile:(NSString *)file error:(NSError **)error;

/**
 * Loads the graph from a binary plist.
 * @param file The name of the file to load from
 * @param error The error generated, if any
 * @return YES if succesful, NO if not.
 */
+(BOOL)loadAllFromFile:(NSString *)file error:(NSError **)error;

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

/**
 * Imports a binary plist into the current graph
 * @param file The name of the file to import from
 * @param error The error generated, if any
 * @return YES if successful, NO if not.
 */
-(BOOL)importFromFile:(NSString *)file error:(NSError **)error;


#pragma mark - Model Management

/**
 * Clears all graphs
 */
+(void)clearAllGraphs;

/**
 * Clears the current graph
 */
-(void)clear;

/**
 * Adds the model to the graph
 * @param model The model to add
 */
-(void)addToGraph:(MKitModel *)model;

/**
 * Removes the model from any graphs
 * @param model The model to remove
 */
+(void)removeFromAnyGraph:(MKitModel *)model;

/**
 * Removes the model from the graph
 * @param model The model to remove
 * @result YES if removed, NO if not.
 */
-(BOOL)removeFromGraph:(MKitModel *)model;

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

#pragma mark - Querying

/**
 * Queries the graph for models of a specific class matching a supplied predicate.
 * @param predicate The predicate to filter with
 * @param modelClass The model class to filter on
 * @return An array of models filtered with the predicate
 */
-(NSArray *)queryWithPredicate:(NSPredicate *)predicate forClass:(Class)modelClass;

@end
