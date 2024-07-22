//
//  ZFMyOrderListViewController.m
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyOrderListViewController.h"
#import "ZFContactUsViewController.h"
#import "ZFOrderDetailViewController.h"
#import "ZFCartViewController.h"
#import "ZFTrackingInfoViewController.h"
#import "ZFOrderSuccessViewController.h"
#import "ZFOrderFailureViewController.h"
#import "ZFSubmitReviewsViewController.h"
#import "ZFInitViewProtocol.h"
#import "ZFMyOrderListStatusHeaderView.h"
#import "ZFMyOrderListStatusFooterView.h"
#import "ZFMyOrderListEmptyFooterView.h"
#import "ZFMyOrderListTopTipView.h"
#import "ZFGoodsDetailViewController.h"
#import "ZFWriteReviewViewController.h"

#import "ZFAccountProductCell.h"
#import "ZFTitleTableViewCell.h"
#import "ZFOrderListCell.h"

#import "ZFPaymentViewController.h"
#import "ZFMyOrderListModel.h"
#import "ZFMyOrderListViewModel.h"
#import "ZFOrderInformationViewModel.h"
#import "OrderDetailOrderModel.h"
#import "ZFOrderRefundModel.h"

#import "ZFMyOrderListTopMessageView.h"
#import "ZFNewPushAllowView.h"
#import "ZFCustomerManager.h"
#import <GGPaySDK/GGPaySDK.h>
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFOrderPayTools.h"
#import <Branch/Branch.h>
#import "ZFThemeManager.h"
#import "AppDelegate.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "UIScrollView+ZFBlankPageView.h"
#import "ZFLocalizationString.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "Masonry.h"
#import "ZFOrderCommitProgressView.h"
#import "ZFOrderQuestionViewController.h"
#import "ZFBranchAnalytics.h"
#import "ZFEmptyView.h"
#import "ZFCMSRecommendViewModel.h"
#import "ZFAccountAnalyticsAop.h"
#import "ZFOrderPayResultHandler.h"

static NSString *const kZFMyOrderListTableViewCellIdentifier = @"kZFMyOrderListTableViewCellIdentifier";
static NSString *const kZFMyOrderListStatusHeaderViewIdentifier = @"kZFMyOrderListStatusHeaderViewIdentifier";
static NSString *const kZFMyOrderListStatusFooterViewIdentifier = @"kZFMyOrderListStatusFooterViewIdentifier";
static NSString *const kZFMyOrderListEmptyFooterViewIdentifier = @"kZFMyOrderListEmptyFooterViewIdentifier";
static NSString *const kZFMyOrderListProductCellIdentifier = @"kZFMyOrderListProductCellIdentifier";
static NSString *const kZFMyOrderListTitleCellIdentifier = @"kZFMyOrderListTitleCellIdentifier";

typedef NS_ENUM(NSInteger) {
    OrderListContentType_OrderList,         //订单列表
    OrderListContentType_RecommendList      //推荐商品列表
}OrderListContentType;

@interface ZFMyOrderListViewController ()
<
    ZFInitViewProtocol,
    UITableViewDelegate,
    UITableViewDataSource,
    ZFOrderCommitProgressViewDelegate,
    ZFOrderQuestionViewControllerDelegate,
    ZFAccountProductCellDelegate
>

@property (nonatomic, strong) UIButton                      *contactButton;
@property (nonatomic, strong) UITableView                   *tableView;
@property (nonatomic, strong) ZFMyOrderListTopMessageView   *topMessageView;
@property (nonatomic, strong) ZFNewPushAllowView            *pushAllowView;

@property (nonatomic, strong) ZFMyOrderListTopTipView       *topTipView;

@property (nonatomic, strong) ZFMyOrderListViewModel        *viewModel;
@property (nonatomic, strong) ZFMyOrderListModel            *listModel;
//如果是从结算页过来的（在结算页未支付成功）
@property (nonatomic, assign) BOOL                          hasInitShowPushView;
@property (nonatomic, strong) ZFOrderPayTools               *payTools;
@property (nonatomic, assign) NSInteger                     currentSection;
//获取推荐商品模型
@property (nonatomic, strong) ZFCMSRecommendViewModel       *recommendViewModel;
@property (nonatomic, assign) OrderListContentType          contentType;
@property (nonatomic, strong) NSMutableArray                *recommendDataList;
@end

@implementation ZFMyOrderListViewController

#pragma mark - Life Cycle

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [[AnalyticsInjectManager shareInstance] analyticsInject:self injectObject:[[ZFAccountAnalyticsAop alloc] init]];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self zfInitView];
    [self zfAutoLayoutView];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateInform:) name:kAppDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateOrderListData) name:kZFReloadOrderListData object:nil];
}

#pragma mark - action methods

- (void)initTopMessageView:(BOOL)show {
    @weakify(self)
    [ZFPushManager canShowAlertView:^(BOOL canShow) {
        if (canShow) {
            @strongify(self)
            [self showTopMessage:show saveTime:NO];
        }
    }];
    
    //如果是从结算页过来的（在结算页未支付成功）
    if (!ZFIsEmptyString(self.sourceOrderId) && !self.hasInitShowPushView) {
        self.hasInitShowPushView = YES;
        [self showPushAlertViewLimit:YES];
    }
}

//显示通知提示
- (void)showTopMessage:(BOOL)show saveTime:(BOOL)saveTime {

    self.topMessageView.hidden = !show;
    [self.topMessageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        if (!show) {
            make.height.mas_equalTo(0);
        }
    }];
    
    if (saveTime) {//只有点击【x】关闭时保存时间
        [ZFPushManager saveShowAlertTimestamp];
    }
}

//显示订单提示
- (void)showTopTipView:(NSString *)tipText {
    ///订单列表为空时，下拉刷新需要显示推荐商品
    if (self.listModel.data.count == 0) {
        ZFEmptyView *emptyView = [[ZFEmptyView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 266)];
        emptyView.msg = ZFLocalizedString(@"MyOrderList_NoData_Title", nil);
        emptyView.msgImage = [UIImage imageNamed:@"blankPage_noOrder"];
        self.tableView.tableHeaderView = emptyView;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.contentType = OrderListContentType_RecommendList;
        [self requestRecommendProduct:YES];
        return;
    }
    
    if (ZFIsEmptyString(tipText)) {
        UIView *tableView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, KScreenWidth, 0.01)];
        self.tableView.tableHeaderView = tableView;
    } else {
        //刷新高度
        [self.topTipView tipText:tipText showArrow:NO];
        CGRect rect = CGRectZero;
        rect.size = [self.topTipView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self.topTipView.frame = rect;
        self.tableView.tableHeaderView = self.topTipView;
        self.contentType = OrderListContentType_OrderList;
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        [self.recommendDataList removeAllObjects];
    }
}

//直接显示
- (void)showPushAlertViewLimit:(BOOL)isLimit {
    if (![self.navigationController.topViewController isEqual:self]) {//尽量确保在当前界面显示
        return;
    }
    
    if (isLimit) {
        @weakify(self)
        [ZFPushManager canShowAlertView:^(BOOL canShow) {
            if (canShow) {
                @strongify(self)
                [self.pushAllowView noLimitShow:PushAllowViewType_Msg operateBlock:^(BOOL flag) {}];
            }
        }];
    } else {
        [self.pushAllowView noLimitShow:PushAllowViewType_Msg operateBlock:^(BOOL flag) {}];
    }
}


- (void)updateInform:(NSNotification *)notify {
    
    //进入【设置】修改通知后，在回到界面时，判断处理通知变化
    @weakify(self)
    [ZFPushManager canShowAlertView:^(BOOL canShow) {
        @strongify(self)
        if (!canShow) {
            [self.pushAllowView hidden];
            [self showTopMessage:NO saveTime:NO];
        }
    }];
}

- (void)updateOrderListData
{
    ///通知刷新页面
    [self requestOrderListPageData:YES];
}

- (void)contactButtonAction:(UIButton *)sender {
    if ([NSStringUtils isBlankString:self.listModel.contact_us]) {
        return;
    }
    //    ZFWebViewViewController *webVC = [[ZFWebViewViewController alloc] init];
    //    webVC.link_url = self.listModel.contact_us;
    //    [self.navigationController pushViewController:webVC animated:YES];
    
    //因为客服页面没有解决跨域问题,需要暂时单独跳进低性能UIWebView页面
    ZFContactUsViewController *webVC = [[ZFContactUsViewController alloc]init];
    webVC.link_url = self.listModel.contact_us;
    [self.navigationController pushViewController:webVC animated:YES];
}

- (void)enterOrderDetailViewControllerWithOrderId:(NSString *)orderId
                                       andSection:(NSInteger)section {
    ZFOrderDetailViewController *detailVC = [[ZFOrderDetailViewController alloc] init];
    detailVC.orderId = orderId;
    detailVC.contactLinkUrl = self.listModel.contact_us;
    @weakify(self);
    detailVC.orderDetailReloadListInfoCompletionHandler = ^(OrderDetailOrderModel *statusModel)   {
        @strongify(self);
        //刷新订单列表页对应数据源
        self.listModel.data[section].order_status = statusModel.order_status;
        self.listModel.data[section].order_status_str = statusModel.order_status_str;
        self.listModel.data[section].pay_id = statusModel.pay_id;
        self.listModel.data[section].pay_left_time = statusModel.pay_left_time;
        self.listModel.data[section].confirm_btn_show = statusModel.confirm_btn_show;
        [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationNone];
    };
    [self.navigationController pushViewController:detailVC animated:YES];
}

#pragma mark - private methods
- (void)requestOrderListPageData:(BOOL)isFirstPage {
    @weakify(self);
    [self.viewModel requestOrderListNetwork:isFirstPage completion:^(ZFMyOrderListModel *listModel, NSDictionary *pageDic) {
        @strongify(self);
        self.view.backgroundColor = listModel ?  ZFCOLOR(245, 245, 245, 1.0) : ZFCOLOR_WHITE;
        self.tableView.backgroundColor = self.view.backgroundColor;
        self.listModel = listModel;
        [self configNavigationBar];
        
        if (isFirstPage) {
            [self initTopMessageView:self.listModel.data.count];
            [self showTopTipView:self.listModel.order_tip];
        }
        
        AccountModel *model = [AccountManager sharedManager].account;
        model.not_paying_order = self.listModel.not_paying_order;
        [[AccountManager sharedManager] updateUserInfo:model];
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageDic];
    }];
}

- (void)requestOrderBackToCartWithOrderId:(NSString *)orderId {
    @weakify(self);
    NSDictionary *dict = @{
                           @"order_id"    : orderId,
                           kLoadingView   : self.view
                           };
    [self.viewModel requestReturnToBag:dict completion:^(id obj) {
        @strongify(self);
        [self.navigationController popViewControllerAnimated:YES];
        ZFNavigationController  *accountNavVC = [self queryTargetNavigationController:TabBarIndexAccount];
        ZFCartViewController *cartVC = [[ZFCartViewController alloc] init];
        [self.navigationController popToRootViewControllerAnimated:NO];
        [accountNavVC pushViewController:cartVC animated:NO];
    } failure:^(id obj) {
        //do nothing
        @strongify(self);
        ShowToastToViewWithText(self.view, ZFLocalizedString(@"Failed", nil));
    }];
}

//订单退款
- (void)requestOrderRefundWithOrderSn:(NSString *)orderSn {
    //弹框提示
    NSString *message = ZFLocalizedString(@"OrderRefundAskTips", nil);
    NSString *oktitle =  ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_Yes", nil);
    NSString *cancelTitle = ZFLocalizedString(@"OrderDetail_Cell_CancelOrder_No", nil);
    
    ShowAlertView(nil, message, @[oktitle], ^(NSInteger buttonIndex, id buttonTitle) {
        
        @weakify(self);
        [self.viewModel requestRefundNetwork:orderSn completion:^(id obj) {
            @strongify(self);
            ZFOrderRefundModel *model = obj;
            if (![NSStringUtils isEmptyString:model.msg]) {
                [self showAlertViewWithTitle:nil Message:model.msg];
            }
        } failure:nil];
        
    }, cancelTitle, nil);
}

//获取推荐商品
- (void)requestRecommendProduct:(BOOL)first
{
    @weakify(self)
    [self.recommendViewModel requestCmsRecommendData:first parmaters:@{} completion:^(NSArray<ZFGoodsModel *> * _Nonnull array, NSDictionary * _Nonnull pageInfo) {
        //根据ABTEST区分显示行数
        @strongify(self)
        NSMutableArray *temProductList = [[NSMutableArray alloc] init];
        NSInteger subSize = 3;
        NSInteger count = 0;
        NSInteger totalCount = [array count];
        if (totalCount%subSize == 0) {
            count = (totalCount / subSize);
        }else{
            count = (totalCount / subSize) + 1;
        }
        for (int i = 0; i < count; i++) {
            NSInteger index = i * subSize;
            NSMutableArray *subArray = [[NSMutableArray alloc] init];
            NSInteger j = index;
            while (j < (subSize * (i + 1)) && j < totalCount) {
                [subArray addObject:array[j]];
                j++;
            }
            [temProductList addObject:subArray];
        }
        if (first) {
            [self.recommendDataList removeAllObjects];
        }
        [self.recommendDataList addObjectsFromArray:temProductList];
        [self.tableView reloadData];
        [self.tableView showRequestTip:pageInfo];
    } failure:^(NSError * _Nonnull error) {
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

- (void)requestTrackingPackageInfoWithOrderModel:(MyOrdersModel *)model {
    @weakify(self);
    NSDictionary *dict = @{
                           @"order_id"    : model.order_id,
                           kLoadingView   : self.view
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
        }
    } failure:nil];
}

- (void)payForMonmentWithOrderModel:(MyOrdersModel *)model {
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
//    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderWithOrderList:model];
    
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

    self.payTools = paytools;
}

- (void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)message {    
    ShowAlertSingleBtnView(title, message, ZFLocalizedString(@"OK", nil));
}

- (void)jumpToOrderReviewViewControllerWithOrderId:(NSString *)orderId {
    ZFSubmitReviewsViewController *reviewVC = [[ZFSubmitReviewsViewController alloc] init];
    reviewVC.orderId = orderId;
    [self.navigationController pushViewController:reviewVC animated:YES];
}

- (void)reviewOrderWithGoodsModel:(MyOrdersModel *)ordersModel {
    
    __block ZFWaitCommentModel *model = [[ZFWaitCommentModel alloc] init];
    
    [ordersModel.goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (obj.is_review == 0) {

            NSString *sttr_str = [NSString stringWithFormat:@"%@%@%@", obj.attr_color ?: @"", (obj.attr_color && obj.attr_size) ? @"/" : @"", obj.attr_size ?: @""];
            model.goods_title = obj.goods_title;
            model.goods_id = obj.goods_id;
            model.goods_attr_str = sttr_str;
            model.goods_thumb = obj.wp_image;
            *stop = YES;
        }
    }];

    ZFWriteReviewViewController *reviewVC = [[ZFWriteReviewViewController alloc] init];
    reviewVC.commentModel = model;
    
    @weakify(self)
    reviewVC.commentSuccessBlock = ^(ZFWaitCommentModel * _Nonnull commentModel) {
        @strongify(self)
        
    };
    [self.navigationController pushViewController:reviewVC animated:YES];
}

- (void)jumpToOrderFinishViewController:(MyOrdersModel *)orderModel payResult:(ZFOrderPayResultModel *)payResultModel {
    ZFOrderPayResultHandler *handler = [ZFOrderPayResultHandler handler];
    handler.zfParentViewController = self;
    @weakify(self)
    handler.dismissSuccessVCBlock = ^{
        @strongify(self)
        [self.tableView.mj_header beginRefreshing];
    };
    [handler orderPaySuccess:ZFOrderPayResultSource_OrderList baseOrderModel:orderModel resultModel:payResultModel];
    
//    ZFOrderSuccessViewController *finischVC = [[ZFOrderSuccessViewController alloc] init];
////    finischVC.orderSN = orderModel.order_sn;
//    finischVC.baseOrderModel = orderModel;
//    finischVC.orderPayResultModel = payResultModel;
//    @weakify(finischVC)
//    finischVC.toAccountOrHomeblock = ^(BOOL gotoAccount){ //跳转到Accont或是Home
//        @strongify(finischVC)
//        [finischVC dismissViewControllerAnimated:NO completion:^{
//            if (gotoAccount) {
//                [self.navigationController popToViewController:self animated:YES];
//                [self.tableView.mj_header beginRefreshing];
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
//
    /*谷歌统计*/
    [ZFAnalytics settleAccountProcedureWithProduct:orderModel.goods step:3 option:nil screenName:@"PaySuccess"];
    [ZFAnalytics trasactionAccountWithProduct:orderModel screenName:@"PaySuccess"];
    //growingIO统计
//    [ZFGrowingIOAnalytics ZFGrowingIOPayOrderSuccessWithOrderList:orderModel];
//
//    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:finischVC];
//    [self presentViewController:nav animated:YES completion:nil];
}

- (void)jumpToOrderFailurViewController {
    ZFOrderFailureViewController *failureVC = [[ZFOrderFailureViewController alloc] init];
    @weakify(failureVC)
    failureVC.orderFailureBlock = ^{
        @strongify(failureVC)
        [failureVC dismissViewControllerAnimated:YES completion:^{
            [self.tableView.mj_header beginRefreshing];
        }];
        // 谷歌统计
        [ZFAnalytics clickButtonWithCategory:@"Payment Failure" actionName:@"Payment Failure - My Account" label:@"Payment Failure - My Account"];
    };
    [self presentViewController:failureVC animated:YES completion:nil];
}

/// 统计订单列表点击回购订单
- (void)analyticsBuyAgainAction:(MyOrdersModel *)orderModel
{
    if (![orderModel isKindOfClass:[MyOrdersModel class]]) return;
    NSDictionary *appsflyerParams = @{
        @"af_content_type" : @"buyagain_button",
        @"af_reciept_id" : ZFToString(orderModel.order_id),
        @"af_price" : ZFToString(orderModel.total_fee),
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_buyagain_click" withValues:appsflyerParams];
}

/// 统计订单列表点击立即支付订单
- (void)analyticsOrderPayNowAction:(MyOrdersModel *)orderModel
{
    if (![orderModel isKindOfClass:[MyOrdersModel class]]) return;
    NSDictionary *appsflyerParams = @{
        @"af_content_type" : @"order_list",
        @"af_reciept_id" : ZFToString(orderModel.order_id),
        @"af_price" : ZFToString(orderModel.total_fee),
    };
    [ZFAppsflyerAnalytics zfTrackEvent:@"af_orderlistpay_click" withValues:appsflyerParams];
}

#pragma mark - <UITableViewDelegate, UITableViewDataSource>
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.contentType == OrderListContentType_OrderList) {
        return self.listModel.data.count;
    } else {
        if (self.recommendDataList.count) {
            return self.recommendDataList.count + 1;
        }
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.contentType == OrderListContentType_OrderList) {
        ZFOrderListCell *cell = [tableView dequeueReusableCellWithIdentifier:kZFMyOrderListTableViewCellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        MyOrdersModel *ordersModel = self.listModel.data[indexPath.section];
        cell.model  = ordersModel;
        @weakify(self);
        cell.orderListOrderBackToCartCompletionHandler = ^{ //回购
            @strongify(self);
            if (self.isFromChat) {
                [self selectedOrderWithSection:indexPath.section];
            } else {
                [self requestOrderBackToCartWithOrderId:ordersModel.order_id];
                [self analyticsBuyAgainAction:ordersModel];//V5.4.0
            }
        };
        
        cell.orderListReviewShowCompletionHandler = ^{
            @strongify(self);
            if (self.isFromChat) {
                [self selectedOrderWithSection:indexPath.section];
            } else {
                [self jumpToOrderReviewViewControllerWithOrderId:ordersModel.order_id];
            }
        };
        
        cell.orderListOrderPayNowCompletionHandler = ^{ //立即支付
            @strongify(self);
            if (self.isFromChat) {
                [self selectedOrderWithSection:indexPath.section];
            } else {
                //弹出一个安全检查弹窗
                self.currentSection = indexPath.section;
                [ZFOrderCommitProgressView showProgressViewType:ZFProgressViewType_Fixed delegate:self];
                
                [self analyticsOrderPayNowAction:ordersModel];//V5.4.0
            }
        };
        
        cell.orderListOrderTrakingInfoCompletionHandler = ^{
            @strongify(self);
            if (self.isFromChat) {
                [self selectedOrderWithSection:indexPath.section];
            } else {
                [self requestTrackingPackageInfoWithOrderModel:ordersModel];
            }
        };
        
        cell.orderListRefundCompletionHandler = ^{
            @strongify(self);
            if (self.isFromChat) {
                [self selectedOrderWithSection:indexPath.section];
            } else {
                [self requestOrderRefundWithOrderSn:ordersModel.order_sn];
            }
        };
        
        cell.orderListCODCheckAddressCompletionHandler = ^{
            @strongify(self);
            if (self.isFromChat) {
                [self selectedOrderWithSection:indexPath.section];
            } else {
                [self enterOrderDetailViewControllerWithOrderId:ordersModel.order_id andSection:indexPath.section];
            }
        };
        return cell;
    } else {
        if (indexPath.section == 0) {
            //第一个为title cell
            ZFTitleTableViewCell *titleCell = [tableView dequeueReusableCellWithIdentifier:kZFMyOrderListTitleCellIdentifier];
            titleCell.title = ZFLocalizedString(@"Account_RecomTitle", nil);
            return titleCell;
        } else {
            NSString *idetifier = [NSString stringWithFormat:@"%@",kZFMyOrderListProductCellIdentifier];
            ZFAccountProductCell *productCell = [tableView dequeueReusableCellWithIdentifier:idetifier];
            if (!productCell) {
                productCell = [[ZFAccountProductCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:idetifier abFlag:1];
            }
            productCell.goodsList = self.recommendDataList[indexPath.section - 1];
            productCell.delegate = self;
            return productCell;
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.isFromChat) {
        [self selectedOrderWithSection:indexPath.section];
    } else {
        if (self.contentType == OrderListContentType_RecommendList) {
            return;
        }
        [self enterOrderDetailViewControllerWithOrderId:self.listModel.data[indexPath.section].order_id andSection:indexPath.section];
    }
}

- (void)selectedOrderWithSection:(NSInteger)section {
    if (self.selectedOrderHandle) {
        MyOrdersModel *model = self.listModel.data[section];
        self.selectedOrderHandle(model.order_sn);
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = ZFLocalizedString(@"MyOrders_VC_Title",nil);
    self.view.backgroundColor = ZFCOLOR_WHITE;
    
    [self.view addSubview:self.topMessageView];
    [self.view addSubview:self.tableView];
}

- (void)zfAutoLayoutView {
    [self.topMessageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self.view);
        make.height.mas_equalTo(0);
    }];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.view.mas_bottom);
        make.top.mas_equalTo(self.topMessageView.mas_bottom);
    }];
}

- (void)configNavigationBar {
    UIBarButtonItem *buttonItem = [[UIBarButtonItem alloc]initWithCustomView:self.contactButton];
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    self.navigationItem.rightBarButtonItems = @[negativeSpacer, buttonItem];
}

#pragma mark - progress delegate

-(void)ZFOrderCommitProgressViewDidStopProgress
{
    if (self.currentSection <= self.listModel.data.count - 1) {
        [self payForMonmentWithOrderModel:self.listModel.data[self.currentSection]];
    }
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

#pragma mark - product cell delegate

-(void)ZFAccountProductCellDidSelectProduct:(ZFGoodsModel *)goodsModel
{
    ZFGoodsDetailViewController *goodsDetail = [[ZFGoodsDetailViewController alloc] init];
    goodsDetail.goodsId = goodsModel.goods_id;
    goodsDetail.sourceType = ZFAppsflyerInSourceTypeMyOrderListRecommend;
    [self.navigationController pushViewController:goodsDetail animated:YES];
}

#pragma mark - getter
- (ZFMyOrderListViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[ZFMyOrderListViewModel alloc] init];
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
    }
    return _contactButton;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = ZFC0xF7F7F7();
        _tableView.tableFooterView = [UIView new];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = 172.5;//尽量跟cell的本身高度一致，以让刷新的时候，cell不会很弹一下
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.exclusiveTouch = YES;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//        _tableView.contentInset = UIEdgeInsetsMake(0, 0, kiphoneXHomeBarHeight, 0);
        
        _tableView.emptyDataImage = [UIImage imageNamed:@"blankPage_noOrder"];
        _tableView.emptyDataTitle = ZFLocalizedString(@"MyOrderList_NoData_Title", nil);
        
        [_tableView registerClass:[ZFOrderListCell class] forCellReuseIdentifier:kZFMyOrderListTableViewCellIdentifier];
        [_tableView registerClass:[ZFMyOrderListStatusHeaderView class] forHeaderFooterViewReuseIdentifier:kZFMyOrderListStatusHeaderViewIdentifier];
        [_tableView registerClass:[ZFMyOrderListStatusFooterView class] forHeaderFooterViewReuseIdentifier:kZFMyOrderListStatusFooterViewIdentifier];
        [_tableView registerClass:[ZFMyOrderListEmptyFooterView class] forHeaderFooterViewReuseIdentifier:kZFMyOrderListEmptyFooterViewIdentifier];
        
        [_tableView registerClass:[ZFTitleTableViewCell class] forCellReuseIdentifier:kZFMyOrderListTitleCellIdentifier];
        @weakify(self);
        [_tableView addHeaderRefreshBlock:^{
            @strongify(self);
            [self requestOrderListPageData:YES];
        } footerRefreshBlock:^{
            @strongify(self);
            if (self.contentType == OrderListContentType_RecommendList) {
                [self requestRecommendProduct:NO];
            } else {
                [self requestOrderListPageData:NO];
            }
        } startRefreshing:YES];
    }
    return _tableView;
}


- (ZFMyOrderListTopMessageView *)topMessageView {
    if (!_topMessageView) {
        _topMessageView = [[ZFMyOrderListTopMessageView alloc] initWithFrame:CGRectZero];
        _topMessageView.hidden = YES;
        @weakify(self)
        _topMessageView.operateCloseBlock = ^{
            @strongify(self)
            [self showTopMessage:NO saveTime:YES];
        };
        _topMessageView.operateEventBlock = ^{
            @strongify(self)
            [self showPushAlertViewLimit:NO];
        };
    }
    return _topMessageView;
}

- (ZFMyOrderListTopTipView *)topTipView {
    if (!_topTipView) {
        _topTipView = [[ZFMyOrderListTopTipView alloc] initWithFrame:CGRectZero];
    }
    return _topTipView;
}

- (ZFNewPushAllowView *)pushAllowView {
    if (!_pushAllowView) {
        _pushAllowView = [[ZFNewPushAllowView alloc] init];
    }
    return _pushAllowView;
}

-(ZFCMSRecommendViewModel *)recommendViewModel
{
    if (!_recommendViewModel) {
        _recommendViewModel = [[ZFCMSRecommendViewModel alloc] init];
        _recommendViewModel.controller = self;
    }
    return _recommendViewModel;
}

-(NSMutableArray *)recommendDataList
{
    if (!_recommendDataList) {
        _recommendDataList = [[NSMutableArray alloc] init];
    }
    return _recommendDataList;
}

- (void)setIsFromChat:(BOOL)isFromChat {
    _isFromChat = isFromChat;
    self.contactButton.hidden = isFromChat;
}

@end
