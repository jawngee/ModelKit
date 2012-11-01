//
//  MKitReflectedClass.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitReflectedClass.h"
#import <objc/runtime.h>
#import "MKitReflectedProperty.h"

/**
 * Private methods
 */
@interface MKitReflectedClass(Internal)

/**
 * Parses the properties for a given class
 * @param class The class to parse properties for
 * @param ignorePropPrefix Properties with this prefix are ignored
 */
-(void)parsePropertiesForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix;

@end

@implementation MKitReflectedClass

@synthesize properties;

+(id)reflectionForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix recurseChainUntil:(Class)topclass
{
    return [[[MKitReflectedClass alloc] initWithClass:class ignorePropPrefix:ignorePropPrefix recurseChainUntil:topclass] autorelease];
}

-(void)parsePropertiesForClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix
{
    unsigned int outCount, i;
    objc_property_t *props = class_copyPropertyList(class, &outCount);
    for(i = 0; i < outCount; i++)
    {
        objc_property_t property = props[i];
        const char *propName = property_getName(property);
        if(propName)
        {
            NSString *propertyName = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
            if ((ignorePropPrefix==nil) || (![propertyName hasPrefix:ignorePropPrefix]))
                [properties setObject:[[[MKitReflectedProperty alloc] initWithName:propertyName forProperty:property] autorelease] forKey:propertyName];
        }
    }
    
    free(props);
}

-(id)initWithClass:(Class)class ignorePropPrefix:(NSString *)ignorePropPrefix recurseChainUntil:(Class)topclass
{
    if ((self=[super init]))
    {
        properties=[[MKitMutableOrderedDictionary alloc] init];
        
        if (topclass==nil)
            topclass=[NSObject class];
        
        Class parsingClass=class;
        while(parsingClass!=topclass)
        {
            [self parsePropertiesForClass:parsingClass ignorePropPrefix:ignorePropPrefix];
            parsingClass=[parsingClass superclass];
            if (parsingClass==nil)
                break;
        }
    }
    
    return self;
}

-(void)dealloc
{
    [properties release];
    [super dealloc];
}


@end
