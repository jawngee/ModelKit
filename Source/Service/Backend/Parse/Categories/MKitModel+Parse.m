//
//  MKitModel+Parse.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/31/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel+Parse.h"

@implementation MKitModel (Parse)

-(NSDictionary *)parsePointer
{
    if (!self.objectId)
        return nil;
    
    return @{@"__type":@"Pointer",@"className":[[self class] modelName],@"objectId":self.objectId};
}

@end
