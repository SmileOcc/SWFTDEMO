//
//  UIFont+ZFExtension.m
//  ZZZZZ
//
//  Created by YW on 2020/1/11.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "UIFont+ZFExtension.h"
#import <objc/runtime.h>
#import "NSObject+Swizzling.h"
#import "Constants.h"

///苹果字体效果: http://www.iosfonts.com/
static NSString * const kZFGlobalFontName = @"ProximaNova-Regular";
static NSString * const kZFGlobalBoldFontName = @"ProximaNova-Semibold";


@implementation UIFont (ZFExtension)

/**
 * 替换全局设置字体方法
 */
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        //系统字体
        Method orignal_system = class_getClassMethod(class, @selector(systemFontOfSize:));
        Method zf_system = class_getClassMethod(class, @selector(zf_systemFontOfSize:));
        method_exchangeImplementations(orignal_system, zf_system);
        
        //系统粗体字体
        Method orignal_bold = class_getClassMethod(class, @selector(boldSystemFontOfSize:));
        Method zf_bold = class_getClassMethod(class, @selector(zf_boldSystemFontOfSize:));
        method_exchangeImplementations(orignal_bold, zf_bold);
    });
}

/// [UIFont systemFontOfSize:(CGFloat)]
+ (UIFont *)zf_systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:kZFGlobalFontName size:fontSize];;
}

/// [UIFont boldSystemFontOfSize:(CGFloat)];
+ (UIFont *)zf_boldSystemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:kZFGlobalBoldFontName size:fontSize];;
}

@end
