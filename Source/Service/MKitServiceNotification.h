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

/**
 * Creates a new notification
 * @param message The message for the notification
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message;

/**
 * Creates a new notification
 * @param message The message for the notification
 * @param badgeCount The badge count for the notification, set to MKitBadgeIncrement to increment the badge count
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message badgeCount:(NSInteger)badgeCount;

/**
 * Creates a new notification
 * @param message The message for the notification
 * @param channels The channels to broadcast the notification to
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels;

/**
 * Creates a new notification
 * @param message The message for the notification
 * @param channels The channels to broadcast the notification to
 * @param badgeCount The badge count for the notification, set to MKitBadgeIncrement to increment the badge count
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels badgeCount:(NSInteger)badgeCount;

/**
 * Creates a new notification
 * @param message The message for the notification
 * @param channels The channels to broadcast the notification to
 * @param query The Installation query that determines where the notification gets sent
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query;

/**
 * Creates a new notification
 * @param message The message for the notification
 * @param channels The channels to broadcast the notification to
 * @param query The Installation query that determines where the notification gets sent
 * @param badgeCount The badge count for the notification, set to MKitBadgeIncrement to increment the badge count
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message channels:(NSArray *)channels query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount;

/**
 * Creates a new notification
 * @param message The message for the notification
 * @param query The Installation query that determines where the notification gets sent
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query;

/**
 * Creates a new notification
 * @param message The message for the notification
 * @param query The Installation query that determines where the notification gets sent
 * @param badgeCount The badge count for the notification, set to MKitBadgeIncrement to increment the badge count
 * @return The new notification
 */
+(MKitServiceNotification *)notificationWithMessage:(NSString *)message query:(MKitServiceModelQuery *)query badgeCount:(NSInteger)badgeCount;

/**
 * Sends the notification
 * @param error The error, if any
 * @return YES if succesful, NO if not
 */
-(BOOL)send:(NSError **)error;

/**
 * Sends the notification in the background
 * @param resultBlock The result block to call when complete
 */
-(void)sendInBackground:(MKitBooleanResultBlock)resultBlock;


@end
