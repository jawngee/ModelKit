//
//  MKitModel.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#pragma mark - Block Defs

typedef void (^MKitBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^MKitArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^MKitObjectResultBlock)(id object, NSError *error);

#pragma mark - Typedefs

/** Model state enumeration */
typedef enum
{
    ModelStateNew,          /**< Model is in a new state */
    ModelStateValid,        /**< Model is valid */
    ModelStateNeedsData,    /**< Model has an ID but has not been fetched */
    ModelStateDirty,        /**< Model is dirty and needs saving */
    ModelStateDeleted       /**< Model has been marked for delete or deleted */
} MKitModelState;

#pragma mark - Notifications

/** Model state has changed */
extern NSString *const MKitModelStateChangedNotification;

/** Model has gained an identifier */
extern NSString *const MKitObjectIdentifierChangedNotification;

/** Model's internal ID has changed */
extern NSString *const MKitModelIdentifierChangedNotification;

/** 
 * A model property has changed.  The notification's userinfo property contains
 * the keyPath and changes unless beginChanges/endChanges were called.  In that
 * case userinfo will be nil.
 */
extern NSString *const MKitModelPropertyChangedNotification;

#pragma mark - Protocols

/** Models that should not be added to the context should "implement" this */
@protocol MKitNoContext @end

#pragma mark - MKitModel

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
 *
 * For very large heirarchies, you might want to skip the context.  In that case
 * implement the MKitNoContext protocol to mark your model as a non participant.
 */
@interface MKitModel : NSObject<NSCoding>
{
@private
    BOOL _changing;
    BOOL _hasChanged;
}

@property (retain, nonatomic) NSString *modelId;            /**< Used internally */
@property (readonly) NSString *modelName;                   /**< Name of the model.  If not overridden, class name is used */
@property (assign, nonatomic) MKitModelState modelState;    /**< The current model state */

// All models have these properties
@property (copy, nonatomic) NSString *objectId;         /**< The object ID - Application specific */
@property (copy, nonatomic) NSDate *createdAt;          /**< Date created */
@property (copy, nonatomic) NSDate *updatedAt;          /**< Date updated */

/**
 * Creates an empty instance of the class
 * @return A new empty instance
 */
+(id)instance;

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
+(id)instanceWithSerializedData:(id)data;


/**
 * Creates a new instance with the contents of a dictionary.  If the dictionary
 * contains an objectId, the context is checked first and if an object of the
 * same class and id exists, refreshes that object's data with the dictionary.
 * @param dictionary The dictionary of data to build the model from
 * @param fromJSON Tells us if the dictionary of data is from a JSON string
 */
+(id)instanceWithSerializedData:(id)data fromJSON:(BOOL)fromJSON;

/**
 * Creates a new instance with the contents of a JSON string.  If the JSON
 * contains an objectId, the context is checked first and if an object of the
 * same class and id exists, refreshes that object's data with the contents of
 * the JSON.
 * @param JSONString The JSONString to build the model from
 */
+(id)instanceWithJSON:(NSString *)JSONString;


/**
 * Adds the object to the context.  This is done automatically, but for models
 * conforming to MKitNoContext protocol, you'll have to call this if you want to
 * add them.
 */
-(void)addToContext;

/**
 * Removes an object from a context.  If you call delete, you do not need to
 * call this.
 */
-(void)removeFromContext;

/**
 * Suspend notifications when properties are changed.
 */
-(void)beginChanges;

/**
 * Resumes notifications when properties are changed.
 */
-(void)endChanges;

/**
 * Flattens the model into a dictionary or array.  If the serialized object contains model properties
 * or an array of models, this method returns an array containing all of the objects.  The first object
 * of the array is the model being serialized.
 * Note this dictionary cannot be stored to plist due to use of NSNull.
 * @result A dictionary containing information about the model plus its properties and their values
 */
-(id)serialize;

/**
 * Loads properties from a dictionary.
 * @param dictionary The dictionary to load values from
 */
-(void)deserialize:(id)data;

/**
 * Serializes the model to JSON
 * @return The serialized model as a JSON string.
 */
-(NSString *)serializeToJSON;

/**
 * Deserializes the model from JSON
 * @param jsonString The JSON string to deserialize form.
 */
-(void)deserializeFromJSON:(NSString *)jsonString;

@end
