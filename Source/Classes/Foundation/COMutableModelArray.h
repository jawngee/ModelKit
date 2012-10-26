//
//  COMutableModelArray.h
//  CloudObject
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * This subclass of NSMutableArray is specific to managing an array of models
 * associated with another model.  
 *
 * Since a context retains all models added to it, models stored in a normal
 * NSMutableArray would never be released.  Furthermore, models that implement
 * the CONoContext protocol need to be retained since they aren't stored in
 * the context.
 *
 * Finally, it makes serialization/deserialization way easier.
 */
@interface COMutableModelArray : NSMutableArray
{
@private
    CFMutableArrayRef _array;
}

@end
