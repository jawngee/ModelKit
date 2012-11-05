//
//  SMASHAppDelegate.m
//  CloudSample
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#include "CSMPAppKeys.h"

#import "CSMPAppDelegate.h"
#import "CSMPTodoListsViewController.h"

@implementation CSMPAppDelegate

- (void)dealloc
{
    [_window release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Make sure your keys are defined in CSMPAppKeys
    [MKitServiceManager setupService:@"Parse" withKeys:@{@"AppID":PARSE_APP_ID,@"RestKey":PARSE_REST_KEY}];
    
    // Reload the existing context if it exists
    NSError *error=nil;
    if (![[MKitModelContext current] loadFromFile:[NSString fileNameInDocumentPath:@"context.plist"] error:&error])
        NSLog(@"Error loading context: %@",error);
    
    self.window = [[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] autorelease];
    
    CSMPTodoListsViewController *tlv=[[[CSMPTodoListsViewController alloc] initWithStyle:UITableViewStylePlain] autorelease];
    UINavigationController *navController=[[[UINavigationController alloc] initWithRootViewController:tlv] autorelease];
    
    self.window.rootViewController = navController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[MKitModelContext current] saveToFile:[NSString fileNameInDocumentPath:@"context.plist"] error:nil];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[MKitModelContext current] saveToFile:[NSString fileNameInDocumentPath:@"context.plist"] error:nil];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [[MKitModelContext current] saveToFile:[NSString fileNameInDocumentPath:@"context.plist"] error:nil];
}

@end
