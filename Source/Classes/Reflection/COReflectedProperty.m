//
//  COReflectedProperty.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COReflectedProperty.h"

@implementation COReflectedProperty

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
                
                if ([NSMutableString isSubclassOfClass:_typeClass])
                    _type=refTypeString;
                else if ([NSNumber isSubclassOfClass:_typeClass])
                    _type=refTypeNumber;
                else if ([NSDate isSubclassOfClass:_typeClass])
                    _type=refTypeDate;
                else if ([NSMutableData isSubclassOfClass:_typeClass])
                    _type=refTypeData;
                else if ([NSMutableDictionary isSubclassOfClass:_typeClass])
                    _type=refTypeDictionary;
                else if ([NSMutableArray isSubclassOfClass:_typeClass])
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
