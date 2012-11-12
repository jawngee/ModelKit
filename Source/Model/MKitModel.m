//
//  MKitModel.m
//  ModelKit
//
//  Created by Jon Gilkison on 10/25/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitModel.h"
#import "MKitModelPredicateQuery.h"
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

/**
 * Private methods
 */
@interface MKitModel(Internal)

/**
 * Basic setup
 */
-(void)setup;


/**
 * Registers for property change notifications
 */
-(void)registerForNotifications;

/**
 * Returns an NSDate from the val, which may be a string or dictionary.
 * @param val The value to convert to an NSDate
 * @return The converted date
 */
-(NSDate *)getDateFromId:(id)val;

/**
 * Searches the objectArray for an object with matching objectId or modelId specified in the dict.
 * @param dict The dictionary containing the objectId or modelId of the object to search for
 * @param objectArray The object array to search through
 * @return The found model's data dictionary, nil if not found.
 */
-(NSDictionary *)getObjectFromDictionary:(NSDictionary *)dict objectArray:(NSArray *)objectArray;

/**
 * Flattens an array into a serialized array
 * @param array The array to flatten
 * @param encodeForJSON Is this array being encoded for JSON
 * @param encodingCache A cache of objects
 * @return The flattened array
 */
-(NSArray *)flattenArray:(NSArray *)array encodeForJSON:(BOOL)encodeForJSON encodingCache:(MKitMutableOrderedDictionary *)encodingCache;

/**
 * Main serialization method
 * @param encodeForJSON This method is being serialized for eventual JSON
 * @param encodingCache The cache of objects being serialized
 */
-(void)serializeForJSON:(BOOL)encodeForJSON encodingCache:(MKitMutableOrderedDictionary *)encodingCache;

/**
 * Unflattens a serialized array back into its original form.
 * @param array The flattened array to be deserialized
 * @param decodeFromJSON Indiciates this array came from a JSON string
 * @param arrayClass The class of the new deserialized array, if nil defaults to NSMutableArray
 * @param objectArray Array of already deserialized objects for resolving references
 * @param decodingCache Dictionary of already deserialzied objects
 * @return The unflattened array
 */
-(id)unflattenArray:(NSArray *)array decodeFromJSON:(BOOL)decodeFromJSON arrayClass:(Class)arrayClass objectArray:(NSArray *)objectArray decodingCache:(NSMutableDictionary *)decodingCache;

/**
 * Main deserializtion method
 * @param dictionary The dictionary being deserialized
 * @param fromJSON Indicates the dictionary came from JSON
 * @param objectArray An array of already deserialized objects
 * @param decodingCache Dictionary of already deserialized objects
 */
-(void)deserialize:(NSDictionary *)dictionary fromJSON:(BOOL)fromJSON objectArray:(NSArray *)objectArray decodingCache:(NSMutableDictionary *)decodingCache;

@end

@implementation MKitModel

@synthesize modelChanges=_modelChanges;

#pragma mark - Class Initialization

+(NSString *)modelName
{
    return NSStringFromClass(self);
}

+(void)register
{
    // We are going to register this class and it's model name with the registry
    // so that when we pull down objects from a service we can correctly map
    // back and forth.
    
    [MKitModelRegistry registerModel:[self modelName] forClass:self];
}

#pragma mark Init/Dealloc

-(void)setup
{
    _changing=NO;
    _modelState=ModelStateNew;
    _createdAt=[[NSDate date] retain];
    _updatedAt=[[NSDate date] retain];
    _modelId=[[NSString UUID] retain];
    _modelChanges=[[NSMutableDictionary dictionary] retain];
    
    if (![[self class] conformsToProtocol:@protocol(MKitNoContext)])
        [self addToContext];
}

-(id)init
{
    if ((self=[super init]))
    {
        [self setup];
        [self registerForNotifications];
    }

    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[super init]))
    {
        [self setup];
        
        [self beginChanges];
        
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
    
        [self endChanges];
        [self registerForNotifications];
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
    
    [_modelChanges release];
    
    [super dealloc];
}

#pragma mark - Static Initializers

+(id)instance
{
    return [[[[self class] alloc] init] autorelease];
}

+(id)instanceWithObjectId:(NSString *)objId
{
    MKitModel *instance=[[MKitModelContext current] modelForObjectId:objId andClass:[self class]];
    if (instance!=nil)
        return instance;
    
    instance=[[[[self class] alloc] init] autorelease];
    instance.objectId=objId;
    instance.modelState=ModelStateNeedsData;
    
    return instance;
}

+(id)instanceWithModelId:(NSString *)modId
{
    MKitModel *instance=[[MKitModelContext current] modelForModelId:modId];
    if (instance!=nil)
        return instance;
    
    instance=[[[[self class] alloc] init] autorelease];
    instance.modelId=modId;
    
    return instance;
}

+(id)instanceWithSerializedData:(id)data fromJSON:(BOOL)fromJSON
{
    MKitModel *instance=nil;
    
    NSDictionary *odict=nil;
    NSArray *oarray=nil;
    
    if ([[data class] isSubclassOfClass:[NSDictionary class]])
        odict=(NSDictionary *)data;
    else if ([[data class] isSubclassOfClass:[NSArray class]])
    {
        oarray=data;
        odict=[data objectAtIndex:0];
    }
    else
        @throw [NSException exceptionWithName:@"Invalid Serialized Data" reason:@"Data must be either a dictionary or array" userInfo:nil];
    
    if ((odict[@"objectId"]) && (odict[@"objectId"]!=[NSNull null]))
        instance=[[MKitModelContext current] modelForObjectId:odict[@"objectId"] andClass:[self class]];
    else if ((odict[@"modelId"]) && (odict[@"modelId"]!=[NSNull null]))
        instance=[[MKitModelContext current] modelForModelId:odict[@"modelId"]];
    
    if (!instance)
    {
        instance=[[[[self class] alloc] init] autorelease];
        if ((odict[@"objectId"]) && (odict[@"objectId"]!=[NSNull null]))
            instance.objectId=odict[@"objectId"];
    }
    
    [instance deserialize:odict fromJSON:fromJSON objectArray:oarray decodingCache:[NSMutableDictionary dictionary]];
    
    return instance;
}

+(id)instanceWithSerializedData:(id)data
{
    return [self instanceWithSerializedData:data fromJSON:NO];
}

+(id)instanceWithJSON:(NSString *)JSONString
{
    id jsonData=[JSONString objectFromJSONString];
    
    return [self instanceWithSerializedData:jsonData fromJSON:YES];
}


#pragma mark - Query

+(MKitModelQuery *)query
{
    return [MKitModelPredicateQuery queryForModelClass:self];
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    
    [aCoder encodeObject:self.createdAt forKey:@"createdAt"];
    [aCoder encodeObject:self.updatedAt forKey:@"updatedAt"];
    [aCoder encodeObject:self.modelId forKey:@"modelId"];
    
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

-(void)registerForNotifications
{
    // We need observe our property changes to send out notifications
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    [self addObserver:self forKeyPath:@"objectId" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"updatedAt" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    [self addObserver:self forKeyPath:@"modelId" options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
    for(MKitReflectedProperty *p in [ref.properties allValues])
        [self addObserver:self forKeyPath:p.name options:(NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld) context:NULL];
}


-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{

    if ([keyPath isEqualToString:@"modelId"])
        [[NSNotificationCenter defaultCenter] postNotificationName:MKitModelIdentifierChangedNotification object:self userInfo:change];
    
    _hasChanged=YES;
    
    if ((![keyPath hasPrefix:@"model"]) && ([@[@"updatedAt",@"createdAt",@"objectId"] indexOfObject:keyPath]==NSNotFound))
        [_modelChanges setObject:change[NSKeyValueChangeNewKey] forKey:keyPath];
    
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

-(void)resetChanges
{
    if (_changing)
        return;
    
    _hasChanged=NO;
    [_modelChanges removeAllObjects];
}

#pragma mark - Private serialization/deserialization methods

-(NSDictionary *)getObjectFromDictionary:(NSDictionary *)dict objectArray:(NSArray *)objectArray;
{
    NSString *oid=dict[@"objectId"];
    NSString *mid=dict[@"modelId"];
    
    for(NSDictionary *d in objectArray)
        if ((oid) && ([oid isEqualToString:d[@"objectId"]]))
            return d;
        else if ((mid) && ([mid isEqualToString:d[@"modelId"]]))
            return d;
    
    return nil;
}

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

-(NSArray *)flattenArray:(NSArray *)array encodeForJSON:(BOOL)encodeForJSON encodingCache:(MKitMutableOrderedDictionary *)encodingCache
{
    NSMutableArray *replacement=[NSMutableArray array];
    
    for(NSObject *ele in array)
    {
        if ([ele isKindOfClass:[MKitModel class]])
        {
            MKitModel *m=(MKitModel *)ele;
            if (![encodingCache objectForKey:m.modelId])
                [m serializeForJSON:encodeForJSON encodingCache:encodingCache];
            
            [replacement addObject:@{@"__type":@"ModelPointer",@"objectId":(m.objectId) ? m.objectId : [NSNull null],@"modelId":m.modelId,@"model":[[m class] modelName]}];
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

-(void)serializeForJSON:(BOOL)encodeForJSON encodingCache:(MKitMutableOrderedDictionary *)encodingCache
{
    MKitMutableOrderedDictionary *result=[MKitMutableOrderedDictionary dictionary];
    
    [encodingCache setValue:result forKey:self.modelId];
    
    [result setObject:self.modelId forKey:@"modelId"];
    
    [result setObject:[[self class] modelName] forKey:@"model"];
    
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
                if (![encodingCache objectForKey:m.modelId])
                    [m serializeForJSON:encodeForJSON encodingCache:encodingCache];

                [props setObject:@{@"__type":@"ModelPointer",@"objectId":(m.objectId) ? m.objectId : [NSNull null],@"modelId":m.modelId,@"model":[[m class] modelName]} forKey:p.name];
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
}

-(id)unflattenArray:(NSArray *)array decodeFromJSON:(BOOL)decodeFromJSON arrayClass:(Class)arrayClass objectArray:(NSArray *)objectArray decodingCache:(NSMutableDictionary *)decodingCache
{
    if ((arrayClass==nil) || (![arrayClass isSubclassOfClass:[NSMutableArray class]]))
        arrayClass=[NSMutableArray class];
    
    NSMutableArray *replacement=[arrayClass array];
    
    for(NSObject *ele in array)
    {
        if ([[ele class] isSubclassOfClass:[NSDictionary class]])
        {
            NSDictionary *d=(NSDictionary *)ele;
            if ([d objectForKey:@"__type"] && [[d objectForKey:@"__type"] isEqualToString:@"ModelPointer"])
            {
                Class mc=[MKitModelRegistry registeredClassForModel:[d objectForKey:@"model"]];
                if (!mc)
                    mc=NSClassFromString([d objectForKey:@"model"]);
                if (!mc)
                    @throw [NSException exceptionWithName:@"Unknown model class" reason:[NSString stringWithFormat:@"Unknown model class '%@'",[d objectForKey:@"model"]] userInfo:d];
                
                MKitModel *model=nil;
                if ((d[@"modelId"]) && (d[@"modelId"]!=[NSNull null]))
                    model=[decodingCache objectForKey:d[@"modelId"]];
                
                if (model==nil)
                {
                    NSDictionary *lookupDict=[self getObjectFromDictionary:d objectArray:objectArray];
                    if (!lookupDict)
                        @throw [NSException exceptionWithName:@"Missing Model Dictionary" reason:@"Could not find model dictionary for model pointer" userInfo:d];
                    
                    if ((lookupDict[@"objectId"]) && (lookupDict[@"objectId"]!=[NSNull null]))
                        model=[mc instanceWithObjectId:lookupDict[@"objectId"]];
                    else if ((lookupDict[@"modelId"]) && (lookupDict[@"modelId"]!=[NSNull null]))
                    {
                        model=[[MKitModelContext current] modelForModelId:lookupDict[@"modelId"]];
                        if (!model)
                        {
                            model=[[[mc alloc] init] autorelease];
                            model.modelId=lookupDict[@"modelId"];
                        }
                    }
                    
                    [model deserialize:lookupDict fromJSON:decodeFromJSON objectArray:objectArray decodingCache:decodingCache];
                    [decodingCache setObject:model forKey:model.modelId];
                }
                
                if (model)
                    [replacement addObject:model];
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

-(void)deserialize:(NSDictionary *)dictionary fromJSON:(BOOL)fromJSON objectArray:(NSArray *)objectArray decodingCache:(NSMutableDictionary *)decodingCache
{
    self.updatedAt=[self getDateFromId:[dictionary objectForKey:@"updatedAt"]];
    self.createdAt=[self getDateFromId:[dictionary objectForKey:@"createdAt"]];
    
    id val=[dictionary objectForKey:@"modelId"];
    if ((val) && (val!=[NSNull null]))
        self.modelId=val;
    
    val=[dictionary objectForKey:@"objectId"];
    if ((val) && (val!=[NSNull null]))
        self.objectId=val;
    
    [decodingCache setObject:self forKey:self.modelId];
    
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
                            MKitModel *model=nil;
                            if ((md[@"modelId"]) && (md[@"modelId"]!=[NSNull null]))
                                model=[decodingCache objectForKey:md[@"modelId"]];
                            
                            if (model==nil)
                            {
                                NSDictionary *lookupDict=[self getObjectFromDictionary:md objectArray:objectArray];
                                if (!lookupDict)
                                    @throw [NSException exceptionWithName:@"Missing Model Dictionary" reason:@"Could not find model dictionary for model pointer" userInfo:md];
                                
                                if ((lookupDict[@"objectId"]) && (lookupDict[@"objectId"]!=[NSNull null]))
                                    model=[p.typeClass instanceWithObjectId:lookupDict[@"objectId"]];
                                else if ((lookupDict[@"modelId"]) && (lookupDict[@"modelId"]!=[NSNull null]))
                                {
                                    model=[[MKitModelContext current] modelForModelId:lookupDict[@"modelId"]];
                                    if (!model)
                                    {
                                        model=[[[p.typeClass alloc] init] autorelease];
                                        model.modelId=lookupDict[@"modelId"];
                                    }
                                }
                                
                                [model deserialize:lookupDict fromJSON:fromJSON objectArray:objectArray decodingCache:decodingCache];
                                [decodingCache setObject:model forKey:model.modelId];
                            }
                            
                            [self setValue:model forKey:p.name];
                        }
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
                [self setValue:[self unflattenArray:val decodeFromJSON:fromJSON arrayClass:p.typeClass objectArray:objectArray decodingCache:decodingCache] forKey:p.name];
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

#pragma mark - Public serialization/deserialization methods

-(NSDictionary *)properties
{
    MKitMutableOrderedDictionary *result=[MKitMutableOrderedDictionary dictionary];
    
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[self class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    
    for(MKitReflectedProperty *prop in [ref.properties allValues])
    {
        id val=[self valueForKey:prop.name];
        if (val==nil)
            val=[NSNull null];
        [result setObject:val forKey:prop.name];
    }
    
    return result;
}

-(id)serialize
{
    MKitMutableOrderedDictionary *encodingCache=[MKitMutableOrderedDictionary dictionary];
    [self serializeForJSON:NO encodingCache:encodingCache];
    if (encodingCache.count==1)
        return [[encodingCache allValues] lastObject];
    else
        return [encodingCache allValues];
}

-(void)deserialize:(id)data
{
    NSDictionary *odict=nil;
    NSArray *oarray=nil;
    
    if ([[data class] isSubclassOfClass:[NSDictionary class]])
        odict=(NSDictionary *)data;
    else if ([[data class] isSubclassOfClass:[NSArray class]])
    {
        oarray=data;
        odict=[data objectAtIndex:0];
    }
    else
        @throw [NSException exceptionWithName:@"Invalid Serialized Data" reason:@"Data must be either a dictionary or array" userInfo:nil];

    [self deserialize:odict fromJSON:NO objectArray:oarray decodingCache:[NSMutableDictionary dictionary]];
}

-(NSString *)serializeToJSON
{
    MKitMutableOrderedDictionary *encodingCache=[MKitMutableOrderedDictionary dictionary];
    [self serializeForJSON:YES encodingCache:encodingCache];
    
    id result;
    if (encodingCache.count==1)
        result=[[encodingCache allValues] lastObject];
    else
        result=[encodingCache allValues];

    return [result JSONStringWithOptions:JKSerializeOptionPretty error:nil];
}

-(void)deserializeFromJSON:(NSString *)jsonString
{
    id data=[jsonString objectFromJSONString];
    
    NSDictionary *odict=nil;
    NSArray *oarray=nil;
    
    if ([[data class] isSubclassOfClass:[NSDictionary class]])
        odict=(NSDictionary *)data;
    else if ([[data class] isSubclassOfClass:[NSArray class]])
    {
        oarray=data;
        odict=[data objectAtIndex:0];
    }
    else
        @throw [NSException exceptionWithName:@"Invalid Serialized Data" reason:@"Data must be either a dictionary or array" userInfo:nil];
    
    [self deserialize:odict fromJSON:YES objectArray:oarray decodingCache:[NSMutableDictionary dictionary]];
}

-(NSString *)debugDescription
{
    NSMutableArray *propsStrings=[NSMutableArray array];
    
    [propsStrings addObject:[NSString stringWithFormat:@"\t%@: %@;",@"objectId",self.modelId]];
    [propsStrings addObject:[NSString stringWithFormat:@"\t%@: %d;",@"modelState",self.modelState]];
    [propsStrings addObject:[NSString stringWithFormat:@"\t%@: %@;",@"objectId",self.objectId]];
    [propsStrings addObject:[NSString stringWithFormat:@"\t%@: %@;",@"createdAt",self.createdAt]];
    [propsStrings addObject:[NSString stringWithFormat:@"\t%@: %@;",@"updateAt",self.updatedAt]];
    
    NSDictionary *props=[self properties];
    [props enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [propsStrings addObject:[NSString stringWithFormat:@"%@: %@",key,obj]];
    }];
    
    return [NSString stringWithFormat:@"<%@: %p> { %@ }",NSStringFromClass([self class]),self,[propsStrings componentsJoinedByString:@";\n"]];
}

@end
