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
    
    MKitReflectedClass *ref=[MKitReflectionManager reflectionForClass:[model class] ignorePropPrefix:@"model" recurseChainUntil:[MKitModel class]];
    
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
            [model setValue:[NSDate dateFromISO8601:data[prop.name]] forKey:prop.name];
        }
        else if ([prop.typeClass isSubclassOfClass:[MKitServiceFile class]])
        {
            NSDictionary *fileDict=data[prop.name];
            [model setValue:[MKitParseFile fileWithName:fileDict[@"name"] andURL:fileDict[@"url"]] forKey:prop.name];
        }
        else if ([prop.typeClass isSubclassOfClass:[MKitGeoPoint class]])
        {
            NSDictionary *geoDict=data[prop.name];
            [model setValue:[MKitGeoPoint geoPointWithLatitude:[geoDict[@"latitude"] doubleValue] andLongitude:[geoDict[@"longitude"] doubleValue]] forKey:prop.name];
        }
        else
        {
            [model setValue:data[prop.name] forKey:prop.name];
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


@end
