//
//  ZFLocalizationString.h
//  ZZZZZ
//
//  Created by YW on 2017/2/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ZFInitializeModel.h"

#undef ZFLocalizedString
#define ZFLocalizedString(key,comment) [[ZFLocalizationString shareLocalizable] ZFLocalizedString:key]

FOUNDATION_EXTERN NSString *const ZFLocalizationStringDidChanged;   // 语言切换的通知
// 管理国际化的类
@interface ZFLocalizationString : NSObject
@property (nonatomic, strong, readonly) NSArray *localizableNames;  // 获取工程支持的多语言的数组
@property (nonatomic, strong) NSArray <ZFSupportLangModel *>*languageArray;     // 支持的语言列表集合
@property (nonatomic, copy) NSString *nomarLocalizable;             // 默认的语言 默认为英语
+ (instancetype)shareLocalizable; //对类初始化单例
- (NSString *)ZFLocalizedString:(NSString *)translation_key; // 用ZFLocalizedString宏进行调用国际化

// 当前 APP 使用的语言，默认为英语
- (NSString *)currentLanguageName;
//当前 APP 使用的语言，默认为英语 <简写>
- (NSString *)currentLanguageMR;

+ (NSString *)fetchAppleLanguages;

- (NSString *)fetchAppLocalLanguage;

/**
 *  筛选支持的数组语言中需要选定的默认语言
 *  @return 筛选出来的语言模型
 */
- (ZFSupportLangModel *)filterSupporlang:(NSArray<ZFSupportLangModel *> *)supportLangList;

/**
 *  保存用户选择的语言，用于筛选语言显示
 */
- (void)saveUserSelectLanguage:(NSString *)selectLanguage;

- (void)saveNomarLocalizableLanguage:(NSString *)language;

@end
