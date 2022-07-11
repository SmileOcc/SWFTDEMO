//
//  OSSVCheckOutPayModuleProtocol.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVCreateOrderModel.h"
#import "OSSVOrderFinishsVC.h"
#import "OSSVAccountOrdersPageVC.h"
#import "AppDelegate.h"

typedef void(^moduleFinsh)(void);
typedef void(^moduleStatusCase) (STLOrderPayStatus status);
typedef void(^analyticsStatusCase) (STLOrderPayStatus status);

@protocol OSSVCheckOutPayModuleProtocol <NSObject>

@property (nonatomic, strong) OSSVCreateOrderModel *OSSVOrderInfoeModel;
//@property (nonatomic, strong) RateModel *rateModel;
@property (nonatomic, weak) STLBaseCtrl *controller;
@property (nonatomic, copy) moduleFinsh payModuleFinsh;
@property (nonatomic, copy) moduleStatusCase payModuleCase;
@property (nonatomic, copy) analyticsStatusCase onalyAnalyticsBlock;

@optional
///<处理支付
-(void)handlePay;

@end
