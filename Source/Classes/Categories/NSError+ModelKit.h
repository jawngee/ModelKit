//
//  NSError+iLab.h
//  iLab
//
//  Created by Jon Gilkison on 4/12/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

/**
 * NSError additions
 */
@interface NSError (ModelKit)

/**
 * Generates an error with a given description
 * @param description A description of the error
 * @result The generated error
 */
+(NSError *)errorWithDescription:(NSString *)description;

/**
 * Generates an error with a given description and application specified error
 * @param err The application error number
 * @param description A description of the error
 * @result The generated error
 */
+(NSError *)appError:(int)err description:(NSString *)description;

/**
 * Generates an error
 * @param domain The error domain
 * @param code The error number
 * @param description The description of the error
 * @param recoverySuggestion Hint on how to avoid the error
 * @result The generated error
 */
+(NSError *)errorWithDomain:(NSString *)domain code:(NSInteger)code description:(NSString *)description recoverySuggestion:(NSString *)recoverySuggestion;

@end
