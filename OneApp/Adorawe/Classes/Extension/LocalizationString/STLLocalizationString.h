//
//  RGLocalizationString.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#undef NSLocalizedString
#define NSLocalizedString(key,comment) [[STLLocalizationString shareLocalizable]STLLocalizedString:key]

#define STLLocalizedString_(key,comment) [[STLLocalizationString shareLocalizable]STLLocalizedString:key]

FOUNDATION_EXTERN NSString *const STLLocalizationStringDidChanged;

// 管理国际化的类
@interface STLLocalizationString : NSObject


+(instancetype)shareLocalizable;

//支持的多语言的数组
@property (nonatomic, strong,readonly) NSArray  *localizableNames;
// 支持的语言列表集合
@property (nonatomic, strong) NSArray <OSSVSupporteLangeModel *>*languageArray;
// 默认的语言 默认为英语
@property (nonatomic, copy) NSString            *nomarLocalizable;
// 是否支持APP内部进行切换语言 默认不支持 强行设置nomarLocalizable 属性会退出程序
@property (nonatomic, assign) BOOL              isSuppoutAppSettingLocalizable;
// 当前语言简称
@property (nonatomic, copy) NSString            *curLanguage;


// 用STLLocalizedString宏进行调用国际化
-(NSString *)STLLocalizedString:(NSString *)translation_key;

// 当前 APP 使用的语言，默认为英语
- (NSString *)currentLanguageName;
//当前 APP 使用的语言，默认为英语 <简写>
//- (NSString *)currentLanguageMR;

+ (NSString *)fetchAppleLanguages;

//- (NSString *)fetchAppLocalLanguage;

+ (BOOL)isArlanguage:(NSString *)language;


/**
 *  处理初始的语言
 */
+ (void)handInitSupporLang:(NSArray<OSSVSupporteLangeModel *> *)supportLangList;


/**
 *  保存用户选择的语言，用于筛选语言显示
 */
- (void)saveUserSelectLanguage:(NSString *)selectLanguage;

- (void)saveNomarLocalizableLanguage:(NSString *)language;

-(NSBundle *)currentBundle;

@end

