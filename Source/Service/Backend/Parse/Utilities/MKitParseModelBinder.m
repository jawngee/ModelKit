//
//  MKitParseModelBinder.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/1/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitParseModelBinder.h"
#import "NSDate+ModelKit.h"
#import "MKitReflectedClass.h"
#import "MKitReflectedProperty.h"
#import "MKitReflectionManager.h"
#import "MKitServiceModel.h"
#import "MKitMutableModelArray.h"
#import "MKitModel+Parse.h"
#import "MKitMutableModelArray+Parse.h"
#import "MKitModelRegistry.h"
#import "MKitParseFile.h"
#import "MKitGeoPoint.h"
#import "MKitGeoPoint+Parse.h"

@implementation MKitParseModelBinder


+(void)bindModel:(MKitModel *)model data:(NSDictionary *)data
{
    model.modelState=ModelStateValid;
    
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[model class] ignorePropPrefix:@"model" ignoreProperties:[[model class] ignoredProperties] recurseChainUntil:[MKitModel class]];
    
    if ((data[@"modelId"]) && (data[@"modelId"]!=[NSNull null]))
        model.modelId=data[@"modelId"];
    
    if ((data[@"createdAt"]) && (data[@"createdAt"]!=[NSNull null]))
        model.createdAt=[NSDate dateFromISO8601:data[@"createdAt"]];
    
    if ((data[@"updatedAt"]) && (data[@"updatedAt"]!=[NSNull null]))
        model.updatedAt=[NSDate dateFromISO8601:data[@"updatedAt"]];
    
    [ref.properties enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        MKitReflectedProperty *prop=obj;
        
        if (data[prop.name]==[NSNull null])
        {
            [model setValue:nil forKey:prop.name];
        }
        else if ([prop.typeClass isSubclassOfClass:[MKitModel class]])
        {
            MKitModel *m=nil;
            NSDictionary *md=[data objectForKey:prop.name];
            if ((md[@"__type"]) && ([md[@"__type"] isEqualToString:@"Object"]))
            {
                m=[prop.typeClass instanceWithObjectId:md[@"objectId"]];
                [self bindModel:m data:md];
            }
            else if ((md[@"__type"]) && ([md[@"__type"] isEqualToString:@"Pointer"]))
            {
                m=[prop.typeClass instanceWithObjectId:md[@"objectId"]];
                if ((m.modelState==ModelStateNeedsData) && ([prop.typeClass isSubclassOfClass:[MKitServiceModel class]]))
                    [((MKitServiceModel *)m) fetchInBackground:nil];
            }
            
            [model setValue:m forKey:prop.name];
        }
        else if ([prop.typeClass isSubclassOfClass:[MKitMutableModelArray class]])
        {
            NSArray *vals=data[prop.name];
            if (vals)
            {
                MKitMutableModelArray *objs=[MKitMutableModelArray array];
                
                for(NSDictionary *md in vals)
                {
                    NSString *cname=md[@"className"];
                    Class c=[MKitModelRegistry registeredClassForModel:cname];
                    if (!c)
                        c=NSClassFromString(cname);
                    if (!c)
                        @throw [NSException exceptionWithName:@"Invalid Class Name" reason:[NSString stringWithFormat:@"Parse returned an unknown classname '%@'.",cname] userInfo:md];
                    
                    MKitModel *m=nil;
                    m=[c instanceWithObjectId:md[@"objectId"]];
                    if ((md[@"__type"]) && ([md[@"__type"] isEqualToString:@"Object"]))
                        [self bindModel:m data:md];
                    else if ((md[@"__type"]) && ([md[@"__type"] isEqualToString:@"Pointer"]))
                    {
                        if ((m.modelState==ModelStateNeedsData) && ([c isSubclassOfClass:[MKitServiceModel class]]))
                            [((MKitServiceModel *)m) fetchInBackground:nil];
                    }
                    
                    [objs addObject:m];
                }
                
                [model setValue:objs forKey:prop.name];
            }
            else
                [model setValue:nil forKey:prop.name];
        }
        else if ([prop.typeClass isSubclassOfClass:[NSDate class]])
        {
            id val=data[prop.name];
            if ([val isKindOfClass:[NSDictionary class]])
            {
                NSDictionary *dict=(NSDictionary *)val;
                if ([dict[@"__type"] isEqualToString:@"Date"])
                {
                    [model setValue:[NSDate dateFromISO8601:dict[@"iso"]] forKey:prop.name];
                }
                else
                    [NSException raise:@"Date is an unknown dictionary type." format:@"Data: %@",dict];
            }
            else if (val!=nil)
            {
                [model setValue:[NSDate dateFromISO8601:data[prop.name]] forKey:prop.name];
            }
        }
        else if ([prop.typeClass isSubclassOfClass:[MKitServiceFile class]])
        {
            NSDictionary *fileDict=data[prop.name];
            if (fileDict)
            {
                MKitParseFile *file=[MKitParseFile fileWithName:fileDict[@"name"] andURL:fileDict[@"url"]];
                [model setValue:file forKey:prop.name];
            }
        }
        else if ([prop.typeClass isSubclassOfClass:[MKitGeoPoint class]])
        {
            NSDictionary *geoDict=data[prop.name];
            if (geoDict)
                [model setValue:[MKitGeoPoint geoPointWithLatitude:[geoDict[@"latitude"] doubleValue] andLongitude:[geoDict[@"longitude"] doubleValue]] forKey:prop.name];
        }
        else
        {
            if (data[prop.name])
            {
                [model setValue:data[prop.name] forKey:prop.name];
            }
        }
    }];
    
    [model resetChanges];
}

+(NSArray *)bindArrayOfModels:(NSArray *)models forClass:(Class)modelClass
{
    NSMutableArray *result=[NSMutableArray array];
    for(NSDictionary *d in models)
    {
        MKitModel *m=[modelClass instanceWithObjectId:d[@"objectId"]];
        
        [self bindModel:m data:d];
        
        [result addObject:m];
    }
    
    return result;
}

+(id)processParseArray:(NSMutableArray *)functionArray
{
    NSMutableArray *array=[NSMutableArray array];
    
    for(id obj in functionArray)
    {
        if ([[obj class] isSubclassOfClass:[NSDictionary class]])
            obj=[self processParseDictionary:obj];
        else if ([[obj class] isSubclassOfClass:[NSArray class]])
            obj=[self processParseArray:obj];
        
        [array addObject:obj];
    }
    
    return array;
}

+(id)extractModel:(NSDictionary *)dictionary
{
    MKitModel *m=nil;
    NSString *type=nil;
    if ((type=dictionary[@"__type"]))
    {
        NSString *cname=dictionary[@"className"];
        Class c=[MKitModelRegistry registeredClassForModel:cname];
        if (!c)
            c=NSClassFromString(cname);
        if (!c)
            @throw [NSException exceptionWithName:@"Invalid Class Name" reason:[NSString stringWithFormat:@"Parse returned an unknown classname '%@'.",cname] userInfo:dictionary];
        m=[c instanceWithObjectId:dictionary[@"objectId"]];
        if ([type isEqualToString:@"Object"])
            [self bindModel:m data:dictionary];
        else if ([type isEqualToString:@"Pointer"])
        {
            if ((m.modelState==ModelStateNeedsData) && ([c isSubclassOfClass:[MKitServiceModel class]]))
                [((MKitServiceModel *)m) fetchInBackground:nil];
        }
        
    }
    
    return m;
}

+(id)processParseDictionary:(NSDictionary *)dictionary
{
    if (dictionary[@"__type"])
        return [self extractModel:dictionary];
    
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
       if ([[obj class] isSubclassOfClass:[NSDictionary class]])
       {
           if (obj[@"__type"])
           {
               id res=[self extractModel:obj];
               
               if (res)
                   [result setObject:res forKey:key];
           }
           else
               [result setObject:[self processParseDictionary:obj] forKey:key];
       }
       else if ([[obj class] isSubclassOfClass:[NSArray class]])
       {
           NSMutableArray *array=[self processParseArray:obj];
           [result setObject:array forKey:key];
       }
       else
       {
           [result setObject:obj forKey:key];
       }
    }];
    
    return result;
}


+(id)processParseResult:(id)result
{
    if ([[result class] isSubclassOfClass:[NSDictionary class]])
        return [self processParseDictionary:result];
    
    if ([[result class] isSubclassOfClass:[NSArray class]])
        return [self processParseArray:result];
    
    return result;
}

+(NSMutableArray *)prepareParseParametersArray:(NSArray *)array
{
    NSMutableArray *result=[NSMutableArray array];
    
    for(id obj in array)
    {
        if ([[obj class] isSubclassOfClass:[NSDictionary class]])
            [result addObject:[self prepareParseParameters:obj]];
        else if ([[obj class] isSubclassOfClass:[MKitMutableModelArray class]])
        {
            MKitMutableModelArray *modelArray=(MKitMutableModelArray *)obj;
            NSMutableArray *array=[NSMutableArray array];
            for(MKitServiceModel *model in modelArray)
            {
                if (model.modelState!=ModelStateValid)
                    @throw [NSException exceptionWithName:@"Invalid Model State" reason:@"Models must be in a valid state." userInfo:nil];
                
                [array addObject:[model parsePointer]];
            }
            
            [result addObject:array];
        }
        else if ([[obj class] isSubclassOfClass:[NSArray class]])
        {
            [result addObject:[self prepareParseParametersArray:obj]];
        }
        else if ([[obj class] isSubclassOfClass:[NSDate class]])
        {
            NSDate *date=(NSDate *)obj;
            [result addObject:@{@"__type":@"Date",@"iso":[date ISO8601String]}];
        }
        else if ([[obj class] isSubclassOfClass:[MKitServiceModel class]])
        {
            MKitServiceModel *model=(MKitServiceModel *)obj;
            if (model.modelState!=ModelStateValid)
                @throw [NSException exceptionWithName:@"Invalid Model State" reason:@"Models must be in a valid state." userInfo:nil];
            
            [result addObject:[model parsePointer]];
        }
        else if ([[obj class] isSubclassOfClass:[MKitParseFile class]])
        {
            MKitParseFile *file=(MKitParseFile *)obj;
            [result addObject:[file parseFilePointer]];
        }
        else if ([[obj class] isSubclassOfClass:[MKitGeoPoint class]])
        {
            MKitGeoPoint *geoPoint=(MKitGeoPoint *)obj;
            [result addObject:[geoPoint parsePointer]];
        }
        else
            [result addObject:obj];
    }
    
    return result;
}

+(NSDictionary *)prepareParseParametersDictionary:(NSDictionary *)dictionary
{
    NSMutableDictionary *result=[NSMutableDictionary dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if ([[obj class] isSubclassOfClass:[NSDictionary class]])
            [result setObject:[self prepareParseParameters:obj] forKey:key];
        else if ([[obj class] isSubclassOfClass:[MKitMutableModelArray class]])
        {
            MKitMutableModelArray *modelArray=(MKitMutableModelArray *)obj;
            NSMutableArray *array=[NSMutableArray array];
            for(MKitServiceModel *model in modelArray)
            {
                if (model.modelState!=ModelStateValid)
                    @throw [NSException exceptionWithName:@"Invalid Model State" reason:@"Models must be in a valid state." userInfo:nil];
                
                [array addObject:[model parsePointer]];
            }
            
            [result setObject:array forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[NSArray class]])
        {
            [result setObject:[self prepareParseParametersArray:obj] forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[NSDate class]])
        {
            NSDate *date=(NSDate *)obj;
            [result setObject:@{@"__type":@"Date",@"iso":[date ISO8601String]} forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[MKitServiceModel class]])
        {
            MKitServiceModel *model=(MKitServiceModel *)obj;
            if (model.modelState!=ModelStateValid)
                @throw [NSException exceptionWithName:@"Invalid Model State" reason:@"Models must be in a valid state." userInfo:nil];

            [result setObject:[model parsePointer] forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[MKitParseFile class]])
        {
            MKitParseFile *file=(MKitParseFile *)obj;
            [result setObject:[file parseFilePointer] forKey:key];
        }
        else if ([[obj class] isSubclassOfClass:[MKitGeoPoint class]])
        {
            MKitGeoPoint *geoPoint=(MKitGeoPoint *)obj;
            [result setObject:[geoPoint parsePointer] forKey:key];
        }
        else
            [result setObject:obj forKey:key];
    }];
    
    return result;
}

+(id)prepareParseParameters:(id)parameters
{
    if ([[parameters class] isSubclassOfClass:[NSDictionary class]])
        return [self prepareParseParametersDictionary:parameters];
    
    if ([[parameters class] isSubclassOfClass:[NSArray class]])
        return [self prepareParseParametersArray:parameters];
    
    return parameters;
}

@end
