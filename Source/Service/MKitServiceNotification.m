//
//  MKitServicePush.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/17/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceNotification.h"

@implementation MKitServiceNotification

#pragma mark - Init/Dealloc

-(id)init
{
    if ((self=[super init]))
    {
        self.badgeCount=-1;
    }
    
    return self;
}

-(void)dealloc
{
    self.channels=nil;
    self.query=nil;
    self.message=nil;
    self.sound=nil;
    self.title=nil;
    self.action=nil;
    self.pushTime=nil;
    
    
    [super dealloc];
}

#pragma mark - Service

+(MKitServiceManager *)service
{
    return nil;
}

#pragma mark - Static Initializers

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    
    return notification;
}

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message badgeCount:(NSInteger)badgeCount
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.badgeCount=badgeCount;
    
    return notification;
}

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    
    return notification;
}

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels badgeCount:(NSInteger)badgeCount
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    notification.badgeCount=badgeCount;
    
    return notification;
}

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    notification.query=query;
    
    return notification;
}

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    notification.query=query;
    notification.badgeCount=badgeCount;
    
    return notification;

}

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.query=query;
    
    return notification;
}

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.query=query;
    notification.badgeCount=badgeCount;
    
    return notification;
}

#pragma mark - Sending


-(BOOL)send:(NSError **)error
{
    return NO;
}

-(void)sendInBackground:(MKitBooleanResultBlock)resultBlock
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSError *error=nil;
        BOOL result=[self send:&error];
        if (resultBlock)
            resultBlock(result,error);
    });
}



@end
