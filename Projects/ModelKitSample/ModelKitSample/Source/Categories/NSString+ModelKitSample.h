//
//  NSString+ModelKitSample.h
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (ModelKitSample)


/**
 * Returns the user's document folder path with the optional
 * subfolder
 */
+(NSString *)fileNameInDocumentPath:(NSString *)filename;

@end
