//
//  COModel.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COModel.h"
#import "COReflectionManager.h"
#import "COReflectedClass.h"
#import "COReflectedProperty.h"

#import "COModelRegistry.h"

@interface COModel()

-(NSArray *)flattenArray:(NSArray *)array;

@end

@implementation COModel

+(void)initialize
{
    COModel *inst=[[self alloc] init];

    // register the model's name if it has one with the model registry for mapping
    if (inst.modelName!=nil)
        [COModelRegistry registerModel:inst.modelName forClass:[self class]];
    
    [inst release];
}

-(id)init
{
    if ((self=[super init]))
    {
        _modelState=ModelStateNew;
        _createdAt=[[NSDate date] retain];
        _updatedAt=[[NSDate date] retain];
    }

    return self;
}

-(void)dealloc
{
    self.objectId=nil;
    self.createdAt=nil;
    self.updatedAt=nil;
    
    [super dealloc];
}

-(NSArray *)flattenArray:(NSArray *)array
{
    NSMutableArray *replacement=[NSMutableArray array];
    
    for(NSObject *ele in array)
    {
        if ([ele isKindOfClass:[COModel class]])
            [replacement addObject:ele];
        else if ([ele isKindOfClass:[NSArray class]])
            [replacement addObject:[self flattenArray:(NSArray *)ele]];
        else if (
                 ([ele isKindOfClass:[NSString class]]) ||
                 ([ele isKindOfClass:[NSDate class]]) ||
                 ([ele isKindOfClass:[NSNumber class]]) ||
                 ([ele isKindOfClass:[NSData class]])
                 )
        {
            [replacement addObject:ele];
        }
    }
    
    return replacement;
}

-(NSDictionary *)toDictionary
{
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    
    if (self.modelName)
        [result setObject:self.modelName forKey:@"model"];
    else
        [result setObject:NSStringFromClass([self class]) forKey:@"model"];
    
    if (self.objectId)
        [result setObject:self.objectId forKey:@"objectId"];
    
    [result setObject:self.createdAt forKey:@"createdAt"];
    [result setObject:self.updatedAt forKey:@"updatedAt"];
    
    NSMutableDictionary *props=[NSMutableDictionary dictionary];
    [result setObject:props forKey:@"properties"];
    
    COReflectedClass *ref=[COReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[COModel class]];
    
    for(COReflectedProperty *p in [ref.properties allValues])
    {
        id val=[self valueForKey:p.name];
        
        if (val==nil)
        {
            val=[NSNull null];
            [props setObject:val forKey:p.name];
        }
        else if (p.type==refTypeClass)
        {
            // We are only interested in other models, otherwise we skip the property
            NSObject *obj=(NSObject *)val;
            if ([obj isKindOfClass:[COModel class]])
                [props setObject:obj forKey:p.name];
        }
        
        else if (p.type==refTypeArray)
        {
            [props setObject:[self flattenArray:(NSArray *)val] forKey:p.name];
        }
        else if ((p.type>=refTypeString && p.type<=refTypeDate) || (p.type>=refTypeChar && p.type<refTypeUnknown))
        {
            [props setObject:val forKey:p.name];
        }
    }
    
    return result;
}

@end
