//
//  TestCases.m
//  TestCases
//
//  Created by Jon Gilkison on 10/28/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitTC0001GraphTestCases.h"
#import "TestModel.h"
#import "TestModelNoGraph.h"

@implementation MKitTC0001GraphTestCases

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)test0001GraphSize
{
    [MKitModelGraph clearAllGraphs];
    
    TestModel *model=[TestModel instanceWithObjectId:@"hey"];
    
    STAssertTrue([MKitModelGraph current].graphSize==80, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==1, @"Graph count mismatch.");
    
    [model removeFromGraph];
    
    STAssertTrue([MKitModelGraph current].graphSize==0, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==0, @"Graph count mismatch.");
}

-(void)test0002GraphPopPush
{
    [MKitModelGraph clearAllGraphs];
    
    [MKitModelGraph push];
    
    [TestModel instanceWithObjectId:@"hey"];
    
    STAssertTrue([MKitModelGraph current].graphSize==80, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==1, @"Graph count mismatch.");
    
    [MKitModelGraph pop];

    STAssertTrue([MKitModelGraph current].graphSize==0, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==0, @"Graph count mismatch.");
}

-(void)test0003GraphActivateDeactivate
{
    MKitModelGraph *graph=[[MKitModelGraph alloc] init];
    
    STAssertTrue([MKitModelGraph current].graphSize==0, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==0, @"Graph count mismatch.");

    [graph activate];
    
    [TestModel instanceWithObjectId:@"hey"];
    
    STAssertTrue([MKitModelGraph current].graphSize==80, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==1, @"Graph count mismatch.");
    
    [graph deactivate];

    STAssertTrue([MKitModelGraph current].graphSize==0, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==0, @"Graph count mismatch.");
    
    [graph activate];

    STAssertTrue([MKitModelGraph current].graphSize==80, @"Graph size mismatch.");
    STAssertTrue([MKitModelGraph current].graphCount==1, @"Graph count mismatch.");

    [graph deactivate];
    [graph release];
}

-(void)test0004FindModel
{
    TestModel *m=[TestModel instanceWithObjectId:@"hey"];

    TestModel *m2=(TestModel *)[[MKitModelGraph current] modelForObjectId:@"hey" andClass:[TestModel class]];
    STAssertTrue(m==m2, @"Objects do not match");
    
    m2=[TestModel instanceWithObjectId:@"hey"];
    STAssertTrue(m==m2, @"Objects do not match");
    
    [[MKitModelGraph current] clear];
    m2=(TestModel *)[[MKitModelGraph current] modelForObjectId:@"hey" andClass:[TestModel class]];
    STAssertTrue(m2==nil, @"Object should be nil");
}

-(void)test0005SaveGraph
{
    TestModel *m1=[TestModel instanceWithObjectId:@"001"];
    TestModel *m2=[TestModel instanceWithObjectId:@"002"];
    TestModel *m3=[TestModel instanceWithObjectId:@"003"];
    TestModel *m4=[TestModel instanceWithObjectId:@"004"];
    TestModel *m5=[TestModel instanceWithObjectId:@"005"];
    TestModel *m6=[TestModel instanceWithObjectId:@"006"];

    
    STAssertTrue([[MKitModelGraph current] saveToFile:@"/tmp/persist.plist" error:nil], @"This should never fail.");
    
    [MKitModelGraph clearAllGraphs];
}

-(void)test0006LoadGraph
{
    [self test0005SaveGraph];
    
    [MKitModelGraph clearAllGraphs];
    
    STAssertTrue([[MKitModelGraph current] loadFromFile:@"/tmp/persist.plist" error:nil], @"This should never fail either.");
    
    TestModel *m=(TestModel *)[[MKitModelGraph current] modelForObjectId:@"004" andClass:[TestModel class]];
    STAssertTrue(m!=nil, @"Model is nil");
}

-(void)test0007ComplicatedSaveLoad
{
    [MKitModelGraph clearAllGraphs];
    
    TestModel *m1=[TestModel instanceWithObjectId:@"001"];
    TestModel *m2=[TestModel instanceWithObjectId:@"002"];
    TestModel *m3=[TestModel instanceWithObjectId:@"003"];
    TestModel *m4=[TestModel instanceWithObjectId:@"004"];
    TestModel *m5=[TestModel instanceWithObjectId:@"005"];
    TestModel *m6=[TestModel instanceWithObjectId:@"006"];
    
    m1.stringV=@"Hey 1";
    m1.shortV=192;
    m1.intV=32456;
    m1.boolV=YES;
    m1.floatV=0.66f;
    m1.doubleV=10.233;
    m1.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m1.amodelV=m5;
    
    m2.stringV=@"Hey 2";
    m2.shortV=192;
    m2.intV=32456;
    m2.boolV=YES;
    m2.floatV=0.66f;
    m2.doubleV=10.233;
    m2.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m6]];
    m2.amodelV=m3;

    m3.stringV=@"Hey 3";
    m3.shortV=192;
    m3.intV=32456;
    m3.boolV=YES;
    m3.floatV=0.66f;
    m3.doubleV=10.233;
    m3.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2]];
    m3.amodelV=m4;

    m4.stringV=@"Hey 4";
    m4.shortV=192;
    m4.intV=32456;
    m4.boolV=YES;
    m4.floatV=0.66f;
    m4.doubleV=10.233;
    m4.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m1,m2,m3]];
    m4.amodelV=m6;

    m5.stringV=@"Hey 5";
    m5.shortV=192;
    m5.intV=32456;
    m5.boolV=YES;
    m5.floatV=0.66f;
    m5.doubleV=10.233;
    m5.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m2,m3]];
    m5.amodelV=m1;

    m6.stringV=@"Hey 6";
    m6.shortV=192;
    m6.intV=32456;
    m6.boolV=YES;
    m6.floatV=0.66f;
    m6.doubleV=10.233;
    m6.amodelArrayV=[MKitMutableModelArray arrayWithArray:@[m4,m5]];
    m6.amodelV=m3;

    STAssertTrue([[MKitModelGraph current] saveToFile:@"/tmp/persist.plist" error:nil]==YES,@"This should never fail.");
    [MKitModelGraph clearAllGraphs];
    STAssertTrue([[MKitModelGraph current] loadFromFile:@"/tmp/persist.plist" error:nil]==YES,@"This should never fail.");
    
    m1=[TestModel instanceWithObjectId:@"001"];
    m2=[TestModel instanceWithObjectId:@"002"];
    m3=[TestModel instanceWithObjectId:@"003"];
    m4=[TestModel instanceWithObjectId:@"004"];
    m5=[TestModel instanceWithObjectId:@"005"];
    m6=[TestModel instanceWithObjectId:@"006"];
    
    STAssertTrue([m1.stringV isEqualToString:@"Hey 1"],@"stringV not equal");
    STAssertTrue(m1.shortV==192,@"shortV not equal");
    STAssertTrue(m1.intV==32456,@"intV not equal");
    STAssertTrue(m1.boolV==YES,@"boolV not equal");
    STAssertTrue(m1.floatV==0.66f,@"floatV not equal");
    STAssertTrue(m1.doubleV==10.233,@"doubleV not equal");
    STAssertTrue(m1.amodelArrayV.count==2,@"modelArrayV count not equal");
    STAssertTrue([m1.amodelArrayV indexOfObject:m2]!=NSNotFound, @"Could not find m2 in array");
    STAssertTrue([m1.amodelArrayV indexOfObject:m3]!=NSNotFound, @"Could not find m2 in array");
    STAssertTrue(m1.amodelV==m5,@"modelV not equal");

    [MKitModelGraph clearAllGraphs];
}

@end
