//
//  YXMineConfigModel.h
//  uSmartOversea
//
//  Created by chenmingmao on 2020/6/16.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface YXMineConfigLogModel : NSObject

@property (nonatomic, strong) NSString *white;
@property (nonatomic, strong) NSString *black;

@property (nonatomic, strong) NSString *cnLogo;
@property (nonatomic, strong) NSString *hkLogo;
@property (nonatomic, strong) NSString *enLogo;

@end

@interface YXMineConfigNameModel : NSObject

@property (nonatomic, strong) NSString *en;
@property (nonatomic, strong) NSString *zhCHT;
@property (nonatomic, strong) NSString *zhCHS;

@end

@interface YXMineConfigElementModel : NSObject

@property (nonatomic, strong) YXMineConfigNameModel *mainTitle;
@property (nonatomic, strong) YXMineConfigNameModel *subTitle;
// 跳转类型，h5，本地，不跳转
@property (nonatomic, assign) NSInteger jumpType;
@property (nonatomic, strong) NSString *jumpUrl;
@property (nonatomic, strong) NSString *eventTrackingId;
@property (nonatomic, assign) BOOL redDotEnabled;
@property (nonatomic, strong) YXMineConfigLogModel *logUrl;
// 小红点枚举，0：无，1：活动中心，2：奖励中心
@property (nonatomic, assign) NSInteger redDotType;
@property (nonatomic, assign) BOOL checkLogin;

@end

@interface YXMineConfigModuleModel : NSObject

@property (nonatomic, strong) NSString *moduleName;
// 模块类型 1.九宫格 2.两列 3.单列
@property (nonatomic, assign) NSInteger moduleType;
@property (nonatomic, strong) YXMineConfigNameModel *leftTitle;
@property (nonatomic, strong) YXMineConfigNameModel *rightTitle;
@property (nonatomic, strong) NSArray <YXMineConfigElementModel *> *elements;
// 跳转类型，h5，本地，不跳转
@property (nonatomic, assign) NSInteger jumpType;
@property (nonatomic, strong) NSString *jumpUrl;
@property (nonatomic, assign) BOOL checkLogin;
@property (nonatomic, strong) NSString *eventTrackingId;

// 小红点枚举，0：无，1：活动中心，2：奖励中心
@property (nonatomic, assign) NSInteger redDotType;
@property (nonatomic, assign) BOOL redDotEnabled;

@end


@interface YXMineConfigModel : NSObject

@property (nonatomic, strong) NSArray <YXMineConfigModuleModel *> *modules;

@end

NS_ASSUME_NONNULL_END
