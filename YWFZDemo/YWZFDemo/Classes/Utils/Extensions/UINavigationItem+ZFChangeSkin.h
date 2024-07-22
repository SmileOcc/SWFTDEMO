//
//  UINavigationItem+ZFChangeSkin.h
//  ZZZZZ
//
//  Created by YW on 2018/7/12.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationItem (ZFChangeSkin)
@end




@interface UINavigationBar (ZFChangeSkin)

/**
 * 改变系统导航条主题色
 */
- (void)zfChangeSkinToSystemNavgationBar;

@end




@interface UIView (ZFChangeSkin)

/**
 * 切换需要渐变自定义导航条背景色
 */
- (BOOL)zfChangeSkinToShadowNavgationBar;

/**
 * 自定义UIView换肤
 */
- (BOOL)zfChangeCustomViewSkin:(UIColor *)skinColor skinImage:(UIImage *)skinImage;

/**
 * 按钮换肤
 */
- (void)zfChangeButtonSkin;

/**
 * 文本换肤
 */
- (void)zfChangeLabelSkin;

/**
 * 改变自定义导航条主题色
 */
- (void)zfChangeSkinToCustomNavgationBar;

@end
