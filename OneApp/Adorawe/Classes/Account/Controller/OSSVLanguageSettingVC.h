//
//  OSSVLanguageSettingVC.h
// XStarlinkProject
//
//  Created by odd on 2020/7/10.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLBaseCtrl.h"

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    LangugeSettingComeFrom_AccountVC,
    LangugeSettingComeFrom_GuideSettingVC
} LangugeSettingComeFromType;

@interface OSSVLanguageSettingVC : STLBaseCtrl

/** 从启动引导进来需要选中之前选择的语言 简称(两个字母) */
@property (nonatomic, strong) NSString                          *shouldSelectedShortenedLang;

@property (nonatomic, assign) LangugeSettingComeFromType        comeFromType;

@property (nonatomic, strong) NSArray <OSSVSupporteLangeModel *>   *supportLangList;

//selectedLanguge: 全称, shortenedLang:简称(两个字母)
@property (nonatomic, copy) void (^convertLangugeBlock)(NSString *selectedLanguge, NSString *shortenedLang);

/**
 * 切换语言,切换国家时 重新初始化AppTabbr, 刷新国家运营数据
 */
+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex;


+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex completion:(void(^)(BOOL success))completion;


@end

NS_ASSUME_NONNULL_END
