//
//  MKitParseFile.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/7/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceFile.h"

/**
 * Parse implementation of MKitServiceFile
 */
@interface MKitParseFile : MKitServiceFile

/**
 * Returns a representation of the file as Parse "pointer".
 * @return Dictionary of pointer rep
 */
-(NSDictionary *)parseFilePointer;

@end
