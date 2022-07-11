//
//  UIFont+CustomFont.h
// XStarlinkProject
//
//  Created by Kevin on 2021/6/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (CustomFont)

//用于所有按钮的字体
+ (UIFont *)stl_buttonFont:(CGFloat)fontSize;

//常规斜体
+ (UIFont *)vivaiaItalicFont:(CGFloat)fontSize;
//V站 粗斜体
+ (UIFont *)vivaiaBoldItalicFont:(CGFloat)fontSize;

//V站 常规粗体
+ (UIFont *)vivaiaSemiBoldFont:(CGFloat)fontSize;

//V站 常规体
+ (UIFont *)vivaiaRegularFont:(CGFloat)fontSize;


@end

NS_ASSUME_NONNULL_END
