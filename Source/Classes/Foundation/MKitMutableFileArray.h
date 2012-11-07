//
//  MKitMutableFileArray.h
//  ModelKit
//
//  Created by Jon Gilkison on 11/7/12.
//  Copyright (c) 2012 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

#include "MKitDefs.h"

/** Multiple file upload progress */
typedef void (^MKitMultiUploadProgressBlock)(NSInteger current, NSInteger total, float currentProgress, float totalProgress);

/**
 * This subclass of NSMutableArray is specific to managing an array of files
 * associated with a model.
 *
 * It provides methods for doing batch uploads
 */
@interface MKitMutableFileArray : NSMutableArray
{
@private
    CFMutableArrayRef _array;
}

/**
 * Uploads all of the files that need uploading in this array
 * @param progressBlock The progress block to call
 * @param error The error
 * @return YES if successful, NO otherwise
 */
-(BOOL)uploadWithProgress:(MKitMultiUploadProgressBlock)progressBlock error:(NSError **)error;

/**
 * Uploads all of the files that need uploading in this array in the background
 * @param progressBlock The progress block to call
 * @param resultBlock The result block to call when the uploads are complete
 */
-(void)uploadInBackgroundWithProgress:(MKitMultiUploadProgressBlock)progressBlock resultBlock:(MKitBooleanResultBlock)resultBlock;


@end
