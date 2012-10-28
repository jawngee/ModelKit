//
//  TestModel.h
//  CloudObject
//
//  Created by Jon Gilkison on 10/28/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COModel.h"
#import "COMutableModelArray.h"

@interface TestModel : COModel

@property (copy, nonatomic) NSString *stringV;
@property (retain, nonatomic) COMutableModelArray *amodelArrayV;
@property (copy, nonatomic) NSDate *dateV;
@property (assign, nonatomic) NSInteger intV;
@property (assign, nonatomic) BOOL boolV;
@property (assign, nonatomic) float floatV;
@property (assign, nonatomic) double doubleV;
@property (assign, nonatomic) short shortV;
@property (assign, nonatomic) TestModel *amodelV;

@end
