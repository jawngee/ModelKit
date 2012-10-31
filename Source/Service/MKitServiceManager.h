//
//  MKitServiceManager.h
//  ModelKit
//
//  Created by Jon Gilkison on 10/29/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MKitModel.h"

@interface MKitServiceManager : NSObject

+(MKitServiceManager *)setupService:(NSString *)name withKeys:(NSDictionary *)keys;
+(MKitServiceManager *)managerForService:(NSString *)name;

-(id)initWithKeys:(NSDictionary *)keys;

-(BOOL)saveModel:(MKitModel *)model error:(NSError **)error;
-(void)saveModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock;

-(BOOL)deleteModel:(MKitModel *)model error:(NSError **)error;
-(void)deleteModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock;

-(BOOL)fetchModel:(MKitModel *)model error:(NSError **)error;
-(void)fetchModelInBackground:(MKitModel *)model withBlock:(MKitBooleanResultBlock)resultBlock;


@end
