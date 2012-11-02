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

@end
