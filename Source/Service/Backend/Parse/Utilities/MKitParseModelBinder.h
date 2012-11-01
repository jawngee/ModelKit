//
//  MKitParseModelBinder.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitModel.h"

@interface MKitParseModelBinder : NSObject


/**
 * Binds a model to the data in a given dictionary
 * @param model The model to bind
 * @param data The data to bind to
 */
+(void)bindModel:(MKitModel *)model data:(NSDictionary *)data;

+(NSArray *)bindArrayOfModels:(NSArray *)models forClass:(Class)modelClass;

@end
