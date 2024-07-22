//
//  SystemConfigUtils.m
//  ZZZZZ
//
//  Created by YW on 2017/2/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "SystemConfigUtils.h"
#import "ZFLocalizationString.h"
#import "Constants.h"

@implementation SystemConfigUtils

/// 阿语、希伯来语
+ (BOOL)isRightToLeftLanguage {
    if ([[ZFLocalizationString shareLocalizable].nomarLocalizable hasPrefix:@"ar"] || [[ZFLocalizationString shareLocalizable].nomarLocalizable hasPrefix:@"he"]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isCanRightToLeftShow {
    if (IOS9UP && [self isRightToLeftLanguage]) {
        return YES;
    }
    return NO;
}

+ (BOOL)isRightToLeftShow {
    if ([self isCanRightToLeftShow]
        && [UIView appearance].semanticContentAttribute == UISemanticContentAttributeForceRightToLeft) {
        return YES;
    }
    return NO;
}
@end
