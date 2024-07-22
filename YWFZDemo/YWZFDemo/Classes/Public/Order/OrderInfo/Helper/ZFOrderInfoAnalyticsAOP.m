//
//  ZFOrderInfoAnalyticsAOP.m
//  ZZZZZ
//
//  Created by YW on 2018/11/2.
//  Copyright © 2018 ZZZZZ. All rights reserved.
//

#import "ZFOrderInfoAnalyticsAOP.h"
#import "ZFOrderInformationViewModel.h"
#import "ZFOrderPaymentListCell.h"
#import "ZFOrderAddressCell.h"
#import "ZFOrderInsuranceCell.h"
#import "ZFOrderCouponCell.h"
#import "ZFOrderGoodsCell.h"
#import <Branch/Branch.h>
#import "ZFPaymentViewController.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "ZFOrderManager.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFBranchAnalytics.h"
#import "ZFOrderPayResultModel.h"

@implementation ZFOrderInfoAnalyticsAOP

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

//生命周期
- (void)after_viewDidLoad
{
    //v4.1.0新增统计代码
    NSDictionary *params = @{ @"af_content_type": @"view checkoutpage",
                              };
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_checkout_page" withValues:params];
    
    NSString *orderTypeName = [self.manager orderTypeNameWithPayCode:self.payCode];
    
    /*谷歌统计*/
    [ZFAnalytics screenViewQuantityWithScreenName:orderTypeName];
    [ZFAnalytics settleInfoProcedureWithProduct:self.checkOutModel.cart_goods.goods_list step:1 option:nil screenName:[NSString stringWithFormat:@"%@ Detail", orderTypeName]];
    
    [ZFFireBaseAnalytics checkoutProgressWithStep:1 checkInfoModel:self.checkOutModel];
}

//底部checkout按钮点击
- (void)after_ZFOrderPlaceBottomViewDidClickPlaceOrderButton
{
    NSString *orderTypeName = [self.manager orderTypeNameWithPayCode:self.payCode];
    [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Place Order" itemName:@"Place Order" ContentType:@"Order - Information" itemCategory:@"Button"];

    [ZFAnalytics clickButtonWithCategory:orderTypeName actionName:[NSString stringWithFormat:@"%@ - Place Order", orderTypeName] label:[NSString stringWithFormat:@"%@ - Place Order", orderTypeName]];
}

//显示收银台
- (void)after_showPaymentView:(ZFOrderCheckDoneDetailModel *)checkDoneDetailModel
{
    [self analyticsWithCheckDoneModel:checkDoneDetailModel];
}

//支付成功
- (void)after_showPaySuccessViewController:(ZFOrderCheckDoneDetailModel *)model payResult:(ZFOrderPayResultModel *)payResultModel
{
    //只有当支付是COD的时候，才会走这一个步骤
    if (self.manager.currentPaymentType == CurrentPaymentTypeCOD) {
        model.realPayment = @"Cod";
        [self analyticsWithCheckDoneModel:model];
    }
    
    if (ZFToString(payResultModel.ebanxUrl).length) {
        //线下支付的不能提交支付成功的事件
        return;
    }
    
    //支付打点
    [ZFOrderInformationViewModel requestPayTag:model.order_sn step:@"completed"];
    //GrowingIO 支付成功统计
//    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderSuccess:model orderManager:self.manager paySource:@"OrderInfo"];
//    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderSKUSuccess:model checkInfoOderDetail:self.checkOutModel orderManager:self.manager paySource:@"OrderInfo"];

    __block NSString *orderTypeName = [self.manager orderTypeNameWithPayCode:self.payCode];
    [ZFAnalytics settleInfoProcedureWithProduct:self.checkOutModel.cart_goods.goods_list step:3 option:nil screenName:[NSString stringWithFormat:@"%@ PaySuccess", orderTypeName]];
    [ZFAnalytics trasactionInfoWithProduct:self.checkOutModel.cart_goods.goods_list order:model screenName:[NSString stringWithFormat:@"%@ PaySuccess", orderTypeName]];
    
    [ZFFireBaseAnalytics checkoutProgressWithStep:3 checkInfoModel:self.checkOutModel];
    [ZFFireBaseAnalytics selectContentWithItemId:@"Payment_Result_Success" itemName:@"" ContentType:@"Payment Result" itemCategory:@""];
}

//支付失败
- (void)after_showPayFailureViewController:(ZFOrderCheckDoneDetailModel *)model
{
    [ZFAnalytics settleInfoProcedureWithProduct:self.checkOutModel.cart_goods.goods_list step:2 option:nil screenName:@"Pay"];
    [ZFFireBaseAnalytics selectContentWithItemId:@"Payment_Result_Fail" itemName:@"" ContentType:@"Payment Result" itemCategory:@""];
}

//支付成功显示成功页面跳转
- (void)after_jumpToMyOrderListViewController:(NSInteger)state orderModel:(ZFOrderCheckDoneDetailModel *)model payResult:(ZFOrderPayResultModel *)resultModel
{
    if (state == PaymentStatusFail) {
        NSString *orderTypeName = [self.manager orderTypeNameWithPayCode:self.payCode];
        [ZFAnalytics clickButtonWithCategory:[NSString stringWithFormat:@"%@ Payment Failure", orderTypeName] actionName:[NSString stringWithFormat:@"%@ Payment Failure - My Account", orderTypeName] label:[NSString stringWithFormat:@"%@ Payment Failure - My Account", orderTypeName]];
        [ZFAnalytics settleInfoProcedureWithProduct:self.checkOutModel.cart_goods.goods_list step:3 option:nil screenName:[NSString stringWithFormat:@"%@ PayFailure", orderTypeName]];
        [ZFAnalytics trasactionInfoWithProduct:self.checkOutModel.cart_goods.goods_list order:model screenName:[NSString stringWithFormat:@"%@ PayFailure", orderTypeName]];

        [ZFFireBaseAnalytics checkoutProgressWithStep:3 checkInfoModel:self.checkOutModel];
    }else if (state == PaymentStatusDone) {
        [ZFFireBaseAnalytics selectContentWithItemId:@"Payment_Success_ToOrderList" itemName:@"" ContentType:@"Payment Success" itemCategory:@""];
    }
}

//选择了优惠券
- (void)after_checkoutCouponWithCouponModel:(NSString *)couponCode myCouponViewController:(UIViewController *)viewController
{
    // 统计
    [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Select_Coupon_%@", couponCode] itemName:@"Coupon" ContentType:@"Order - Information" itemCategory:@"Coupon Item"];
}

//点击了cell
- (void)after_tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *selectCell = [tableView cellForRowAtIndexPath:indexPath];
    NSString *orderTypeName = [self.manager orderTypeNameWithPayCode:self.payCode];
    if (selectCell.class == [ZFOrderAddressCell class]) {
        // 统计
        [ZFAnalytics clickButtonWithCategory:[NSString stringWithFormat:@"%@ Order", orderTypeName] actionName:[NSString stringWithFormat:@"%@ Order - Address", orderTypeName] label:[NSString stringWithFormat:@"%@ Order - Address", orderTypeName]];
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Address" itemName:[NSString stringWithFormat:@"%@ Address", orderTypeName] ContentType:@"Order - Information" itemCategory:[NSString stringWithFormat:@"%@ Address", orderTypeName]];
    }else if (selectCell.class == [ZFOrderPaymentListCell class]){
        ZFOrderPaymentListCell *paymentListCell = [tableView cellForRowAtIndexPath:indexPath];
        PaymentListModel *model = paymentListCell.paymentListmodel;
        
        [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_PayMethod_%@", model.pay_code] itemName:[NSString stringWithFormat:@"%@ PayMethod", orderTypeName] ContentType:@"Order - Information" itemCategory:[NSString stringWithFormat:@"%@ PayMethod", orderTypeName]];
    }else if (selectCell.class == [ZFOrderInsuranceCell class]){
        // 统计
        ZFOrderInsuranceCell *insuranceCell = [tableView cellForRowAtIndexPath:indexPath];
        [ZFFireBaseAnalytics selectContentWithItemId:[NSString stringWithFormat:@"Click_Shipping_Insurance_%d", insuranceCell.isChoose] itemName:[NSString stringWithFormat:@"%@ Shipping_Insurance", orderTypeName] ContentType:@"Order - Information" itemCategory:[NSString stringWithFormat:@"%@ Shipping_Insurance", orderTypeName]];
    }else if (selectCell.class == [ZFOrderCouponCell class]){
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Coupon" itemName:@"Coupon" ContentType:@"Order - Information" itemCategory:@"Coupon Item"];
    }else if (selectCell.class == [ZFOrderGoodsCell class]){
        [ZFFireBaseAnalytics selectContentWithItemId:@"Click_Item" itemName:@"Item" ContentType:@"Order - Information" itemCategory:@"Item"];
    }
}

#pragma mark - protocol

- (nonnull NSDictionary *)injectMenthodParams {
    NSDictionary *params = @{
                             //生命周期
                             @"viewDidLoad" :
                             @"after_viewDidLoad",
                             //底部checkout按钮点击
                             @"ZFOrderPlaceBottomViewDidClickPlaceOrderButton" :
                             @"after_ZFOrderPlaceBottomViewDidClickPlaceOrderButton",
                             //支付成功
                             @"showPaySuccessViewController:payResult:" :
                             @"after_showPaySuccessViewController:payResult:",
                             //支付失败
                             @"showPayFailureViewController:" :
                             @"after_showPayFailureViewController:",
                             //支付成功显示成功页面跳转
                             @"jumpToMyOrderListViewController:orderModel:payResult:" :
                             @"after_jumpToMyOrderListViewController:orderModel:payResult:",
                             //显示收银台
                             @"showPaymentView:" :
                             @"after_showPaymentView:",
                             //选择了优惠券
                             @"checkoutCouponWithCouponModel:myCouponViewController:" :
                             @"after_checkoutCouponWithCouponModel:myCouponViewController:",
                             //点击了cell
                             @"tableView:didSelectRowAtIndexPath:" :
                             @"after_tableView:didSelectRowAtIndexPath:"
                             };
    return params;
}

#pragma mark - private method

- (void)analyticsWithCheckDoneModel:(ZFOrderCheckDoneDetailModel *)doneModel
{
    NSString *goodsStr = [self.manager appendGoodsSN:self.checkOutModel];
    NSString *goodsPrices = [self.manager appendGoodsPrice:self.checkOutModel];
    NSString *goodsQuantity = [self.manager appendGoodsQuantity:self.checkOutModel];
    
    //用户创建订单成功统计
    NSMutableDictionary *valuesDic = [NSMutableDictionary dictionary];
    valuesDic[AFEventParamContentId] = ZFToString(goodsStr);
    valuesDic[AFEventParamContentType] = @"product";
    NSString *paymenthod = doneModel.pay_method;
    if (ZFIsEmptyString(paymenthod)) {
        //如果后台没有返回，就取用本地的
        paymenthod = self.manager.paymentCode;
    }
    valuesDic[@"af_payment"] = ZFToString(paymenthod);
    valuesDic[@"af_reciept_id"] = ZFToString(doneModel.order_sn);
    valuesDic[AFEventParamPrice] = ZFToString(goodsPrices);
    valuesDic[AFEventParamQuantity] = ZFToString(goodsQuantity);
    [ZFAnalytics appsFlyerTrackEvent:@"af_create_order_success" withValues:valuesDic];
    // Branch
    doneModel.shipping_fee = self.manager.shippingPrice;
    [[ZFBranchAnalytics sharedManager] branchInitiatePurchaseWithCheckModel:doneModel checkoutModel:self.checkOutModel];
    
    [ZFAnalytics settleInfoProcedureWithProduct:self.checkOutModel.cart_goods.goods_list step:2 option:nil screenName:@"Pay"];
    
    [ZFFireBaseAnalytics createOrderWithOrderModel:doneModel];
    [ZFFireBaseAnalytics checkoutProgressWithStep:2 checkInfoModel:self.checkOutModel];
}

- (void)setCheckOutModel:(ZFOrderCheckInfoDetailModel *)checkOutModel {
    _checkOutModel = checkOutModel;
    // Branch
    [[ZFBranchAnalytics sharedManager] branchProcessToPayWithCheckModel:checkOutModel];
}

@end
