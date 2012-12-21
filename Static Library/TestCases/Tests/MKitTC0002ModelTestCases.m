//
//  ModelTestCases.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/28/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitTC0002ModelTestCases.h"
#import "TestModel.h"

@implementation MKitTC0002ModelTestCases

-(TestModel *)makeModelWithId:(NSString *)modelId
{
    TestModel *m1=[TestModel instanceWithObjectId:modelId];
    
    m1.stringV=modelId;
    m1.shortV=192;
    m1.intV=32456;
    m1.boolV=YES;
    m1.floatV=0.66f;
    m1.doubleV=10.233;
    m1.stringV=@"String Value";
    m1.dateV=[NSDate date];
    
    return m1;
}

-(void)test001SerializeDeserialize
{
    [MKitModelGraph clearAllGraphs];
    
    TestModel *m1=[self makeModelWithId:@"001"];
    TestModel *m2=[self makeModelWithId:@"002"];
    TestModel *m3=[self makeModelWithId:@"003"];
    TestModel *m4=[self makeModelWithId:@"004"];
    
    
    // Note the circular references
    m1.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m1.amodelV=m4;
    
    m2.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m3,m4]];
    m2.amodelV=m1;
    
    m3.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m3.amodelV=m2;
    
    m4.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m4.amodelV=m3;
    
    // Serialize
    id data=[m1 serialize];
    
    // Make sure the graph has been cleared
    [MKitModelGraph clearAllGraphs];
    m1=(TestModel *)[[MKitModelGraph defaultGraph] modelForObjectId:@"001" andClass:[TestModel class]];
    STAssertTrue(m1==nil, @"Graph wasn't cleared.");
    
    // Deserialize
    m1=[TestModel instanceWithSerializedData:data];
    
    // Make sure we have 4 objects in the graph
    STAssertTrue([MKitModelGraph defaultGraph].objectCount==4, @"Graph count mismatch, should be 4.");
    
    m2=[TestModel instanceWithObjectId:@"002"];
    m3=[TestModel instanceWithObjectId:@"003"];
    m4=[TestModel instanceWithObjectId:@"004"];

    
    STAssertTrue(m1.amodelV==m4, @"Model didn't deserialize correctly.");
    STAssertTrue(m2.amodelV==m1, @"Model didn't deserialize correctly.");
    STAssertTrue(m3.amodelV==m2, @"Model didn't deserialize correctly.");
    STAssertTrue(m4.amodelV==m3, @"Model didn't deserialize correctly.");
    STAssertTrue([m1.amodelArrayV indexOfObject:m2]!=NSNotFound, @"Model didn't deserialize correctly.");
}

-(void)test002SerializeDeserializeJSON
{
    [MKitModelGraph clearAllGraphs];
    
    TestModel *m1=[self makeModelWithId:@"001"];
    TestModel *m2=[self makeModelWithId:@"002"];
    TestModel *m3=[self makeModelWithId:@"003"];
    TestModel *m4=[self makeModelWithId:@"004"];
    
    // Note the circular references
    m1.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m1.amodelV=m4;
    
    m2.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m3,m4]];
    m2.amodelV=m1;
    
    m3.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m3.amodelV=m2;
    
    m4.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m4.amodelV=m3;
    
    // Serialize
    NSString *json=[m1 serializeToJSON];
    
    // Make sure the graph has been cleared
    [MKitModelGraph clearAllGraphs];
    m1=(TestModel *)[[MKitModelGraph defaultGraph] modelForObjectId:@"001" andClass:[TestModel class]];
    STAssertTrue(m1==nil, @"Graph wasn't cleared.");
    
    // Deserialize
    m1=[TestModel instanceWithJSON:json];
    
    // Make sure we have 4 objects in the graph
    STAssertTrue([MKitModelGraph defaultGraph].objectCount==4, @"Graph count mismatch, should be 4.");
    
    m2=[TestModel instanceWithObjectId:@"002"];
    m3=[TestModel instanceWithObjectId:@"003"];
    m4=[TestModel instanceWithObjectId:@"004"];
    
    
    STAssertTrue(m1.amodelV==m4, @"Model didn't deserialize correctly.");
    STAssertTrue(m2.amodelV==m1, @"Model didn't deserialize correctly.");
    STAssertTrue(m3.amodelV==m2, @"Model didn't deserialize correctly.");
    STAssertTrue(m4.amodelV==m3, @"Model didn't deserialize correctly.");
    STAssertTrue([m1.amodelArrayV indexOfObject:m2]!=NSNotFound, @"Model didn't deserialize correctly.");
}


-(void)test003PredicateQuery
{
    [MKitModelGraph clearAllGraphs];
    
    TestModel *m1=[self makeModelWithId:@"001"];
    TestModel *m2=[self makeModelWithId:@"002"];
    TestModel *m3=[self makeModelWithId:@"003"];
    TestModel *m4=[self makeModelWithId:@"004"];
    
    // Note the circular references
    m1.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m1.stringV=@"Jon";
    m1.shortV=255;
    m1.boolV=YES;
    m1.amodelV=m4;
    
    m2.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m3,m4]];
    m2.stringV=@"Jon";
    m2.shortV=255;
    m2.boolV=NO;
    m2.amodelV=m1;
    
    m3.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m3.stringV=@"Chan";
    m3.shortV=192;
    m3.boolV=NO;
    m3.amodelV=m1;
    
    m4.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m4.stringV=@"Jasan";
    m4.shortV=192;
    m4.boolV=YES;
    m4.amodelV=m1;
    
    MKitModelQuery *query=[TestModel query];
    [query key:@"shortV" condition:KeyEquals value:@(255)];
    NSArray *results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==2, [NSString stringWithFormat:@"Should have 2 items, has %d",results.count]);
    
    query=[TestModel query];
    [query key:@"amodelV" condition:KeyEquals value:m1];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==3, [NSString stringWithFormat:@"Should have 3 items, has %d",results.count]);

    query=[TestModel query];
    [query key:@"stringV" condition:KeyBeginsWith value:@"Jo"];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==2, [NSString stringWithFormat:@"Should have 2 items, has %d",results.count]);

    query=[TestModel query];
    [query key:@"stringV" condition:KeyEndsWith value:@"an"];
    [query key:@"boolV" condition:KeyEquals value:@(YES)];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==1, [NSString stringWithFormat:@"Should have 1 items, has %d",results.count]);
    
    query=[TestModel query];
    results=[[query execute:nil] objectForKey:MKitQueryResultKey];
    STAssertTrue(results.count==4, [NSString stringWithFormat:@"Should have 4 items, has %d",results.count]);
    
}

-(void)test004SavePerformance
{
    [MKitModelGraph clearAllGraphs];
    
    for(int i=0; i<1200; i++)
        [self makeModelWithId:[NSString stringWithFormat:@"%d",i]];
    
    NSTimeInterval start=[[NSDate date] timeIntervalSince1970];
    [[MKitModelGraph defaultGraph] saveToFile:@"/tmp/100k.plist" error:nil];
    NSTimeInterval end=[[NSDate date] timeIntervalSince1970];
    NSLog(@"WRITE TIME %f",end-start);
    
    [MKitModelGraph clearAllGraphs];
    
    start=[[NSDate date] timeIntervalSince1970];
    [[MKitModelGraph defaultGraph] loadFromFile:@"/tmp/100k.plist" error:nil];
    end=[[NSDate date] timeIntervalSince1970];
    NSLog(@"READ TIME %f",end-start);
}

@end
