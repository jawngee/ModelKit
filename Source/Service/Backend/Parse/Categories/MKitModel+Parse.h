//
//  MKitModel+Parse.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/31/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"

/**
 * Helper methods for dealing with models and Parse
 */
@interface MKitModel (Parse)

/**
 * Returns Parse's pointer type.
 * @return The model as a dictionary in Parse's Pointer format.
 */
-(NSDictionary *)parsePointer;

@end
