//
//  MKitTC0004ModelQueryTestCases.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/11/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitTC0004ModelQueryTestCases.h"
#import "ModelKit.h"

@interface SampleModel : MKitModel

@property (assign, nonatomic) NSInteger intV;

@end

@implementation SampleModel @end

@implementation MKitTC0004ModelQueryTestCases

-(void)setUp
{
    for(int i=1; i<=100; i++)
    {
        SampleModel *sm=[SampleModel instanceWithObjectId:[NSString stringWithFormat:@"%d",i]];
        sm.intV=i;
    }
}

-(void)tearDown
{
    [MKitModelGraph clearAllGraphs];
}

-(void)test0001QueryOrderByIntV
{
    MKitModelQuery *q=[SampleModel query];
    [q orderBy:@"intV" direction:orderDESC];
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    for(int i=100; i>=1; i--)
    {
        SampleModel *sm=[results objectAtIndex:100-i];
        STAssertTrue(sm.intV==i, @"Sort order is incorrect.");
    }
    
    q=[SampleModel query];
    [q orderBy:@"intV" direction:orderASC];
    results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    for(int i=1; i<=100; i++)
    {
        SampleModel *sm=[results objectAtIndex:i-1];
        STAssertTrue(sm.intV==i, @"Sort order is incorrect.");
    }
}

-(void)test0001QueryOrderByCreatedAt
{
    MKitModelQuery *q=[SampleModel query];
    [q orderBy:@"createdAt" direction:orderDESC];
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    for(int i=100; i>=1; i--)
    {
        SampleModel *sm=[results objectAtIndex:100-i];
        STAssertTrue(sm.intV==i, @"Sort order is incorrect.");
    }
    
    q=[SampleModel query];
    [q orderBy:@"createdAt" direction:orderASC];
    results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    for(int i=1; i<=100; i++)
    {
        SampleModel *sm=[results objectAtIndex:i-1];
        STAssertTrue(sm.intV==i, @"Sort order is incorrect.");
    }
}

-(void)test0001QueryEquals
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyEquals value:@75];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==1, @"Results count is incorrect.");
    
    SampleModel *sm=[results objectAtIndex:0];
    STAssertTrue(sm.intV==75, @"Incorrect query result.");
}

-(void)test0001QueryNotEqual
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyNotEqual value:@75];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==99, @"Results count is incorrect.");
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SampleModel *sm=(SampleModel *)obj;
        STAssertTrue(sm.intV!=75, @"Incorrect query results.");
    }];
}

-(void)test0001QueryGreaterThanEqual
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyGreaterThanEqual value:@50];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==51, @"Results count is incorrect.");
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SampleModel *sm=(SampleModel *)obj;
        STAssertTrue(sm.intV>=50, @"Incorrect query results.");
    }];
}

-(void)test0001QueryGreaterThan
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyGreaterThan value:@50];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==50, @"Results count is incorrect.");
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SampleModel *sm=(SampleModel *)obj;
        STAssertTrue(sm.intV>50, @"Incorrect query results.");
    }];
}

-(void)test0001QueryLessThan
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyLessThan value:@50];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==49, @"Results count is incorrect.");
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SampleModel *sm=(SampleModel *)obj;
        STAssertTrue(sm.intV<50, @"Incorrect query results.");
    }];
}


-(void)test0001QueryLessThanEqual
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyLessThanEqual value:@50];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==50, @"Results count is incorrect.");
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SampleModel *sm=(SampleModel *)obj;
        STAssertTrue(sm.intV<=50, @"Incorrect query results.");
    }];
}


-(void)test0001QueryIn
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyIn value:@[@5,@10,@15,@20]];
    [q orderBy:@"intV" direction:orderASC];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==4, @"Results count is incorrect.");
 
    SampleModel *sm=[results objectAtIndex:0];
    STAssertTrue(sm.intV==5, @"Incorrect results.");
    
    sm=[results objectAtIndex:1];
    STAssertTrue(sm.intV==10, @"Incorrect results.");
    
    sm=[results objectAtIndex:2];
    STAssertTrue(sm.intV==15, @"Incorrect results.");
    
    sm=[results objectAtIndex:3];
    STAssertTrue(sm.intV==20, @"Incorrect results.");
}

-(void)test0001QueryNotIn
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyNotIn value:@[@5,@10,@15,@20]];
    [q orderBy:@"intV" direction:orderASC];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==96, @"Results count is incorrect.");
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SampleModel *sm=obj;
        STAssertTrue(((sm.intV!=5) && (sm.intV!=10) && (sm.intV!=15) && (sm.intV!=20)), @"Incorrect results");
    }];
}

-(void)test0001QueryWithin
{
    MKitModelQuery *q=[SampleModel query];
    [q key:@"intV" condition:KeyNotIn value:@[@5,@10,@15,@20]];
    [q orderBy:@"intV" direction:orderASC];
    
    NSArray *results=[[q execute:nil] objectForKey:MKitQueryResultKey];
    
    STAssertTrue(results.count==96, @"Results count is incorrect.");
    
    [results enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SampleModel *sm=obj;
        STAssertTrue(((sm.intV!=5) && (sm.intV!=10) && (sm.intV!=15) && (sm.intV!=20)), @"Incorrect results");
    }];
}

//KeyWithin,
//KeyExists,
//KeyNotExist,
//KeyBeginsWith,
//KeyEndsWith,
//KeyLike,
//KeyWithinDistance

@end
