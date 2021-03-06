/*
 *****************************************************************************
 * Copyright (C) 2005-2014 UC Mobile Limited. All Rights Reserved
 * File			: G9SharePopupWindow.h
 *
 * Description	: 控件，下方弹出框
 *
 * Author		: liutf@ucweb.com
 *
 * History		: Creation, 7/20/15, liutf@ucweb.com, Create the file
 ******************************************************************************
 **/

#import <UIKit/UIKit.h>

@interface G9SharePopupWindow : UIWindow

- (instancetype)initWithASharedActivity:(NSArray *)shareActivity actionActivities:(NSArray *)actionActivities;

- (void)show;


@end
