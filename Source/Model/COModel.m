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
#import "COModelContext.h"

@interface COModel()

-(NSArray *)flattenArray:(NSArray *)array;

@end

@implementation COModel

#pragma mark - Class Initialization

+(void)initialize
{
    COModel *inst=[[self alloc] init];

    // register the model's name if it has one with the model registry for mapping
    if (inst.modelName!=nil)
        [COModelRegistry registerModel:inst.modelName forClass:[self class]];
    
    [inst release];
}

#pragma mark Init/Dealloc

-(id)init
{
    if ((self=[super init]))
    {
        _modelState=ModelStateNew;
        _createdAt=[[NSDate date] retain];
        _updatedAt=[[NSDate date] retain];
        
        [[COModelContext current] addToContext:self];
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


+(id)instanceWithId:(NSString *)objId
{
    COModel *instance=[[COModelContext current] modelForId:objId andClass:[self class]];
    if (instance!=nil)
        return instance;
    
    instance=[[[[self class] alloc] init] autorelease];
    instance.objectId=objId;
    
    return instance;
}

+(id)instanceWithDictionary:(NSDictionary *)dictionary
{
    COModel *instance=nil;
    if ([dictionary objectForKey:@"objectId"])
        instance=[[COModelContext current] modelForId:[dictionary objectForKey:@"objectId"] andClass:[self class]];
    
    if (!instance)
    {
        instance=[[[[self class] alloc] init] autorelease];
        if ([dictionary objectForKey:@"objectId"])
            instance.objectId=[dictionary objectForKey:@"objectId"];
    }
    
    [instance fromDictionary:dictionary];
    
    return instance;
}


#pragma mark - Context related

-(void)remove
{
    [[COModelContext current] removeFromContext:self];
}

#pragma mark - Conversion

-(NSArray *)flattenArray:(NSArray *)array
{
    NSMutableArray *replacement=[NSMutableArray array];
    
    for(NSObject *ele in array)
    {
        if ([ele isKindOfClass:[COModel class]])
            [replacement addObject:[((COModel *)ele) toDictionary]];
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
    
    [result setObject:@"model" forKey:@"__type"];
    
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
                [props setObject:[((COModel *)obj) toDictionary] forKey:p.name];
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

-(void)fromDictionary:(NSDictionary *)dictionary
{
    
}

@end
