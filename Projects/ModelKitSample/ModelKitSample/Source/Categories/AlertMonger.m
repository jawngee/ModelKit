//
//  AlertMonger.m
//
//  Created by Jon Gilkison on 12/29/10.
//  Copyright 2010 Interfacelab LLC. All rights reserved.
//

#import "AlertMonger.h"

@interface AlertMonger(Private)

-(id)initWithBlock:(AMClickedButtonAtIndexBlock)onClickedButtonAtIndexBlock;

-(void)showAlertWithTitle:(NSString *)title
				  message:(NSString *)message
		cancelButtonTitle:(NSString *)cancelButtonTitle
		otherButtonTitles:(NSArray *)otherButtonTitles;
@end


@implementation AlertMonger


-(id)initWithBlock:(AMClickedButtonAtIndexBlock)onClickedButtonAtIndexBlock
{
	if (self=[super init])
	{
		clickedButtonAtIndexBlock=Block_copy(onClickedButtonAtIndexBlock);
	}
	
	return self;
}

-(void)dealloc
{
    Block_release(clickedButtonAtIndexBlock);
    [super dealloc];
}


+(void)showAlertWithTitle:(NSString *)title
				  message:(NSString *)message
		cancelButtonTitle:(NSString *)cancelButtonTitle
	 clickedButtonAtIndex:(AMClickedButtonAtIndexBlock)onClickedButtonAtIndexBlock
		otherButtonTitles:(NSString *)otherButtonTitles,...
{
    NSMutableArray *titles=nil;
    
    if (otherButtonTitles!=nil)
    {
        titles=[NSMutableArray arrayWithObject:otherButtonTitles];
        va_list argumentList;
        id eachObject=nil;
        
        va_start(argumentList,otherButtonTitles);
        while ((eachObject=va_arg(argumentList, id)))
            [titles addObject:eachObject];
        va_end(argumentList);
    }

    AlertMonger *am=[[AlertMonger alloc] initWithBlock:onClickedButtonAtIndexBlock];
    [am showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:titles];
}

+(void)showAlertWithTitle:(NSString *)title
				  message:(NSString *)message
		cancelButtonTitle:(NSString *)cancelButtonTitle
{
	AlertMonger *am=[[AlertMonger alloc] initWithBlock:nil];
	[am showAlertWithTitle:title message:message cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if (clickedButtonAtIndexBlock!=nil)
		clickedButtonAtIndexBlock(buttonIndex);
	
	[self release];
}

-(void)showAlertWithTitle:(NSString *)title
				  message:(NSString *)message
		cancelButtonTitle:(NSString *)cancelButtonTitle
		otherButtonTitles:(NSArray *)otherButtonTitles
{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *av=[[[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil] autorelease];
        
        if (otherButtonTitles!=nil)
            for(NSString *t in otherButtonTitles)
                [av addButtonWithTitle:t];
        
        [av show];
    });
}

@end
