//
//  MKitReflectionManager.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MKitReflectedClass;

/**
 * Manages the cache for class reflections to avoid repeated runtime introspection
 */
@interface MKitReflectionManager : NSObject

/**
 * Retrieves the cached reflection for a class.  If non exists, it will create one.
 * @param class The class to retrieve the reflection for.
 * @param ignorePropPrefix The property prefix to ignore when reflecting the class's properties
 * @param topclass The reflection will recurse up the class hiearachy until it hits this class.  If nil, NSObject is topclass
 * @return The reflected class
 */
+(MKitReflectedClass *)reflectionForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix ignoreProperties:(NSArray *)ignoredProps recurseChainUntil:(Class)topclass;

@end
