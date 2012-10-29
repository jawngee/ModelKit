//
//  NSDate+CloudObject.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (ModelKit)

/**
 * Returns a date from a supplied ISO8601 formatted string
 * @param iso8601 The string in ISO 8601 format
 * @result The parsed date
 */
+(NSDate *)dateFromISO8601:(NSString *)iso8601;

/**
 * Returns a string formatted to ISO 8601 format from the current date
 * @result The ISO 8601 string
 */
-(NSString *)ISO8601String;

@end
