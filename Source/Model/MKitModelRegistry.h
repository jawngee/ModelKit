//
//  MKitModelRegistry.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Registers a model's name with its class for mapping.  MKitModel automatically does this for you
 * if you override the modelName property with your own.
 */
@interface MKitModelRegistry : NSObject

/**
 * Registers a model's class name for its class
 * @param modelName The name of the model
 * @param class The class to map to
 */
+(void)registerModel:(NSString *)modelName forClass:(Class)objclass;

/**
 * Retrieves the registered class for a given model
 * @param modelName The name of the model to retrieve
 * @return The Class for the given model name, nil if not found.
 */
+(Class)registeredClassForModel:(NSString *)modelName;

@end
