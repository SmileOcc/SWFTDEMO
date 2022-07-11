//
//  OSSVPayOnlineModule.m
// XStarlinkProject
//
//  Created by Kevin on 2020/12/16.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVPayOnlineModule.h"
#import "OSSVAdvsEventsManager.h"
#import "OSSVPayPalsVC.h"

@implementation OSSVPayOnlineModule
@synthesize OSSVOrderInfoeModel = _orderInfoModel;
@synthesize controller = _controller;
@synthesize payModuleFinsh = _payModuleFinsh;
@synthesize payModuleCase = _payModuleCase;
@synthesize onalyAnalyticsBlock = _onalyAnalyticsBlock;

-(void)handlePay
{
    UIViewController *topVC = [OSSVAdvsEventsManager gainTopViewController];
    OSSVPayPalsVC *ppView = [[OSSVPayPalsVC alloc] init];
    STLOrderModel *orderModel = self.OSSVOrderInfoeModel.orderList[0];
    ppView.url = orderModel.url;

    @weakify(self)
    ppView.block = ^(STLOrderPayStatus status){
        @strongify(self)
        if (self.onalyAnalyticsBlock) {
            self.onalyAnalyticsBlock(status);
        }
        if (self.payModuleCase) {
            self.payModuleCase(status);
            return;
        }
        /*支付页回调*/
        switch (status) {
            case STLOrderPayStatusUnknown:
            {
                /***********未知错误操作*********/
            }
            case STLOrderPayStatusCancel:
            {
                [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:status];
            }
                break;
            case STLOrderPayStatusDone:
            {
                OSSVOrderFinishsVC *orderFinishVC = [OSSVOrderFinishsVC new];
                orderFinishVC.createOrderModel = self.OSSVOrderInfoeModel;
                orderFinishVC.block = ^{
                    if (self.payModuleFinsh) {
                        self.payModuleFinsh();
                    }else{
                        [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:status];
                    }
                };
                [self.controller.navigationController pushViewController:orderFinishVC animated:YES];

//                [self.controller presentViewController:orderFinishVC animated:YES completion:nil];
            }
                break;
            case STLOrderPayStatusFailed:
            {
                STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:nil message:STLLocalizedString_(@"payFailed", nil) preferredStyle:UIAlertControllerStyleAlert];
                [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"ok", nil) : STLLocalizedString_(@"ok", nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [OSSVAdvsEventsManager advEventOrderListWithPaymentStutas:status];
                }]];

                [self.controller presentViewController:alertController animated:YES completion:^{}];
            }
                break;
            default:
                break;
        }
    };
    [topVC.navigationController pushViewController:ppView animated:YES];
}

@end
