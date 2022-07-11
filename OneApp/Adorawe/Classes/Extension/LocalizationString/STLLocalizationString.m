//
//  RGLocalizationString.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/27.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "STLLocalizationString.h"
#import <objc/runtime.h>

NSString *const STLLocalizationStringDidChanged = @"STLLocalizationStringDidChanged";
NSString *const KLocalizableSetting = @"KLocalizableSetting";
//保存用户选择过的国家语言d简码，匹配用户在App内使用语言时用到
NSString *const kUserSelectLanguage = @"kUserSelectLanguage";

@interface STLLocalizationString()

@property (nonatomic, strong) NSBundle      *currentBundle;
@property (nonatomic, copy) NSString        *currentLanguage;

@end

@implementation STLLocalizationString

@synthesize localizableNames = _localizableNames;
@synthesize languageArray    = _languageArray;
@synthesize nomarLocalizable = _nomarLocalizable;

+ (instancetype)shareLocalizable {
   static STLLocalizationString *localizable;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localizable = [[STLLocalizationString alloc]init];
        [localizable getlocalizableNames];
        [localizable settingParment];
//        [localizable fetchCurLanguage];
    });
    return localizable;
}

+ (BOOL)isArlanguage:(NSString *)language {
 
    if (!STLIsEmptyString(language) && ([language hasPrefix:@"ar"] || [language hasPrefix:@"he"])) {
        return YES;
    }
    return NO;
}
+ (NSString *)fetchAppleLanguages {
    NSString *languageName = @"en";
    NSArray *appLanguageArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    
    if (STLJudgeNSArray(appLanguageArr)) {
        
        languageName =  appLanguageArr.count > 0 ? [appLanguageArr objectAtIndex:0] : @"";
        if (![languageName hasPrefix:@"en"] &&
            ![languageName hasPrefix:@"fr"] &&
            ![languageName hasPrefix:@"es"] &&
            ![languageName hasPrefix:@"ar"] &&
            ![languageName hasPrefix:@"pt"] &&
            ![languageName hasPrefix:@"de"]&&
            ![languageName hasPrefix:@"ja"]) {
            languageName = @"en";
        }
        if (languageName.length > 2) {
            languageName = [languageName substringToIndex:2];
        }
    }
    return languageName;
}

- (NSString *)fetchAppLocalLanguage {
    NSString *languageName = @"en";
    NSArray *appLanguageArr = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];

    if (STLJudgeNSArray(appLanguageArr)) {
        languageName =  appLanguageArr.count > 0 ? [appLanguageArr objectAtIndex:0] : @"";
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
        self.nomarLocalizable = [[NSUserDefaults standardUserDefaults] objectForKey:KLocalizableSetting];
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

    if (![self isContrainLocalLanguate:_nomarLocalizable]) {
        _nomarLocalizable = @"en";
    }
}

//是否存在本地支持的语言中
- (BOOL)isContrainLocalLanguate:(NSString *)language {
    if ([_localizableNames containsObject:language]) {
        return YES;
    }
    return NO;
}

-(NSString *)nomarLocalizable {
    if ([_nomarLocalizable isEqualToString:@"zh-Hans"]) {
        return @"zh";
    } else if ([_nomarLocalizable isEqualToString:@"zh-Hant-TW"]) {
        return @"zh-tw";
    } else if ([_nomarLocalizable isEqualToString:@"pt-BR"]) {
        return @"pt";
    }
    return _nomarLocalizable;
}


- (NSString *)STLLocalizedString:(NSString *)translation_key {
    NSString *s = nil;
    
    if (_nomarLocalizable && self.currentBundle) {
        s = [self.currentBundle localizedStringForKey:translation_key value:@"" table:nil];
    }else{
        s = NSLocalizedStringFromTable(translation_key, nil, nil);
    }
    return [NSString stringWithFormat:@"%@",s];
}

- (void)getlocalizableNames{
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
    //ja转化为jp
    NSInteger jpIndex = [_localizableNames indexOfObject:@"ja"];
    if (jpIndex != NSNotFound) {
        NSMutableArray* newArr = [_localizableNames mutableCopy];
        newArr[jpIndex] = @"jp";
        _localizableNames = [newArr copy];
    }
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
    return  [[NSUserDefaults standardUserDefaults] objectForKey:KLocalizableSetting]?YES:NO;
}

// 获取当前语言Code
- (void)fetchCurLanguage {
    __block NSString *curLanguage = @"en";
    NSString *locallizable = [[NSLocale preferredLanguages] objectAtIndex:0];
    [_localizableNames enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([locallizable hasPrefix:obj]) {
            curLanguage = obj;
            *stop = YES;
        }
    }];
    _curLanguage = curLanguage;
}


#pragma mark - 用户设置
// 全称
- (NSString *)currentLanguageName {
    NSString *languageName = STLLocalizedString_(@"Languge_Setting_English", nil);
    for (NSInteger i = 0; i < self.languageArray.count; i++) {
        OSSVSupporteLangeModel *model = self.languageArray[i];
        NSString *languegeCode = model.code;
        if ([languegeCode hasPrefix:self.nomarLocalizable]) {
            languageName = model.name;
            break;
        }
    }
    return languageName;
}

//当前 APP 使用的语言，默认为英语 <简写>
- (NSString *)currentLanguageMR {
    return self.nomarLocalizable;
}


/**
 *  筛选支持的数组语言中需要选定的默认语言
 *  @return 筛选出来的语言模型
 */
//- (OSSVSupporteLangeModel *)filterSupporlang:(NSArray<OSSVSupporteLangeModel *> *)supportLangList
//{
//    if ([supportLangList count]) {
//        //设置语言
//        NSString *userLocalSetting = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSelectLanguage];
//        __block BOOL find = NO;
//        __block OSSVSupporteLangeModel *supportModel = nil;
//        if (userLocalSetting) {
//            //如果本地设置过语言
//            [supportLangList enumerateObjectsUsingBlock:^(OSSVSupporteLangeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                //用本地设置过的语言去匹配后台语言库
//                if ([obj.code isEqualToString:userLocalSetting]) {
//                    //如果用户本机的语言，存在在我们后台返回的语言里面
//                    supportModel = obj;
//                    find = YES;
//                    *stop = YES;
//                }
//            }];
//        }
//
//        if (!find) {
//            NSString *localCountryCode = [[STLLocalizationString shareLocalizable] fetchAppLocalLanguage];
//            [supportLangList enumerateObjectsUsingBlock:^(OSSVSupporteLangeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                //使用本机语言匹配后台语言库
//                if ([obj.code isEqualToString:localCountryCode]) {
//                    //如果用户本机的语言，存在在我们后台返回的语言里面
//                    supportModel = obj;
//                    find = YES;
//                    *stop = YES;
//                }
//            }];
//        }
//
//        if (!find) {
//            //如果本机不存在后台返回的语言中，就默认选择第一个语言
//            if (supportLangList.firstObject) {
//                supportModel = supportLangList.firstObject;
//            } else {
//                OSSVSupporteLangeModel *model = [[OSSVSupporteLangeModel alloc] init];
//                model.code = @"en";
//                model.name = @"English";
//                supportModel = model;
//            }
//        }
//
//        return supportModel;
//    } else {
//        OSSVSupporteLangeModel *model = [[OSSVSupporteLangeModel alloc] init];
//        model.code = @"en";
//        model.name = @"English";
//        return model;
//    }
//}

+ (void )handInitSupporLang:(NSArray<OSSVSupporteLangeModel *> *)supportLangList
{
    if (!STLJudgeNSArray(supportLangList)) {
        supportLangList = @[];
    }
    
    STLLocalizationString *manager = [STLLocalizationString shareLocalizable];
    __block OSSVSupporteLangeModel *supportModel = nil;
    if ([supportLangList count]) {
        //设置语言
        NSString *userLocalSetting = [[NSUserDefaults standardUserDefaults] objectForKey:kUserSelectLanguage];
        __block BOOL find = NO;
        
        if (!STLIsEmptyString(userLocalSetting)) {//如果本地设置过语言
            [supportLangList enumerateObjectsUsingBlock:^(OSSVSupporteLangeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                //用本地设置过的语言去匹配后台语言库
                if ([obj isKindOfClass:[OSSVSupporteLangeModel class]] && [STLToString(obj.code) isEqualToString:userLocalSetting]) {
                    //如果用户本机的语言，存在在我们后台返回的语言里面
                    supportModel = obj;
                    
                    [[STLLocalizationString shareLocalizable] saveUserSelectLanguage:STLToString(supportModel.code)];
                    [[STLLocalizationString shareLocalizable] saveNomarLocalizableLanguage:STLToString(supportModel.code)];
                    
                    find = YES;
                    *stop = YES;
                }
            }];
        }
        
//        if (!find) {//没有找到，用本机取本地手机与后台匹配，
//            NSString *localCountryCode = [[STLLocalizationString shareLocalizable] fetchAppLocalLanguage];
//            [supportLangList enumerateObjectsUsingBlock:^(OSSVSupporteLangeModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//                //使用本机语言匹配后台语言库
//                if ([obj.code isEqualToString:localCountryCode]) {
//                    //如果用户本机的语言，存在在我们后台返回的语言里面
//                    supportModel = obj;
//                    find = YES;
//                    *stop = YES;
//                }
//            }];
//        }
        
        if (!find) {//没有找到，取后台默认的，
            
            //如果本机不存在后台返回的语言中，就先后面默认选择的
            for (OSSVSupporteLangeModel *model in supportLangList) {
                if (model.is_default == 1) {
                    supportModel = model;
                }
            }
        }
        
        //如果本地化不存在，默认英语
        if (supportModel && ![manager isContrainLocalLanguate:STLToString(supportModel.code)]) {
            OSSVSupporteLangeModel *model = [[OSSVSupporteLangeModel alloc] init];
            model.code = @"en";
            model.name = @"English";
            supportModel = model;
        }
        
    }
    
    if (!supportModel) {
        supportModel = [[OSSVSupporteLangeModel alloc] init];
        supportModel.code = @"en";
        supportModel.name = @"English";
    }
    
    [STLLocalizationString shareLocalizable].languageArray = supportLangList;
    [STLLocalizationString shareLocalizable].nomarLocalizable = STLToString(supportModel.code);
}


/**
 *  保存用户选择的语言，用于筛选语言显示
 */
- (void)saveUserSelectLanguage:(NSString *)selectLanguage {
    if (!STLIsEmptyString(selectLanguage)) {
        [[NSUserDefaults standardUserDefaults] setObject:selectLanguage forKey:kUserSelectLanguage];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)saveNomarLocalizableLanguage:(NSString *)language {
    if (!STLIsEmptyString(language)) {
        [[NSUserDefaults standardUserDefaults] setObject:language forKey:KLocalizableSetting];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}


#pragma mark - getter/setter

- (NSArray<OSSVSupporteLangeModel *> *)languageArray {
    
    if (![_languageArray count]) {
        //本地默认英语
        if (APP_TYPE == 1) {//中东项目
            OSSVSupporteLangeModel *supportLangModel = [[OSSVSupporteLangeModel alloc] init];
            supportLangModel.name = @"English";
            supportLangModel.code = @"en";
            
            OSSVSupporteLangeModel *arLangModel = [[OSSVSupporteLangeModel alloc] init];
            arLangModel.name = @"العربية";
            arLangModel.code = @"ar";
    
            return @[supportLangModel,arLangModel];
        } else {
            OSSVSupporteLangeModel *supportLangModel = [[OSSVSupporteLangeModel alloc] init];
            supportLangModel.name = @"English";
            supportLangModel.code = @"en";
            return @[supportLangModel];
        }
    } else {
        return _languageArray;
    }
}

- (void)setLanguageArray:(NSArray *)languageArray {
    _languageArray = languageArray;
}

-(NSBundle *)currentBundle {
    if (_currentBundle && [_currentLanguage isEqualToString:_nomarLocalizable]) {
        return _currentBundle;
    } else {
        NSString *nomarLocalizable = [_nomarLocalizable isEqualToString:@"jp"] ? @"ja" : _nomarLocalizable;
        NSString *path = [[NSBundle mainBundle] pathForResource:nomarLocalizable ofType:@"lproj"];
        NSBundle *languageBundle = [NSBundle bundleWithPath:path];
        _currentLanguage = _nomarLocalizable;
        _currentBundle = languageBundle;
        return _currentBundle;
    }
}

/*
 // 当前所在地信息
 NSString *identifier = [[NSLocalecurrentLocale] localeIdentifier];
 NSString *displayName = [[NSLocale currentLocale] displayNameForKey:NSLocaleIdentifier value:identifier];
 NSLog(@"%@", displayName);
 
 // 当前所在地的使用语言
 NSLocale *currentLocale = [NSLocale currentLocale];
 NSLog(@"Language Code is %@", [currentLocale objectForKey:NSLocaleLanguageCode]);
 
 // 系统语言
 NSArray *arLanguages = [[NSUserDefaultsstandardUserDefaults] objectForKey:@"AppleLanguages"];
 NSString *strLang = [arLanguages objectAtIndex:0];
 NSLog(@"LANG:%@",strLang);
 */

@end

