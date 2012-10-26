//
//  CSMPBlog.h
//  CloudSample
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COModel.h"

@interface CSMPBlog : COModel

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *description;
@property (retain, nonatomic) COMutableModelArray *posts;

@end
