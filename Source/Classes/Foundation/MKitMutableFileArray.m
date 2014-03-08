//
//  MKitMutableFileArray.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/7/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitMutableFileArray.h"
#import "MKitServiceFile.h"
#import "MKitModelGraph.h"

@implementation MKitMutableFileArray

-(id)init
{
    if ((self=[super init]))
    {
        _array = CFArrayCreateMutable(NULL,
                                      0,
                                      &kCFTypeArrayCallBacks);
    }
    
    return self;
}

-(id)initWithCapacity:(NSUInteger)numItems
{
    if ((self=[super init]))
    {
        _array = CFArrayCreateMutable(NULL,
                                      numItems,
                                      &kCFTypeArrayCallBacks);
    }
    
    return self;
}

-(void)dealloc
{
    CFRelease(_array);
    [super dealloc];
}

- (NSUInteger)count
{
    return CFArrayGetCount(_array);
}


-(void)insertObject:(id)anObject atIndex:(NSUInteger)index
{
    if (![anObject isKindOfClass:[MKitServiceFile class]])
        @throw [NSException exceptionWithName:@"Not Model" reason:@"Attempting to add a non MKitServiceFile class into MKitMutableFileArray" userInfo:nil];

     CFArrayInsertValueAtIndex(_array,
                              index,
                              (const void *)anObject);
}

-(id)objectAtIndex:(NSUInteger)index
{
    return (id)CFArrayGetValueAtIndex(_array, index);
}

-(void)removeObjectAtIndex:(NSUInteger)index
{
    CFArrayRemoveValueAtIndex(_array, index);
}

-(void)addObject:(id)anObject
{
    if (![anObject isKindOfClass:[MKitServiceFile class]])
        @throw [NSException exceptionWithName:@"Not Model" reason:@"Attempting to add a non MKitServiceFile class into MKitMutableFileArray" userInfo:nil];
    
    CFArrayAppendValue(_array, (const void *)anObject);
}

-(void)removeLastObject
{
    CFArrayRemoveValueAtIndex(_array, self.count-1);
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (![anObject isKindOfClass:[MKitServiceFile class]])
        @throw [NSException exceptionWithName:@"Not Model" reason:@"Attempting to add a non MKitServiceFile class into MKitMutableFileArray" userInfo:nil];
    
    CFArrayReplaceValues(_array, CFRangeMake(index, 1), (const void **)&anObject, 1);
}

-(BOOL)uploadWithProgress:(MKitMultiUploadProgressBlock)progressBlock error:(NSError **)error
{
    NSInteger count=0;
    NSInteger totalCount=self.count;
    __block float totalProgress=0.0f;
    __block float lastProgress=0.0f;
    for(MKitServiceFile *f in self)
    {
        count++;
        if (f.state!=FileStateNew)
        {
            totalProgress+=1.0f;
            if (progressBlock)
                progressBlock(count, totalCount, 1.0f, totalProgress/(float)totalCount);
        }
        else
        {
            lastProgress=0.0f;
            BOOL result=[f save:error progressBlock:^(float progress) {
                totalProgress+=(progress-lastProgress);
                lastProgress=progress;
                if (progressBlock)
                    progressBlock(count, totalCount, progress, totalProgress/(float)totalCount);
            }];
            
            if (!result)
                return NO;
        }
    }
    
    return YES;
}

-(void)uploadInBackgroundWithProgress:(MKitMultiUploadProgressBlock)progressBlock resultBlock:(MKitBooleanResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [currentGraph push];
        
        NSError *error=nil;
        BOOL result=[self uploadWithProgress:progressBlock error:&error];
        
        if (resultBlock)
            resultBlock(result,error);
        
        [currentGraph pop];
    });
}


@end
