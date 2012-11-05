//
//  AlertMonger.h
//
//  Created by Jon Gilkison on 12/29/10.
//  Copyright 2010 Interfacelab LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^AMClickedButtonAtIndexBlock)(NSInteger buttonIndex);

@interface AlertMonger : NSObject<UIAlertViewDelegate> {
	@private
	AMClickedButtonAtIndexBlock clickedButtonAtIndexBlock;
}

+(void)showAlertWithTitle:(NSString *)title
				  message:(NSString *)message
		cancelButtonTitle:(NSString *)cancelButtonTitle
	 clickedButtonAtIndex:(AMClickedButtonAtIndexBlock)onClickedButtonAtIndexBlock
		otherButtonTitles:(NSString *)otherButtonTitles,...;

+(void)showAlertWithTitle:(NSString *)title
				  message:(NSString *)message
		cancelButtonTitle:(NSString *)cancelButtonTitle;

@end
