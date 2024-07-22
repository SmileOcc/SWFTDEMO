//
//  UIColor+ExTypeChange.m
//  WuZhouHui
//
//  Created by karl.luo on 16/7/15.
//  Copyright © 2016年 wuzhouhui. All rights reserved.
//

#import "UIColor+ExTypeChange.h"

@implementation UIColor (ExTypeChange)


+ (UIColor*)colorWithHex:(NSInteger)hexValue alpha:(CGFloat)alphaValue {
    
    return [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((hexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(hexValue & 0xFF))/255.0 alpha:alphaValue];
}

+ (UIColor *)colorWithHex:(NSInteger)hexValue {
    
    return [UIColor colorWithHex:hexValue alpha:1.0];
}

+ (NSString *)hexFromUIColor: (UIColor*) color {
    
    if (CGColorGetNumberOfComponents(color.CGColor) < 4) {
        
        const CGFloat *components = CGColorGetComponents(color.CGColor);
        color = [UIColor colorWithRed:components[0]
                                green:components[0]
                                 blue:components[0]
                                alpha:components[1]];
    }
    
    if (CGColorSpaceGetModel(CGColorGetColorSpace(color.CGColor)) != kCGColorSpaceModelRGB) {
        return [NSString stringWithFormat:@"#FFFFFF"];
    }
    
    return [NSString stringWithFormat:@"#%x%x%x", (int)((CGColorGetComponents(color.CGColor))[0]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[1]*255.0),
            (int)((CGColorGetComponents(color.CGColor))[2]*255.0)];
}

+ (NSArray *)getRGBComponents:(UIColor *)color {
    if (!color) {
        return @[[NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.0],  [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.0]];
    }
    CGFloat R, G, B, A;
    
    CGColorRef colorRef = [color CGColor];
    int numComponents = (int)CGColorGetNumberOfComponents(colorRef);
    
    if (numComponents == 4) {
        const CGFloat *components = CGColorGetComponents(colorRef);
        R = components[0];
        G = components[1];
        B = components[2];
        A = components[3];
    } else {
        const CGFloat *components = CGColorGetComponents(colorRef);
        R = components[0];
        G = components[1];
        B = components[2];
        A = 1;
    }
    
    return @[[NSNumber numberWithFloat:R], [NSNumber numberWithFloat:G],  [NSNumber numberWithFloat:B], [NSNumber numberWithFloat:A]];
}

//默认alpha值为1
+ (UIColor *)colorWithHexString:(NSString *)color {
    
    return [self colorWithHexString:color alpha:1.0f];
}

+ (UIColor *)colorWithHexString:(NSString *)color alpha:(CGFloat)alpha
{
    // 删除字符串中的空格
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    // 如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    // 如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    if ([cString length] != 6) {
        return [UIColor clearColor];
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

// defaultColor: 表示如果hexcolorStr不能转成颜色时,函数返回的默认颜色
+ (UIColor *)colorWithHexString:(NSString *)hexcolorStr defaultColor:(UIColor *)defaultColor
{
    if (![defaultColor isKindOfClass:[UIColor class]]) {
        defaultColor = [UIColor blackColor];
    }
    
    if (![hexcolorStr isKindOfClass:[NSString class]]) {
        return defaultColor;
    }
    
    // 删除字符串中的空格
    NSString *cString = [[hexcolorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {
        return defaultColor;
    }
    
    // strip 0X if it appears
    // 如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    // 如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    if ([cString length] != 6) {
        return defaultColor;
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:1];
}

/** 兼容透明度的16进制颜色
 * 解释: 透明度由Alpha通道(#AARRGGBB中的AA)控制。最大值(255 dec，FF hex)表示完全不透明。最小值(0 dec，00 hex)表示完全透明。之间的值是半透明的，即颜色与背景颜色混合。
 * @param hexcolorStr  需要转换的16进制颜色 如: #00000000
 * @param defaultColor 表示如果hexcolorStr不能转成颜色时,函数返回的默认颜色
 **/
+ (UIColor *)colorWithAlphaHexColor:(NSString *)hexcolorStr
                       defaultColor:(UIColor *)defaultColor
{
    if (![defaultColor isKindOfClass:[UIColor class]]) {
        defaultColor = [UIColor blackColor];
    }
    
    if (![hexcolorStr isKindOfClass:[NSString class]]) {
        return defaultColor;
    }
    
    // 删除字符串中的空格
    NSString *cString = [[hexcolorStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    if ([cString length] < 6) {
        return defaultColor;
    }
    
    // 如果是0x开头的，那么截取字符串，字符串从索引为2的位置开始，一直到末尾
    if ([cString hasPrefix:@"0X"]) {
        cString = [cString substringFromIndex:2];
    }
    // 如果是#开头的，那么截取字符串，字符串从索引为1的位置开始，一直到末尾
    if ([cString hasPrefix:@"#"]) {
        cString = [cString substringFromIndex:1];
    }
    
    NSInteger offset = 0;
    if ([cString length] == 6) {
        offset = 0;
    } else if ([cString length] == 8) {
        offset = 2;
    } else {
        return defaultColor;
    }
    
    // 透明度由Alpha通道(#AA RR GG BB中的AA)控制
    NSRange range;
    range.location = 0;
    range.length = 2;
    //a
    NSString *aString = [cString substringWithRange:range];
    //r
    range.location = offset;
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2 + offset;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4 + offset;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b, a;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    if (offset == 2) {
        [[NSScanner scannerWithString:aString] scanHexInt:&a];
        a = (float)a / 255.0f;
    } else {
        a = 1;
    }
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:a];
}

@end
