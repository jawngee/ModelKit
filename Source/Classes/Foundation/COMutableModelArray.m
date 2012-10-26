//
//  COMutableModelArray.m
//  CloudObject
//
//  Created by Jon Gilkison on 10/26/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "COMutableModelArray.h"
#import "COModel.h"


const void *__CFArrayRetainCallBack(CFAllocatorRef allocator, const void *value)
{
    NSLog(@"retain cb");
    COModel *model=(COModel *)value;
    if ([model conformsToProtocol:@protocol(CONoContext)])
        [model retain];
    
    return value;
}

void __CFArrayReleaseCallBack(CFAllocatorRef allocator, const void *value)
{
    NSLog(@"release cb");
    
    COModel *model=(COModel *)value;
    if ([model conformsToProtocol:@protocol(CONoContext)])
        [model release];
}

@implementation COMutableModelArray

-(id)init
{
    if ((self=[super init]))
    {
        CFArrayCallBacks cb=kCFTypeArrayCallBacks;
        
        cb.retain=&__CFArrayRetainCallBack;
        cb.release=&__CFArrayReleaseCallBack;
        
        _array = CFArrayCreateMutable(NULL,
                                           0,
                                           &cb);
    }
    
    return self;
}

-(id)initWithCapacity:(NSUInteger)numItems
{
    if ((self=[super init]))
    {
        CFArrayCallBacks cb=kCFTypeArrayCallBacks;
        
        cb.retain=&__CFArrayRetainCallBack;
        cb.release=&__CFArrayReleaseCallBack;
        _array = CFArrayCreateMutable(NULL,
                                      numItems,
                                      &cb);
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
    if (![anObject isKindOfClass:[COModel class]])
        @throw [NSException exceptionWithName:@"Not Model" reason:@"Attempting to insert a non COModel class into COMutableModelArray" userInfo:nil];
    
//    if (![anObject conformsToProtocol:@protocol(CONoContext)])
//        [anObject autorelease];
    
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
    if (![anObject isKindOfClass:[COModel class]])
        @throw [NSException exceptionWithName:@"Not Model" reason:@"Attempting to add a non COModel class into COMutableModelArray" userInfo:nil];

//    if (![anObject conformsToProtocol:@protocol(CONoContext)])
//        [anObject autorelease];
    
    CFArrayAppendValue(_array, (const void *)anObject);
}

-(void)removeLastObject
{
    CFArrayRemoveValueAtIndex(_array, self.count-1);
}

-(void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject
{
    if (![anObject isKindOfClass:[COModel class]])
        @throw [NSException exceptionWithName:@"Not Model" reason:@"Attempting to replace a non COModel class into COMutableModelArray" userInfo:nil];

//    if (![anObject conformsToProtocol:@protocol(CONoContext)])
//        [anObject autorelease];
    
    CFArrayReplaceValues(_array, CFRangeMake(index, 1), (const void **)&anObject, 1);
}

@end
