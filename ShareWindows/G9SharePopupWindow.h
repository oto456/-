//
//  G9SharePopupWindow.h
//  ShareWindows
//
//  Created by kakapo on 15/7/29.
//  Copyright (c) 2015年 kakapo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface G9SharePopupWindow : UIWindow

- (instancetype)initWithASharedActivity:(NSArray *)shareActivity actionActivities:(NSArray *)actionActivities;

- (void)show;


@end
