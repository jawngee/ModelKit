//
//  NSString+ModelKit.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/30/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "NSString+ModelKit.h"

@implementation NSString (ModelKit)

+(NSString *)UUID
{
	CFUUIDRef uuid = CFUUIDCreate(NULL);
	CFStringRef uuidString = CFUUIDCreateString(NULL, uuid);
	CFRelease(uuid);
	NSString *result=[NSString stringWithFormat:@"%@",(NSString *)uuidString];
	CFRelease(uuidString);
	
	return result;
}


@end
