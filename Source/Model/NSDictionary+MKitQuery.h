//
//  NSDictionary+MKitQuery.h
//  Aspekt
//
//  Created by Jon Gilkison on 6/12/13.
//  Copyright (c) 2013 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * Provides convenience methods for dealing with the query results dictionary.
 */
@interface NSDictionary (MKitQuery)

/**
 * @return Returns the query results array
 */
-(NSArray *)queryResults;

/**
 * @return Retuns the query count, which may be different than the number of items
 * in the result
 */
-(NSInteger)queryCount;

@end
