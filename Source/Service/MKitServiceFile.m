//
//  MKitServiceFile.m
//  ModelKit
//
//  Created by Jon Gilkison on 11/7/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import "MKitServiceFile.h"
#import "MKitServiceManager.h"
#import "MKitModelGraph.h"

/**
 * Internal methods
 */
@interface MKitServiceFile(Internal)

/**
 * Determines the content type for a filename
 * @param filename The filename
 * @return The content type
 */
-(NSString *)contentTypeForFileName:(NSString *)filename;

@end

@implementation MKitServiceFile

#pragma mark - Init/Dealloc

-(id)init
{
    if ((self=[super init]))
    {
        self.state=FileStateNew;
    }
    
    return self;
}

-(id)initWithFile:(NSString *)filename
{
    if ((self=[self init]))
    {
        self.filename=filename;
        self.name=[filename lastPathComponent];
        self.data=[NSData dataWithContentsOfFile:filename options:NSDataReadingMappedAlways error:nil];
        self.contentType=[self contentTypeForFileName:filename];
    }
    
    return self;
}

-(id)initWithData:(NSData *)data name:(NSString *)name contentType:(NSString *)contentType
{
    if ((self=[self init]))
    {
        self.data=data;
        self.name=name;
        self.contentType=contentType;
    }
    
    return self;
}

-(id)initWithName:(NSString *)name andURL:(NSString *)url
{
    if ((self=[self init]))
    {
        self.name=name;
        self.contentType=[self contentTypeForFileName:name];
        self.url=url;
    }
    
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self=[self init]))
    {
        self.contentType=[aDecoder decodeObjectForKey:@"contentType"];
        self.filename=[aDecoder decodeObjectForKey:@"filename"];
        self.data=[aDecoder decodeObjectForKey:@"data"];
        self.state=[aDecoder decodeIntegerForKey:@"state"];
        self.name=[aDecoder decodeObjectForKey:@"name"];
        self.url=[aDecoder decodeObjectForKey:@"url"];
    }
    
    return self;
}

-(void)dealloc
{
    self.contentType=nil;
    self.filename=nil;
    self.data=nil;
    self.name=nil;
    self.url=nil;
    
    [super dealloc];
}

#pragma mark - Static Initializers

+(id)fileWithFile:(NSString *)filename
{
    return [[[self alloc] initWithFile:filename] autorelease];
}

+(id)fileWithData:(NSData *)data name:(NSString *)name contentType:(NSString *)contentType
{
    return [[[self alloc] initWithData:data name:name contentType:contentType] autorelease];
}

+(id)fileWithName:(NSString *)name andURL:(NSString *)url
{
    return [[[self alloc] initWithName:name andURL:url] autorelease];
}

#pragma mark - Static methods

+(MKitServiceManager *)service
{
    return nil;
}

#pragma mark - NSCoding

-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.contentType forKey:@"contentType"];
    [aCoder encodeObject:self.filename forKey:@"filename"];
    [aCoder encodeObject:self.data forKey:@"data"];
    [aCoder encodeInteger:self.state forKey:@"state"];
    [aCoder encodeObject:self.name forKey:@"name"];
    [aCoder encodeObject:self.url forKey:@"url"];
}


#pragma mark - Internal

-(NSString *)contentTypeForFileName:(NSString *)filename
{
    CFStringRef fileExtension = (CFStringRef)[filename pathExtension];
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    CFStringRef MIMEType = UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType);
    CFRelease(UTI);
    return (NSString *)MIMEType;
}

#pragma mark - Save/Delete

-(BOOL)save:(NSError **)error progressBlock:(MKitProgressBlock)progressBlock
{
    return [[[self class] service] saveFile:self progressBlock:progressBlock error:error];
}

-(void)saveInBackgroundWithProgress:(MKitProgressBlock)progressBlock resultBlock:(MKitBooleanResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [currentGraph push];
        
        NSError *error=nil;
        BOOL result=[self save:&error progressBlock:progressBlock];
        
        if (resultBlock)
            resultBlock(result, error);
        
        [currentGraph pop];
    });
}

-(BOOL)delete:(NSError **)error
{
    return [[[self class] service] deleteFile:self error:error];
}

-(void)deleteInBackground:(MKitBooleanResultBlock)resultBlock
{
    __block MKitModelGraph *currentGraph=[MKitModelGraph current];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [currentGraph push];
        
        NSError *error=nil;
        BOOL result=[self delete:&error];
        
        if (resultBlock)
            resultBlock(result, error);
        
        [currentGraph pop];
    });
}

-(NSString *)debugDescription
{
    NSMutableArray *propsStrings=[NSMutableArray array];
    
    [propsStrings addObject:[NSString stringWithFormat:@"\n\t%@: %@",@"contentType",self.contentType]];
    [propsStrings addObject:[NSString stringWithFormat:@"%@: %@",@"filename",self.filename]];
    [propsStrings addObject:[NSString stringWithFormat:@"%@: %d",@"state",self.state]];
    [propsStrings addObject:[NSString stringWithFormat:@"%@: %@",@"name",self.name]];
    [propsStrings addObject:[NSString stringWithFormat:@"%@: %@",@"url",self.url]];
    
    
    return [NSString stringWithFormat:@"<%@: %p> { %@;\n}\n",NSStringFromClass([self class]),self,[propsStrings componentsJoinedByString:@";\n\t"]];
}

-(NSString *)description
{
    return [self debugDescription];
}


@end
