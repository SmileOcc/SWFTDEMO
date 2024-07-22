//
//  ZFAccountCountryViewController.h
//  ZZZZZ
//
//  Created by YW on 2018/6/19.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFBaseViewController.h"
@class ZFAddressCountryModel;

typedef enum : NSUInteger {
    CountryVCComeFrom_AccountCountry,
    CountryVCComeFrom_GuideCountry,
} ZFCountryVCComeFromType;


typedef void(^SelectCountryBlcok)(ZFAddressCountryModel *model);

@interface ZFAccountCountryViewController : ZFBaseViewController

/** 从启动引导进来需要选中之前选择的国家 */
@property (nonatomic, strong) ZFAddressCountryModel *shouldSelectedModel;

@property (nonatomic, assign) ZFCountryVCComeFromType comeFromType;

@property (nonatomic, copy) SelectCountryBlcok selectCountryBlcok;

@end
