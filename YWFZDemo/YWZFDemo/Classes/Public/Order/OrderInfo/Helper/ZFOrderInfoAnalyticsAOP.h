//
//  ZFOrderInfoAnalyticsAOP.h
//  ZZZZZ
//
//  Created by YW on 2018/11/2.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//  提交订单页面统计AOP
//  适用于 ZFOrderInfoViewController

#import <Foundation/Foundation.h>
#import "AnalyticsInjectManager.h"
#import "ZFAnalyticsInjectProtocol.h"
#import "ZFCartBtsModel.h"
#import "ZFOrderManager.h"
#import "ZFOrderCheckInfoDetailModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface ZFOrderInfoAnalyticsAOP : NSObject
<
    ZFAnalyticsInjectProtocol
>
//支付类型
@property (nonatomic, assign) PayCodeType     payCode;
//支付管理器
@property (nonatomic, weak) ZFOrderManager    *manager;
//提交订单订单信息
@property (nonatomic, weak) ZFOrderCheckInfoDetailModel *checkOutModel;

@end

NS_ASSUME_NONNULL_END
