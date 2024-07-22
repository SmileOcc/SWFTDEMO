//
//  UITabBar+ZFDotView.h
//  Zaful
//
//  Created by QianHan on 2018/1/15.
//  Copyright © 2018年 Y001. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITabBar (ZFDotView)

- (void)showDotOnItemIndex:(NSInteger)index; // 显示小红点
- (void)hideDotOnItemIndex:(NSInteger)index; // 隐藏小红点

- (void)showAnimated:(BOOL)animated;
- (void)hideAnimated:(BOOL)animated;

@end
