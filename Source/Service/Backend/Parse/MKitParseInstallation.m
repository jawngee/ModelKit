//
//  MKitParseInstallation.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/17/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseInstallation.h"
#import "SecureUDID.h"

@implementation MKitParseInstallation

+(void)load
{
    [self register];
}

+(NSString *)modelName
{
    return @"_Installation";
}

-(void)setup
{
    [super setup];
    
    self.channels=[NSMutableArray array];
    self.deviceType=@"ios";
    self.timeZone=[[NSTimeZone systemTimeZone] name];
    self.installationId=[SecureUDID UDIDForDomain:@"com.interfacelab.modelkit" usingKey:@"parse"];
}

+(id<MKitServiceInstallation>)currentInstallation
{
    static MKitParseInstallation *currentInstallation=nil;
    
    if (currentInstallation)
        return currentInstallation;
    
    id installData=[[self service] installationData];
    
    if (!installData)
    {
        currentInstallation=[[[self class] alloc] init];
    }
    else
    {
        currentInstallation=[[self instanceWithSerializedData:installData] retain];
    }
    
    return currentInstallation;
}

-(BOOL)save:(NSError **)error
{
    BOOL result=[super save:error];
    if (result)
        [[[self class] service] storeInstallationData:self];
    
    return result;
}

-(BOOL)delete:(NSError **)error
{
    return NO;
}

-(BOOL)fetch:(NSError **)error
{
    BOOL result=[super fetch:error];
    if (result)
        [[[self class] service] storeInstallationData:self];
    
    return result;
}

@end
