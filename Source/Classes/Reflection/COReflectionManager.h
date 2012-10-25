//
//  COReflectionManager.h
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class COReflectedClass;

/**
 * Manages the cache for class reflections to avoid repeated runtime introspection
 */
@interface COReflectionManager : NSObject

/**
 * Retrieves the cached reflection for a class.  If non exists, it will create one.
 * @param class The class to retrieve the reflection for.
 * @param ignorePropPrefix The property prefix to ignore when reflecting the class's properties
 * @param topclass The reflection will recurse up the class hiearachy until it hits this class.  If nil, NSObject is topclass
 * @return The reflected class
 */
+(COReflectedClass *)reflectionForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix recurseChainUntil:(Class)topclass;

@end
