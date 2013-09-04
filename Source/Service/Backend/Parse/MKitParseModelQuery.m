//
//  MKitParseModelQuery.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitDefs.h"
#import "MKitParseServiceManager.h"
#import "MKitParseModelQuery.h"
#import "NSDate+ModelKit.h"
#import "MKitModel+Parse.h"
#import "MKitMutableModelArray+Parse.h"
#import "JSONKit.h"
#import "MKitParseModelBinder.h"
#import "MKitGeoPoint.h"
#import "MKitGeoPoint+Parse.h"

/**
 * Internal methods
 */
@interface MKitParseModelQuery(Internal)

/**
 * Builds the HTTP Request for the query
 * @param limit The limit to the number of items the request should return, NSNotFound for no limit
 * @param skip The number of items to skip when returning results, NSNotFound for no skip
 * @param includeCount Determines if the total object count should be returned from the request
 * @return The HTTP Request
 */
-(AFHTTPRequestOperation *)buildQueryOpWithLimit:(NSInteger)limit skip:(NSInteger)skip includeCount:(BOOL)includeCount;

@end

@implementation MKitParseModelQuery

-(id)buildQuery
{
    NSMutableArray *builtSubqueries=[NSMutableArray array];
    
    for(MKitParseModelQuery *sq in subqueries)
    {
        [builtSubqueries addObject:[sq buildQuery]];
    }
    
    NSMutableDictionary *query=[NSMutableDictionary dictionary];
    for(NSDictionary *c in conditions)
    {
        id val=c[@"value"];
        id val2=c[@"value2"];
        
        if ([[val class] isSubclassOfClass:[MKitModel class]])
            val=[((MKitModel *) val) parsePointer];
        else if ([[val class] isSubclassOfClass:[MKitMutableModelArray class]])
        {
            NSMutableArray *toSave=nil;
            val=[((MKitMutableModelArray *) val) parsePointerArray:&toSave];
        }
        else if ([[val class] isSubclassOfClass:[NSDate class]])
            val=@{@"__type":@"Date",@"iso":[((NSDate *) val) ISO8601String]};
        
        if ([[val2 class] isSubclassOfClass:[NSDate class]])
            val2=@{@"__type":@"Date",@"iso":[((NSDate *) val) ISO8601String]};
        
        MKitGeoPoint *geoPoint=nil;
        double distance=0.0;
        
        NSMutableArray *newVals=[NSMutableArray array];
        
        switch ([c[@"condition"] integerValue])
        {
            case KeyContains:
            case KeyEquals:
                [query setObject:val forKey:c[@"key"]];
                break;
            case KeyNotEqual:
                [query setObject:@{@"$ne":val} forKey:c[@"key"]];
                break;
            case KeyGreaterThanEqual:
                [query setObject:@{@"$gte":val} forKey:c[@"key"]];
                break;
            case KeyGreaterThan:
                [query setObject:@{@"$gt":val} forKey:c[@"key"]];
                break;
            case KeyLessThan:
                [query setObject:@{@"$lt":val} forKey:c[@"key"]];
                break;
            case KeyLessThanEqual:
                [query setObject:@{@"$lte":val} forKey:c[@"key"]];
                break;
            case KeyIn:
                if ([val isKindOfClass:[NSArray class]])
                {
                    [newVals removeAllObjects];
                    [((NSArray *)val) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([[obj class] isSubclassOfClass:[MKitModel class]])
                            obj=[((MKitModel *) obj) parsePointer];
                        
                        [newVals addObject:obj];
                    }];
                    
                    val=[[newVals copy] autorelease];
                }
                
                [query setObject:@{@"$in":val} forKey:c[@"key"]];
                break;
            case KeyNotIn:
                if ([val isKindOfClass:[NSArray class]])
                {
                    [newVals removeAllObjects];
                    [((NSArray *)val) enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        if ([[obj class] isSubclassOfClass:[MKitModel class]])
                            obj=[((MKitModel *) obj) parsePointer];
                        
                        [newVals addObject:obj];
                    }];
                    
                    val=[[newVals copy] autorelease];
                }
                
                [query setObject:@{@"$nin":val} forKey:c[@"key"]];
                break;
            case KeyExists:
                [query setObject:@{@"$exists":@(YES)} forKey:c[@"key"]];
                break;
            case KeyNotExist:
                [query setObject:@{@"$exists":@(NO)} forKey:c[@"key"]];
                break;
            case KeyWithin:
                [query setObject:@{@"$gte":val,@"$lte":val2} forKey:c[@"key"]];
                break;
            case KeyBeginsWith:
                [query setObject:@{@"$regex":[NSString stringWithFormat:@"^%@",val],@"$options":@"im"} forKey:c[@"key"]];
                break;
            case KeyEndsWith:
                [query setObject:@{@"$regex":[NSString stringWithFormat:@"%@$",val],@"$options":@"im"} forKey:c[@"key"]];
                break;
            case KeyLike:
                [query setObject:@{@"$regex":val,@"$options":@"im"} forKey:c[@"key"]];
                break;
            case KeyWithinDistance:
                geoPoint=[val objectForKey:@"point"];
                distance=[[val objectForKey:@"distance"] doubleValue];
                
                [query setObject:@{@"$nearSphere":[geoPoint parsePointer],@"$maxDistanceInKilometers":@(distance)} forKey:c[@"key"]];
                break;
            case KeyContainsAll:
                if (![((NSObject *)val) isKindOfClass:[NSArray class]])
                    [NSException raise:@"Value must be array" format:@"KeyContainsAll value must be an array."];
                
                [query setObject:@{@"$all":val} forKey:c[@"key"]];
                break;
            default:
                break;
        }
    }
    
    if (builtSubqueries.count>0)
    {
        [builtSubqueries addObject:query];
        return builtSubqueries;
    }
    
    return query;
}

-(AFHTTPRequestOperation *)buildQueryOpWithLimit:(NSInteger)limit skip:(NSInteger)skip includeCount:(BOOL)includeCount
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    
    if (limit!=NSNotFound)
        [params setObject:@(limit) forKey:@"limit"];
    
    if (skip!=NSNotFound)
        [params setObject:@(skip) forKey:@"skip"];
    
    if (includeCount)
        [params setObject:@(1) forKey:@"count"];
    
    id query=[self buildQuery];
    
    if ([[query class] isSubclassOfClass:[NSArray class]])
    {
        [params setObject:[@{@"$or":query} JSONString] forKey:@"where"];
    }
    else
    {
        if ([query allKeys].count>0)
            [params setObject:[query JSONString] forKey:@"where"];
    }
    
    NSMutableArray *ordering=[NSMutableArray array];
    for(NSDictionary *o in orders)
    {
        if ([o[@"dir"] integerValue]==orderASC)
            [ordering addObject:o[@"key"]];
        else
            [ordering addObject:[NSString stringWithFormat:@"-%@",o[@"key"]]];
    }
    
    if (ordering.count>0)
        [params setObject:[ordering componentsJoinedByString:@","] forKey:@"order"];
    
    if (includes.count>0)
        [params setObject:[includes componentsJoinedByString:@","] forKey:@"include"];
    
    NSLog(@"%@",params);
    
    return [manager classRequestWithMethod:@"GET" class:modelClass params:((params.count>0) ? params : nil) body:nil];
}

-(NSDictionary *)executeWithLimit:(NSInteger)limit skip:(NSInteger)skip error:(NSError **)error
{
    if (!manager.reachable)
    {
        *error=[NSError errorWithDomain:MKitParseErrorDomain code:666 description:@"Parse is not currently reachable" recoverySuggestion:@"Check your internet connection."];
        
        return nil;
    }
    
    AFHTTPRequestOperation *op=[self buildQueryOpWithLimit:limit skip:skip includeCount:YES];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        id data=[op.responseString objectFromJSONString];
        return @{
            MKitQueryItemCountKey:data[@"count"],
            MKitQueryResultKey:(data==nil) ? @[] : [MKitParseModelBinder bindArrayOfModels:[data objectForKey:@"results"] forClass:modelClass]
        };
    }
    
    if (error)
        *error=op.error;
    
    return nil;
}


-(NSInteger)count:(NSError **)error
{
    if (!manager.reachable)
    {
        if (error!=nil)
            *error=[NSError errorWithDomain:MKitParseErrorDomain code:666 description:@"Parse is not currently reachable" recoverySuggestion:@"Check your internet connection."];
        
        return 0;
    }
    
    AFHTTPRequestOperation *op=[self buildQueryOpWithLimit:0 skip:NSNotFound includeCount:YES];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        id data=[op.responseString objectFromJSONString];
        return [data[@"count"] integerValue];
    }
    
    if ((error!=nil) && (op.error))
        *error=op.error;
    
    return 0;
}

@end
