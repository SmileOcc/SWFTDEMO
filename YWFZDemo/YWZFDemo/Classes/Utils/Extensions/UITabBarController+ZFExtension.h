//
//  UITabBarController+ZFExtension.h
//  ZZZZZ
//
//  Created by YW on 2018/3/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kTabBarBadgeTag   888

@interface UITabBarController (ZFExtension)

/**
 * 初始化TabBar
 */
- (void)setupZFTabBarSkin;

/**
 设置tabbar背景

 @param image 背景图片
 */
- (void)setBabbarBackgroudImage:(UIImage *)image;

/**
 修改tabbar选项图片

 @param index 选项索引
 @param image 非高亮图
 @param selectedImage 高亮图
 */
- (void)setBabbarItemIndex:(NSInteger)index image:(UIImage *)image selectedImage:(UIImage *)selectedImage;


- (void)showBadgeOnItemIndex:(NSInteger)index;
- (void)hideBadgeOnItemIndex:(NSInteger)index;

//显示隐藏红点状态
- (void)updateBadgeOnItemIndex:(NSInteger)index hide:(BOOL)hide;

//重置红点按钮
- (void)resetBadgeOnItems:(NSArray *)indexsArray;

@end
