//
//  MKitReflectedProperty.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitReflectedProperty.h"

@implementation MKitReflectedProperty

-(id)initWithName:(NSString *)propName forProperty:(objc_property_t)property
{
    if ((self=[super init]))
    {
        _name=[propName copy];
        
        const char *attributes = property_getAttributes(property);
        NSString *typeStr=[NSString stringWithCString:attributes encoding:NSASCIIStringEncoding];
        NSString *type=[[typeStr componentsSeparatedByString:@","] objectAtIndex:0];
        if ([type hasPrefix:@"T@"])
        {
            if ([type isEqualToString:@"T@"])
            {
                _type=refTypeId;
            }
            else
            {
                NSString *actualType=[type substringWithRange:NSMakeRange(3, type.length-4)];
                
                _typeClass=NSClassFromString(actualType);
                if (_typeClass==nil)
                    @throw [NSException exceptionWithName:@"Missing Reflection Class" reason:[NSString stringWithFormat:@"Can not find class '%@'.",actualType] userInfo:nil];
                
                if ([_typeClass isSubclassOfClass:[NSString class]])
                    _type=refTypeString;
                else if ([_typeClass isSubclassOfClass:[NSNumber class]])
                    _type=refTypeNumber;
                else if ([_typeClass isSubclassOfClass:[NSDate class]])
                    _type=refTypeDate;
                else if ([_typeClass isSubclassOfClass:[NSData class]])
                    _type=refTypeData;
                else if ([_typeClass isSubclassOfClass:[NSDictionary class]])
                    _type=refTypeDictionary;
                else if ([_typeClass isSubclassOfClass:[NSArray class]])
                {
                    _typeClass=NSClassFromString(actualType);
                    if (_typeClass==nil)
                        _typeClass=[NSMutableArray class];
                    
                    _type=refTypeArray;
                }
                else
                    _type=refTypeClass;
            }
        }
        else
        {
            if ([type isEqualToString:@"Tc"])
                _type=refTypeChar;
            else if ([type isEqualToString:@"Ts"])
                _type=refTypeShort;
            else if ([type isEqualToString:@"Ti"])
                _type=refTypeInteger;
            else if ([type isEqualToString:@"Tl"])
                _type=refTypeLong;
            else if ([type isEqualToString:@"Tf"])
                _type=refTypeFloat;
            else if ([type isEqualToString:@"Td"])
                _type=refTypeDouble;
            else
                _type=refTypeUnknown;
        }
    }
    
    return self;
}

-(void)dealloc
{
    [_name release];
    
    [super dealloc];
}

@end
