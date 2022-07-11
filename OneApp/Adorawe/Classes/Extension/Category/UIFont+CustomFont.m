//
//  UIFont+CustomFont.m
// XStarlinkProject
//
//  Created by Kevin on 2021/6/24.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "UIFont+CustomFont.h"
#import <objc/runtime.h>
#import "NSObject+Swizzling.h"

static NSString * const kSTLGlobalEnFontName = @"Lato-Regular";
static NSString * const kSTLGlobalENBoldFontName = @"Lato-Bold";
static NSString * const kSTLButtonEnFontName = @"Lato-Black";

static NSString * const VivGlobalEnItalicName = @"PlayfairDisplay-Italic";               //斜体
static NSString * const VivGlobalENFontName = @"PlayfairDisplay-Regular";         //常规体
static NSString * const VivGlobalENBoldFontName = @"PlayfairDisplay-SemiBold";          //常规体加粗
static NSString * const VivGlobalEnBoldItalicName = @"PlayfairDisplay-SemiBoldItalic";  //斜体加粗


static NSString * const kSTLGlobalArFontName = @"Almarai-Regular";
static NSString * const kSTLGlobalArBoldFontName = @"Almarai-Bold";
static NSString * const kSTLButtonArFontName = @"Almarai-ExtraBold";

@implementation UIFont (CustomFont)
/**
 * 替换全局设置字体方法
 */
+(void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        //系统字体
        Method orignal_system = class_getClassMethod(class, @selector(systemFontOfSize:));
        Method stl_system = class_getClassMethod(class, @selector(stl_systemFontOfSize:));
        method_exchangeImplementations(orignal_system, stl_system);

        //系统粗体字体
        Method orignal_bold = class_getClassMethod(class, @selector(boldSystemFontOfSize:));
        Method stl_bold = class_getClassMethod(class, @selector(stl_boldSystemFontOfSize:));
        method_exchangeImplementations(orignal_bold, stl_bold);
        
    });
    
}

+ (UIFont *)stl_systemFontOfSize:(CGFloat)fontSize {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return [UIFont fontWithName:kSTLGlobalArFontName size:fontSize];

    } else {
            return [UIFont fontWithName:kSTLGlobalEnFontName size:fontSize];
    }
}

+ (UIFont *)stl_boldSystemFontOfSize:(CGFloat)fontSize {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return [UIFont fontWithName:kSTLGlobalArBoldFontName size:fontSize];
    } else {
            return [UIFont fontWithName:kSTLGlobalENBoldFontName size:fontSize];
    }
}

//用于所有按钮的字体
+ (UIFont *)stl_buttonFont:(CGFloat)fontSize {
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return [UIFont fontWithName:kSTLButtonArFontName size:fontSize];
    } else {
        if (APP_TYPE == 3) {
            return [UIFont fontWithName:VivGlobalENBoldFontName size:fontSize];
        } else {
            return [UIFont fontWithName:kSTLButtonEnFontName size:fontSize];
        }
    }
}


//自定义，加粗斜体
+(UIFont *)vivaiaBoldItalicFont:(CGFloat)fontSize {
    
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return [UIFont fontWithName:kSTLGlobalArBoldFontName size:fontSize];
    } else {
        return [UIFont fontWithName:VivGlobalEnBoldItalicName size:fontSize];
        }
}

//常规斜体
+(UIFont *)vivaiaItalicFont:(CGFloat)fontSize {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return [UIFont fontWithName:kSTLGlobalArFontName size:fontSize];
    } else {
        return [UIFont fontWithName:VivGlobalEnItalicName size:fontSize];
    }
}

//   V站常规体

+(UIFont *)vivaiaRegularFont:(CGFloat)fontSize {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return [UIFont fontWithName:kSTLGlobalArFontName size:fontSize];
    } else {
        return [UIFont fontWithName:VivGlobalENFontName size:fontSize];
    }
}

//V站常规粗体
+(UIFont *)vivaiaSemiBoldFont:(CGFloat)fontSize {
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        return [UIFont fontWithName:kSTLGlobalArFontName size:fontSize];
    } else {
        return [UIFont fontWithName:VivGlobalENBoldFontName size:fontSize];
    }
}

@end
