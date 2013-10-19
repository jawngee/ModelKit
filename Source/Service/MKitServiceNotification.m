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

+(id)notificationWithMessage:(NSString *)message
{
    return [self notificationWithMessage:message parameters:nil];
}

+(id)notificationWithMessage:(NSString *)message badgeCount:(NSInteger)badgeCount
{
    return [self notificationWithMessage:message badgeCount:badgeCount parameters:nil];
}

+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels
{
    return [self notificationWithMessage:message channels:channels parameters:nil];
}
+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels badgeCount:(NSInteger)badgeCount
{
    return [self notificationWithMessage:message channels:channels badgeCount:badgeCount parameters:nil];
}

+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query
{
    return [self notificationWithMessage:message channels:channels query:query parameters:nil];
}

+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount
{
    return [self notificationWithMessage:message channels:channels query:query badgeCount:badgeCount parameters:nil];
}

+(id)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query
{
    return [self notificationWithMessage:message query:query parameters:nil];
}

+(id)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount
{
    return [self notificationWithMessage:message query:query badgeCount:badgeCount parameters:nil];
}



+(id)notificationWithMessage:(NSString *)message parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.parameters=parameters;
    
    return notification;
}

+(id)notificationWithMessage:(NSString *)message badgeCount:(NSInteger)badgeCount parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.badgeCount=badgeCount;
    notification.parameters=parameters;
    
    return notification;
}

+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    notification.parameters=parameters;
    
    return notification;
}


+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels badgeCount:(NSInteger)badgeCount parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    notification.parameters=parameters;
    notification.badgeCount=badgeCount;
    
    return notification;
}

+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    notification.parameters=parameters;
    notification.query=query;
    
    return notification;
}

+(id)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.channels=[[channels mutableCopy] autorelease];
    notification.parameters=parameters;
    notification.query=query;
    notification.badgeCount=badgeCount;
    
    return notification;

}

+(id)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.query=query;
    notification.parameters=parameters;
    
    return notification;
}

+(id)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount parameters:(NSDictionary *)parameters
{
    MKitServiceNotification *notification=[[[self alloc] init] autorelease];
    
    notification.message=message;
    notification.query=query;
    notification.badgeCount=badgeCount;
    notification.parameters=parameters;
    
    return notification;
}

#pragma mark - Sending


-(BOOL)send:(NSError **)error
{
    return NO;
}

-(void)sendInBackground:(MKitBooleanResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [currentGraph push];
        
        NSError *error=nil;
        BOOL result=[self send:&error];
        if (resultBlock)
            resultBlock(result,error);
    
        [currentGraph pop];
    });
}



@end
