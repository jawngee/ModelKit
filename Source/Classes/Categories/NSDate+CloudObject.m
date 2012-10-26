//
//  NSDate+CloudObject.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "NSDate+CloudObject.h"
#import "ISO8601DateFormatter.h"

@implementation NSDate (CloudObject)

+(NSDate *)dateFromISO8601:(NSString *)iso8601
{
    ISO8601DateFormatter *formatter=[[[ISO8601DateFormatter alloc] init] autorelease];
    return [formatter dateFromString:iso8601];
}

-(NSString *)ISO8601String
{
    ISO8601DateFormatter *formatter=[[[ISO8601DateFormatter alloc] init] autorelease];
    formatter.includeTime=YES;
    return [formatter stringFromDate:self];
}

@end
