//
//  MKitMutableModelArray+Parse.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/31/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitMutableModelArray.h"

/**
 * Helper methods for dealing with MKitMutableModelArray and Parse
 */
@interface MKitMutableModelArray (Parse)

/**
 * Converts the array to an array of Parse pointer types.  Models that
 * can't be converted (they have no objectId assigned by Parse) are placed
 * into the modelsToSave array.
 * @param modelsToSave The array to store the models to save.
 * @return An array of parse pointer types
 */
-(NSArray *)parsePointerArray:(NSMutableArray **)modelsToSave;

@end
