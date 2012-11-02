//
//  MKitModelPredicateQuery.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/2/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModelPredicateQuery.h"
#import "MKitModelContext.h"

/**
 * Internal
 */
@interface MKitModelPredicateQuery(Internal)

/**
 * Builds the query
 * @return The query predicate
 */
-(NSPredicate *)buildQuery;

@end

@implementation MKitModelPredicateQuery

-(NSPredicate *)buildQuery
{
    NSMutableArray *predicates=[NSMutableArray array];
    
    for(NSDictionary *c in conditions)
    {
        id val=c[@"value"];
        id val2=c[@"value2"];
        
        switch ([c[@"condition"] integerValue])
        {
            case KeyEquals:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ == %%@",c[@"key"]],val]];
                break;
            case KeyNotEqual:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ != %%@",c[@"key"]],val]];
                break;
            case KeyGreaterThanEqual:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ >= %%@",c[@"key"]],val]];
                break;
            case KeyGreaterThan:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ > %%@",c[@"key"]],val]];
                break;
            case KeyLessThan:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ < %%@",c[@"key"]],val]];
                break;
            case KeyLessThanEqual:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ <= %%@",c[@"key"]],val]];
                break;
            case KeyIn:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ IN %%@",c[@"key"]],val]];
                break;
            case KeyNotIn:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"NONE %@ IN %%@",c[@"key"]],val]];
                break;
            case KeyExists:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ != NIL",c[@"key"]]]];
                break;
            case KeyNotExist:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ == NIL",c[@"key"]]]];
                break;
            case KeyWithin:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ >= %%@ AND %@ <= %%@",c[@"key"],c[@"key"]],val,val2]];
                break;
            case KeyBeginsWith:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ BEGINSWITH[cd] %%@",c[@"key"]],val]];
                break;
            case KeyEndsWith:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ ENDSWITH[cd] %%@",c[@"key"]],val]];
                break;
            case KeyLike:
                [predicates addObject:[NSPredicate predicateWithFormat:[NSString stringWithFormat:@"%@ LIKE[cd] *%%@*",c[@"key"]],val]];
                break;
            default:
                break;
        }
    }

    return [NSCompoundPredicate andPredicateWithSubpredicates:predicates];
}

-(NSDictionary *)executeWithLimit:(NSInteger)limit skip:(NSInteger)skip error:(NSError **)error
{
    NSPredicate *predicate=[self buildQuery];
    
    NSArray *results=[[MKitModelContext current] queryWithPredicate:predicate forClass:modelClass];
    
    return @{
        MKitQueryItemCountKey:@(results.count),
        MKitQueryResultKey:results
    };
}

-(NSInteger)count:(NSError **)error
{
    return [[[self executeWithLimit:NSNotFound skip:NSNotFound error:error] objectForKey:MKitQueryItemCountKey] integerValue];
}

@end
