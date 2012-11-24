//
//  MKitParseNotification.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/23/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseNotification.h"
#import "MKitParseModelQuery.h"
#import "MKitParseServiceManager.h"
#import "AFNetworking.h"
#import "JSONKit.h"


@implementation MKitParseNotification

+(MKitServiceManager *)service
{
    static MKitServiceManager *parseService=nil;
    
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        parseService=[MKitServiceManager managerForServiceNamed:MKitParseServiceName];
    });
    
    return parseService;
}

-(BOOL)send:(NSError **)error
{
    BOOL result=NO;
    
    NSMutableDictionary *data=[NSMutableDictionary dictionary];
    NSMutableDictionary *body=[NSMutableDictionary dictionary];
    
    if ((self.channels) && (self.channels.count>0))
        [body setObject:self.channels forKey:@"channels"];
    
    if (self.query)
    {
        if ([[self.query class] isSubclassOfClass:[MKitParseModelQuery class]])
            [body setObject:[((MKitParseModelQuery *)self.query) buildQuery] forKey:@"where"];
        else
            @throw [NSException exceptionWithName:@"Invalid Query Type" reason:@"Query is not a MKitParseModelQuery" userInfo:nil];
    }
    
    if (!self.message)
        @throw [NSException exceptionWithName:@"Notification Missing Message" reason:@"Notification is missing a message" userInfo:nil];
    
    [data setObject:self.message forKey:@"alert"];
    
    if (self.badgeCount!=MKitBadgeNoCount)
        [data setObject:(self.badgeCount==MKitBadgeIncrement) ? @"Increment" : @(self.badgeCount) forKey:@"badge"];
    
    if (self.sound)
        [data setObject:self.sound forKey:@"sound"];
    
    if (self.contentAvailable)
        [data setObject:@(self.contentAvailable) forKey:@"content-available"];
    
    if (self.action)
        [data setObject:self.action forKey:@"action"];
    
    if (self.title)
        [data setObject:self.title forKey:@"title"];
    
    [body setObject:data forKey:@"data"];
    
    AFHTTPRequestOperation *op=[[[self class] service] requestWithMethod:@"POST" path:@"push" params:nil body:[body JSONData] contentType:nil];
    
    [op start];
    [op waitUntilFinished];
    
    if ([op hasAcceptableStatusCode])
    {
        result=YES;
    }
    
    if (error)
        *error=op.error;
 
    return result;
}

@end
