//
//  MKitParseModelQuery.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceModelQuery.h"

/**
 * Implements querying via Parse
 */
@interface MKitParseModelQuery : MKitServiceModelQuery

/**
 * Builds the query
 * @return The query
 */
-(id)buildQuery;

@end
