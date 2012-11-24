//
//  TestModelAltGraph.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/14/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"
#import "TestModel.h"
#import "MKitMutableModelArray.h"

@interface TestModelAltGraph : MKitModel

@property (copy, nonatomic) NSString *stringV;
@property (retain, nonatomic) MKitMutableModelArray *amodelArrayV;
@property (copy, nonatomic) NSDate *dateV;
@property (assign, nonatomic) NSInteger intV;
@property (assign, nonatomic) BOOL boolV;
@property (assign, nonatomic) float floatV;
@property (assign, nonatomic) double doubleV;
@property (assign, nonatomic) short shortV;
@property (assign, nonatomic) TestModel *amodelV;

@end
