//
//  MKitServicePush.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/17/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#include "MKitDefs.h"
#import <Foundation/Foundation.h>
#import "MKitServiceModelQuery.h"

#define MKitBadgeNoCount -1
#define MKitBadgeIncrement NSIntegerMax
#define MKitBadgeDecrement NSNotFound

/**
 * Represents a push notification
 */
@interface MKitServiceNotification : NSObject

@property (retain, nonatomic) NSMutableArray *channels;     /**< The channels to push to */
@property (retain, nonatomic) MKitServiceModelQuery *query; /**< The query to perform to select the installations to push to */
@property (retain, nonatomic) NSString *message;            /**< The message to push. */
@property (assign, nonatomic) NSInteger badgeCount;         /**< The badge count to set, use MKitBadgeDecrement to decrement the badge, MKitBadgeIncrement to increment */
@property (retain, nonatomic) NSString *sound;              /**< The sound to use */
@property (retain, nonatomic) NSString *title;              /**< Android only, the title of the notification */
@property (retain, nonatomic) NSString *action;             /**< Android only, the action */
@property (assign, nonatomic) NSInteger contentAvailable;   /**< For newsstand, triggers a background download */
@property (retain, nonatomic) NSDate *pushTime;                         /**< Date the notification will be sent */
@property (assign, nonatomic) NSTimeInterval expirationTimeInterval;    /**< The number of seconds from now that the notification expires. */

+(MKitServiceNotification *)notificationWithMessage:(NSString *)message;
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message badgeCount:(NSInteger)badgeCount;
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels;
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels badgeCount:(NSInteger)badgeCount;
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query;
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount;
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query;
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount;


-(BOOL)send:(NSError **)error;
-(void)sendInBackground:(MKitBooleanResultBlock)resultBlock;


@end
