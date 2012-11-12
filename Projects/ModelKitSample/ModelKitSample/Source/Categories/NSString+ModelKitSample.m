//
//  NSString+ModelKitSample.m
//  ModelKitSample
//
//  Created by Jon Gilkison on 11/3/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "NSString+ModelKitSample.h"

@implementation NSString (ModelKitSample)

+(NSString *)fileNameInDocumentPath:(NSString *)filename
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0]; // Get documents folder
    
    return [documentsDirectory stringByAppendingPathComponent:filename];
}


@end
