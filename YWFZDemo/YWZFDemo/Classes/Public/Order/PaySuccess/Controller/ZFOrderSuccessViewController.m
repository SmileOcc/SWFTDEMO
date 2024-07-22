//
//  YSOrderFinishViewController.m
//  Yoshop
//
//  Created by 7F-shigm on 16/6/24.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "ZFOrderSuccessViewController.h"
#import "ZFOrderSuccessPageVC.h"
#import "ZFOfflineOrderSuccessViewController.h"
#import "ZFLocalizationString.h"

@interface ZFOrderSuccessViewController ()

@end

@implementation ZFOrderSuccessViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = ZFLocalizedString(@"paySuccess_title", nil);
    
    BOOL offlinePayment = [self isOfflinePayment];
    
    if (offlinePayment) {
        ZFOfflineOrderSuccessViewController *offlineVC = [[ZFOfflineOrderSuccessViewController alloc] init];
        offlineVC.orderResultModel = self.orderPayResultModel;
        offlineVC.checkOrderHandler = ^{
            if (self.toAccountOrHomeblock) {
                self.toAccountOrHomeblock(YES);
            }
        };
        [offlineVC willMoveToParentViewController:self];
        [self addChildViewController:offlineVC];
        [self.view addSubview:offlineVC.view];
    } else {
        ZFOrderSuccessPageVC *successPageVC = [[ZFOrderSuccessPageVC alloc] init];
        successPageVC.fromType = self.fromType;
        successPageVC.toAccountOrHomeblock = self.toAccountOrHomeblock;
        successPageVC.isShowNotictionView = self.isShowNotictionView;
        successPageVC.isCodPay = self.baseOrderModel.isCodPay;
        successPageVC.offlineLink = self.orderPayResultModel.ebanxUrl;
        successPageVC.fiveThModel = self.orderPayResultModel.five_th_info;
        successPageVC.baseOrderModel = self.baseOrderModel;
        [successPageVC willMoveToParentViewController:self];
        [self addChildViewController:successPageVC];
        [self.view addSubview:successPageVC.view];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)isOfflinePayment
{
    if ([self.orderPayResultModel isBoletoPayment] ||
        [self.orderPayResultModel isPagoefePayment] || [self.orderPayResultModel isOXXOPayment]) {
        //这个判断分支显示 ZFOfflineOrderSuccessViewController 线下支付成功页
        return YES;
    }
    return NO;
}
@end
