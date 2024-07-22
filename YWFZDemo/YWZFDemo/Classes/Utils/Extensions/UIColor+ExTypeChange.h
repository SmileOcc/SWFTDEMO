//
//  UIColor+ExTypeChange.h
//  WuZhouHui
//
//  Created by karl.luo on 16/7/15.
//  Copyright © 2016年 wuzhouhui. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  @brief 颜色类型转换
 */
@interface UIColor (ExTypeChange)

/**
 *  @brief 16进制颜色转换成UIColor
 *
 *  @param hexValue 例如0xfafafa
 *
 *  @return UIColor
 */
+ (UIColor *)colorWithHex:(NSInteger)hexValue;
+ (UIColor *)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue;
/**
 *  @brief 将UIColor转成16进制颜色
 *
 *  @param color 颜色值
 *
 *  @return 16进制字符串
 */
+ (NSString *)hexFromUIColor: (UIColor *)color;
/**
 * 将color分理处RGB值， 返回@[r, g, b, a]，
 */
+ (NSArray *)getRGBComponents:(UIColor *)color;
+ (UIColor *)colorWithHexString:(NSString *)color;
+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha;

// defaultColor: 表示如果hexcolorStr不能转成颜色时,函数返回的默认颜色
+ (UIColor *)colorWithHexString:(NSString *)hexcolorStr defaultColor:(UIColor *)defaultColor;

/**
 * 兼容透明度的16进制颜色 #00000000 -> #AARRGGBB
 **/
+ (UIColor *)colorWithAlphaHexColor:(NSString *)hexcolorStr
                       defaultColor:(UIColor *)defaultColor;

@end
