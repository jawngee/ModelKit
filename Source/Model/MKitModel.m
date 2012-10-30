//
//  MKitModel.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"
#import "MKitReflectionManager.h"
#import "MKitReflectedClass.h"
#import "MKitReflectedProperty.h"

#import "MKitModelRegistry.h"
#import "MKitModelContext.h"

#import "NSDate+ModelKit.h"
#import "NSString+ModelKit.h"

#import "JSONKit.h"


NSString *const MKitModelStateChangedNotification=@"MKitModelStateChangedNotification";
NSString *const MKitObjectIdentifierChangedNotification=@"MKitObjectIdentifierChangedNotification";
NSString *const MKitModelPropertyChangedNotification=@"MKitModelPropertyChangedNotification";
NSString *const MKitModelIdentifierChangedNotification=@"MKitModelIdentifierChangedNotification";

@interface MKitModel()

-(NSDate *)getDateFromId:(id)val;
-(NSDictionary *)serializeForJSON:(BOOL)encodeForJSON encodingCache:(NSMutableArray *)encodingCache;
-(void)deserialize:(NSDictionary *)dictionary fromJSON:(BOOL)fromJSON;
-(NSArray *)flattenArray:(NSArray *)array encodeForJSON:(BOOL)encodeForJSON encodingCache:(NSMutableArray *)encodingCache;
-(id)unflattenArray:(NSArray *)array decodeFromJSON:(BOOL)decodeFromJSON arrayClass:(Class)arrayClass;

@end

@implementation MKitModel

#pragma mark - Class Initialization

+(void)initialize
{
    // We are going to register this class and it's model name with the registry
    // so that when we pull down objects from a service we can correctly map
    // back and forth.
    
    MKitModel *inst=[[self alloc] init];

    if (inst.modelName!=nil)
        [MKitModelRegistry registerModel:inst.modelName forClass:[self class]];
    
    [inst removeFromContext];
    [inst release];
}

#pragma mark Init/Dealloc

-(id)init
{
    if ((self=[super init]))
    {
        _changing=NO;
        _modelState=ModelStateNew;
        _createdAt=[[NSDate date] retain];
        _updatedAt=[[NSDate date] retain];
        _modelId=[[NSString UUID] retain];
        
        if (![[self class] conformsToProtocol:@protocol(MKitNoContext)])
            [self addToContext];

        // We need observe our property changes to send out notifications
        MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
        [self addObserver:self forKeyPath:@"objectId" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        [self addObserver:self forKeyPath:@"updatedAt" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        [self addObserver:self forKeyPath:@"modelId" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
        for(MKitReflectedProperty *p in [ref.properties allValues])
            [self addObserver:self forKeyPath:p.name options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    }

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[self init]))
    {
        id val=nil;
        
        self.updatedAt=[aDecoder decodeObjectForKey:@"updatedAt"];
        self.createdAt=[aDecoder decodeObjectForKey:@"createdAt"];
        self.modelId=[aDecoder decodeObjectForKey:@"modelId"];
        val=[aDecoder decodeObjectForKey:@"objectId"];
        if (val)
            self.objectId=val;
        
        MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
        for(MKitReflectedProperty *p in [ref.properties allValues])
        {
            val=[aDecoder decodeObjectForKey:p.name];
            
            if (val==[NSNull null])
                val=nil;
            
            [self setValue:val forKey:p.name];
        }
    }
    
    return self;
}

-(void)dealloc
{
    // Remove our selves from as observers
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    [self removeObserver:self forKeyPath:@"objectId"];
    [self removeObserver:self forKeyPath:@"updatedAt"];
    [self removeObserver:self forKeyPath:@"modelId"];
    for(MKitReflectedProperty *p in [ref.properties allValues])
        [self removeObserver:self forKeyPath:p.name];
    
    self.objectId=nil;
    self.createdAt=nil;
    self.updatedAt=nil;
    self.modelId=nil;
    
    [super dealloc];
}

+(id)instanceWithId:(NSString *)objId
{
    MKitModel *instance=[[MKitModelContext current] modelForObjectId:objId andClass:[self class]];
    if (instance!=nil)
        return instance;
    
    instance=[[[[self class] alloc] init] autorelease];
    instance.objectId=objId;
    
    return instance;
}

+(id)instanceWithDictionary:(NSDictionary *)dictionary fromJSON:(BOOL)fromJSON
{
    MKitModel *instance=nil;
    if ([dictionary objectForKey:@"objectId"])
        instance=[[MKitModelContext current] modelForObjectId:[dictionary objectForKey:@"objectId"] andClass:[self class]];
    
    if (!instance)
    {
        instance=[[[[self class] alloc] init] autorelease];
        if ([dictionary objectForKey:@"objectId"])
            instance.objectId=[dictionary objectForKey:@"objectId"];
    }
    
    [instance deserialize:dictionary fromJSON:fromJSON];
    
    return instance;
}

+(id)instanceWithDictionary:(NSDictionary *)dictionary
{
    return [self instanceWithDictionary:dictionary fromJSON:NO];
}

+(id)instanceWithJSON:(NSString *)JSONString
{
    NSDictionary *jsonDict=[JSONString objectFromJSONString];
    
    return [self instanceWithDictionary:jsonDict fromJSON:YES];
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    
    [aCoder encodeObject:self.createdAt forKey:@"createdAt"];
    [aCoder encodeObject:self.updatedAt forKey:@"updatedAt"];
    
    if (self.objectId)
        [aCoder encodeObject:self.objectId forKey:@"objectId"];
    
    id val=nil;
    for(MKitReflectedProperty *p in [ref.properties allValues])
    {
        switch(p.type)
        {
            case refTypeId:
            case refTypeClass:
            case refTypeString:
            case refTypeNumber:
            case refTypeData:
            case refTypeDate:
            case refTypeArray:
            case refTypeDictionary:
            case refTypeChar:
            case refTypeShort:
            case refTypeInteger:
            case refTypeLong:
            case refTypeFloat:
            case refTypeDouble:
                val=[self valueForKey:p.name];
                if (val==nil)
                    val=[NSNull null];
                [aCoder encodeObject:val forKey:p.name];
                break;
                
            default:
                break;
        }
    }
}

#pragma mark - Property observation

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"modelId"])
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitModelIdentifierChangedNotification object:self userInfo:change];
    
    _hasChanged=YES;
    
    if (_changing)
        return;
    
    if (([keyPath isEqualToString:@"objectId"]) && (change[NSKeyValueChangeNewKey]!=[NSNull null]))
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitObjectIdentifierChangedNotification object:self];
    
    if (self.modelState==ModelStateValid)
    {
        self.modelState=ModelStateDirty;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitModelStateChangedNotification object:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MKitModelPropertyChangedNotification object:self userInfo:@{@"keyPath":keyPath,@"change":change}];
}

#pragma mark - Context related

-(void)addToContext
{
    [[MKitModelContext current] addToContext:self];
}

-(void)removeFromContext
{
    [[MKitModelContext current] removeFromContext:self];
}

#pragma mark - Notification

-(void)beginChanges
{
    _changing=YES;
    _hasChanged=NO;
}

-(void)endChanges
{
    _changing=NO;
    
    if (!_hasChanged)
        return;
    
    if (self.modelState==ModelStateValid)
    {
        self.modelState=ModelStateDirty;
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitModelStateChangedNotification object:self];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:MKitModelPropertyChangedNotification object:self userInfo:nil];
}

#pragma mark - Conversion

-(NSDate *)getDateFromId:(id)val
{
    if (val==nil)
        return nil;
    
    if ([[val class] isSubclassOfClass:[NSDate class]])
        return (NSDate *)val;
    
    if ([[val class] isSubclassOfClass:[NSDictionary class]])
    {
        NSString *type=[val objectForKey:@"__type"];
        if ((type==nil) || (![type isEqualToString:@"Date"]))
            return nil;
        
        NSString *iso=[val objectForKey:@"iso"];
        if (!iso)
            return nil;
        
        return [NSDate dateFromISO8601:iso];
    }
    
    if ([[val class] isSubclassOfClass:[NSString class]])
        return [NSDate dateFromISO8601:val];
    
    return nil;
}

-(NSArray *)flattenArray:(NSArray *)array encodeForJSON:(BOOL)encodeForJSON encodingCache:(NSMutableArray *)encodingCache
{
    NSMutableArray *replacement=[NSMutableArray array];
    
    for(NSObject *ele in array)
    {
        if ([ele isKindOfClass:[MKitModel class]])
        {
            MKitModel *m=(MKitModel *)ele;
            if ([encodingCache indexOfObject:m.objectId]!=NSNotFound)
            {
                NSString *modelName=(m.modelName) ? m.modelName : NSStringFromClass([m class]);
                [replacement addObject:@{@"__type":@"ModelPointer",@"objectId":m.objectId,@"model":modelName}];
            }
            else
            {
                if (encodeForJSON)
                    [replacement addObject:@{@"__type":@"Model",@"model":[((MKitModel *)ele) serializeForJSON:encodeForJSON encodingCache:encodingCache]}];
                else
                    [replacement addObject:[((MKitModel *)ele) serializeForJSON:encodeForJSON encodingCache:encodingCache]];
            }
        }
        else if ([ele isKindOfClass:[NSArray class]])
            [replacement addObject:[self flattenArray:(NSArray *)ele encodeForJSON:encodeForJSON encodingCache:encodingCache]];
        else if ([ele isKindOfClass:[NSDate class]])
        {
            if (encodeForJSON)
                [replacement addObject:@{@"__type":@"Date",@"iso":[((NSDate *)ele) ISO8601String]}];
            else
                [replacement addObject:ele];
        }
        else if (
                 ([ele isKindOfClass:[NSString class]]) ||
                 ([ele isKindOfClass:[NSNumber class]]) ||
                 ([ele isKindOfClass:[NSData class]])
                 )
        {
            [replacement addObject:ele];
        }
    }
    
    return replacement;
}

-(id)unflattenArray:(NSArray *)array decodeFromJSON:(BOOL)decodeFromJSON arrayClass:(Class)arrayClass
{
    if ((arrayClass==nil) || (![arrayClass isSubclassOfClass:[NSMutableArray class]]))
        arrayClass=[NSMutableArray class];
    
    NSMutableArray *replacement=[arrayClass array];
    
    for(NSObject *ele in array)
    {
        if ([[ele class] isSubclassOfClass:[NSDictionary class]])
        {
            NSDictionary *d=(NSDictionary *)ele;
            
            if (!decodeFromJSON)
            {
                if ([d objectForKey:@"__type"] && [[d objectForKey:@"__type"] isEqualToString:@"ModelPointer"])
                {
                    Class mc=[MKitModelRegistry registeredClassForModel:[d objectForKey:@"model"]];
                    if (!mc)
                        mc=NSClassFromString([d objectForKey:@"model"]);
                    if (!mc)
                        @throw [NSException exceptionWithName:@"Unknown model class" reason:[NSString stringWithFormat:@"Unknown model class '%@'",[d objectForKey:@"model"]] userInfo:d];
                    
                    MKitModel *m=[mc instanceWithId:[d objectForKey:@"objectId"]];
                    [replacement addObject:m];
                }
                else if ([d objectForKey:@"model"])
                {
                    Class mc=[MKitModelRegistry registeredClassForModel:[d objectForKey:@"model"]];
                    if (!mc)
                        mc=NSClassFromString([d objectForKey:@"model"]);
                    if (!mc)
                        @throw [NSException exceptionWithName:@"Unknown model class" reason:[NSString stringWithFormat:@"Unknown model class '%@'",[d objectForKey:@"model"]] userInfo:d];
                    
                    MKitModel *m=[mc instanceWithDictionary:d];
                    [replacement addObject:m];
                }
            }
            else
            {
                NSString *type=[d objectForKey:@"__type"];
                if (type)
                {
                    if ([type isEqualToString:@"Date"])
                    {
                        [replacement addObject:[self getDateFromId:d]];
                    }
                    else if ([type isEqualToString:@"Model"])
                    {
                        NSDictionary *md=[d objectForKey:@"model"];
                        Class mc=[MKitModelRegistry registeredClassForModel:[md objectForKey:@"model"]];
                        if (!mc)
                            mc=NSClassFromString([md objectForKey:@"model"]);
                        if (!mc)
                            @throw [NSException exceptionWithName:@"Unknown model class" reason:[NSString stringWithFormat:@"Unknown model class '%@'",[md objectForKey:@"model"]] userInfo:md];
                        
                        MKitModel *m=[mc instanceWithDictionary:md fromJSON:decodeFromJSON];
                        [replacement addObject:m];
                    }
                }
            }
        }
        else
        {
            [replacement addObject:ele];
        }
    }
    
    return replacement;

}

-(NSDictionary *)serializeForJSON:(BOOL)encodeForJSON encodingCache:(NSMutableArray *)encodingCache
{
    MKitMutableOrderedDictionary *result=[MKitMutableOrderedDictionary dictionary];
    
    if (encodingCache==nil)
        encodingCache=[[NSMutableArray array] retain];
    else
        [encodingCache retain];
    
    if (self.objectId)
        [encodingCache addObject:self.objectId];
    
    if (self.modelName)
        [result setObject:self.modelName forKey:@"model"];
    else
        [result setObject:NSStringFromClass([self class]) forKey:@"model"];
    
    if (self.objectId)
        [result setObject:self.objectId forKey:@"objectId"];
    
    if (encodeForJSON)
    {
        [result setObject:@{@"__type":@"Date",@"iso":[self.createdAt ISO8601String]} forKey:@"createdAt"];
        [result setObject:@{@"__type":@"Date",@"iso":[self.updatedAt ISO8601String]} forKey:@"updatedAt"];
    }
    else
    {
        [result setObject:self.createdAt forKey:@"createdAt"];
        [result setObject:self.updatedAt forKey:@"updatedAt"];
    }
    
    MKitMutableOrderedDictionary *props=[MKitMutableOrderedDictionary dictionary];
    [result setObject:props forKey:@"properties"];
    
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    
    for(MKitReflectedProperty *p in [ref.properties allValues])
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
            if ([obj isKindOfClass:[MKitModel class]])
            {
                MKitModel *m=(MKitModel *)val;
                if ([encodingCache indexOfObject:m.objectId]!=NSNotFound)
                {
                    NSString *modelName=(m.modelName) ? m.modelName : NSStringFromClass([m class]);
                    [props setObject:@{@"__type":@"ModelPointer",@"objectId":m.objectId,@"model":modelName} forKey:p.name];
                }
                else
                {
                    [encodingCache addObject:m.objectId];
                    if (encodeForJSON)
                        [props setObject:@{@"__type":@"Model",@"model":[((MKitModel *)obj) serializeForJSON:encodeForJSON encodingCache:encodingCache]} forKey:p.name];
                    else
                        [props setObject:[((MKitModel *)obj) serializeForJSON:encodeForJSON encodingCache:encodingCache] forKey:p.name];
                }
            }
        }
        else if (p.type==refTypeArray)
        {
            [props setObject:[self flattenArray:(NSArray *)val encodeForJSON:encodeForJSON encodingCache:encodingCache] forKey:p.name];
        }
        else if (p.type==refTypeDate)
        {
            if (encodeForJSON)
                [props setObject:@{@"__type":@"Date",@"iso":[((NSDate *)val) ISO8601String]} forKey:p.name];
            else
                [props setObject:val forKey:p.name];
        }
        else if ((p.type>=refTypeString && p.type<refTypeDate) || (p.type>=refTypeChar && p.type<refTypeUnknown))
        {
            [props setObject:val forKey:p.name];
        }
    }
    
    [encodingCache release];
    
    return result;
}

-(void)deserialize:(NSDictionary *)dictionary fromJSON:(BOOL)fromJSON
{
    self.updatedAt=[self getDateFromId:[dictionary objectForKey:@"updatedAt"]];
    self.createdAt=[self getDateFromId:[dictionary objectForKey:@"createdAt"]];
    
    id val=[dictionary objectForKey:@"objectId"];
    
    if ((val!=[NSNull null]) && (val!=nil))
        self.objectId=val;
    
    NSDictionary *props=[dictionary objectForKey:@"properties"];
    if (!props)
        props=dictionary;
    
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    val=nil;
    for(MKitReflectedProperty *p in [ref.properties allValues])
    {
        val=[props objectForKey:p.name];
        if (val==[NSNull null])
            val=nil;
        
        switch(p.type)
        {
            case refTypeId:
            case refTypeClass:
                if ((val!=nil) && ([p.typeClass isSubclassOfClass:[MKitModel class]]))
                {
                    if ([[val class] isSubclassOfClass:[NSDictionary class]])
                    {
                        NSDictionary *md=(NSDictionary *)val;
                        if (([md objectForKey:@"__type"]) && ([[md objectForKey:@"__type"] isEqualToString:@"ModelPointer"]))
                        {
                            MKitModel *model=[p.typeClass instanceWithId:[md objectForKey:@"objectId"]];
                            [self setValue:model forKey:p.name];
                        }
                        else if (fromJSON)
                        {
                            MKitModel *m=[[[p.typeClass alloc] init] autorelease];
                            [m deserialize:[dictionary objectForKey:@"model"] fromJSON:YES];
                            [self setValue:m forKey:p.name];
                        }
                        else
                            [self setValue:[p.typeClass instanceWithDictionary:val] forKey:p.name];
                    }
                    else if ([[val class] isSubclassOfClass:[MKitModel class]])
                    {
                        [self setValue:val forKey:p.name];
                    }
                    else
                        [self setValue:nil forKey:p.name];
                    
                }
                else
                    [self setValue:nil forKey:p.name];
                break;
            case refTypeString:
            case refTypeNumber:
            case refTypeChar:
            case refTypeShort:
            case refTypeInteger:
            case refTypeLong:
            case refTypeFloat:
            case refTypeDouble:
                [self setValue:val forKey:p.name];
                break;
            case refTypeArray:
                [self setValue:[self unflattenArray:val decodeFromJSON:fromJSON arrayClass:p.typeClass] forKey:p.name];
                break;
            case refTypeDictionary:
                [self setValue:nil forKey:p.name];
                break;
            case refTypeData:
                [self setValue:nil forKey:p.name];
                break;
            case refTypeDate:
                if (val)
                    [self setValue:[self getDateFromId:val] forKey:p.name];
                else
                    [self setValue:nil forKey:p.name];
                break;
            default:
                break;
        }
    }
}


-(NSDictionary *)serialize
{
    return [self serializeForJSON:NO encodingCache:nil];
}

-(void)deserialize:(NSDictionary *)dictionary
{
    [self deserialize:dictionary fromJSON:NO];
}

-(NSString *)serializeToJSON
{
    NSDictionary *d=[self serializeForJSON:YES encodingCache:nil];
    return [d JSONStringWithOptions:JKSerializeOptionPretty error:nil];
}

-(void)deserializeFromJSON:(NSString *)jsonString
{
    [self deserialize:[jsonString objectFromJSONString] fromJSON:YES];
}

@end
