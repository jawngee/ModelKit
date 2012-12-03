//
//  MKitDefs.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#ifndef ModelKit_MKitDefs_h
#define ModelKit_MKitDefs_h

#pragma mark - Block Defs

typedef void (^MKitBooleanResultBlock)(BOOL succeeded, NSError *error);
typedef void (^MKitArrayResultBlock)(NSArray *objects, NSError *error);
typedef void (^MKitObjectResultBlock)(id object, NSError *error);
typedef void (^MKitIntResultBlock)(NSInteger result, NSError *error);
typedef void (^MKitProgressBlock)(float progress);
typedef void (^MKitServiceResultBlock)(BOOL succeeded, NSError *error, id result);


#endif
