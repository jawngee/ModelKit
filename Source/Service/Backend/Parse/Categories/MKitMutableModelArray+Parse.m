//
//  MKitMutableModelArray+Parse.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/31/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitMutableModelArray+Parse.h"
#import "MKitModel+Parse.h"

@implementation MKitMutableModelArray (Parse)

-(NSArray *)parsePointerArray:(NSMutableArray **)modelsToSave
{
    NSMutableArray *result=[NSMutableArray array];
    NSMutableArray *toSave=[NSMutableArray array];
    
    for(MKitModel *model in self)
    {
        if (model.objectId)
        {
            if (model.modelState==ModelStateDirty)
                [toSave addObject:model];
            else if (model.modelState!=ModelStateDeleted)
                [result addObject:[model parsePointer]];
        }
        else
            [toSave addObject:model];
    }
    
    if (toSave.count>0)
        *modelsToSave=toSave;
    
    return result;
}

@end
