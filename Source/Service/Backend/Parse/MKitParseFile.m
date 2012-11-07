//
//  MKitParseFile.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/7/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseFile.h"
#import "MKitServiceManager.h"

@implementation MKitParseFile

static MKitServiceManager *parseService=nil;

+(MKitServiceManager *)service
{
    if (parseService==nil)
        parseService=[MKitServiceManager managerForService:@"Parse"];
    
    return parseService;
}

-(NSDictionary *)parseFilePointer
{
    if (self.state!=FileStateSaved)
        @throw [NSException exceptionWithName:@"Invalid File State" reason:@"The MKitParseFile is in an invalid state.  It has either been deleted or not saved." userInfo:nil];
    
    return @{@"__type":@"File",@"name":self.name};
}

@end
