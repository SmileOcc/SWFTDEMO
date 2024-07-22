//
//  ZFOrderPayResultHandler.m
//  ZZZZZ
//
//  Created by YW on 2019/9/18.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFOrderPayResultHandler.h"

#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"

#import "YSAlertView.h"
#import "YWCFunctionTool.h"
#import "ZFLocalizationString.h"

#import "ZFOrderSuccessViewController.h"
#import "ZFMyOrderListViewController.h"
#import "ZFOrderDetailViewController.h"
#import "ZFTabBarController.h"

typedef NS_ENUM(NSInteger, PaymentStatus) {
    PaymentStatusUnknown,
    PaymentStatusDone,
    PaymentStatusCancel,
    PaymentStatusFail,
};

@interface ZFOrderPayResultHandler ()

@property (nonatomic, assign) ZFOrderPayResultSource source;

@end

@implementation ZFOrderPayResultHandler

- (void)dealloc
{
    YWLog(@"ZFOrderPayResultHandler dealloc");
}

+ (instancetype)handler
{
    return [[self alloc] init];
}

- (void)orderPaySuccess:(ZFOrderPayResultSource)source baseOrderModel:(ZFBaseOrderModel *)orderModel resultModel:(ZFOrderPayResultModel *)resultModel
{
    self.source = source;
    [self showPaySuccessViewController:orderModel payResult:resultModel];
}

- (void)showPaySuccessViewController:(ZFBaseOrderModel *)orderModel payResult:(ZFOrderPayResultModel *)payResultModel {
    // 清除购物车选择主动记住的全局优惠券
    [AccountManager clearUserSelectedCoupon];
    
    ZFOrderSuccessViewController *finischVC = [[ZFOrderSuccessViewController alloc] init];
    finischVC.isShowNotictionView = YES;
    finischVC.orderPayResultModel = payResultModel;
    finischVC.baseOrderModel = orderModel;
    finischVC.fromType = ZFOrderPayResultSource_Other;
    finischVC.toAccountOrHomeblock = ^(BOOL gotoOrderList){
        @weakify(self)
        [self.zfParentViewController dismissViewControllerAnimated:NO completion:^{
            @strongify(self)
            if (gotoOrderList) {
                if (self.source == ZFOrderPayResultSource_OrderInfo) {
                    [self jumpToOrderDetailViewController:PaymentStatusDone orderModel:orderModel payResult:payResultModel];
                } else {
                    [self.zfParentViewController.navigationController popToViewController:self.zfParentViewController animated:YES];
                    if (self.dismissSuccessVCBlock) {
                        self.dismissSuccessVCBlock();
                    }
                    //通知订单列表刷新页面
                    if (self.source == ZFOrderPayResultSource_OrderDetail) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:kZFReloadOrderListData object:nil];
                    }
                }
            }else{
                [self.zfParentViewController.navigationController popToRootViewControllerAnimated:NO];
                ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
                [tabBarVC setZFTabBarIndex:TabBarIndexHome];
                if (self.source == ZFOrderPayResultSource_OrderInfo) {
                    [ZFFireBaseAnalytics selectContentWithItemId:@"Payment_Success_ToHome" itemName:@"" ContentType:@"Payment Success" itemCategory:@""];
                }
            }
        }];
    };
    
    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:finischVC];
    [self.zfParentViewController.navigationController presentViewController:nav animated:YES completion:nil];
}

- (void)jumpToOrderDetailViewController:(NSInteger)state orderModel:(ZFBaseOrderModel *)model payResult:(ZFOrderPayResultModel *)payResultModel {
    ZFTabBarController *tabbar = (ZFTabBarController *)self.zfParentViewController.tabBarController;
    [tabbar setZFTabBarIndex:TabBarIndexAccount];
    ZFNavigationController *nav = [tabbar navigationControllerWithMoudle:TabBarIndexAccount];
    if (nav) {
        if (nav.viewControllers.count>1) {
            [nav popToRootViewControllerAnimated:NO];
        }
        ZFMyOrderListViewController *orderListVC = [[ZFMyOrderListViewController alloc] init];
        //取消、失败需要传入订单ID到后面支付这个订单时，是否弹窗远程通知视图
        if (state == PaymentStatusCancel || state == PaymentStatusFail) {
            orderListVC.sourceOrderId = ZFToString(model.order_id);
        }
        [nav pushViewController:orderListVC animated:NO];
        
        ZFOrderDetailViewController *orderDetailVC = [[ZFOrderDetailViewController alloc] init];
        orderDetailVC.orderId = model.order_id;
        [orderListVC.navigationController pushViewController:orderDetailVC animated:YES];
    }
    if (ZFToString(payResultModel.ebanxUrl).length) {
        //线下支付不弹窗
        state = PaymentStatusUnknown;
    }
    [self showTipsWithPayState:state];
}

- (void)showTipsWithPayState:(NSInteger )states {
    NSString *title;
    NSString *message;
    switch (states) {
        case PaymentStatusDone:
        {
            message = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusDone_Alert_Message",nil);
            title = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusDone_Alert_Title",nil);
        }
            break;
        case PaymentStatusCancel:
        {
            message = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusCancel_Alert_Message",nil);
            title = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusCancel_Alert_Title",nil);
        }
            break;
        case PaymentStatusFail:
        {
            message = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusFail_Alert_Message",nil);
            title = ZFLocalizedString(@"CartOrderInfoModel_PaymentStatusFail_Alert_Title",nil);
        }
            break;
    }
    ShowAlertSingleBtnView(title, message, ZFLocalizedString(@"OK", nil));
}

@end
