//
//  MKitReflectedProperty.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

/** Property type enumeration */
typedef enum
{
    // class types
    refTypeId           =-1,        /**< id type */
    refTypeClass        =0,         /**< Class type that isn't id, nsarray, nsdictionary, etc. */
    refTypeArray        =2,         /**< NSArray/NSMutableArray */
    refTypeDictionary   =3,         /**< NSDictionary/NSMutableDictionary */
    refTypeString       =4,         /**< NSString/NSMutableString */
    refTypeNumber       =5,         /**< NSNumber */
    refTypeData         =6,         /**< NSData/NSMutableData */
    refTypeDate         =7,         /**< NSDate */
    
    // primitive types
    refTypeBool         =99,       /**<  BOOL type */
    refTypeChar         =100,       /**< Char type */
    refTypeShort        =101,       /**< Short type */
    refTypeInteger      =102,       /**< Integer type */
    refTypeLong         =103,       /**< Long type */
    refTypeFloat        =104,       /**< Float type */
    refTypeDouble       =105,       /**< Double type */
    
    // unknown
    refTypeUnknown      =666        /**< Unknown type */
} MKitReflectedPropertyType;

/**
 * Wraps an object property reflection info
 */
@interface MKitReflectedProperty : NSObject

/**
 * Initializes a new instance
 * @param propName Name of the property
 * @param property The run time objc_property_t type
 * @result New instance.
 */
-(id)initWithName:(NSString *)propName forProperty:(objc_property_t)property;

@property (readonly) NSString *name;                /**< Name of the property */
@property (readonly) MKitReflectedPropertyType type;  /**< Type of property */
@property (readonly) Class typeClass;               /**< Class type, if any */

@end
