//
//  ZFLangugeSettingViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/11/24.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
#import "ZFTabBarController.h"
#import "AccountManager.h"

typedef enum : NSUInteger {
    LangugeSettingComeFrom_AccountVC,
    LangugeSettingComeFrom_GuideSettingVC
} LangugeSettingComeFromType;

@interface ZFLangugeSettingViewController : ZFBaseViewController

/** 从启动引导进来需要选中之前选择的语言 简称(两个字母) */
@property (nonatomic, strong) NSString *shouldSelectedShortenedLang;

@property (nonatomic, assign) LangugeSettingComeFromType comeFromType;

@property (nonatomic, strong) NSArray <ZFSupportLangModel *> *supportLangList;

//selectedLanguge: 全称, shortenedLang:简称(两个字母)
@property (nonatomic, copy) void (^convertLangugeBlock)(NSString *selectedLanguge, NSString *shortenedLang);

/**
 * 切换语言统计
 */
+ (void)convertLangugeAnalytic;

/**
 * 切换语言,切换国家时 重新初始化AppTabbr, 刷新国家运营数据
 */
+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex;


+ (void)initAppTabBarVCFromChangeLanguge:(NSInteger)tabBarIndex completion:(void(^)(BOOL success))completion;

@end
