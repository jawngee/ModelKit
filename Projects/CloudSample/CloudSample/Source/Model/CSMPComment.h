//
//  CSMPComment.h
//  CloudSample
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COModel.h"
#import "CSMPAuthor.h"

@interface CSMPComment : COModel

@property (assign, nonatomic) CSMPAuthor *author;
@property (copy, nonatomic) NSString *comment;

@end
