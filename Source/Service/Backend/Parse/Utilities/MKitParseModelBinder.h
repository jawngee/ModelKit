//
//  MKitParseModelBinder.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitModel.h"

/**
 * Utility class to bind incoming parse data to models.
 */
@interface MKitParseModelBinder : NSObject


/**
 * Binds a model to the data in a given dictionary
 * @param model The model to bind
 * @param data The data to bind to
 */
+(void)bindModel:(MKitModel *)model data:(NSDictionary *)data;

/**
 * Converts an array of parse models into ModelKit models.
 * @param models Array of dicitionaries of parse model data
 * @param modelClass The Class for the models to create
 * @return The converted array of models
 */
+(NSArray *)bindArrayOfModels:(NSArray *)models forClass:(Class)modelClass;

/**
 * This method will take the array result from a parse service
 * call and map/create any models in the response.
 * @param array The result of the cloud function
 * @return The processed array.
 */
+(NSMutableArray *)processParseArray:(NSMutableArray *)array;

/**
 * This method will take the dictionary result from a parse service
 * call and map/create any models in the response.
 * @param dictionary The result of the cloud function
 * @return The processed dictionary.
 */
+(NSDictionary *)processParseDictionary:(NSDictionary *)dictionary;

/**
 * This method will take the dictionary or array result from a parse service
 * call and map/create any models in the response.
 * @param result The result of the cloud function
 * @return The processed result.
 */
+(id)processParseResult:(id)result;

/**
 * This method will take the parameters to send to a parse cloud function
 * and insure it's the format that Parse anticipates.
 * @param array The array of parameters
 * @return The prepared array.
 */
+(NSMutableArray *)prepareParseParametersArray:(NSArray *)array;

/**
 * This method will take the parameters to send to a parse cloud function
 * and insure it's the format that Parse anticipates.
 * @param dictionary The dictionary of parameters
 * @return The prepared dictionary.
 */
+(NSDictionary *)prepareParseParametersDictionary:(NSDictionary *)dictionary;

/**
 * This method will take the parameters to send to a parse cloud function
 * and insure it's the format that Parse anticipates.
 * @param parameters The parameters, either an array or a dictionary
 * @return The prepared parameters
 */
+(id)prepareParseParameters:(id)parameters;

@end
