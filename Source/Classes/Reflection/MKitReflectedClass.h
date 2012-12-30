//
//  MKitReflectedClass.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitMutableOrderedDictionary.h"

/**
 * Wraps the runtime reflection of a given class
 */
@interface MKitReflectedClass : NSObject
{
    MKitMutableOrderedDictionary *properties;    /**< Dictionary of MKitReflectedProperty objects for each property */
}

@property (readonly) MKitMutableOrderedDictionary *properties;   /**< Dictionary of MKitReflectedProperty objects for each property */


/**
 * Creates a new instance, performing reflection on the supplied class.
 * @param class The class to retrieve the reflection for.
 * @param ignorePropPrefix The property prefix to ignore when reflecting the class's properties
 * @param topclass The reflection will recurse up the class hiearachy until it hits this class.  If nil, NSObject is topclass
 * @return The new instance
 */
-(id)initWithClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix ignoreProperties:(NSArray *)ignoredProps recurseChainUntil:(Class)topclass;


/**
 * Creates a new runtime reflection of the supplied class.
 * @param class The class to retrieve the reflection for.
 * @param ignorePropPrefix The property prefix to ignore when reflecting the class's properties
 * @param topclass The reflection will recurse up the class hiearachy until it hits this class.  If nil, NSObject is topclass
 * @return The reflected class
 */
+(id)reflectionForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix ignoreProperties:(NSArray *)ignoredProps recurseChainUntil:(Class)topclass;

@end
