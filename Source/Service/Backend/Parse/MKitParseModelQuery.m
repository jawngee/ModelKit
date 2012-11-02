//
//  MKitParseModelQuery.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseModelQuery.h"
#import "NSDate+ModelKit.h"
#import "MKitModel+Parse.h"
#import "MKitMutableModelArray+Parse.h"
#import "JSONKit.h"
#import "MKitParseModelBinder.h"

@interface MKitParseModelQuery(Internal)

-(AFHTTPRequestOperation *)buildQueryOpWithLimit:(NSInteger)limit skip:(NSInteger)skip includeCount:(BOOL)includeCount;

@end

@implementation MKitParseModelQuery

-(AFHTTPRequestOperation *)buildQueryOpWithLimit:(NSInteger)limit skip:(NSInteger)skip includeCount:(BOOL)includeCount
{
    NSMutableDictionary *params=[NSMutableDictionary dictionary];
    
    if (limit!=NSNotFound)
        [params setObject:@(limit) forKey:@"limit"];
    
    if (skip!=NSNotFound)
        [params setObject:@(skip) forKey:@"skip"];
    
    if (includeCount)
        [params setObject:@(1) forKey:@"count"];
    
    NSMutableDictionary *query=[NSMutableDictionary dictionary];
    for(NSDictionary *c in conditions)
    {
        id val=c[@"value"];
        
        if ([[val class] isSubclassOfClass:[MKitModel class]])
            val=[((MKitModel *) val) parsePointer];
        else if ([[val class] isSubclassOfClass:[MKitMutableModelArray class]])
        {
            NSMutableArray *toSave=nil;
            val=[((MKitMutableModelArray *) val) parsePointerArray:&toSave];
        }
        else if ([[val class] isSubclassOfClass:[NSDate class]])
            val=@{@"__type":@"Date",@"iso":[((NSDate *) val) ISO8601String]};
        
        switch ([c[@"condition"] integerValue])
        {
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
                [query setObject:@{@"$in":val} forKey:c[@"key"]];
                break;
            case KeyNotIn:
                [query setObject:@{@"$nin":val} forKey:c[@"key"]];
                break;
            case KeyExists:
                [query setObject:@{@"$exists":@(YES)} forKey:c[@"key"]];
                break;
            case KeyNotExist:
                [query setObject:@{@"$exists":@(NO)} forKey:c[@"key"]];
                break;
        }
    }
    
    if (query.count>0)
        [params setObject:[query JSONString] forKey:@"where"];
    
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
    
    return [manager classRequestWithMethod:@"GET" class:modelClass params:((params.count>0) ? params : nil) body:nil];
}

-(NSDictionary *)executeWithLimit:(NSInteger)limit skip:(NSInteger)skip error:(NSError **)error
{
    AFHTTPRequestOperation *op=[self buildQueryOpWithLimit:limit skip:skip includeCount:YES];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        id data=[op.responseString objectFromJSONString];
        return @{
            MKitQueryItemCountKey:data[@"count"],
            MKitQueryResultKey:[MKitParseModelBinder bindArrayOfModels:[data objectForKey:@"results"] forClass:modelClass]
        };
    }
    
    if (error)
        *error=op.error;
    
    return nil;
}


-(NSInteger)count:(NSError **)error
{
    AFHTTPRequestOperation *op=[self buildQueryOpWithLimit:0 skip:NSNotFound includeCount:YES];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        id data=[op.responseString objectFromJSONString];
        return [data[@"count"] integerValue];
    }
    
    if (error)
        *error=op.error;
    
    return 0;
}

@end
