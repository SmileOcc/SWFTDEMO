//
//  STLstemConfigUtils.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OSSVSystemsConfigsUtils : NSObject
//当前语言是阿拉伯语
+ (BOOL)isRightToLeftLanguage;
//判断当前是否支持View反向
+ (BOOL)isCanRightToLeftShow;
//当前View是反向显示
+ (BOOL)isRightToLeftShow;

///是否使用自定义阿语字体
+ (BOOL)isCustomizeFontLanguageAR;
//当前支持的国际化语言
+ (NSString *)currentLocalLanguage;

@end
