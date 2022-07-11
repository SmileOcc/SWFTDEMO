//
//  OSSVCodPayModule.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/18.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVCodPayModule.h"
#import "OSSVAdvsEventsManager.h"

@implementation OSSVCodPayModule
@synthesize OSSVOrderInfoeModel = _orderInfoModel;
@synthesize controller = _controller;
@synthesize payModuleFinsh = _payModuleFinsh;
@synthesize payModuleCase = _payModuleCase;
//@synthesize rateModel = _rateModel;
@synthesize onalyAnalyticsBlock = _onalyAnalyticsBlock;

-(void)handlePay
{
    OSSVOrderFinishsVC *orderFinishVC = [OSSVOrderFinishsVC new];
    orderFinishVC.createOrderModel = self.OSSVOrderInfoeModel;
    orderFinishVC.isCOD = YES;
//    orderFinishVC.rateModel = self.rateModel;

    orderFinishVC.block = ^{
        [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:STLOrderPayStatusDone];
    };
    
    if (self.payModuleFinsh) {
        self.payModuleFinsh();
    }
    [self.controller.navigationController pushViewController:orderFinishVC animated:YES];

//    [self.controller presentViewController:orderFinishVC animated:YES completion:nil];
}

@end
