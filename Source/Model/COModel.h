//
//  COModel.h
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

/** Model state enumeration */
typedef enum
{
    ModelStateNew,      /**< Model is in a new state */
    ModelStateValid,    /**< Model is valid */
    ModelStateUnknown,  /**< Model has an ID but has not been fetched */
    ModelStateDirty,    /**< Model is dirty and needs saving */
    ModelStateDeleted   /**< Model has been marked for delete or deleted */
} COModelState;

/**
 * Base model.
 *
 * This model will save/load its properties automatically.  By convention
 * any property prefixed with 'model' is not persisted.
 *
 * All models are stored within a context which has one important side
 * effect you must be aware of: they will never be released or autoreleased
 * unless you explicitly remove them by calling their remove method.
 *
 * The context is sort of like a global storage for models so that your
 * application isn't littered with different instances of the same object.
 */
@interface COModel : NSObject

@property (readonly) NSString *modelName;               /**< Name of the model.  If not overridden, class name is used */
@property (assign, nonatomic) COModelState modelState;  /**< The current model state */

// All models have these properties
@property (copy, nonatomic) NSString *objectId;         /**< The object ID */
@property (copy, nonatomic) NSDate *createdAt;          /**< Date created */
@property (copy, nonatomic) NSDate *updatedAt;          /**< Date updated */

/**
 * Creates an instance with the given object id, but first checks the context for
 * an existing model of the same class and matching id, returning that if it exists.
 * @param objId The object id
 */
+(id)instanceWithId:(NSString *)objId;

/**
 * Creates a new instance with the contents of a dictionary.  If the dictionary
 * contains an objectId, the context is checked first and if an object of the
 * same class and id exists, refreshes that object's data with the dictionary.
 * @param dictionary The dictionary of data to build the model from
 */
+(id)instanceWithDictionary:(NSDictionary *)dictionary;

/**
 * Removes an object from a context.  If you call delete, you do not need to
 * call this.
 */
-(void)remove;

/**
 * Flattens the model into a dictionary
 * @result A dictionary containing information about the model plus its properties and their values
 */
-(NSDictionary *)toDictionary;

/**
 * Loads properties from a dictionary.
 * @param dictionary The dictionary to load values from
 */
-(void)fromDictionary:(NSDictionary *)dictionary;

@end
