//
//  ZFLocalizationString.m
//  ZZZZZ
//
//  Created by YW on 2017/2/13.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFLocalizationString.h"
#import <objc/runtime.h>
#import "NSArray+SafeAccess.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

NSString *const ZFKLocalizableSetting = @"ZFKLocalizableSetting";
NSString *const ZFLocalizationStringDidChanged = @"ZFLocalizationStringDidChanged";
//保存用户选择过的国家语言d简码，匹配用户在App内使用语言时用到
NSString *const ZFUserSelectLanguage = @"ZFUserSelectLanguage";

@interface ZFLocalizationString ()

@property (nonatomic, strong) NSBundle *currentBundle;
@property (nonatomic, copy) NSString *currentLanguage;

@end

@implementation ZFLocalizationString

@synthesize localizableNames = _localizableNames;
@synthesize languageArray    = _languageArray;
@synthesize nomarLocalizable = _nomarLocalizable;

+ (instancetype)shareLocalizable {
    static ZFLocalizationString *localizable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localizable = [[ZFLocalizationString alloc]init];
        [localizable getlocalizableNames];
        [localizable settingParment];
    });
    return localizable;
}

/**
 * 启动时获取语言来显示相应引导图
 */
+ (NSString *)fetchAppleLanguages
{
    NSString *languageName = @"en";
    NSArray *appLanguageArr = GetUserDefault(APPLELANGUAGES);
    if (ZFJudgeNSArray(appLanguageArr)) {
        languageName = [appLanguageArr objectWithIndex:0];
        if (![languageName hasPrefix:@"en"] &&
            ![languageName hasPrefix:@"fr"] &&
            ![languageName hasPrefix:@"es"] &&
            ![languageName hasPrefix:@"ar"]) {
            languageName = @"en";
        }
        if (languageName.length > 2) {
            languageName = [languageName substringToIndex:2];
        }
    }
    return languageName;
}

- (NSString *)fetchAppLocalLanguage
{
    NSString *languageName = @"en";
    NSArray *appLanguageArr = GetUserDefault(APPLELANGUAGES);
    if (ZFJudgeNSArray(appLanguageArr)) {
        languageName = [appLanguageArr objectWithIndex:0];
        if (languageName.length > 2) {
            languageName = [languageName substringToIndex:2];
        }
        languageName = [languageName lowercaseString];
    }
    return languageName;
}

- (void)settingParment{
    if ([self isExitLocalLocalizable]) {
        // 以 APP 设置的优先
        self.nomarLocalizable = [[NSUserDefaults standardUserDefaults] objectForKey:ZFKLocalizableSetting];
    }
}

- (void)setNomarLocalizable:(NSString *)nomarLocalizable {
    //转化后台语言为本地语言包
    //ar
    //de
    //en
    //es
    //fr
    //id
    //it
    //pt
    //ru
    //th
    //tr
    //zh-Hans
    //zh-Hant-TW
    //设置语言
    if ([nomarLocalizable isEqualToString:@"zh-tw"]) {
        _nomarLocalizable = @"zh-Hant-TW";
    } else if ([nomarLocalizable isEqualToString:@"zh"]) {
        _nomarLocalizable = @"zh-Hans";
    } else {
        _nomarLocalizable  = nomarLocalizable;
    }
    if (![_localizableNames containsObject:_nomarLocalizable]) {
        _nomarLocalizable = @"en";
    }
}

-(NSString *)nomarLocalizable
{
    if ([_nomarLocalizable isEqualToString:@"zh-Hans"]) {
        return @"zh";
    } else if ([_nomarLocalizable isEqualToString:@"zh-Hant-TW"]) {
        return @"zh-tw";
    }
    return _nomarLocalizable;
}

- (NSString *)ZFLocalizedString:(NSString *)translation_key {
    NSString *s = nil;
    
    if (_nomarLocalizable && self.currentBundle) {
        s = [self.currentBundle localizedStringForKey:translation_key value:@"" table:nil];
    }else{
        s = NSLocalizedStringFromTable(translation_key, nil, nil);
    }
    return [NSString stringWithFormat:@"%@",s];
}

- (void)getlocalizableNames {
    NSArray *array             = [[NSBundle mainBundle]pathsForResourcesOfType:@"lproj" inDirectory:nil];
    NSMutableArray *filltArray = [NSMutableArray array];

    NSString *systemLanguage;
    if ([NSLocale preferredLanguages].count > 0) {
        systemLanguage   = [[[NSLocale preferredLanguages] objectAtIndex:0] substringToIndex:2];
    } else {
        systemLanguage   = [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode];
    }
    __block BOOL isExist       = NO;
    [array enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj = [obj stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%@/", [NSBundle mainBundle].resourcePath] withString:@""];
        obj = [obj stringByReplacingOccurrencesOfString:@".lproj" withString:@""];
        if ([obj isEqualToString:systemLanguage]) {
            isExist = YES;
        }
        [filltArray addObject:obj];
    }];
    
    if (![self isExitLocalLocalizable]) {
        if (isExist) {
            _nomarLocalizable = systemLanguage;
        } else {
            _nomarLocalizable = @"en";
        }
    }
    _localizableNames = filltArray;
}

- (BOOL)currentLocalizable:(NSString *)locallizable{
    __block BOOL isExit = NO;
    [_localizableNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([locallizable hasPrefix:obj]) {
            isExit = YES;
            *stop = YES;
        }
    }];
    return isExit;
}

- (BOOL)isExitLocalLocalizable {
    return  [[NSUserDefaults standardUserDefaults] objectForKey:ZFKLocalizableSetting] ? YES : NO;
}

// 全称
- (NSString *)currentLanguageName {
    NSString *languageName = ZFLocalizedString(@"Languge_Setting_English", nil); 
    for (NSInteger i = 0; i < self.languageArray.count; i++) {
        ZFSupportLangModel *model = self.languageArray[i];
        NSString *languegeCode = model.code;
        if ([languegeCode isEqualToString:self.nomarLocalizable]) {
            languageName = model.name;
            break;
        }
    }
    return languageName;
}

//简写
- (NSString *)currentLanguageMR {
    return self.nomarLocalizable;
}

/**
 *  筛选支持的数组语言中需要选定的默认语言
 *  @return 筛选出来的语言模型
 */
- (ZFSupportLangModel *)filterSupporlang:(NSArray<ZFSupportLangModel *> *)supportLangList
{
    if ([supportLangList count]) {
        //设置语言
        NSString *userLocalSetting = [[NSUserDefaults standardUserDefaults] objectForKey:ZFUserSelectLanguage];
        __block BOOL find = NO;
        __block ZFSupportLangModel *supportModel = nil;
        if (userLocalSetting) {
            //如果本地设置过语言
            [supportLangList enumerateObjectsUsingBlock:^(ZFSupportLangModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //用本地设置过的语言去匹配后台语言库
                if ([obj.code isEqualToString:userLocalSetting]) {
                    //如果用户本机的语言，存在在我们后台返回的语言里面
                    supportModel = obj;
                    find = YES;
                    *stop = YES;
                }
            }];
        }
        
        if (!find) {
            NSString *localCountryCode = [[ZFLocalizationString shareLocalizable] fetchAppLocalLanguage];
            [supportLangList enumerateObjectsUsingBlock:^(ZFSupportLangModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //使用本机语言匹配后台语言库
                if ([obj.code isEqualToString:localCountryCode]) {
                    //如果用户本机的语言，存在在我们后台返回的语言里面
                    supportModel = obj;
                    find = YES;
                    *stop = YES;
                }
            }];
        }
        
        if (!find) {
            //如果本机不存在后台返回的语言中，就默认选择第一个语言
            if (supportLangList.firstObject) {
                supportModel = supportLangList.firstObject;
            } else {
                ZFSupportLangModel *model = [[ZFSupportLangModel alloc] init];
                model.code = @"en";
                model.name = @"English";
                supportModel = model;
            }
        }
        
        return supportModel;
    } else {
        ZFSupportLangModel *model = [[ZFSupportLangModel alloc] init];
        model.code = @"en";
        model.name = @"English";
        return model;
    }
}

/**
 *  保存用户选择的语言，用于筛选语言显示
 */
- (void)saveUserSelectLanguage:(NSString *)selectLanguage
{
    [[NSUserDefaults standardUserDefaults] setObject:selectLanguage forKey:ZFUserSelectLanguage];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)saveNomarLocalizableLanguage:(NSString *)language
{
    [[NSUserDefaults standardUserDefaults] setObject:language forKey:ZFKLocalizableSetting];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - getter/setter

- (NSArray<ZFSupportLangModel *> *)languageArray
{
    if (![_languageArray count]) {
        ZFSupportLangModel *supportLangModel = [[ZFSupportLangModel alloc] init];
        supportLangModel.name = @"English";
        supportLangModel.code = @"en";
        return @[supportLangModel];
    } else {
        return _languageArray;
    }
}

- (void)setLanguageArray:(NSArray *)languageArray {
    _languageArray = languageArray;
}

-(NSBundle *)currentBundle
{
    if (_currentBundle && [_currentLanguage isEqualToString:_nomarLocalizable]) {
        return _currentBundle;
    } else {
        NSString *path = [[NSBundle mainBundle] pathForResource:_nomarLocalizable ofType:@"lproj"];
        NSBundle *languageBundle = [NSBundle bundleWithPath:path];
        _currentLanguage = _nomarLocalizable;
        _currentBundle = languageBundle;
        return _currentBundle;
    }
}

@end
