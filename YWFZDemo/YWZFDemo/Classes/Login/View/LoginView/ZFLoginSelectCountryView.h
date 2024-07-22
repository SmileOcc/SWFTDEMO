//
//  YWLoginSelectCountryView.h
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//  登录选择国家的视图

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class YWLoginNewCountryModel;
typedef void(^didSelectCountryBlock)(YWLoginNewCountryModel *model);

@interface YWLoginSelectCountryView : UIView

@property (nonatomic, copy) didSelectCountryBlock selectCountryHandler;

@property (nonatomic, strong) NSArray<YWLoginNewCountryModel *> *countryList;

@property (nonatomic, strong) YWLoginNewCountryModel *defaultCountryModel;

@end

NS_ASSUME_NONNULL_END
