//
//  NSError+iLab.m
//  iLab
//
//  Created by Jon Gilkison on 4/12/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "NSError+ModelKit.h"

@implementation NSError (ModelKit)

+ (NSError *)errorWithDescription:(NSString *)description
{
	return [self appError:-1 description:description];
}

+ (NSError *)appError:(int)err description:(NSString *)description
{
	return [NSError errorWithDomain:[[NSBundle mainBundle] bundleIdentifier] code:err userInfo:[NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, nil]];
}

+ (NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description recoverySuggestion:(NSString *)recoverySuggestion
{
	return [NSError errorWithDomain:domain code:code userInfo:[NSDictionary dictionaryWithObjectsAndKeys:description, NSLocalizedDescriptionKey, recoverySuggestion, NSLocalizedRecoverySuggestionErrorKey, nil]];
}

@end
