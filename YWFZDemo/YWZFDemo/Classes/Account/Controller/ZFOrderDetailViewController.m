//
//  ZFOrderDetailViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailViewController.h"
//#import "ZFWebViewViewController.h"
#import "ZFContactUsViewController.h"
#import "ZFCartViewController.h"
#import "ZFSubmitReviewsViewController.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFTrackingInfoViewController.h"
#import "ZFOrderSuccessViewController.h"
#import "ZFOrderFailureViewController.h"
#import "ZFContactUsViewController.h"

#import "ZFInitViewProtocol.h"
#import "ZFMyOrderListViewModel.h"
#import "ZFOrderDetailViewModel.h"
#import "ZFOrderInformationViewModel.h"
#import "ZFOrderDetailStructModel.h"
#import "ZFOrderDetailPriceModel.h"
#import "ZFOrderDeatailListModel.h"
#import "ZFOrderRefundModel.h"
#import "ZFOrderDetailOperatorView.h"

#import "ZFOrderDetailOrderInfoTableViewCell.h"
#import "ZFOrderDetailPaymentStatusTableViewCell.h"
#import "ZFOrderDetailAddressTableViewCell.h"
#import "ZFOrderDetailOrderGoodsTableViewCell.h"
#import "ZFOrderDetailOrderPriceInfoTableViewCell.h"
#import "ZFOrderDetailVatTableViewCell.h"
#import "ZFOrderDetailGrandTotalCell.h"
#import "ZFOrderDetailDeliveryShippingCell.h"
#import "ZFOrderDetailOrderGoodsHeaderCell.h"
#import "ZFOrderDetailBannerCell.h"
#import "ZFActionSheetView.h"
#import "ZFOrderCommitProgressView.h"
#import "ZFOrderDetailPartHintCell.h"

#import "ZFPaymentViewController.h"
#import <GGPaySDK/GGPaySDK.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFOrderPayTools.h"
#import "ZFOrderDetailCountDownView.h"
#import <Branch/Branch.h>
#import "FilterManager.h"
#import "ZFThemeManager.h"
#import "ZFTabBarController.h"
#import "ZFNavigationController.h"
#import "AppDelegate.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "ZFGrowingIOAnalytics.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "ZFRefreshHeader.h"
#import "ZFRefreshFooter.h"
#import "Masonry.h"
#import "Constants.h"
#import "BoletoApi.h"
#import "ZFOrderQuestionViewController.h"
#import "ZFBranchAnalytics.h"
#import "ZFCommunityTopicDetailPageViewController.h"
#import "ZFAddressEditViewController.h"
#import "ZFTimerManager.h"
#import "ZFOrderPayResultHandler.h"
#import "ZFCommonRequestManager.h"
#import "NSDictionary+SafeAccess.h"
#import "BannerManager.h"
#import "ZFWriteReviewViewController.h"

//-------------------------------------------------------------------------------------------------------------------------------------------------
static NSString *const kZFOrderDetailOrderInfoTableViewCellIdentifier = @"kZFOrderDetailOrderInfoTableViewCellIdentifier";
static NSString *const kZFOrderDetailPaymentStatusTableViewCellIdentifier = @"kZFOrderDetailPaymentStatusTableViewCellIdentifier";
static NSString *const kZFOrderDetailAddressTableViewCellIdentifier = @"kZFOrderDetailAddressTableViewCellIdentifier";
static NSString *const kZFOrderDetailOrderGoodsTableViewCellIdentifier = @"kZFOrderDetailOrderGoodsTableViewCellIdentifier";
static NSString *const kZFOrderDetailOrderPriceInfoTableViewCellIdentifier = @"kZFOrderDetailOrderPriceInfoTableViewCellIdentifier";
static NSString *const kZFOrderDetailVatTableViewCellIdentifier = @"kZFOrderDetailVatTableViewCellIdentifier";
static NSString *const kZFOrderDetailGrandTotalCellIdentifier = @"kZFOrderDetailGrandTotalCellIdentifier";
static NSString *const kZFOrderDetailDeliveryShippingCellIdentifier = @"kZFOrderDetailDeliveryShippingCellIdentifier";
static NSString *const kZFOrderDetailOrderGoodsHeaderCellIdentifier = @"kZFOrderDetailOrderGoodsHeaderCellIdentifier";
static NSString *const kZFOrderDetailOrderTopicBannerCellIdentifier = @"kZFOrderDetailOrderTopicBannerCellIdentifier";
static NSString *const kZFOrderDetailPartHintCellIdentifier = @"kZFOrderDetailPartHintCellIdentifier";

static NSString *const kEmptyHeaderViewIdentifier = @"kEmptyHeaderViewIdentifier";

@interface ZFOrderDetailViewController ()
<
    ZFInitViewProtocol,
    UITableViewDelegate,
    UITableViewDataSource,
    ZFOrderCommitProgressViewDelegate,
    ZFOrderQuestionViewControllerDelegate,
    ZFOrderDetailAddressTableViewCellDelegate
>

@property (nonatomic, strong) UIButton                                      *contactButton;
@property (nonatomic, strong) ZFOrderDetailOperatorView                     *operatorView;
@property (nonatomic, strong) UITableView                                   *tableView;
@property (nonatomic, strong) ZFOrderDetailViewModel                        *viewModel;
@property (nonatomic, strong) ZFOrderDeatailListModel                       *model;
@property (nonatomic, strong) NSMutableArray<ZFOrderDetailStructModel *>    *dataArray;
@property (nonatomic, strong) NSMutableArray<ZFOrderDetailPriceModel *>     *priceArray;
@property (nonatomic, strong) ZFOrderPayTools                               *payTools;
@property (nonatomic, strong) ZFOrderDetailCountDownView                    *countDownView;
@property (nonatomic, strong) NSArray                                       *advertBannerArray;
//@property (nonatomic, assign) BOOL                                          countDownAB;   //0 显示提示语  1 不显示提示语
@end

@implementation ZFOrderDetailViewController
#pragma mark - Life Cycle

- (void)dealloc
{
    HideLoadingFromView(nil);
    NSString *key = [self.countDownView countDownKey:self.model.main_order.order_id];
    [self.countDownView stopCountTime:key];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNavigationBar];
    [self zfInitView];
    [self zfAutoLayoutView];
    [self requestOrderDetailInfomation];
}

#pragma mark - action methods
- (void)contactButtonAction:(UIButton *)sender {
    if ([NSStringUtils isBlankString:self.contactLinkUrl]) {
        return;
    }
    ZFContactUsViewController *webVC = [[ZFContactUsViewController alloc]init];
    webVC.link_url = self.contactLinkUrl;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)showAlert:(NSString *)message actionTitle:(NSString *)string {
    ShowAlertSingleBtnView(nil, message, string);
}

//客服弹框提示
- (void)showRefoundAlert:(NSString *)refoundUrl
{
    NSString *title = ZFLocalizedString(@"OrderDetail_Apologies", nil);
    NSString *message = ZFLocalizedString(@"OrderDetail_UnRefundTips", nil);
    NSString *oktitle = ZFLocalizedString(@"ZFOrderList_Contact_us", nil);
    NSString *cancelTitle = ZFLocalizedString(@"community_outfit_leave_cancel", nil);
    
    @weakify(self)
    ShowAlertView(title, message, @[oktitle], ^(NSInteger buttonIndex, id buttonTitle) {
        @strongify(self)
        ZFContactUsViewController *contactVC = [[ZFContactUsViewController alloc] init];
        contactVC.link_url = refoundUrl;
        [self.navigationController pushViewController:contactVC animated:YES];
    }, cancelTitle, nil);
}

//选择退款原因提示
- (void)showRefoundReasonAlertOrderSn:(NSString *)orderSn
{
    NSString *title = ZFLocalizedString(@"OrderDetail_returnReason", nil);
    if ([self.operatorView.model isKlarnaPayment]) {
        title = ZFLocalizedString(@"Order_cancel_klarna_reason", nil);
    }
    
    NSString *cancel = ZFLocalizedString(@"Cancel", nil);
    NSMutableArray *otherTitles = [NSMutableArray array];
    for (int i = 0; i < [self.model.refund_select_info count]; i++) {
        ZFRefundReasonModel *reasonModel = self.model.refund_select_info[i];
        if (ZFToString(reasonModel.reason).length) {
            [otherTitles addObject:reasonModel.reason];
        }
    }
    if (self.model.refund_select_info.count) {
        //有退款原因可以选择，并且支付方式不是klarna (ps:klarna退款不需要选择退款原因 https://axhub.im/pro/cab800d6cacd107a/#g=1&p=%E8%A7%84%E5%88%99%E8%AF%B4%E6%98%8E)
        [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
            if (buttonIndex < self.model.refund_select_info.count) {
                ZFRefundReasonModel *reasonModel = self.model.refund_select_info[buttonIndex];
                if (reasonModel.otherReason) {
                    //最后一个，弹出一个输入原因的alert
                    [self alertInputReason:orderSn reasonModel:reasonModel];
                } else {
                    [self orderRefoundAction:orderSn reason:reasonModel.reason reasonId:reasonModel.reasonId parentId:reasonModel.parent];
                }
            }
        } cancelButtonBlock:^{
            
        } sheetTitle:title cancelButtonTitle:cancel otherButtonTitleArr:otherTitles];
    }else{
        [self orderRefoundAction:orderSn reason:nil reasonId:nil parentId:nil];
    }
}

- (void)alertInputReason:(NSString *)ordersn reasonModel:(ZFRefundReasonModel *)reasonModel
{
    NSString *title = ZFLocalizedString(@"OrderRequestRefund", nil);
    NSString *message = ZFLocalizedString(@"Order_reason_for_refund", nil);
    
    if ([self.operatorView.model isKlarnaPayment]) {
        title = ZFLocalizedString(@"Order_cancel_klarna_rexplain", nil);
        message = ZFLocalizedString(@"Order_reason_for_klarna_refund", nil);
    }
    
    NSString *placeholder = ZFLocalizedString(@"Order_inputReason", nil);
    NSString *cancel = ZFLocalizedString(@"Cancel", nil);
    NSString *OKTitle = ZFLocalizedString(@"OK", nil);
    @weakify(self)
    [YSAlertView inputAlertWithTitle:title message:message text:nil placeholder:placeholder cancelTitle:cancel otherTitle:OKTitle keyboardType:UIKeyboardTypeDefault buttonBlock:^(NSString *inputText) {
        @strongify(self)
        //发起订单退款
        [self orderRefoundAction:ordersn reason:inputText reasonId:reasonModel.reasonId parentId:reasonModel.parent];
    } cancelBlock:^{
        //不做操作
    }];
}

/**
 * 是否显示底部操作View
 */
- (BOOL)fetchShowOperatorView {
    NSInteger orderStatus = [self.model.main_order.order_status integerValue];
    if ([self.model.main_order.pay_id isEqualToString:@"Cod"]) { // COD订单
        if (orderStatus == 0 || orderStatus == 3 || orderStatus == 4) {
            /** 显示【Reviews&Show】按钮的情况
             0:未付款WaitingForPayment
             3:完全发货Shipped
             4:已收到货Delivered
             */
            //return YES;
            //@张思杰,V5.5.0d订单中的全部商品只要一个没评论就显示评论按钮
            return NO;
        }
        
        if (orderStatus == 0 || orderStatus == 1 ||
            orderStatus == 3 || orderStatus == 4 || orderStatus == 15 ||
            orderStatus == 16 || orderStatus == 20 ) {
            /** 显示【Tracking info】按钮的情况
             0:未付款WaitingForPayment, 1:已付款Paid,
             3:完全发货Shipped out, 4:已收到货Delivered, 15:部分配货PartialOrderDispatched
             16:完全配货Dispatched, 20:部分发货PartialOrderShipped
             */
            return YES;
        }
        
        if (orderStatus == 2) {
            /**COD订单 备货状态不显示悬停按钮
             * 2:备货状态
             */
            return NO;
        }
        
        if (self.model.main_order.add_to_cart.integerValue == 1 && orderStatus != 0) {
            /** 显示【回购】按钮的情况
             0:未付款WaitingForPayment, 1:已付款Paid, 2:备货Processing
             */
            return YES;
        }
        
    } else { // 非COD订单
        /** Cell下不显示任何按钮的订单情况:
         * 11:Cancelled（取消）,6:Pending（付款中）,
         * 8:Partial Paid（部分付款）,10:Refunded（退款）
         * 2019年09月26日 v5.2.0 去掉 8:Partial Paid（部分付款)
         */
        if (orderStatus == 11 || orderStatus == 6 ||
            orderStatus == 10) {
            return NO;
        } else if (orderStatus == 3 || orderStatus == 4) {
            return NO;
        }
    }
    return YES;
}

#pragma mark - private methods
- (void)requestOrderDetailInfomation {
    @weakify(self);
    NSDictionary *dict = @{
                           @"order_id" : self.orderId,
                           kLoadingView : self.view
                           };
    
    [self.viewModel requestNetwork:dict completion:^(id obj) {
        @strongify(self);
        [self removeEmptyView];
        self.model = obj;
        AccountModel *model = [AccountManager sharedManager].account;
        model.not_paying_order =  self.model.not_paying_order;
        [[AccountManager sharedManager] updateUserInfo:model];
        self.operatorView.model = self.model.main_order;
        
        BOOL showOperatorView = [self fetchShowOperatorView];
        self.operatorView.hidden = showOperatorView ? NO : YES;
        
        //@张思杰,V5.5.0d订单中的全部商品只要一个没评论就显示评论按钮
        CGFloat height = showOperatorView ? 49 : 0;
        [self.operatorView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(height);
        }];
        
        [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.top.mas_equalTo(self.view);
            make.bottom.mas_equalTo( (showOperatorView ? self.operatorView.mas_top : self.view) );
        }];
        
        [self dealPriceInfoWithModel:self.model.main_order];
        [self dealWithOrderDetailInfoStructWithModel:self.model];
        [self.tableView reloadData];
        
        /// 请求CMS广告
        [self requestCMSOrderAdvertBanner:self.model.main_order.order_status];
        
        if (self.orderDetailReloadListInfoCompletionHandler) {
            self.orderDetailReloadListInfoCompletionHandler(self.model.main_order);
        }
        if (showOperatorView && self.model.main_order.order_status.integerValue == 0 && ![self.model.main_order.pay_id isEqualToString:@"Cod"] && self.model.main_order.pay_left_time.integerValue) {
            //未付款的时候提示
            self.countDownView.countDownTime = self.model.main_order.pay_left_time;
            NSString *key = [self.countDownView countDownKey:self.model.main_order.order_id];
            [[ZFTimerManager shareInstance] startTimer:key];
            [self.countDownView showCountTimePositionView:self.operatorView.rightButton countDownKey:key];
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, self.countDownView.height - 8, 0);
            YWLog(@"orderDetailCountDown %@ - %ld",self.model.main_order.order_id, self.model.main_order.pay_left_time.integerValue);
        }else{
            [self.countDownView removeFromSuperview];
            self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    } failure:^(id obj) {
        [self showEmptyViewHandler:^{
            @strongify(self)
            [self requestOrderDetailInfomation];
        }];
    }];
}

/// 加载订单详情页CMS广告
- (void)requestCMSOrderAdvertBanner:(NSString *)orderStatus
{
    [ZFCommonRequestManager requestCMSAppAdvertsWithTpye:(ZFCMSAppAdvertsType_OrderDetail) otherId:orderStatus completion:^(NSDictionary *responseObject) {
        
        self.advertBannerArray = nil;
        NSArray *resultArray = responseObject[ZFDataKey];
        if (!ZFJudgeNSArray(resultArray)) return;
        
        NSDictionary *resultDic = [resultArray firstObject];
        if(!ZFJudgeNSDictionary(resultDic)) return;
        NSArray *listArray = [resultDic ds_arrayForKey:@"list"];

        NSMutableArray *bannerArray = [NSMutableArray array];
        for (NSDictionary *bannerDict in listArray) {
            ZFBannerModel *bannerModel = [[ZFBannerModel alloc] init];
            bannerModel.image = [bannerDict ds_stringForKey:@"img"];
            bannerModel.name = [bannerDict ds_stringForKey:@"name"];
            bannerModel.colid = [bannerDict ds_stringForKey:@"colId"];
            bannerModel.componentId = [bannerDict ds_stringForKey:@"componentId"];
            bannerModel.banner_id = [bannerDict ds_stringForKey:@"advertsId"];
            bannerModel.menuid = [bannerDict ds_stringForKey:@"menuId"];
            bannerModel.banner_height = [bannerDict ds_stringForKey:@"height"];
            bannerModel.banner_width = [bannerDict ds_stringForKey:@"width"];

            NSString *actionType = [bannerDict ds_stringForKey:@"actionType"];
            NSString *url = [bannerDict ds_stringForKey:@"url"];

            //如果actionType=-2,则特殊处理自定义完整ddeplink
            if (actionType.integerValue == -2) {
                bannerModel.deeplink_uri = ZFToString(ZFEscapeString(url, YES));
            } else {
                bannerModel.deeplink_uri = [NSString stringWithFormat:ZFCMSConvertDeepLinkString, actionType, url, bannerModel.name];;
            }
            [bannerArray addObject:bannerModel];
        }
        
        if (bannerArray.count > 0) {
            self.advertBannerArray = bannerArray;
            //重新加载页面
            [self dealWithOrderDetailInfoStructWithModel:self.model];
            [self.tableView reloadData];
        }
        
    } target:nil];
}

- (void)requestTrackingPackageInfoWithOrderModel:(OrderDetailOrderModel *)model {
    @weakify(self);
    NSDictionary *dict = @{
                           @"order_id" : model.order_id,
                           kLoadingView : self.view
                           };
    
    [self.viewModel requestTrackingPackageData:dict completion:^(NSArray<ZFTrackingPackageModel *> *array, NSString *trackingMessage, NSString *trackingState) {
        @strongify(self);
        // 3 - 完全发货  4 - 已收到货  20 - 部分发货
        if ([model.order_status integerValue] == 3 || [model.order_status integerValue] == 4 || [model.order_status integerValue] == 20) {
            if ([trackingState integerValue] == 0) {
                // 付款了还没有物流信息
                [self showAlertViewWithTitle:nil Message:trackingMessage];
                return;
            }
            // 进入物流
            ZFTrackingInfoViewController *trackingInfoVC = [[ZFTrackingInfoViewController alloc] init];
            trackingInfoVC.packages = array;
            [self.navigationController pushViewController:trackingInfoVC animated:YES];
        }else if ([model.order_status integerValue] != 0) {
            // 提示不可点击
            [self showAlertViewWithTitle:nil Message:trackingMessage];
        }else if ([model.pay_id isEqualToString:@"Cod"] && [model.order_status integerValue] == 0) {
            [self showAlertViewWithTitle:nil Message:trackingMessage];
        }else {
            [self showAlertViewWithTitle:nil Message:trackingMessage];
        }
    } failure:^(id obj) {
        
    }];
}

- (void)requestOrderBackToCartWithOrderId:(NSString *)orderId {
    @weakify(self);
    NSDictionary *dict = @{
                           @"order_id" : orderId,
                           kLoadingView : self.view
                           };
    
    [self.viewModel requestReturnToBag:dict completion:^(id obj) {
        @strongify(self);
        ZFNavigationController  *accountNavVC = [self queryTargetNavigationController:TabBarIndexAccount];
        ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
        [self.navigationController popToRootViewControllerAnimated:NO];
        dispatch_async(dispatch_get_main_queue(), ^{
            [accountNavVC pushViewController:cartVC animated:NO];
        });
    } failure:^(id obj) {
        //do nothing
        @strongify(self);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
    }];
}

/// 统计订单详情点击回购订单
- (void)analyticsDetailBuyAgain
{
    NSDictionary *appsflyerParams = @{
        @"af_content_type" : @"buyagain_button",
        @"af_reciept_id" : ZFToString(self.orderId),
        @"af_price" : ZFToString(self.model.main_order.grand_total),
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_buyagain_click" withValues:appsflyerParams];
}

/// 统计订单详情点击立即支付
- (void)analyticsDetailPayNow
{
    NSDictionary *appsflyerParams = @{
        @"af_content_type" : @"order_detail",
        @"af_reciept_id" : ZFToString(self.orderId),
        @"af_price" : ZFToString(self.model.main_order.grand_total),
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_orderdetailpay_click" withValues:appsflyerParams];
}

//订单退款
- (void)requestOrderRefundWithOrderSn:(NSString *)orderSn contactUsUrl:(NSString *)tk_page_url {
    /// status = 1 paid
    /// status = 2 processing
    /// status = 3 完全发货
    /// status = 20 部分发货
    
    //弹框提示
    NSString *title = ZFLocalizedString(@"OrderDetail_Apologies", nil);
    NSString *message = ZFLocalizedString(@"OrderRefundAskTips", nil);
    NSString *oktitle = ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_Yes", nil);
    NSString *cancelTitle = ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_No", nil);
    NSInteger status = [self.model.main_order.order_status integerValue];
    if (status == 2){
        title = nil;
        message = ZFLocalizedString(@"OrderDetail_SureWantToRefund", nil);
        if ([self.model.main_order isKlarnaPayment]) {
            //klarna支付方式，退款时显示文案跟其他支付方式不一样
            message = ZFLocalizedString(@"OrderDetailViewModel_CancelOrder_Message", nil);
        }
    }else if (status == 3 || status == 20){
        //这里应该要在新版直接打开联系客服的页面，需要后台在订单详情接口返回tk_url
        [self showRefoundAlert:tk_page_url];
        return;
    }

    if ([self.operatorView.model isKlarnaPayment]) {
        [self showRefoundReasonAlertOrderSn:orderSn];
        
    } else {
        @weakify(self)
        ShowAlertView(title, message, @[oktitle], ^(NSInteger buttonIndex, id buttonTitle) {
            //增加一个原因
            @strongify(self)
            [self showRefoundReasonAlertOrderSn:orderSn];
        }, cancelTitle, nil);
    }
}

/**
 发起退款
 
 @param ordersn 订单号
 */
- (void)orderRefoundAction:(NSString *)ordersn
                    reason:(NSString *)reason
                  reasonId:(NSString *)reasonId
                  parentId:(NSString *)parentId
{
    ShowLoadingToView(self.view);
    NSDictionary *params = @{
                             @"order_sn"    :  ZFToString(ordersn),
                             @"refund_reason_parent" : ZFToString(parentId), //
                             @"refund_reason_child" : ZFToString(reasonId),
                             @"cancel_reason" : ZFToString(reason)
                             };
    @weakify(self);
    [self.viewModel requestRefundNetwork:params completion:^(id obj) {
        @strongify(self);
        HideLoadingFromView(self.view);
        ZFOrderRefundModel *model = obj;
        if (!ZFIsEmptyString(model.tk_page_url)) {
            ///如果有退款链接，就打开弹窗
            [self showRefoundAlert:model.tk_page_url];
        }else{
            ///正常逻辑
            if (![NSStringUtils isEmptyString:model.msg]) {
                [self showAlertViewWithTitle:nil Message:model.msg];
            }
            if (model.status) {
                [self requestOrderDetailInfomation];
            }
        }
    } failure:^(id obj) {
        HideLoadingFromView(self.view);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
    }];
}

- (ZFNavigationController *)queryTargetNavigationController:(NSInteger)index {
    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
    if (tabBarVC.selectedIndex != index) {
        ZFNavigationController  *currentNavVC = (ZFNavigationController *)tabBarVC.selectedViewController;
        [currentNavVC popToRootViewControllerAnimated:NO];
        tabBarVC.selectedIndex = index;
    }
    ZFNavigationController  *targetNavVC = (ZFNavigationController *)tabBarVC.selectedViewController;
    return targetNavVC;
}

- (void)dealWithOrderDetailInfoStructWithModel:(ZFOrderDeatailListModel *)model
{
    [self.dataArray removeAllObjects];
    ZFOrderDetailStructModel *addressModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypeAddress cellsCount:1];
    [self.dataArray addObject:addressModel];
    
    // 拆单提示
    if (!ZFIsEmptyString(model.main_order.order_part_hint)) {
        ZFOrderDetailStructModel *orderPartHintModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypeOrderPartHint cellsCount:1];
        [self.dataArray addObject:orderPartHintModel];
    }
 
    ZFOrderDetailStructModel *paymentModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypePaymentInfo cellsCount:1];
    [self.dataArray addObject:paymentModel];
 
    ZFOrderDetailStructModel *goodsHeaderModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypeGoodsHeader cellsCount:1];
    [self.dataArray addObject:goodsHeaderModel];
    
    ///商品拆单1,2,3,4。。。
    for (ZFOrderDetailChildModel *childModel in model.child_order) {
        
        ZFOrderDetailStructModel *orderModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypeOrderNumber cellsCount:1];
        orderModel.childModel = childModel;
        [self.dataArray addObject:orderModel];
        
        ZFOrderDetailStructModel *goodsModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypeGoodsInfo cellsCount:childModel.goods_list.count];
        goodsModel.childModel = childModel;
        [self.dataArray addObject:goodsModel];
    }
    
/** 从V5.5.0开始,订单详情也的广告使用CMS配置
    NSInteger orderStatus = model.main_order.order_status.integerValue;
    if ((ZFToString(model.orderTopicImageUrl).length || ZFToString(model.orderTopicId).length) && (orderStatus == 16 || orderStatus == 15 || orderStatus == 3 || orderStatus == 4)) {
        //完全配货，部分发货，完全发货，已收到货
        //如果请求到了 社区topic图片
        ZFOrderDetailStructModel *topicBannerModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypeBanner cellsCount:1];
        [self.dataArray addObject:topicBannerModel];
    }
*/
    ///有CMS广告才显示Banner图片
    if (ZFJudgeNSArray(self.advertBannerArray) && self.advertBannerArray.count > 0) {
        ZFOrderDetailStructModel *topicBannerModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypeBanner cellsCount:self.advertBannerArray.count];
        [self.dataArray addObject:topicBannerModel];
    }
    
    ZFOrderDetailStructModel *totalModel = [[ZFOrderDetailStructModel alloc] initWithType:ZFOrderDetailStructTypePriceInfo cellsCount:self.priceArray.count];
    [self.dataArray addObject:totalModel];
}

- (void)cancelCurrentOrderWithOrderId:(NSString *)orderId {
    
    UIAlertController *alertController =  [UIAlertController
                                           alertControllerWithTitle: nil
                                           message:ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_Message",nil)
                                           preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction * cancelAction = [UIAlertAction actionWithTitle:ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_No",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
    }];
    UIAlertAction * sureAction = [UIAlertAction actionWithTitle:ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_Yes",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        @weakify(self);
        NSDictionary *dict = @{
                               @"order_id" : orderId,
                               kLoadingView : self.view
                               };
        [self.viewModel requestCancelOrderNetwork:dict completion:^(id obj) {
            @strongify(self);
            BOOL isOK = [obj boolValue];
            if (isOK) {
                if (self.orderDetailReloadListInfoCompletionHandler) {
                    self.orderDetailReloadListInfoCompletionHandler(self.model.main_order);
                }
                [self requestOrderDetailInfomation];
            }
        } failure:^(id obj) {
            
        }];
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:sureAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)dealPriceInfoWithModel:(OrderDetailOrderModel *)model {
    [self.priceArray removeAllObjects];
    
    ZFOrderDetailPriceModel *productModel = [[ZFOrderDetailPriceModel alloc] init];
    productModel.type = ZFOrderDetailPriceTypeProductTotal;
    [self.priceArray addObject:productModel];
    
    ZFOrderDetailPriceModel *shippingModel = [[ZFOrderDetailPriceModel alloc] init];
    shippingModel.type = ZFOrderDetailPriceTypeShipping;
    [self.priceArray addObject:shippingModel];
    
    if ([model.pay_id isEqualToString:@"Cod"]) {
        ZFOrderDetailPriceModel *codCostModel = [[ZFOrderDetailPriceModel alloc] init];
        codCostModel.type = ZFOrderDetailPriceTypeCodCost;
        [self.priceArray addObject:codCostModel];
    }
    
    if (fabs([model.insurance floatValue]) > 0.0) {
        ZFOrderDetailPriceModel *insuranceModel = [[ZFOrderDetailPriceModel alloc] init];
        insuranceModel.type = ZFOrderDetailPriceTypeInsurance;
        [self.priceArray addObject:insuranceModel];
    }
    
    if (fabs([model.other_discount floatValue]) > 0.0) {
        ZFOrderDetailPriceModel *eventDiscountModel = [[ZFOrderDetailPriceModel alloc] init];
        eventDiscountModel.type = ZFOrderDetailPriceTypeEventDiscount;
        [self.priceArray addObject:eventDiscountModel];
    }
    
    //v457新增
    if (fabs([model.coupon floatValue]) > 0.0) {
        ZFOrderDetailPriceModel *couponDiscountModel = [[ZFOrderDetailPriceModel alloc] init];
        couponDiscountModel.type = ZFOrderDetailPriceTypeCoupon;
        [self.priceArray addObject:couponDiscountModel];
    }
    
    if (fabs([model.pay_deduct floatValue]) > 0.0) {
        ZFOrderDetailPriceModel *onlineDiscountModel = [[ZFOrderDetailPriceModel alloc] init];
        onlineDiscountModel.type = ZFOrderDetailPriceTypeOnlinePayDiscount;
        [self.priceArray addObject:onlineDiscountModel];
    }
    
    if (fabs([model.student_discount floatValue]) > 0.0) {
        ZFOrderDetailPriceModel *studentDiscountModel = [[ZFOrderDetailPriceModel alloc] init];
        studentDiscountModel.type = ZFOrderDetailPriceTypeStudentDiscount;
        [self.priceArray addObject:studentDiscountModel];
    }
    
    if (fabs([model.z_point floatValue]) > 0.0) {
        ZFOrderDetailPriceModel *pointsModel = [[ZFOrderDetailPriceModel alloc] init];
        pointsModel.type = ZFOrderDetailPriceTypeZPoints;
        [self.priceArray addObject:pointsModel];
    }
 
    //cod discount
    if ([model.pay_id isEqualToString:@"Cod"] && [model.cod_orientation integerValue] != CashOnDeliveryTruncTypeDefault && [model.cod_discount floatValue] != 0) {
        //v4.1.0 修改COD取整等于0的时候不显示这一行
        ZFOrderDetailPriceModel *codModel = [[ZFOrderDetailPriceModel alloc] init];
        codModel.type = ZFOrderDetailPriceTypeCODDiscount;
        [self.priceArray addObject:codModel];
    }
    
    ZFOrderDetailPriceModel *grandTotalModel = [[ZFOrderDetailPriceModel alloc] init];
    grandTotalModel.type = ZFOrderDetailPriceTypeGrandTotal;
    [self.priceArray addObject:grandTotalModel];

    //wallet
    if ([model.used_wallet floatValue] != 0) {
        ZFOrderDetailPriceModel *walletModel = [[ZFOrderDetailPriceModel alloc] init];
        walletModel.type = ZFOrderDetailPriceTypeWallet;
        [self.priceArray addObject:walletModel];
        
        //online payment
        ZFOrderDetailPriceModel *onlinePayment = [[ZFOrderDetailPriceModel alloc] init];
        onlinePayment.type = ZFOrderDetailPriceTypeOnlinePayment;
        [self.priceArray addObject:onlinePayment];
    }

    //delivery shipping info
    if (([model.pay_id isEqualToString:@"Cod"] && [model.order_status integerValue] != 13)
        || [model.show_refund integerValue] == 2) {
        ZFOrderDetailPriceModel *deliveryModel = [[ZFOrderDetailPriceModel alloc] init];
        deliveryModel.type = ZFOrderDetailPriceTypeDeliveryShipping;
        [self.priceArray addObject:deliveryModel];
    }
}

- (void)payForMonmentWithOrderModel:(OrderDetailOrderModel *)model {
    // 催付
    if (!ZFIsEmptyString([NSStringUtils getPid]) &&
        !ZFIsEmptyString([NSStringUtils getC]) &&
        !ZFIsEmptyString([NSStringUtils getIsRetargeting]) &&
        ![NSStringUtils isBlankString:model.order_id])
    {
        [ZFMyOrderListViewModel requestRushPay:model.order_id];
    }
    // 支付打点
    [ZFOrderInformationViewModel requestPayTag:model.order_sn step:@"place"];
    // v4.1.0 接入原生支付SDK,需要先请求后台接口获取token
    ZFOrderPayTools *paytools = [ZFOrderPayTools paytools];
    paytools.channel = PayChannel_Default;
    paytools.payUrl = model.pay_url;
    paytools.orderId = model.order_id;
    paytools.parentViewController = self;
    
    @weakify(self)
    paytools.paySuccessCompletionHandle = ^(ZFOrderPayResultModel * _Nonnull orderPayResultMoedl) {
        ///SOA 支付成功
        @strongify(self)
        [ZFOrderInformationViewModel requestPayTag:model.order_sn step:@"completed"];
        model.realPayment = orderPayResultMoedl.payChannelCode;
        [self jumpToOrderFinishViewController:model payResult:orderPayResultMoedl]; // 跳转到付款成功页面
    };
    
    paytools.payFailureCompletionHandle = ^{
        @strongify(self)
        [self.navigationController popToViewController:self animated:NO];
        [self jumpToOrderFailurViewController]; // 跳转到付款失败页面
    };
    
    paytools.payCancelCompolementHandle = ^{
        @strongify(self)
        [ZFOrderInformationViewModel requestPayTag:model.order_sn step:@"cancel"];
        [self.navigationController popToViewController:self animated:YES];
        if ([model.pay_id isEqualToString:@"boletoBancario"]) {
            return;
        }
        [self showAlertViewWithTitle:ZFLocalizedString(@"MyOrdersViewModel_PaymentStatusCancel_Title",nil) Message:ZFLocalizedString(@"MyOrdersViewModel_PaymentStatusCancel_Message",nil)];
    };
    
    paytools.loadH5PaymentHandle = ^{
        [ZFOrderInformationViewModel requestPayTag:model.order_sn step:@"load"];
    };
    
    paytools.paymentSurveyHandle = ^{
        @strongify(self)
        ZFOrderQuestionViewController *questionVC = [[ZFOrderQuestionViewController alloc] init];
        questionVC.delegate = self;
        questionVC.ordersn = model.order_sn;
        questionVC.orderId = model.order_id;
        questionVC.fd_interactivePopDisabled = NO;
        [self.navigationController pushViewController:questionVC animated:YES];
    };
    
    
    [paytools startPay];
    
    _payTools = paytools;
}

- (void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)message {
    ShowAlertSingleBtnView(title, message, ZFLocalizedString(@"OK", nil));
}

- (void)jumpToOrderReviewViewControllerWithOrderId:(NSString *)orderId {
//    ZFSubmitReviewsViewController *reviewVC = [[ZFSubmitReviewsViewController alloc] init];
//    reviewVC.orderId = orderId;
//    [self.navigationController pushViewController:reviewVC animated:YES];
}

- (void)reviewOrderWithCommentModel:(ZFWaitCommentModel *)commentModel {
    ZFWriteReviewViewController *reviewVC = [[ZFWriteReviewViewController alloc] init];
    reviewVC.commentModel = commentModel;
    
    @weakify(self)
    reviewVC.commentSuccessBlock = ^(ZFWaitCommentModel * _Nonnull commentModel) {
        @strongify(self)
        [self handleCommentGoodsState:commentModel];
    };
    [self.navigationController pushViewController:reviewVC animated:YES];
}

- (void)handleCommentGoodsState:(ZFWaitCommentModel *)comment {
    
    [self.dataArray enumerateObjectsUsingBlock:^(ZFOrderDetailStructModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.type == ZFOrderDetailStructTypeGoodsInfo) {
            
            for (OrderDetailGoodModel * goodsObj in obj.childModel.goods_list) {
                
                if ([goodsObj.goods_id isEqualToString:comment.goods_id] && [goodsObj.goods_title isEqualToString:comment.goods_title]) {
                    goodsObj.is_review = YES;
                    *stop = YES;
                }
            }
        }
    }];
    
    [self.tableView reloadData];
}
- (void)jumpToOrderFinishViewController:(OrderDetailOrderModel *)orderModel payResult:(ZFOrderPayResultModel *)payResultModel {
    ZFOrderPayResultHandler *handler = [ZFOrderPayResultHandler handler];
    NSMutableArray *goodsList = [[NSMutableArray alloc] init];
    [self.model.child_order enumerateObjectsUsingBlock:^(ZFOrderDetailChildModel * _Nonnull childModel, NSUInteger idx, BOOL * _Nonnull stop) {
        [goodsList addObjectsFromArray:childModel.goods_list];
    }];
    orderModel.baseGoodsList = goodsList.copy;
    handler.zfParentViewController = self;
    @weakify(self)
    handler.dismissSuccessVCBlock = ^{
        @strongify(self)
        [self requestOrderDetailInfomation];
    };
    [handler orderPaySuccess:ZFOrderPayResultSource_OrderDetail baseOrderModel:orderModel resultModel:payResultModel];
    
//    ZFOrderSuccessViewController *finischVC = [[ZFOrderSuccessViewController alloc] init];
////    finischVC.orderSN = orderModel.order_sn;
//    finischVC.baseOrderModel = orderModel;
//    finischVC.orderPayResultModel = payResultModel;
//    NSMutableArray *goodsList = [[NSMutableArray alloc] init];
//    [self.model.child_order enumerateObjectsUsingBlock:^(ZFOrderDetailChildModel * _Nonnull childModel, NSUInteger idx, BOOL * _Nonnull stop) {
//        [goodsList addObjectsFromArray:childModel.goods_list];
//    }];
//    finischVC.baseOrderModel.baseGoodsList = goodsList.copy;
//
//    @weakify(finischVC)
//    finischVC.toAccountOrHomeblock = ^(BOOL gotoAccount){ //跳转到Accont或是Home
//        @strongify(finischVC)
//        [finischVC dismissViewControllerAnimated:NO completion:^{
//            if (gotoAccount) {
//                [self.navigationController popToViewController:self animated:YES];
//                [self requestOrderDetailInfomation];
//                //通知订单列表刷新页面
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"kZFReloadOrderListData" object:nil];
//                // 谷歌统计
//                [ZFAnalytics clickButtonWithCategory:@"Payment Success" actionName:@"Payment Success - My Account" label:@"Payment Success - My Account"];
//            }else{
//                ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
//                UINavigationController *navVC = tabBarVC.selectedViewController;
//                [navVC popToRootViewControllerAnimated:NO];
//                tabBarVC.selectedIndex = TabBarIndexHome;
//                // 谷歌统计
//                [ZFAnalytics clickButtonWithCategory:@"Payment Success" actionName:@"Payment Success - Return to Home" label:@"Payment Success - Return to Home"];
//            }
//        }];
//    };
 
    //谷歌统计
    [ZFAnalytics settleAccountInfoProcedureWithProduct:goodsList step:3 option:nil screenName:@"ProductDetail"];
    [ZFAnalytics trasactionAccountInfoWithProduct:goodsList order:orderModel screenName:@"ProductDetail"];
    
    // growingIO 支付完成统计
//    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderSuccessWithOrderDetail:orderModel listModel:self.model];
//    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:finischVC];
//    [self presentViewController:nav animated:YES completion:nil];
}

- (void)jumpToOrderFailurViewController {
    ZFOrderFailureViewController *failureVC = [[ZFOrderFailureViewController alloc] init];
    @weakify(failureVC)
    failureVC.orderFailureBlock = ^{
        @strongify(failureVC)
        [failureVC dismissViewControllerAnimated:YES completion:^{}];
        // 谷歌统计
        [ZFAnalytics clickButtonWithCategory:@"Payment Failure" actionName:@"Payment Failure - My Account" label:@"Payment Failure - My Account"];
    };
    [self presentViewController:failureVC animated:YES completion:nil];
}

- (void)showJointOrderActionSheetView:(NSArray<ZFRefundOrderModel *> *)refundOrderList
{
    NSString *sheetTitle = ZFLocalizedString(@"OrderDetail_CancelManyOrderTip", nil);
    NSString *orderText = ZFLocalizedString(@"MyOrders_Cell_Order", nil);
    NSString *cancelTitle = ZFLocalizedString(@"Cancel",nil);
    
    NSMutableArray *otherTitleArr = [NSMutableArray array];
    for (NSInteger i=0; i<refundOrderList.count; i++) {
        ZFRefundOrderModel *orderModel = refundOrderList[i];
        NSString *tempTitle = [NSString stringWithFormat:@"%@%ld:%@",orderText, (long)(i+1), orderModel.order_sn];
        [otherTitleArr addObject:tempTitle];
    }
    
    [ZFActionSheetView actionSheetByBottomCornerRadius:^(NSInteger buttonIndex, id title) {
        if (refundOrderList.count > buttonIndex) {
            NSString *order_sn = refundOrderList[buttonIndex].order_sn;
            NSString *contactUsUrl = refundOrderList[buttonIndex].order_sn;
            [self requestOrderRefundWithOrderSn:order_sn contactUsUrl:contactUsUrl];
        }
    } cancelButtonBlock:nil sheetTitle:sheetTitle cancelButtonTitle:cancelTitle otherButtonTitleArr:otherTitleArr];
}

- (void)checkOfflineToken {
    BoletoApi *api = [[BoletoApi alloc] initWithOrderID:self.orderId];
    ShowLoadingToView(self.view);
    [api startWithBlockSuccess:^(__kindof SYBaseRequest *request) {
        HideLoadingFromView(self.view);
        id requestJSON = [NSStringUtils desEncrypt:request api:NSStringFromClass(BoletoApi.class)];
        if ([requestJSON[@"statusCode"] integerValue] == 200) {
            NSDictionary *dict = requestJSON[ZFResultKey];
            NSString *url = dict[@"pay_url"];
            if (ZFToString(url).length) {
                ZFPaymentViewController *paymentVC = [[ZFPaymentViewController alloc] init];
                paymentVC.url = url;
                paymentVC.block = ^(PaymentStatus status) {
                    [self.navigationController popViewControllerAnimated:YES];
                };
                [self.navigationController pushViewController:paymentVC animated:YES];
            }
        }
    } failure:^(__kindof SYBaseRequest *request, NSError *error) {
        HideLoadingFromView(self.view);
    }];
}

///确认订单
- (void)confirmOrder:(NSString *)orderSn
{
    @weakify(self)
    [self.viewModel requestConfirmOrder:orderSn completion:^(NSInteger status, NSError *error) {
        if (!error) {
            //刷新
            @strongify(self)
            if (status) {
                self.model.main_order.confirm_btn_show = 0;
                [self.tableView reloadData];
                if (self.orderDetailReloadListInfoCompletionHandler) {
                    self.orderDetailReloadListInfoCompletionHandler(self.model.main_order);
                }
            }
        }
    }];
}

///修改地址
- (void)requestChangeAddress:(NSString *)orderSn
{
    ZFAddressEditViewController *editVC = [[ZFAddressEditViewController alloc] init];
    editVC.addressOrderSn = orderSn;
    editVC.addressNoPayOrder = self.addressNoPayOrder;
    if ([self.model.main_order.pay_status isEqualToString:@"0"]) {//未付款
        editVC.addressNoPayOrder = YES;
    }
    @weakify(self)
    editVC.addressEditSuccessCompletionHandler = ^(AddressEditStateType editStateType) {
        @strongify(self)
        if (editStateType == AddressEditStatePayOrderSuccess) {
            //重新请求订单数据
            [self requestOrderDetailInfomation];
        } else if(editStateType == AddressEditStateNoPayOrderSuccess) {
            NSString *title = ZFLocalizedString(@"OrderDetail_UpdateAddressTitle", nil);
            NSString *content = ZFLocalizedString(@"OrderDetail_QuickPayTips", nil);
            NSString *titleContent = [NSString stringWithFormat:@"%@\n%@", title, content];
            ShowToastToViewWithText(nil, titleContent);
            //重新请求订单数据
            [self requestOrderDetailInfomation];
        }
    };
    [self.navigationController pushViewController:editVC animated:YES];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataArray.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataArray[section].cellsCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ZFOrderDetailStructModel *structModel = self.dataArray[indexPath.section];
    ZFOrderDetailStructType type = structModel.type;
    
    if (type == ZFOrderDetailStructTypeOrderNumber) {
        ZFOrderDetailOrderInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailOrderInfoTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.orderSortNum = nil;
        if (self.model.child_order.count > 0 &&
            [self.model.child_order containsObject:structModel.childModel]) {
            NSInteger index = [self.model.child_order indexOfObject:structModel.childModel];
            cell.orderSortNum = [NSString stringWithFormat:@"%zd", (index+1)];
        }
        cell.mainOrder = self.model.main_order;
        cell.childModel = structModel.childModel;
        return cell;
        
    } else if (type == ZFOrderDetailStructTypePaymentInfo) {
        ZFOrderDetailPaymentStatusTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailPaymentStatusTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = self.model.main_order;
        @weakify(self)
        cell.orderDetailOrderTrakingInfoCompletionHandler = ^(void){
            @strongify(self)
            [self requestTrackingPackageInfoWithOrderModel:self.model.main_order];
        };
        return cell;
        
    } else if (type == ZFOrderDetailStructTypeAddress) {
        ZFOrderDetailAddressTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailAddressTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = self.model.main_order;
        cell.delegate = self;
        return cell;
        
    } else if (type == ZFOrderDetailStructTypeGoodsHeader) {
        ZFOrderDetailOrderGoodsHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailOrderGoodsHeaderCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.model = self.model;
        @weakify(self)
        cell.orderDetailOrderBackToCartCompletionHandler = ^(ButtonType type){
            @strongify(self)
            if (type == ButtonType_OpenOfflineToken) {
                //线下支付的凭证查看按钮
                [self checkOfflineToken];
            }
            if (type == ButtonType_BuyAgain) {
                //发起再次购买请求
                [self requestOrderBackToCartWithOrderId:self.orderId];
                [self analyticsDetailBuyAgain];
            }
        };
        return cell;
        
    } else if (type == ZFOrderDetailStructTypeGoodsInfo) {
        ZFOrderDetailOrderGoodsTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailOrderGoodsTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
//        cell.model = structModel.childModel.goods_list[indexPath.row];
        [cell configCellDataWithGoodsModel:structModel.childModel.goods_list[indexPath.row] orderDetailModel:self.model.main_order];
        
        NSInteger orderStatus = [self.model.main_order.order_status integerValue];
        BOOL isCod = [self.model.main_order.pay_id isEqualToString:@"Cod"];
        [cell showReviewButtonState:orderStatus isCod:isCod isReview:cell.model.is_review];
        
        @weakify(self)
        cell.touchReviewBlock = ^(ZFWaitCommentModel *model) {
            @strongify(self)
            model.order_id = self.orderId;
            [self reviewOrderWithCommentModel:model];
        };
        return cell;
        
    } else if (type == ZFOrderDetailStructTypePriceInfo) {
        if (self.priceArray[indexPath.row].type == ZFOrderDetailPriceTypeGrandTotal) {
            ZFOrderDetailGrandTotalCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailGrandTotalCellIdentifier];
            cell.model = self.model.main_order;
            return cell;
            
        } else if (self.priceArray[indexPath.row].type == ZFOrderDetailPriceTypeDeliveryShipping) {
            ZFOrderDetailDeliveryShippingCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailDeliveryShippingCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.model = self.model.main_order;
            return cell;
        } else {
            ZFOrderDetailOrderPriceInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailOrderPriceInfoTableViewCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.priceModel = self.priceArray[indexPath.row];
            cell.model = self.model;
            return cell;
        }
    } else if (type == ZFOrderDetailStructTypeBanner) {
        ZFOrderDetailBannerCell *bannerCell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailOrderTopicBannerCellIdentifier];
        
        //V5.5.0已对接CMS广告
        //bannerCell.imageUrl = self.model.orderTopicImageUrl;
        
        if (self.advertBannerArray.count > indexPath.row) {
            ZFBannerModel *bannerModel = self.advertBannerArray[indexPath.row];
            CGFloat width = [bannerModel.banner_width floatValue];
            CGFloat height = [bannerModel.banner_height floatValue];
            CGFloat scale = width > 0 ? height / width : 0;
            [bannerCell configurate:bannerModel.image scale:scale];
        }
        return bannerCell;
    } else if (type == ZFOrderDetailStructTypeOrderPartHint) {
        ZFOrderDetailPartHintCell *partHintCell = [tableView dequeueReusableCellWithIdentifier:kZFOrderDetailPartHintCellIdentifier];
        partHintCell.model = self.model.main_order;
        return partHintCell;
    }
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZFOrderDetailStructModel *goodsModel = self.dataArray[indexPath.section];
    ZFOrderDetailStructType type = goodsModel.type;
    
    if (type == ZFOrderDetailStructTypeGoodsInfo) {
        ZFGoodsDetailViewController *detailVC = [[ZFGoodsDetailViewController alloc] init];

        detailVC.goodsId = goodsModel.childModel.goods_list[indexPath.row].goods_id;
        detailVC.sourceType = ZFAppsflyerInSourceTypeOrderDetailsProduct;
        self.navigationController.delegate = nil;
        [self.navigationController pushViewController:detailVC animated:YES];
        
        // appflyer统计
        NSString *goodsSN = goodsModel.childModel.goods_list[indexPath.row].goods_sn;
        NSString *skuSN = nil;
        if (goodsSN.length > 7) {
            skuSN = [goodsSN substringWithRange:NSMakeRange(0, 7)];
        }else{
            skuSN = goodsSN;
        }
        NSDictionary *appsflyerParams = @{@"af_content_id" : ZFToString(goodsSN),
                                          @"af_spu_id" : ZFToString(skuSN),
                                          @"af_user_type" : ZFToString([AccountManager sharedManager].af_user_type), //值为"1"或"0",标识网站用户属于新用户或旧用户（新用户：未登录或未生成过已付款订单的用户
                                          @"af_page_name" : @"myorder_page",    // 当前页面名称
                                          };
        [ZFAppsflyerAnalytics zfTrackEvent:@"af_sku_click" withValues:appsflyerParams];
        [ZFGrowingIOAnalytics ZFGrowingIOSetEvar:@{GIOGoodsTypeEvar : GIOGoodsTypeOther,
                                                   GIOGoodsNameEvar : @"orderdetails_product"
        }];
    }
    
    if (type == ZFOrderDetailStructTypeBanner) {
    /** V5.5.0对接CMS广告
        ZFCommunityTopicDetailPageViewController *topicVC = [[ZFCommunityTopicDetailPageViewController alloc] init];
        topicVC.topicId = self.model.orderTopicId;
        [self.navigationController pushViewController:topicVC animated:YES];
     */
        if (self.advertBannerArray.count > indexPath.row) {
            ZFBannerModel *bannerModel = self.advertBannerArray[indexPath.row];
            [BannerManager doBannerActionTarget:self withBannerModel:bannerModel];
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UITableViewHeaderFooterView *headerView = [tableView dequeueReusableHeaderFooterViewWithIdentifier:kEmptyHeaderViewIdentifier];
    headerView.contentView.backgroundColor = ZFCOLOR(245, 245, 245, 1.f);
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    ZFOrderDetailStructType type = self.dataArray[section].type;
    if (type == ZFOrderDetailStructTypeOrderNumber) {
        return 1;
    }
    if (type == ZFOrderDetailStructTypeGoodsInfo) {
        return 0;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return CGFLOAT_MIN;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.tableView numberOfSections]) {
        NSInteger maxSection = [self.tableView numberOfSections] - 1;
        NSInteger lastRow = [self.tableView numberOfRowsInSection:maxSection] - 1;
        NSIndexPath *lastRowIndexPath = [NSIndexPath indexPathForRow:lastRow inSection:maxSection];
        UITableViewCell *lastCell = [self.tableView cellForRowAtIndexPath:lastRowIndexPath];
        NSArray *visiCellList = [self.tableView visibleCells];
        if ([visiCellList containsObject:lastCell]) {
            [self.operatorView operatorViewExchangePriceViewStatus:YES];
        } else {
            [self.operatorView operatorViewExchangePriceViewStatus:NO];
        }
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.title = ZFLocalizedString(@"OrderDetail_VC_Title",nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;//ZFCOLOR(245, 245, 245, 1.0);
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.operatorView];
}

- (void)zfAutoLayoutView {
    [self.operatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom).mas_offset(-kiphoneXHomeBarHeight);
        make.height.mas_equalTo(49);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.operatorView.mas_top);
    }];
}

- (void)configNavigationBar {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:self.contactButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
}

#pragma mark - progress delegate

- (void)ZFOrderCommitProgressViewDidStopProgress
{
    [self payForMonmentWithOrderModel:self.model.main_order];
}

#pragma mark - orderQuestion delegate

-(void)ZFOrderQuestionViewControllerDidClickBackToOrders
{
    [self.navigationController popToViewController:self animated:YES];
}

-(void)ZFOrderQuestionViewControllerDidClickGontinueShopping
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    ZFTabBarController *tabBarVC = APPDELEGATE.tabBarVC;
    [tabBarVC setZFTabBarIndex:TabBarIndexHome];
}

#pragma mark - address delegate

- (void)ZFOrderDetailAddressTableViewCellDidClickConfirmButton:(OrderDetailOrderModel *)model
{
    [self confirmOrder:model.order_sn];
}

- (void)ZFOrderDetailAddressTableViewCellDidClickChangeAddressButton:(OrderDetailOrderModel *)model
{
    NSString *title = ZFLocalizedString(@"Order_change_address", nil);
    NSString *message = ZFLocalizedString(@"Order_confirm_change_current_address", nil);
    @weakify(self)
    ShowAlertView(title, message, @[ZFLocalizedString(@"Modify", nil)], ^(NSInteger buttonIndex, id buttonTitle) {
        @strongify(self)
        [self requestChangeAddress:model.order_sn];
    }, ZFLocalizedString(@"Cancel", nil), ^(id cancelTitle) {
        
    });
}

#pragma mark - setter
- (void)setOrderId:(NSString *)orderId {
    _orderId = orderId;
}

- (void)setContactLinkUrl:(NSString *)contactLinkUrl {
    _contactLinkUrl = contactLinkUrl;
}

#pragma mark - getter
- (NSMutableArray<ZFOrderDetailPriceModel *> *)priceArray {
    if (!_priceArray) {
        _priceArray = [NSMutableArray array];
    }
    return _priceArray;
}

- (NSMutableArray<ZFOrderDetailStructModel *> *)dataArray {
    if (!_dataArray) {
        _dataArray = [NSMutableArray array];
    }
    return _dataArray;
}

- (ZFOrderDetailViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFOrderDetailViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (UIButton *)contactButton {
    if (!_contactButton) {
        _contactButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_contactButton setImage:[UIImage imageNamed:@"contact_us-min"] forState:UIControlStateNormal];
        [_contactButton addTarget:self action:@selector(contactButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_contactButton sizeToFit];
        _contactButton.hidden = ZFIsEmptyString(self.contactLinkUrl);
    }
    return _contactButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.backgroundColor = ZFCOLOR_WHITE;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 80;
        _tableView.tableFooterView = [UIView new];
        [_tableView registerClass:[ZFOrderDetailOrderInfoTableViewCell class] forCellReuseIdentifier:kZFOrderDetailOrderInfoTableViewCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailPaymentStatusTableViewCell class] forCellReuseIdentifier:kZFOrderDetailPaymentStatusTableViewCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailAddressTableViewCell class] forCellReuseIdentifier:kZFOrderDetailAddressTableViewCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailOrderGoodsTableViewCell class] forCellReuseIdentifier:kZFOrderDetailOrderGoodsTableViewCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailOrderPriceInfoTableViewCell class] forCellReuseIdentifier:kZFOrderDetailOrderPriceInfoTableViewCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailVatTableViewCell class] forCellReuseIdentifier:kZFOrderDetailVatTableViewCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailGrandTotalCell class] forCellReuseIdentifier:kZFOrderDetailGrandTotalCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailDeliveryShippingCell class] forCellReuseIdentifier:kZFOrderDetailDeliveryShippingCellIdentifier];
        [_tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:kEmptyHeaderViewIdentifier];
        [_tableView registerClass:[ZFOrderDetailOrderGoodsHeaderCell class] forCellReuseIdentifier:kZFOrderDetailOrderGoodsHeaderCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailBannerCell class] forCellReuseIdentifier:kZFOrderDetailOrderTopicBannerCellIdentifier];
        [_tableView registerClass:[ZFOrderDetailPartHintCell class] forCellReuseIdentifier:kZFOrderDetailPartHintCellIdentifier];
        if (@available(iOS 11.0, *)) _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _tableView;
}

- (ZFOrderDetailOperatorView *)operatorView {
    if (!_operatorView) {
        _operatorView = [[ZFOrderDetailOperatorView alloc] initWithFrame:CGRectZero];
        _operatorView.hidden = YES;
        @weakify(self);
        _operatorView.orderDetailCheckReviewCompletionHandler = ^{
            @strongify(self);
            ZFSubmitReviewsViewController *reviewVC = [[ZFSubmitReviewsViewController alloc] init];
            reviewVC.orderId = self.orderId;
            [self.navigationController pushViewController:reviewVC animated:YES];
        };
        
        _operatorView.orderDetailCancelCompletionHandler = ^{
            @strongify(self);
            [self cancelCurrentOrderWithOrderId:self.orderId];
        };
        
        _operatorView.orderDetailOrderPayNowCompletionHandler = ^{
            @strongify(self);
            [ZFOrderCommitProgressView showProgressViewType:ZFProgressViewType_Fixed delegate:self];
            [self analyticsDetailPayNow];
        };
        
        _operatorView.orderDetailOrderTrakingInfoCompletionHandler = ^{
            @strongify(self);
            [self requestTrackingPackageInfoWithOrderModel:self.model.main_order];
        };
        
        _operatorView.orderDetailOrderBackToCartCompletionHandler = ^{
            @strongify(self);
            [self requestOrderBackToCartWithOrderId:self.orderId];
        };
        
        _operatorView.orderDetailRefundCompletionHandler = ^{
            @strongify(self);
            ///如果是拆单的，需要弹出一个选择订单的视图
            NSArray<ZFRefundOrderModel *> *refundOrderList = self.model.refund_order_list;
            if (refundOrderList.count > 1) {
                [self showJointOrderActionSheetView:refundOrderList];
            }else{
                NSString *order_sn = [refundOrderList firstObject].order_sn;
                NSString *contactUsUrl = [refundOrderList firstObject].tk_page_url;
                [self requestOrderRefundWithOrderSn:order_sn contactUsUrl:contactUsUrl];
            }
        };
    }
    return _operatorView;
}

-(ZFOrderDetailCountDownView *)countDownView
{
    if (!_countDownView) {
        _countDownView = [[ZFOrderDetailCountDownView alloc] init];
    }
    return _countDownView;
}

- (NSArray *)refundReasonParams{
    NSArray *refundReasonList = @[@{
                                        @"refund_reason_parent" : @"2",
                                        @"refund_reason_child" : @"19",
                                        @"refund_message" : @"Item became cheaper"
                                        },
                                    @{
                                        @"refund_reason_parent" : @"2",
                                        @"refund_reason_child" : @"19",
                                        @"refund_message" : @"Item became cheaper"
                                        },
                                    @{
                                        @"refund_reason_parent" : @"2",
                                        @"refund_reason_child" : @"19",
                                        @"refund_message" : @"Item became cheaper"
                                        }];
    return refundReasonList;
}

@end

