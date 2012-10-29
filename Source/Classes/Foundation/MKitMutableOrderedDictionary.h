//
//  MKitMutableOrderedDictionary.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * A dictionary whose keys are kept in the same order in which they are added
 */
@interface MKitMutableOrderedDictionary : NSMutableDictionary
{
@private
    CFMutableDictionaryRef _dictionary;
    NSMutableArray *_orderedKeyArray;
}

@end
