//
//  MKitServiceFile.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/7/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#include "MKitDefs.h"
#import <Foundation/Foundation.h>

@class MKitServiceManager;

/** File states */
typedef enum
{
    FileStateNew,
    FileStateSaved,
    FileStateDeleted
} MKitFileState;

/**
 * Represents a file that can be saved to a backend service
 */
@interface MKitServiceFile : NSObject<NSCoding>

@property (copy, nonatomic) NSString *contentType;  /**< Content type */
@property (copy, nonatomic) NSString *filename;     /**< File name of local file that this points to, can be nil */
@property (retain, nonatomic) NSData *data;         /**< Data for this file, can be nil */
@property (assign, nonatomic) MKitFileState state;  /**< The current state of the file */
@property (copy, nonatomic) NSString *name;         /**< The backend's name for the file */
@property (copy, nonatomic) NSString *url;          /**< The backend's url for the file */

/**
 * Returns the service manager this file uses for persistence
 * @return service The service this file uses
 */
+(MKitServiceManager *)service;

/**
 * Creates a new instance with a local file
 * @param filename The file name of the local file
 * @return A new instance
 */
+(id)fileWithFile:(NSString *)filename;


/**
 * Creates a new instance with data
 * @param data The data
 * @param name The name of the file
 * @param contentType The content type
 * @return A new instance
 */
+(id)fileWithData:(NSData *)data name:(NSString *)name contentType:(NSString *)contentType;

/**
 * Creates a new instance with a name and a url.  Created for objects already
 * saved to the backend
 * @param name The backend's name for the file
 * @param url The backend's url for the file
 * @return New instance
 */
+(id)fileWithName:(NSString *)name andURL:(NSString *)url;

/**
 * Initializes the file with the contents of a local file
 * @param filename The file name of the local file
 * @return A new instance
 */
-(id)initWithFile:(NSString *)filename;

/**
 * Initializes a new instance with data
 * @param data The data
 * @param name The name of the file
 * @param contentType The content type
 * @return A new instance
 */
-(id)initWithData:(NSData *)data name:(NSString *)name contentType:(NSString *)contentType;

/**
 * Initialized a new instance with a name and a url.  Created for objects already
 * saved to the backend
 * @param name The backend's name for the file
 * @param url The backend's url for the file
 * @return New instance
 */
-(id)initWithName:(NSString *)name andURL:(NSString *)url;

/**
 * Saves the file to the backend
 * @param error The error
 * @param progressBlock The progress block to call with progress updates
 * @return YES if successful, NO if not
 */
-(BOOL)save:(NSError **)error progressBlock:(MKitProgressBlock)progressBlock;

/**
 * Saves the file to the backend in a background thread
 * @param progressBlock The progress block to call with progress updates
 * @param resultBlock The result block to call when complete
 */
-(void)saveInBackgroundWithProgress:(MKitProgressBlock)progressBlock resultBlock:(MKitBooleanResultBlock)resultBlock;

/**
 * Deletes the file from the backend
 * @param error The error
 * @return YES if succesful, NO if not
 */
-(BOOL)delete:(NSError **)error;

/**
 * Deletes the file from the backend in a background thread.
 * @param resultBlock The result block to call when complete
 */
-(void)deleteInBackground:(MKitBooleanResultBlock)resultBlock;

@end
