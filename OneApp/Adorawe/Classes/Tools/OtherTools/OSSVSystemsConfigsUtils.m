//
//  STLstemConfigUtils.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/9.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSystemsConfigsUtils.h"

@implementation OSSVSystemsConfigsUtils

+ (BOOL)isRightToLeftLanguage {
    NSString *language = [STLLocalizationString shareLocalizable].nomarLocalizable;
    
    if ([language hasPrefix:@"ar"] || [language hasPrefix:@"he"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCanRightToLeftShow {
    if ([self isRightToLeftLanguage]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isRightToLeftShow {
    if ([self isCanRightToLeftShow] && [UIView appearance].semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCustomizeFontLanguageAR {
    return [OSSVSystemsConfigsUtils isRightToLeftShow];
}


//当前支持的国际化语言
+ (NSString *)currentLocalLanguage {
    
    // （iOS获取的语言字符串比较不稳定）目前框架只处理en、zh-Hans、zh-Hant三种情况，其他按照系统默认处理
    NSString *language = [NSLocale preferredLanguages].firstObject;
    if ([language hasPrefix:@"en"]) {
        language = @"en";
    } else if ([language hasPrefix:@"ar"]) {
        language = @"ar"; // 繁體中文
    } else if ([language hasPrefix:@"es"]) {
        language = @"es"; // 西班牙文
    }
//    else if ([language hasPrefix:@"zh"]) {
//        if ([language rangeOfString:@"Hans"].location != NSNotFound) {
//            language = @"zh-Hans"; // 简体中文
//        } else { // zh-Hant\zh-HK\zh-TW
//            language = @"zh-Hant"; // 繁體中文
//        }
//    }

//    else if ([language hasPrefix:@"fr"]) {
//        language = @"fr"; // 法文
//    }
    else {
        language = @"en";
    }
    
    return language;
}
@end
