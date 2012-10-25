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
 */
@interface COModel : NSObject

@property (readonly) NSString *modelName;               /**< Name of the model.  If not overridden, class name is used */
@property (assign, nonatomic) COModelState modelState;  /**< The current model state */

// All models have these properties
@property (copy, nonatomic) NSString *objectId;         /**< The object ID */
@property (copy, nonatomic) NSDate *createdAt;          /**< Date created */
@property (copy, nonatomic) NSDate *updatedAt;          /**< Date updated */

/**
 * Flattens the model into a dictionary
 * @result A dictionary containing information about the model plus its properties and their values
 */
-(NSDictionary *)toDictionary;

@end
