//
//  OSSVAccountsOrderDetailVC.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/7.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

//****************************** Controllers *******************************//
#import "OSSVAccountsOrderDetailVC.h"
#import "OSSVDetailsVC.h"
/*跳转西联汇款信息页H5*/
#import "STLActivityWWebCtrl.h"
/*订单列表控制器*/
#import "OSSVAccountsMyOrderVC.h"
/*查看评论控制器*/
#import "CheckReviewViewController.h"
/*写评论控制器*/
#import "WriteReviewViewController.h"
#import "STLCartViewCtrl.h"
#import "STLOrderReviewCtrl.h"
//新的物流轨迹
#import "STLNewTrackingListViewController.h"
#import "STLTransportSplitViewController.h"
/*物流控制器*/
//#import "STLTrackingInforCtrl.h"
#import "STLTrackingListCtrl.h"
/*支付完成显示页*/
#import "STLOrderFinishCtrl.h"

//******************************* Views *******************************//
/*地址信息栏*/
#import "CartOrderInformationAddressView.h"
/*商品信息栏*/
#import "AccountOrderDetailView.h"
/*倒计时标签*/
#import "MZTimerLabel.h"
/*信用卡支付页面*/
#import "STLCreditCardView.h"
/*西联支付页面*/
#import "STLWesternUnionView.h"
/*WorldPay支付页面*/
#import "STLWorldPayView.h"
/*推送*/
#import "STLOrdersTimeDownView.h"
#import "STLSMSVerifyView.h"
#import "STLOrderCodConfirmView.h"
#import "STLCheckOutCodMsgAlertView.h"
#import "STLOrderCodSuccessView.h"
#import "YYText.h"
#import "STLOrderTrackView.h" //新增物流信息
#import "STLTransportSplitView.h" //拆单物流信息
#import "STLBottomButtonsView.h"

/********************************ViewModels*********************************/
#import "AccountMyOrdersDetailViewModel.h"
#import "AccountMyOrdersViewModel.h"
#import "STLPayPalModule.h"

/******************************** Models数据模型 *********************************/
#import "AccountOrdersDetailShippingModel.h"//物流信息数据模型
#import "AccountMyOrdersDetailModel.h"//订单详情页数据模型
#import "AddressBookModel.h"//地址数据模型
/*支付数据*/
#import "AccountOrderDetailExtraModel.h"
#import "TrackingInformationModel.h"
#import "STLTransportTrackMode.h"

//***************************** API 接口文件****************************//
#import "TrackingInformationApi.h"
#import "STLOrderBuyAgainApi.h"
#import "STLCodCancelAddApi.h"

//Helps
#import "UIView+WhenTappedBlocks.h"

#import "Adorawe-Swift.h"

@import RangersAppLog;


@interface OSSVAccountsOrderDetailVC ()<AccountOrderDetailViewDelegate, STLBottomButtonViewDelegate>

/*========================================分割线======================================*/

/*底层容器*/
@property (nonatomic,strong) UIScrollView *scrollView;
@property (nonatomic,strong) UIView *containerView;

/*========================================分割线======================================*/

/**订单状态*/
@property (nonatomic,strong) UIView *topOrderStateView;

/*订单状态容器*/
@property (nonatomic,strong) UIView *statusBottomView;
/*物流状态容器*/
@property (nonatomic,strong) UIView *trackingBottomView;
/*地址信息容器*/
@property (nonatomic,strong) UIView *addressBottomView;
/*商品信息容器*/
@property (nonatomic,strong) UIView *goodsBottomView;
/*购物方式信息容器*/
@property (nonatomic,strong) UIView *shippingBottomView;
/*价格信息容器*/
@property (nonatomic,strong) UIView *totalBottomView;
/*是否使用积分或优惠券直减容器*/
//@property (nonatomic,weak) UIView *couponBottomView;
/**/
//@property (nonatomic, strong) UIView *pointBottomView;
/*总价容器*/
@property (nonatomic,strong) UIView *grandTotalBottomView;
/*取消,支付按钮容器*/
@property (nonatomic,strong) STLBottomButtonsView *payBottomView;
@property (nonatomic,strong) UIView               *bottomSafeView;
/*进入订单详情页的时候展示的空白页面*/
@property (nonatomic,strong) UIView *VirtualView;
///<COD商品展示取整视图
//@property (nonatomic, strong) UIView *codBottomView;

/*========================================分割线======================================*/


/*订单状态*/
@property (nonatomic,strong) UILabel *statusLabel;

@property (nonatomic,strong) UIView             *waitCheckView;
@property (nonatomic,strong) UILabel            *codCheckTipLabel;//cod 等待check

/*地址信息*/
@property (nonatomic,strong) CartOrderInformationAddressView *addressView;
/*仓库title*/
@property (nonatomic,strong) UILabel                        *wareHouseTitleLabel;
/*商品信息*/
@property (nonatomic,strong) AccountOrderDetailView         *goodsView;

/*订单号*/
@property (nonatomic,strong) STLOrderDetailTitileDescView   *orderNoView;
/*订单时间*/
@property (nonatomic,strong) STLOrderDetailTitileDescView   *orderDateView;
/*物流方式*/
@property (nonatomic,strong) STLOrderDetailTitileDescView   *orderShipMethodView;
/*支付方式*/
@property (nonatomic,strong) STLOrderDetailTitileDescView   *orderPaymentMethodView;


/*折扣*/
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalSavePriceCostView;

/********************商品价格,邮费,优惠券等价格*********************/
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalProdcetCostView;
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalShippingCostView;
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalTrackingCostView;
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalInsuranceCostView;
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalCouponCostView;
///支付方式优惠金额
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalDiscountCostView;
///金币金额
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalCoinDiscountCostView;
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalCodCostView;
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalPointCostView;
///部分付款的层
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalPartyPayCostView;
///<COD商品订单总额 总额价格
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalCodOrderCostView;
///<COD商品取整类型 取整数额
@property (nonatomic, strong) STLOrderDetailTitlePriceView *totalCodOrderDistypeCostView;

@property (nonatomic, strong) UIView                       *totalLineView;
/*总价*/
@property (nonatomic,strong) UILabel                       *reallyPayTotalLabel;
@property (nonatomic,strong) UILabel                       *reallyTaxLabel;       //含税Label
@property (nonatomic,strong) UILabel                       *reallyTotapPayPriceLabel;  //总计


@property (nonatomic, strong) STLOrdersTimeDownView *countDownView;
/*========================================分割线======================================*/

/*订单详情页数据模型*/
@property (nonatomic,strong) AccountMyOrdersDetailModel *orderDetailModel;
/*当前VC的ViewModel*/
@property (nonatomic,strong) AccountMyOrdersDetailViewModel *viewModel;
@property (nonatomic, strong) STLPayPalModule *payModule;
/*========================================分割线======================================*/


@property (nonatomic, strong) STLSMSVerifyView                      *smsVerifyView;
@property (nonatomic, strong) STLCheckOutCodMsgAlertView            *codMsgAlertView;
@property (nonatomic, strong) STLOrderCodSuccessView                *codSuccessView;
@property (nonatomic, strong) CartOrderInfoViewModel                *infoViewModel;
@property (nonatomic, strong) AccountMyOrdersViewModel              *myOrderlistModel;


@property (copy,nonatomic) NSString *confirmMethod;

@end

@implementation OSSVAccountsOrderDetailVC

-(void)dealloc
{
    
    if (_countDownView) {
        [_countDownView removeFromSuperview];
    }
    [self.viewModel freesource];
}

/*========================================分割线======================================*/

- (instancetype)initWithOrderId:(NSString*)orderId {
    if (self = [super init]) {
        _orderId = orderId;
    }
    return self;
}

/*========================================分割线======================================*/

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = STLLocalizedString_(@"orderDetail",nil);
    [self initView];
    [self reloadData];
    
}

/*========================================分割线======================================*/

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    /*谷歌统计*/
    if (!self.firstEnter) {
    }
    self.firstEnter = YES;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
/*========================================分割线======================================*/

- (AccountMyOrdersDetailViewModel*)viewModel {
    if (!_viewModel) {
        _viewModel = [[AccountMyOrdersDetailViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

/*========================================分割线======================================*/
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectZero];;
        scrollView.showsVerticalScrollIndicator = NO;
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [UIView new];
        containerView.backgroundColor = [STLThemeColor col_F5F5F5];
        containerView.layer.cornerRadius = 6;
        containerView.layer.masksToBounds = YES;
        _containerView = containerView;
    }
    return _containerView;
}

- (UIView *)topOrderStateView {
    if (!_topOrderStateView) {
        _topOrderStateView = [[UIView alloc] init];
        _topOrderStateView.backgroundColor = [STLThemeColor col_60CD8E];
        _topOrderStateView.layer.cornerRadius = 6;
        _topOrderStateView.layer.masksToBounds = YES;
    }
    return _topOrderStateView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        UILabel *statusLabel = [UILabel new];
        statusLabel.font = [UIFont boldSystemFontOfSize:14];
        statusLabel.textColor = [STLThemeColor stlWhiteColor];
        
        statusLabel.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            statusLabel.textAlignment = NSTextAlignmentRight;
        }
        _statusLabel = statusLabel;
        
    }
    return _statusLabel;
}

- (UIView *)trackingBottomView {
    if (!_trackingBottomView) {
        UIView *trackingBottomView = [UIView new];
        trackingBottomView.backgroundColor = STLThemeColor.col_FFFFFF;
        trackingBottomView.layer.cornerRadius = 6;
        trackingBottomView.layer.masksToBounds = YES;
        _trackingBottomView = trackingBottomView;
    }
    return _trackingBottomView;
}

- (UIView *)addressBottomView {
    if (!_addressBottomView) {
        UIView *addressBottomView = [UIView new];
        addressBottomView.layer.cornerRadius = 6;
        addressBottomView.layer.masksToBounds = YES;
        _addressBottomView = addressBottomView;
    }
    return _addressBottomView;
}

- (CartOrderInformationAddressView *)addressView {
    if (!_addressView) {
        CartOrderInformationAddressView *addressView = [CartOrderInformationAddressView new];
        addressView.addressShowBtn.hidden = YES;
        _addressView = addressView;
    }
    return _addressView;
}

- (UIView *)shippingBottomView {
    if (!_shippingBottomView) {
        UIView *shippingBottomView = [UIView new];
        shippingBottomView.backgroundColor = STLThemeColor.col_FFFFFF;
        shippingBottomView.layer.cornerRadius = 6;
        shippingBottomView.layer.masksToBounds = YES;
        _shippingBottomView = shippingBottomView;
    }
    return _shippingBottomView;
}

//- (UILabel *)shipMethodLabel {
//    if (!_shipMethodLabel) {
//        UILabel *shipMethodLabel = [UILabel new];
//        shipMethodLabel.font = [UIFont systemFontOfSize:14];
//        shipMethodLabel.textColor = STLThemeColor.col_333333;
//        _shipMethodLabel = shipMethodLabel;
//    }
//    return _shipMethodLabel;
//}

- (STLOrderDetailTitileDescView *)orderShipMethodView {
    if (!_orderShipMethodView) {
        _orderShipMethodView = [[STLOrderDetailTitileDescView alloc] initWithFrame:CGRectZero title:STLLocalizedString_(@"shipMethod", nil)];
        
    }
    return _orderShipMethodView;
}

//- (UILabel *)paymentMethodLabel {
//    if (!_paymentMethodLabel) {
//        UILabel *paymentMethodLabel = [UILabel new];
//        paymentMethodLabel.font = [UIFont systemFontOfSize:14];
//        paymentMethodLabel.textColor = STLThemeColor.col_333333;
//        _paymentMethodLabel = paymentMethodLabel;
//    }
//    return _paymentMethodLabel;
//}
- (STLOrderDetailTitileDescView *)orderPaymentMethodView {
    if (!_orderPaymentMethodView) {
        _orderPaymentMethodView = [[STLOrderDetailTitileDescView alloc] initWithFrame:CGRectZero title:STLLocalizedString_(@"paymentMethod", nil)];
    }
    return _orderPaymentMethodView;
}

//- (UILabel *)orderNoLabel {
//    if (!_orderNoLabel) {
//        UILabel *orderNoLabel = [UILabel new];
//        orderNoLabel.userInteractionEnabled = YES;
//        orderNoLabel.font = [UIFont systemFontOfSize:14];
//        orderNoLabel.textColor = STLThemeColor.col_333333;
//        _orderNoLabel = orderNoLabel;
//    }
//    return _orderNoLabel;
//}

- (STLOrderDetailTitileDescView *)orderNoView {
    if (!_orderNoView) {
        _orderNoView = [[STLOrderDetailTitileDescView alloc] initWithFrame:CGRectZero title:STLLocalizedString_(@"orderNo", nil)];
        [_orderNoView showCopyWithShow:YES];
        
        @weakify(self)
        _orderNoView.eventlock = ^{
            @strongify(self)
            [self actionCopyOrderNumber];
        };
    }
    return _orderNoView;
}

//- (UILabel *)orderDate {
//    if (!_orderDate) {
//        UILabel *orderDate = [UILabel new];
//        orderDate.font = [UIFont systemFontOfSize:14];
//        orderDate.textColor = STLThemeColor.col_333333;
//        _orderDate = orderDate;
//    }
//    return _orderDate;
//}

- (STLOrderDetailTitileDescView *)orderDateView {
    if (!_orderDateView) {
        _orderDateView = [[STLOrderDetailTitileDescView alloc] initWithFrame:CGRectZero title:STLLocalizedString_(@"orderDate", nil)];
    }
    return _orderDateView;
}


- (UIView *)goodsBottomView {
    if (!_goodsBottomView) {
        _goodsBottomView = [UIView new];
        _goodsBottomView.backgroundColor = [STLThemeColor stlWhiteColor];
        _goodsBottomView.layer.cornerRadius = 6;
        _goodsBottomView.layer.masksToBounds = YES;
    }
    return _goodsBottomView;
}

- (UILabel *)wareHouseTitleLabel {
    if (!_wareHouseTitleLabel) {
        _wareHouseTitleLabel = [UILabel new];
        _wareHouseTitleLabel.textColor = [STLThemeColor col_0D0D0D];
        _wareHouseTitleLabel.font = [UIFont boldSystemFontOfSize:14];
        _wareHouseTitleLabel.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _wareHouseTitleLabel.textAlignment = NSTextAlignmentRight;
        }
    }
    return _wareHouseTitleLabel;
}

- (UIView *)totalBottomView {
    if (!_totalBottomView) {
        UIView *totalBottomView = [UIView new];
        totalBottomView.backgroundColor = STLThemeColor.col_FFFFFF;
        _totalBottomView = totalBottomView;
        _totalBottomView.layer.cornerRadius = 6;
        _totalBottomView.layer.masksToBounds = YES;
    }
    return _totalBottomView;
}


- (STLOrderDetailTitlePriceView *)totalProdcetCostView {
    if (!_totalProdcetCostView) {
        _totalProdcetCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"protudts_total",nil)]];
    }
    return _totalProdcetCostView;
}

- (STLOrderDetailTitlePriceView *)totalShippingCostView {
    if (!_totalShippingCostView) {
        _totalShippingCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"shipCost",nil)]];
    }
    return _totalShippingCostView;
}

- (STLOrderDetailTitlePriceView *)totalDiscountCostView {
    if (!_totalDiscountCostView) {
        _totalDiscountCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"disCountTitle",nil)]];
        _totalDiscountCostView.priceLabel.textColor = [STLThemeColor col_B62B21];

    }
    return _totalDiscountCostView;
}

- (STLOrderDetailTitlePriceView *)totalTrackingCostView {
    if (!_totalTrackingCostView) {
        _totalTrackingCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"tracking",nil)]];
    }
    return _totalTrackingCostView;
}

- (STLOrderDetailTitlePriceView *)totalInsuranceCostView {
    if (!_totalInsuranceCostView) {
        _totalInsuranceCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"insurance",nil)]];
    }
    return _totalInsuranceCostView;
}

- (STLOrderDetailTitlePriceView *)totalCodCostView {
    if (!_totalCodCostView) {
        _totalCodCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"codCost",nil)]];
    }
    return _totalCodCostView;
}

- (STLOrderDetailTitlePriceView *)totalSavePriceCostView {
    if (!_totalSavePriceCostView) {
        _totalSavePriceCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"save",nil)]];
        _totalSavePriceCostView.priceLabel.textColor = [STLThemeColor col_B62B21];

    }
    return _totalSavePriceCostView;
}

- (STLOrderDetailTitlePriceView *)totalCoinDiscountCostView {
    if (!_totalCoinDiscountCostView) {
        _totalCoinDiscountCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"CoinsCost",nil)]];
        _totalCoinDiscountCostView.priceLabel.textColor = [STLThemeColor col_B62B21];
    }
    return _totalCoinDiscountCostView;
}

- (STLOrderDetailTitlePriceView *)totalCouponCostView {
    if (!_totalCouponCostView) {
        _totalCouponCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"orderInfo_coupon",nil)]];
        _totalCouponCostView.priceLabel.textColor = [STLThemeColor col_B62B21];

    }
    return _totalCouponCostView;
}

- (STLOrderDetailTitlePriceView *)totalPointCostView {
    if (!_totalPointCostView) {
        _totalPointCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"orderInfo_point",nil)]];
        _totalPointCostView.priceLabel.textColor = [STLThemeColor col_B62B21];
    }
    return _totalPointCostView;
}

- (STLOrderDetailTitlePriceView *)totalPartyPayCostView {
    if (!_totalPartyPayCostView) {
        _totalPartyPayCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"AmountPaid",nil)]];
    }
    return _totalPartyPayCostView;
}

- (STLOrderDetailTitlePriceView *)totalCodOrderCostView {
    if (!_totalCodOrderCostView) {
        _totalCodOrderCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"total",nil)]];
    }
    return _totalCodOrderCostView;
}


- (STLOrderDetailTitlePriceView *)totalCodOrderDistypeCostView {
    if (!_totalCodOrderDistypeCostView) {
        _totalCodOrderDistypeCostView = [[STLOrderDetailTitlePriceView alloc] initWithFrame:CGRectZero title:[NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"COD_discount",nil)]];
        _totalCodOrderDistypeCostView.priceLabel.textColor = [STLThemeColor col_B62B21];
    }
    return _totalCodOrderDistypeCostView;
}

- (UIView *)totalLineView {
    if (!_totalLineView) {
        _totalLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _totalLineView.backgroundColor = [STLThemeColor col_EEEEEE];
    }
    return _totalLineView;
}

- (UILabel *)reallyPayTotalLabel {
    if (!_reallyPayTotalLabel) {
        _reallyPayTotalLabel = [[UILabel alloc] init];
        _reallyPayTotalLabel.font = [UIFont boldSystemFontOfSize:14];
        _reallyPayTotalLabel.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _reallyPayTotalLabel.textAlignment = NSTextAlignmentRight;

        }
        _reallyPayTotalLabel.textColor = [STLThemeColor col_0D0D0D];
        _reallyPayTotalLabel.text = [NSString stringWithFormat:@"%@:",STLLocalizedString_(@"totalPayable",nil)];
    }
    return _reallyPayTotalLabel;
}

- (UILabel *)reallyTotapPayPriceLabel {
    if (!_reallyTotapPayPriceLabel) {
        _reallyTotapPayPriceLabel = [[UILabel alloc] init];
        _reallyTotapPayPriceLabel.font = [UIFont boldSystemFontOfSize:14];
        _reallyTotapPayPriceLabel.textAlignment = NSTextAlignmentRight;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _reallyTotapPayPriceLabel.textAlignment = NSTextAlignmentLeft;
        }
        _reallyTotapPayPriceLabel.textColor = [STLThemeColor col_0D0D0D];
    }
    return _reallyTotapPayPriceLabel;
}

- (UILabel *)reallyTaxLabel {
    if (!_reallyTaxLabel) {
        _reallyTaxLabel = [[UILabel alloc] init];
        _reallyTaxLabel.font = [UIFont systemFontOfSize:10];
        _reallyTaxLabel.textAlignment = NSTextAlignmentLeft;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _reallyTaxLabel.textAlignment = NSTextAlignmentRight;
        }
        _reallyTaxLabel.textColor = [STLThemeColor col_B2B2B2];
    }
    return _reallyTaxLabel;
}

- (UIView *)bottomSafeView {
    if (!_bottomSafeView) {
        _bottomSafeView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomSafeView.backgroundColor = [STLThemeColor stlWhiteColor];
    }
    return _bottomSafeView;
}



- (void) initView {
    
    
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.countDownView];
    [self.scrollView addSubview:self.topOrderStateView];
    [self.scrollView addSubview:self.containerView];
    
    [self.topOrderStateView addSubview:self.statusLabel];

    [self.containerView addSubview:self.waitCheckView];
    [self.waitCheckView addSubview:self.codCheckTipLabel];

    [self.containerView addSubview:self.trackingBottomView];
    [self.containerView addSubview:self.addressBottomView];
    [self.addressBottomView addSubview:self.addressView];


    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH - 24);
        make.height.mas_offset(69);
        make.top.mas_equalTo(self.scrollView.mas_top).mas_offset(12);
        make.left.mas_equalTo(self.scrollView.mas_left).mas_offset(12);
    }];
    
    
    [self.topOrderStateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(SCREEN_WIDTH - 24);
        make.height.mas_offset(51+10);
        make.top.mas_equalTo(self.scrollView.mas_top).mas_offset(12);
        make.left.mas_equalTo(self.scrollView.mas_left).mas_offset(12);
    }];
    

    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topOrderStateView.mas_centerY).mas_offset((-8));
        make.leading.mas_equalTo(self.topOrderStateView.mas_leading).offset(14);
    }];
        
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.scrollView.mas_bottom).mas_offset(-12);
        make.leading.mas_equalTo(self.scrollView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.scrollView.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.scrollView.mas_top).mas_offset(57);
        make.width.mas_equalTo(SCREEN_WIDTH - 24);
    }];
    
    // 提示
    [self.waitCheckView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.containerView);
        make.top.mas_equalTo(self.containerView.mas_top);
    }];
    
    [self.codCheckTipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waitCheckView.mas_top).mas_offset(13);
        make.bottom.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(-13);
        make.leading.mas_equalTo(self.waitCheckView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.waitCheckView.mas_trailing).offset(-14);
    }];
    
    // 物流
    [self.trackingBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(self.containerView.mas_leading);
        make.trailing.mas_equalTo(self.containerView.mas_trailing);
    }];
    
    
    // 地址信息
    [self.addressBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.trackingBottomView.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.containerView.mas_leading);
        make.trailing.mas_equalTo(self.containerView.mas_trailing);
    }];
    
    [self.addressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.addressBottomView).insets(UIEdgeInsetsMake(0, 0, 0, 0));
    }];
    
    
    [self.containerView addSubview:self.shippingBottomView];
    [self.shippingBottomView addSubview:self.orderNoView];
    [self.shippingBottomView addSubview:self.orderDateView];
    [self.shippingBottomView addSubview:self.orderShipMethodView];
    [self.shippingBottomView addSubview:self.orderPaymentMethodView];
    
    [self.shippingBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.addressBottomView.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.containerView.mas_leading);
        make.trailing.mas_equalTo(self.containerView.mas_trailing);
    }];

    [self.orderNoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shippingBottomView.mas_top).offset(8);
        make.leading.mas_equalTo(self.shippingBottomView.mas_leading);
        make.trailing.mas_equalTo(self.shippingBottomView.mas_trailing);
        make.height.mas_equalTo(36);
    }];
    
    [self.orderDateView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderNoView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.orderNoView);
        make.height.mas_equalTo(36);
    }];
    
    [self.orderShipMethodView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderDateView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.orderNoView);
        make.height.mas_equalTo(36);
    }];
    
    [self.orderPaymentMethodView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.orderShipMethodView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.orderNoView);
        make.height.mas_equalTo(36);
        make.bottom.mas_equalTo(self.shippingBottomView.mas_bottom).offset(-6);
    }];

    
    /*=======================商品模块=======================*/

    [self.containerView addSubview:self.goodsBottomView];
    [self.goodsBottomView addSubview:self.wareHouseTitleLabel];

    [self.goodsBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shippingBottomView.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(self.containerView.mas_leading);
        make.trailing.mas_equalTo(self.containerView.mas_trailing);
    }];

    [self.wareHouseTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsBottomView.mas_top).mas_offset(6);
        make.height.mas_equalTo(36);
        make.leading.mas_equalTo(self.goodsBottomView.mas_leading).mas_offset(14);
        make.trailing.mas_equalTo(self.goodsBottomView.mas_trailing).mas_offset(-14);
    }];
    
    /*=======================从这里开始是订单金额的明细=======================*/
    CGFloat detailHeight = 26;
   
    [self.containerView addSubview:self.totalBottomView];
    [self.totalBottomView addSubview:self.totalProdcetCostView];
    [self.totalBottomView addSubview:self.totalShippingCostView];
    [self.totalBottomView addSubview:self.totalDiscountCostView];
    [self.totalBottomView addSubview:self.totalTrackingCostView];
    [self.totalBottomView addSubview:self.totalInsuranceCostView];
    [self.totalBottomView addSubview:self.totalCodCostView];
    
    [self.totalBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.goodsBottomView.mas_bottom).offset(10);
        make.bottom.mas_equalTo(self.containerView.mas_bottom);
        make.leading.mas_equalTo(self.containerView.mas_leading);
        make.trailing.mas_equalTo(self.containerView.mas_trailing);
        make.width.mas_equalTo(SCREEN_WIDTH - 24);
    }];
    

    [self.totalProdcetCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalBottomView.mas_top).mas_offset(14);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];
    
    
    [self.totalShippingCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalProdcetCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_equalTo(detailHeight);
    }];

    [self.totalDiscountCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalShippingCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_equalTo(detailHeight);
    }];

    [self.totalTrackingCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalDiscountCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];

    [self.totalInsuranceCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalTrackingCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_equalTo(detailHeight);
    }];

    
    [self.totalCodCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalInsuranceCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];
    

    [self.totalBottomView addSubview:self.totalSavePriceCostView];
    [self.totalBottomView addSubview:self.totalCouponCostView];
    [self.totalBottomView addSubview:self.totalCoinDiscountCostView];
    [self.totalBottomView addSubview:self.totalPointCostView];
    [self.totalBottomView addSubview:self.totalPartyPayCostView];
    //COD商品取整类型和COD商品总价格
    [self.totalBottomView addSubview:self.totalCodOrderCostView];
    [self.totalBottomView addSubview:self.totalCodOrderDistypeCostView];
    
    [self.totalSavePriceCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalCodCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];
    
    
    [self.totalCouponCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalSavePriceCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_equalTo(detailHeight);
    }];
    
    
    [self.totalCoinDiscountCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalCouponCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];


    [self.totalPointCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalCoinDiscountCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];
    
    [self.totalPartyPayCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalPointCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];


    [self.totalCodOrderCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalPartyPayCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];


    [self.totalCodOrderDistypeCostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalCodOrderCostView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.totalBottomView);
        make.height.mas_offset(detailHeight);
    }];

    
    ///total 明细 UI
    //实际付款视图
    [self.totalBottomView addSubview:self.totalLineView];
    [self.totalBottomView addSubview:self.reallyPayTotalLabel];
    [self.totalBottomView addSubview:self.reallyTaxLabel];
    [self.totalBottomView addSubview:self.reallyTotapPayPriceLabel];

    [self.totalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.totalBottomView.mas_leading).offset(14);
        make.trailing.mas_equalTo(self.totalBottomView.mas_trailing).offset(-14);
        make.top.mas_equalTo(self.totalCodOrderDistypeCostView.mas_bottom);
        make.height.mas_equalTo(0.5);
    }];
    
    
    [self.reallyPayTotalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalLineView.mas_bottom).mas_offset(12);
        make.leading.mas_equalTo(self.totalBottomView.mas_leading).offset(14);
    }];


    [self.reallyTotapPayPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.totalBottomView.mas_trailing).offset(-14);
        make.centerY.mas_equalTo(self.reallyPayTotalLabel.mas_centerY);
    }];
    
    [self.reallyTaxLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.reallyPayTotalLabel.mas_bottom);
        make.leading.mas_equalTo(self.reallyPayTotalLabel.mas_leading);
        make.trailing.mas_equalTo(self.totalBottomView.mas_trailing).offset(-14);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.totalBottomView.mas_bottom).offset(-14);
    }];
    
    /*=======================从这里是订单明细UI的结尾=======================*/
    
    [self.view addSubview:self.payBottomView];
    [self.view addSubview:self.bottomSafeView];
    
    [self.bottomSafeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.view);
        if (kIS_IPHONEX) {
            make.height.mas_equalTo(STL_TABBAR_IPHONEX_H);
        } else {
            make.height.mas_equalTo(0);
        }
    }];
    
    [self.payBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.scrollView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(self.bottomSafeView.mas_top);
        make.height.mas_offset(0);
    }];
    
      
    /*空白页面*/
    UIView *VirtualView = [[UIView alloc] initWithFrame:self.view.bounds];
    VirtualView.backgroundColor = STLThemeColor.col_FFFFFF;
    [self.view addSubview:VirtualView];
    self.VirtualView = VirtualView;
}

/*========================================分割线======================================*/

#pragma mark - 取消COD订单

- (void)cancelOrderCOD {
        
    if (!self.orderDetailModel.selAddressModel) {
        @weakify(self)
        [self.myOrderlistModel requestOrderAddress:@{@"order_id":STLToString(self.orderDetailModel.orderId)} completion:^(NSDictionary *reuslt) {
            @strongify(self)
            if (STLJudgeNSDictionary(reuslt)) {
                AddressBookModel *addressModel = [AddressBookModel yy_modelWithJSON:reuslt];
                self.orderDetailModel.selAddressModel = addressModel;
                [self cancelOrderCOD];
            }
            
        } failure:^(id error) {
            
        }];
        return;
    }
    
    self.codMsgAlertView.order_flow_switch = @"0";
    if (self.orderDetailModel.orderStatus == OrderStateTypeWaitConfirm) {
        self.codMsgAlertView.order_flow_switch = self.orderDetailModel.order_flow_switch;
    }
    [self.codMsgAlertView show];
}

#pragma mark --STLBottomViewDelegate------------下方按钮的代理事件

#pragma mark -- 取消订单
- (void)clickCancel:(UIButton *)sender {
    
    [STLAnalytics analyticsGAEventWithName:@"order_action" parameters:@{
           @"screen_group":@"OrderDetail",
           @"action":@"Cancel_Button"}];
    
    if ([self.orderDetailModel.payCode isEqualToString:@"Cod"]) {
        if (self.orderDetailModel.orderStatus == OrderStateTypeWaitingForPayment || self.orderDetailModel.orderStatus == OrderStateTypeWaitConfirm) {
            [self cancelOrderCOD];
        }
        return;
    }

    NSArray *upperTitle = @[STLLocalizedString_(@"no",nil).uppercaseString,STLLocalizedString_(@"yes", nil).uppercaseString];
    NSArray *lowserTitle = @[STLLocalizedString_(@"no",nil),STLLocalizedString_(@"yes", nil)];

    @weakify(self)
    [STLAlertViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:STLLocalizedString_(@"cancelOreder", nil) buttonTitles:APP_TYPE == 3 ? lowserTitle : upperTitle buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
        @strongify(self)
        if (index == 1) {
            
            [STLAnalytics analyticsGAEventWithName:@"cancel_order" parameters:@{
                   @"screen_group":@"OrderDetail",
                   @"action":@"Cancel_Yes"}];
            
            [self.viewModel requestCancelOrder:self.orderDetailModel.orderId completion:^(id obj) {
                [self reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];
                [self orderCancelSuccess:YES normal:YES cancelReason:@""];
            } failure:^(id obj) {
                [self orderCancelSuccess:NO normal:YES cancelReason:@""];

            }];
        } else {
            [STLAnalytics analyticsGAEventWithName:@"cancel_order" parameters:@{
                   @"screen_group":@"OrderDetail",
                   @"action":@"Cancel_No"}];
        }
        
    }];
}

#pragma mark ---支付按钮
- (void)clickPayNow:(UIButton *)sender {
    
    [STLAnalytics analyticsGAEventWithName:@"order_action" parameters:@{
           @"screen_group":@"OrderDetail",
           @"action":@"Pay Now"}];
    
    if ([self.orderDetailModel.payCode isEqualToString:@"Cod"]) {
        if (self.orderDetailModel.orderStatus == OrderStateTypeWaitingForPayment || self.orderDetailModel.orderStatus == OrderStateTypeWaitConfirm) {
            [self payOrderCOD];
        }
        
        return;
    }
    
    [self.viewModel requestPayNowOrder:self.orderDetailModel.orderId completion:^(STLOrderInforModel *obj) {
        if (obj) {
            STLPayPalModule *module = [[STLPayPalModule alloc] init];
            STLCreateOrderModel *creatOrderModel = [[STLCreateOrderModel alloc] init];
            creatOrderModel.goodsList = self.orderDetailModel.goodsList;
            creatOrderModel.shippingFee = self.orderDetailModel.money_info.shipping_fee;
            creatOrderModel.couponCode = STLToString(self.orderDetailModel.coupon_code);
            creatOrderModel.payCode = self.orderDetailModel.payCode;
            
            STLOrderModel *orderModel = [[STLOrderModel alloc] init];
            orderModel.order_sn = self.orderDetailModel.orderSn;
            orderModel.order_amount = self.orderDetailModel.money_info.payable_amount;
            orderModel.url = obj.url;
            orderModel.pay_code = STLToString(self.orderDetailModel.payCode);
            
            creatOrderModel.orderList = @[orderModel];
            module.orderInfoModel = creatOrderModel;
            module.payModuleCase = ^(STLOrderPayStatus status){
                
                [self orderOnlePayResultAnalyticsState:status == STLOrderPayStatusDone];

                
                switch (status) {
                    case STLOrderPayStatusUnknown:
                    {
                        /*没做任何处理*/
                    }
                        break;
                        /*取消支付后返回订单详情页弹出信息提示*/
                    case STLOrderPayStatusCancel:
                    {
                        NSString *message = STLLocalizedString_(@"paymentCancel", nil);
                        [self showAlertViewWithTitle:STLLocalizedString_(@"payCancel", nil) Message:message];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefrshUserInfo object:nil];
                    }
                        break;
                        /*成功支付后展示的页面*/
                    case STLOrderPayStatusDone:
                    {
                        STLOrderFinishCtrl *orderFinishVC = [STLOrderFinishCtrl new];
                        orderFinishVC.createOrderModel = creatOrderModel;
                        orderFinishVC.isFromOrder = YES;
                        @weakify(self)
                        orderFinishVC.block = ^{
                            @strongify(self)
                            /*刷新当前订单详情页的数据*/
                            [self reloadData];
                            /*刷新订单列表数据*/
                            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];
                           
                        };
                        [self.navigationController pushViewController:orderFinishVC animated:YES];
                    }
                        break;
                        /*支付失败*/
                    case STLOrderPayStatusFailed:
                    {
                        NSString *message = STLLocalizedString_(@"paymentFailed", nil);
                        [self showAlertViewWithTitle:STLLocalizedString_(@"failedPay", nil) Message:message];
                    }
                        break;
                    default:
                        break;
                }
                

            };
            [module handlePay];
            self.payModule = module;
        } else {
            [self orderOnlePayResultAnalyticsState:NO];
        }
    } failure:^(id obj) {
        
    }];
}



#pragma mark 再次购买
- (void)clickBuyAgain:(UIButton *)sender {

    
    if (self.orderDetailModel.orderStatus == OrderStateTypeWaitingForPayment
        || self.orderDetailModel.orderStatus == OrderStateTypeDeductionFailed || self.orderDetailModel.orderStatus == OrderStateTypeWaitConfirm) {
        
        [STLAnalytics analyticsGAEventWithName:@"order_action" parameters:@{
               @"screen_group":@"OrderDetail",
               @"action":@"Cancel_Repurchase"}];
        
        STLAlertTempView *orderCancelAddToCart = [[STLAlertTempView alloc] initWithFrame:CGRectZero message:STLLocalizedString_(@"order_cancel_buy_msg", nil) buttonTitle:STLLocalizedString_(@"order_cancel_buy_btn", nil)];
        
        [orderCancelAddToCart showAlert];
        
        @weakify(self)
        orderCancelAddToCart.confirmBlock = ^{
            @strongify(self)
            [self cancelOrderAndAddCart];
        };
        return;
    }
    
    [STLAnalytics analyticsGAEventWithName:@"order_action" parameters:@{
           @"screen_group":@"OrderDetail",
           @"action":@"Repurchase_Button"}];
    [self buyAgainOrderRefresh:NO];
}

- (void)buyAgainOrderRefresh:(BOOL)refresh {
    
    
    STLOrderBuyAgainApi *buyAgainApi = [[STLOrderBuyAgainApi alloc] initWithOrderId:STLToString(self.orderId)];
    [HUDManager showHUD:MBProgressHUDModeIndeterminate hide:NO afterDelay:0 enabled:NO message:nil];
    
    @weakify(self)
    [buyAgainApi startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
        @strongify(self)
        
        [HUDManager hiddenHUD];
        NSDictionary *buyAgainDic = [NSStringTool desEncrypt:request];
        
        
        BOOL state = NO;
        if ([buyAgainDic[kStatusCode] integerValue] == kStatusCode_200) {
            state = YES;
            NSDictionary *resultDic = buyAgainDic[kResult];
            STLCartViewCtrl *ctrl = [[STLCartViewCtrl alloc] init];
            ctrl.buyAgainAlert = [resultDic[@"needAppAlert"] boolValue];            
            [self.navigationController pushViewController:ctrl animated:YES];
        }else{
            NSString *message = buyAgainDic[kMessagKey];
            if (message.length > 0) {
                [HUDManager showHUDWithMessage:message];
            }
        }
        
        [STLAnalytics analyticsSensorsEventWithName:@"AddToCartOrder" parameters:@{@"is_success":@(state),@"order_sn":STLToString(self.orderDetailModel.orderSn)}];
        
        [self analyticsAddToCartIsSuccess:state];
        [self repurchaseAnalytics:state];
        if(refresh) {
            [self reloadData];
        }
        
    } failure:^(__kindof STLBaseRequest *request, NSError *error) {
        @strongify(self)
        [HUDManager hiddenHUD];
        [self repurchaseAnalytics:NO];
        if(refresh) {
            [self reloadData];
        }
    }];
}

- (void)analyticsAddToCartIsSuccess:(BOOL)isSuccess{
    
    [self.orderDetailModel.goodsList enumerateObjectsUsingBlock:^(AccountOrdersDetailGoodsModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSDictionary *sensorsDic = @{@"referrer":[UIViewController currentTopViewControllerPageName],
                                     @"goods_sn":STLToString(obj.goods_sn),
                                     @"goods_name":STLToString(obj.goodsName),
                                     @"cat_id":STLToString(obj.cat_id),
                                     @"cat_name":STLToString(obj.cat_name),
                                     @"item_type":@"normal",
                                     @"original_price":@([STLToString(obj.market_price) floatValue]),
                                     @"present_price":@([STLToString(obj.goods_price) floatValue]),
                                     @"goods_quantity":@([STLToString(obj.goodsNumber) integerValue]),
                                     @"currency":@"USD",
                                     @"shoppingcart_entrance":@"repurchase",
                                     @"is_success"     : @(isSuccess)
        };
                                     
        [STLAnalytics analyticsSensorsEventWithName:@"AddToCart" parameters:sensorsDic];
        [STLAnalytics analyticsSensorsEventFlush];
        
        [DotApi addToCart];
    }];
}

///订单挽留再次购买
- (void)cancelOrderAndAddCart {
    
    if ([self.orderDetailModel.payCode isEqualToString:@"Cod"]) {
        
        @weakify(self)
        [self codCancelRequest:@"0" cancelResult:@"" completion:^(id obj) {
            @strongify(self)
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];
            [self buyAgainOrderRefresh:YES];
        } failure:^(id obj) {
            @strongify(self)
            [self repurchaseAnalytics:NO];
        }];
        
    } else {
        @weakify(self)
        [self.viewModel requestCancelOrder:self.orderDetailModel.orderId completion:^(id obj) {
            @strongify(self)
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];
            [self orderCancelSuccess:YES normal:NO cancelReason:@""];
            [self buyAgainOrderRefresh:YES];
        } failure:^(id obj) {
            @strongify(self)
            [self orderCancelSuccess:NO normal:NO cancelReason:@""];
            [self repurchaseAnalytics:NO];
        }];
    }
}
#pragma mark 评论
- (void)clickReview:(UIButton *)sender {

    STLOrderReviewCtrl *orderReviewCtrl = [[STLOrderReviewCtrl alloc] init];
    orderReviewCtrl.orderId = self.orderId;
    [self.navigationController pushViewController:orderReviewCtrl animated:YES];
}


#pragma mark 支付订单

- (void)payOrderCOD {
    
    if (!self.orderDetailModel.selAddressModel) {
        @weakify(self)
        [self.myOrderlistModel requestOrderAddress:@{@"order_id":STLToString(self.orderDetailModel.orderId)} completion:^(NSDictionary *reuslt) {
            @strongify(self)
            if (STLJudgeNSDictionary(reuslt)) {
                AddressBookModel *addressModel = [AddressBookModel yy_modelWithJSON:reuslt];
                self.orderDetailModel.selAddressModel = addressModel;
                [self payOrderCOD];
            }
            
        } failure:^(id error) {
            
        }];
        return;
    }
    
    ///弹出输入验证码框
    UIWindow *keyWindow = [SHAREDAPP keyWindow];
    CGRect rect = CGRectMake(0, kSCREEN_BAR_HEIGHT, SCREEN_WIDTH, SCREEN_HEIGHT-kSCREEN_BAR_HEIGHT);
    self.smsVerifyView = [[STLSMSVerifyView alloc] initWithFrame:rect];
    NSString *userPhoneNum = [NSString stringWithFormat:@"+%@ %@%@",self.orderDetailModel.selAddressModel.countryCode,STLToString(self.orderDetailModel.selAddressModel.phoneHead), self.orderDetailModel.selAddressModel.phone];
    NSString *paymentAmount = self.orderDetailModel.money_info.payable_amount_converted_symbol;
    
    BOOL codISAB = [self.orderDetailModel.order_flow_switch integerValue];
    if (codISAB && self.orderDetailModel.orderStatus == OrderStateTypeWaitConfirm) {
        ///1.4.6 根据配置与AB流量配置
        BOOL is_cod_sms_opend = [[BDAutoTrack ABTestConfigValueForKey:@"is_cod_sms_opend" defaultValue:@(YES)] boolValue];
        BOOL goWithNewProcess = AccountManager.sharedManager.sysIniModel.cod_confirm_sms_open && AccountManager.sharedManager.sysIniModel.cod_confirm_sms_abtest && is_cod_sms_opend;
        if (goWithNewProcess) {
            [self confirmCODWithOutSMSNew:paymentAmount phoneMsg:userPhoneNum];
            return;
        }
        [self confirmCODWithOutSMS:paymentAmount phoneMsg:userPhoneNum];
        
        return;
    }
    
    NSDictionary *sensorsDic = @{@"order_sn":STLToString(self.orderDetailModel.orderSn),
    };
    [STLAnalytics analyticsSensorsEventWithName:@"CodPaymentPopup" parameters:sensorsDic];
    
    [self.smsVerifyView setUserPhoneNum:userPhoneNum paymentAmount:paymentAmount];
    @weakify(self)
    
    self.smsVerifyView.verifyCodeAnalyticBlock = ^(BOOL hasCode) {
        @strongify(self)
        [self conConfirmAnalytics:hasCode];
    };
    
    self.smsVerifyView.sendSMSRequestBlock = ^{
        @strongify(self)
        [self.infoViewModel requestSMSVerifyNetwork:STLToString(self.orderDetailModel.orderId) completion:^(id obj) {
            if (obj) {
                [[NSNotificationCenter defaultCenter] postNotificationName:SEND_SMS_SUCCESS object:obj];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefrshUserInfo object:nil];
            } else {
                STLLog(@"❌❌❌Send SMS验证出错.手机号码错误或者PHP接口出错.");
                [[NSNotificationCenter defaultCenter] postNotificationName:SEND_SMS_FAIL object:nil];
            }
        } failure:^(id obj) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SEND_SMS_FAIL object:nil];
        }];
    };
    
    self.smsVerifyView.verifyCodeRequestBlock = ^(NSString *code){
        @strongify(self)
        @weakify(self)
        [self.myOrderlistModel requestCodOrderConfirm:@{@"order_id":STLToString(self.orderDetailModel.orderId),
                                       @"code":STLToString(code),
                                       @"address_id":STLToString(self.orderDetailModel.selAddressModel.addressId)
        } completion:^(BOOL flag) {
            @strongify(self)
            if (flag) {
                [self.smsVerifyView coolse];
                [self.codSuccessView show];
                [self reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];

            }
            [self paySuccesWithProductCod:flag];

        } failure:^(id error) {
            [self paySuccesWithProductCod:NO];

        }];
        
    };
    
    self.smsVerifyView.closeSMSBlock = ^{
        @strongify(self)
        @weakify(self)
        
        NSMutableAttributedString *codAttr = [[NSMutableAttributedString alloc] initWithString:STLLocalizedString_(@"Cod_Cancel_OverTime_Tip", nil)];
        
        NSRange conatchEmailRange = [codAttr.string rangeOfString:STLLocalizedString_(@"Cod_Tip_24_hour", nil)];
        
        
        if (conatchEmailRange.location != NSNotFound) {
            [codAttr yy_setTextHighlightRange:conatchEmailRange
                                             color:[STLThemeColor col_FF5875]
                                   backgroundColor:[UIColor clearColor]
                                         tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
                                             
                                         }];
            
        }
        
        
        [STLAlertViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:codAttr buttonTitles:@[STLLocalizedString_(@"Continue_Cancel",nil).uppercaseString,STLLocalizedString_(@"Continue_To_Verify",nil).uppercaseString] buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
            @strongify(self)
            if (index == 1) {
                [self payOrderCOD];
            }
            
        }];
    };
    
    [keyWindow addSubview:self.smsVerifyView];
}


-(void)confirmCODWithSMS:(NSString *)paymentAmount phoneMsg:(NSString*)userPhoneNum{
    CODVierifyViewController *vc = [[CODVierifyViewController alloc] init];
    NSArray* phoneArr = [userPhoneNum componentsSeparatedByString:@" "];
    vc.phoneCode = phoneArr.firstObject;
    vc.orderId = STLToString(STLToString(self.orderDetailModel.orderId));
    vc.orderSn = STLToString(self.orderDetailModel.orderSn);
    vc.phone = phoneArr.lastObject;
    vc.amountStr = paymentAmount;
    vc.success = ^(BOOL success, NSString* confirm_method) {
        [self reloadData];
        if (self.callback) {
            self.callback();
        }
        self.confirmMethod = confirm_method;
        if (success) {
            [self paySuccesWithProductCod:success];
        }
    };
    [self presentViewController:vc animated:true completion:nil];
}

-(void)confirmCODWithOutSMSNew:(NSString *)paymentAmount phoneMsg:(NSString*)userPhoneNum{
    
    CODConfirmWithoutSmsNewViewController *vc = [[CODConfirmWithoutSmsNewViewController alloc] init];
    NSArray* phoneArr = [userPhoneNum componentsSeparatedByString:@" "];
    vc.phoneCode = phoneArr.firstObject;
    vc.orderId = STLToString(STLToString(self.orderDetailModel.orderId));
    vc.orderSn =  STLToString(self.orderDetailModel.orderSn);
    vc.phone = phoneArr.lastObject;
    vc.amountStr = paymentAmount;
    
    vc.success = ^(BOOL success,NSString* confirm_method) {
        
        if (self.callback) {
            self.callback();
        }
        self.confirmMethod = confirm_method;
        if (success) {
            [self paySuccesWithProductCod:success];
        }
        
        [self reloadData];
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];
    };
    
    
    vc.jumpToSMS = ^(NSString * _Nonnull paymentAmount, NSString * _Nonnull userPhoneNum) {
        [self confirmCODWithSMS:paymentAmount phoneMsg:userPhoneNum];
    };
    
    [self presentViewController:vc animated:true completion:nil];
}

-(void)confirmCODWithOutSMS:(NSString *)paymentAmount phoneMsg:(NSString*)userPhoneNum{
    STLOrderCodConfirmView *codConfirmView = [[STLOrderCodConfirmView alloc] initWithFrame:CGRectZero titleMsg:paymentAmount phoneMsg:userPhoneNum];
    [codConfirmView show];
    
    NSDictionary *sensorsDic = @{@"order_sn":STLToString(self.orderDetailModel.orderSn),
    };
    [STLAnalytics analyticsSensorsEventWithName:@"CodPaymentPopup" parameters:sensorsDic];
    
    
    @weakify(self)
    @weakify(codConfirmView)
    codConfirmView.confirmRequestBlock = ^{
        @strongify(self)
        @strongify(codConfirmView)
        [self conConfirmAnalytics:YES];
        @weakify(self)
        @weakify(codConfirmView)
        [self.myOrderlistModel requestCodOrderChangeStatusConfirm:@{@"order_id":STLToString(self.orderDetailModel.orderId)} completion:^(BOOL flag) {
            @strongify(self)
            @strongify(codConfirmView)
            if (flag) {
                [codConfirmView dismiss];
                [self reloadData];
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];

            }
            [self paySuccesWithProductCod:flag];

        } failure:^(id error) {
            [self paySuccesWithProductCod:NO];

        }];
    };
}



/*========================================分割线======================================*/

#pragma mark - 请求数据
- (void)reloadData {
    /*请求订单数据*/
    @weakify(self);
    [self.viewModel requestNetwork:self.orderId completion:^(AccountMyOrdersDetailModel *obj) {
        /*赋值外部变量->数据*/
        @strongify(self);
        [self handleOrdersDetailModel:obj];
        
    } failure:^(id obj) {
        
    }];
    
    
}

- (void)handleOrdersDetailModel:(AccountMyOrdersDetailModel *)obj {
    if (!self) {return;}
    if (!obj) {
        return;
    }
    
    /*物流状态是动态创建的->防止多次调用- (void)reloadData这个方法会多次创建*/
    [self.trackingBottomView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIView class]]) {
            [obj mas_remakeConstraints:^(MASConstraintMaker *make) {}];
            [obj removeFromSuperview];
        }
    }];
    [self.goodsBottomView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (![obj isKindOfClass:[UILabel class]] && [obj isKindOfClass:[UIView class]]) {
            [obj mas_remakeConstraints:^(MASConstraintMaker *make) {}];
            [obj removeFromSuperview];
        }
    }];
    
    
    

    self.orderDetailModel = obj;
    /*数据请求成功后移除空白页面*/
    [self.VirtualView removeFromSuperview];
    self.payBottomView.cancelBtn.hidden = YES;
    self.payBottomView.payNowBtn.hidden = YES;
    self.payBottomView.buyAgainBtn.hidden = YES;
    self.payBottomView.reviewBtn.hidden = YES;
    self.countDownView.hidden = YES;
    self.topOrderStateView.hidden = YES;
    
    self.totalCodOrderCostView.hidden = YES;
    self.totalCodOrderDistypeCostView.hidden = YES;
    self.totalTrackingCostView.hidden = YES;
    self.totalCodCostView.hidden = YES;
    self.totalInsuranceCostView.hidden = YES;
    self.totalSavePriceCostView.hidden = YES;
    self.totalCoinDiscountCostView.hidden = YES;
    self.totalCouponCostView.hidden = YES;
    self.totalPointCostView.hidden = YES;
    self.totalPartyPayCostView.hidden = YES;
    self.totalDiscountCostView.hidden = YES;
    self.reallyTaxLabel.hidden = YES;
    self.topOrderStateView.backgroundColor = [STLThemeColor col_60CD8E];
    [self.countDownView updateTipsTypeMsg:STLLocalizedString_(@"Remaining_payment_time", nil)];
    
    [self.payBottomView.buyAgainBtn setBackgroundColor:[STLThemeColor stlClearColor]];
    [self.payBottomView.buyAgainBtn setTitleColor:[STLThemeColor col_0D0D0D] forState:UIControlStateNormal];
    
    //普通再次购买标识
    self.payBottomView.buyAgainBtn.sensor_element_id = @"repurchase_complete_button";
    BOOL hasPay = NO;
    BOOL hasReview = NO;
    BOOL hasBuyAgain = NO;
    BOOL hasCancel = NO;
    
    CGFloat payBottomViewH = 0;
    NSString *formatStrminus = [SystemConfigUtils isRightToLeftShow] ? @"%@-" : @"-%@";
    NSString *formatStrAdd = [SystemConfigUtils isRightToLeftShow] ? @"%@+" : @"+%@";
    
    NSString *taxStr = STLUserDefaultsGet(@"tax");
    NSLog(@"获取到的含税信息：%@", taxStr);
    if (taxStr.length) {
        self.reallyTaxLabel.hidden = NO;
        self.reallyTaxLabel.text = [NSString stringWithFormat:@"(%@)", taxStr];
        [self.reallyTaxLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(12);
        }];
    } else {
        [self.reallyTaxLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
    }
    
    
    self.codCheckTipLabel.text = @"";
    if (!STLIsEmptyString(self.orderDetailModel.order_remark)) {
        self.codCheckTipLabel.text = self.orderDetailModel.order_remark;

        [self.codCheckTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.waitCheckView.mas_top).offset(@13);
            make.bottom.mas_equalTo(self.waitCheckView.mas_bottom).offset(@(-13));
        }];
        
        // 物流
        [self.trackingBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(8);
        }];
    } else {
        
        [self.codCheckTipLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.waitCheckView.mas_top).offset(@0);
            make.bottom.mas_equalTo(self.waitCheckView.mas_bottom).offset(@(0));
        }];
        
        // 物流
        [self.trackingBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(0);
        }];
    }
    
    [self.payBottomView.payNowBtn setTitle:STLLocalizedString_(@"payNow", nil).uppercaseString forState:UIControlStateNormal];
    if ([obj.payCode isEqualToString:@"Cod"]) {
        //self.totalCodPrice.text = obj.money_info.cod_cost_converted_symbol;
        self.totalCodCostView.priceLabel.text = STLToString(obj.money_info.cod_cost_converted_symbol);
        ///如果是cod商品,则增加取整类型和取整金额
        NSString *codOrderDistypeText = @"";
        NSString *codOrderDisValueText = @"";
        
        if ([obj.codFractionsType containsString:@"1"]) {
            codOrderDistypeText = [NSString stringWithFormat:@"%@ :", STLLocalizedString_(@"Air_cargo_insurance", nil)];
            codOrderDisValueText = [NSString stringWithFormat:formatStrAdd, obj.money_info.cod_discount_converted_symbol];
            self.totalCodOrderCostView.hidden = NO;
            self.totalCodOrderDistypeCostView.hidden = NO;
        }else if([obj.codFractionsType containsString:@"2"]){
            codOrderDistypeText = [NSString stringWithFormat:@"%@ :", STLLocalizedString_(@"COD_discount", nil)];
            codOrderDisValueText = [NSString stringWithFormat:formatStrminus, obj.money_info.cod_discount_converted_symbol];
            self.totalCodOrderCostView.hidden = NO;
            self.totalCodOrderDistypeCostView.hidden = NO;
        }else{
            ///如果不需要取整的商品，隐藏取整提示栏
            [self.totalCodOrderCostView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_offset(0);
            }];
            [self.totalCodOrderDistypeCostView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.height.mas_offset(0);
            }];
        }
        self.totalCodOrderDistypeCostView.titleLabel.text = codOrderDistypeText;
        self.totalCodOrderDistypeCostView.priceLabel.text = codOrderDisValueText;
        
        // cod 总价
        self.totalCodOrderCostView.priceLabel.text = obj.money_info.order_amount_converted_symbol;
        // 订单 总价
        self.reallyTotapPayPriceLabel.text = [NSString stringWithFormat:@"%@",obj.money_info.payable_amount_converted_symbol];
        
        if (obj.orderStatus == OrderStateTypeWaitingForPayment || obj.orderStatus == OrderStateTypeWaitConfirm) {
            hasPay = YES;
            hasCancel = YES;
            hasBuyAgain = YES;

            //订单挽留再次购买标识
            self.payBottomView.buyAgainBtn.sensor_element_id = @"repurchase_button";
            
            [self.payBottomView.payNowBtn setTitle:STLLocalizedString_(@"verify", nil) forState:UIControlStateNormal];
            if (obj.orderStatus == OrderStateTypeWaitConfirm) {
                if (APP_TYPE == 3) {
                    [self.payBottomView.payNowBtn setTitle:STLLocalizedString_(@"confirm", nil) forState:UIControlStateNormal];
                } else {
                    [self.payBottomView.payNowBtn setTitle:STLLocalizedString_(@"confirm", nil).uppercaseString forState:UIControlStateNormal];
                }
                [self.countDownView updateTipsTypeMsg:STLLocalizedString_(@"Remaining_confirm_time", nil)];
            }
            
        } else if (obj.orderStatus == OrderStateTypeCancelled
            || obj.orderStatus == OrderStateTypeRefunded) {// 取消、退款
            hasBuyAgain = YES;
            
            self.topOrderStateView.backgroundColor = [STLThemeColor col_CCCCCC];

            
        } else if (obj.orderStatus == OrderStateTypePaid
                   || obj.orderStatus == OrderStateTypeProcessing
                   || obj.orderStatus == OrderStateTypeShippedOut
                   || obj.orderStatus == OrderStateTypeDelivered
                   || obj.orderStatus == OrderStateTypePartialOrderShipped) {// 已付款、备货、完全发货、已收到货、部分发货
            
            if (obj.orderStatus == OrderStateTypeShippedOut
                || obj.orderStatus == OrderStateTypeDelivered || obj.orderStatus == OrderStateTypePartialOrderShipped) {//部分发货，完全发货、已收到货
                hasBuyAgain = YES;
                
                ///1.4.6 review 单独处理 //收到货才能评论
                if (obj.orderStatus == OrderStateTypeDelivered) {//完全发货、已收到货
                    hasReview = YES;
                }
            }
        } else if (obj.orderStatus == OrderStateTypeWatingAudit) {//cod待审核
            
        }
        
    } else {
        
        [self.totalCodOrderCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
        [self.totalCodOrderDistypeCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
        
        self.reallyTotapPayPriceLabel.text = [NSString stringWithFormat:@"%@",obj.money_info.payable_amount_converted_symbol];
        
        if (obj.orderStatus == OrderStateTypeCancelled
            || obj.orderStatus == OrderStateTypeRefunded) {// 取消、退款
            hasBuyAgain = YES;
            self.topOrderStateView.backgroundColor = [STLThemeColor col_CCCCCC];

        } else if (obj.orderStatus == OrderStateTypeWaitingForPayment
                   || obj.orderStatus == OrderStateTypePartialOrderPaid
                   || obj.orderStatus == OrderStateTypeDeductionFailed) {//未付款、部分付款、扣款失败
            
            hasPay = YES;
            if (obj.orderStatus == OrderStateTypeWaitingForPayment
                || obj.orderStatus == OrderStateTypeDeductionFailed) {//未付款、扣款失败
                hasCancel = YES;
                hasBuyAgain = YES;
                //订单挽留再次购买标识
                self.payBottomView.buyAgainBtn.sensor_element_id = @"repurchase_button";

            }
        } else if (obj.orderStatus == OrderStateTypePaid
                   || obj.orderStatus == OrderStateTypeProcessing
                   || obj.orderStatus == OrderStateTypeShippedOut
                   || obj.orderStatus == OrderStateTypeDelivered
                   || obj.orderStatus == OrderStateTypePartialOrderShipped) {// 已付款、备货、完全发货、已收到货、部分发货
            
            if (obj.orderStatus == OrderStateTypeShippedOut
                || obj.orderStatus == OrderStateTypeDelivered || obj.orderStatus == OrderStateTypePartialOrderShipped) {//部分发货，完全发货、已收到货
                hasBuyAgain = YES;
                
                ///1.4.6 review 单独处理 //收到货才能评论
                if (obj.orderStatus == OrderStateTypeDelivered) {//完全发货、已收到货
                    hasReview = YES;
                }
            }
        }

    }
    
    if (self.orderDetailModel.orderStatus == OrderStateTypeWaitingForPayment
               || self.orderDetailModel.orderStatus == OrderStateTypePaying
               || self.orderDetailModel.orderStatus == OrderStateTypePartialOrderPaid
               || self.orderDetailModel.orderStatus == OrderStateTypeWaitConfirm
        || self.orderDetailModel.orderStatus == OrderStateTypeDeductionFailed
        || self.orderDetailModel.orderStatus == OrderStateTypeWatingAudit) {
        
        self.topOrderStateView.backgroundColor = [STLThemeColor col_B62B21];

    }
    /*订单号*/
//    self.orderNoLabel.text = [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"orderNo",nil),obj.orderSn];
    self.orderNoView.descLabel.text = STLToString(obj.orderSn);
    
    /*订单状态*/
    self.statusLabel.text = [NSString stringWithFormat:@"%@",STLToString(obj.orderStatusValue)];

    ///订单未支付状态 新增倒计时状态到视图顶部
    if (self.orderDetailModel.expiresTime > 0 && (self.orderDetailModel.orderStatus == OrderStateTypeWaitingForPayment || self.orderDetailModel.orderStatus == OrderStateTypeWaitConfirm)) {

        self.topOrderStateView.hidden = YES;
        self.countDownView.hidden = NO;
        self.countDownView.title = obj.orderStatusValue;
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.scrollView.mas_top).mas_offset(75);
        }];
        [self.countDownView handleCountDownView:self.orderDetailModel.expiresTime];
    } else {
        self.topOrderStateView.hidden = NO;
        self.countDownView.hidden = YES;
        
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make){
            make.top.mas_equalTo(self.scrollView.mas_top).mas_offset(57);
        }];
    }
    [self handleTrackInfor:obj];
    
    /*将地址信息栏的数据装成model进行赋值*/
    AddressBookModel *bookModel = [[AddressBookModel alloc] init];
    bookModel.firstName = obj.firstName;
    bookModel.lastName = obj.lastName;
    bookModel.phone = obj.phone;
    bookModel.streetMore = obj.streetMore;
    bookModel.street = obj.street;
    bookModel.city = obj.city;
    bookModel.country = obj.country;
    bookModel.zipPostNumber = obj.zip;
    bookModel.state = obj.province;
    bookModel.district = STLToString(obj.district);
    self.addressView.addressModel = bookModel;
    
    /*购买商品列表创建*/
    [self handleGoodsImgae:obj];
    
    /*物流方式*/
//    self.shipMethodLabel.text = [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"shipMethod",nil),STLToString(obj.shippingName)];
    self.orderShipMethodView.descLabel.text = STLToString(obj.shippingName);
    
    /*支付方式*/
//    self.paymentMethodLabel.text = [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"paymentMethod",nil),STLToString(obj.payName)];
    self.orderPaymentMethodView.descLabel.text = STLToString(obj.payName);
    
    /*订单时间*/
    self.orderDateView.descLabel.text = STLToString(obj.orderDate);

//    if ([SystemConfigUtils isRightToLeftShow]) {
//        self.orderDate.text = [NSString stringWithFormat:@"%@ : %@",STLToString(obj.orderDate),STLLocalizedString_(@"orderDate",nil)];
//
//    } else {
//        self.orderDate.text = [NSString stringWithFormat:@"%@ : %@",STLLocalizedString_(@"orderDate",nil),STLToString(obj.orderDate)];
//    }
    
    /*商品总价*/
//    self.totalSubtotalPrice.text = STLToString(obj.money_info.goods_amount_converted_symbol);
    self.totalProdcetCostView.priceLabel.text = STLToString(obj.money_info.goods_amount_converted_symbol);
    
    /*物流价格*/
//    self.totalShippingCostPrice.text = STLToString(obj.money_info.shipping_fee_converted_symbol);
    self.totalShippingCostView.priceLabel.text = STLToString(obj.money_info.shipping_fee_converted_symbol);
    
    /*物流保障金->判断如果不保障的话则不显示*/
//    if ([self isZero:obj.trackingCost]) {
        [self.totalTrackingCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
//    }else {
//        self.totalTrackingPrice.text = STLToString(obj.trackingCost);
//    }
    
    //COD COST
    if ([self isZero:obj.money_info.cod_cost]) {
        [self.totalCodCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    }else{
        self.totalCodCostView.hidden = NO;
        self.totalCodCostView.priceLabel.text = STLToString(obj.money_info.cod_cost_converted_symbol);
    }
    
    /*运费险费用->判断运费险为0的话则不显示*/
    if ( [self isZero:obj.money_info.shipping_insurance_converted]) {
        [self.totalInsuranceCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    }else {
        self.totalInsuranceCostView.hidden = NO;
        self.totalInsuranceCostView.priceLabel.text = STLToString(obj.money_info.shipping_insurance_converted_symbol);
    }
    
    if ([self isZero:obj.money_info.activity_save]) {
        [self.totalSavePriceCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    }else{
        self.totalSavePriceCostView.hidden = NO;
        self.totalSavePriceCostView.priceLabel.text = [NSString stringWithFormat:formatStrminus,STLToString(obj.money_info.activity_save_converted_symbol)];
    }
    
    //金币金额
    if ([self isZero:obj.money_info.coin_save]) {
        [self.totalCoinDiscountCostView mas_updateConstraints:^(MASConstraintMaker *make) {
               make.height.mas_offset(0);
        }];
    } else {
        self.totalCoinDiscountCostView.hidden = NO;
        self.totalCoinDiscountCostView.priceLabel.text = [NSString stringWithFormat:formatStrminus,STLToString(obj.money_info.coin_save_converted_symbol)];
    }
    
    /*积分以及优惠券直减价格*/
    if ([self isZero:obj.money_info.coupon_save]) {
        [self.totalCouponCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    } else {
        self.totalCouponCostView.hidden = NO;
        self.totalCouponCostView.priceLabel.text = [NSString stringWithFormat:formatStrminus,STLToString(obj.money_info.coupon_save_converted_symbol)];
    }
    
    if ([self isZero:obj.pointMoney]) {
        [self.totalPointCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    } else {
        self.totalPointCostView.hidden = NO;
        self.totalPointCostView.priceLabel.text = [NSString stringWithFormat:formatStrminus,STLToString(obj.pointMoney)];
    }
    
//    if (obj.orderStatus == OrderStateTypePartialOrderPaid){
//        if ([self isZero:obj.paid_amount]) {
//            [self.totalPartyPayCostView mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_offset(0);
//            }];
//        }else{
//            self.totalPartyPayCostView.pirceLabel.text = [NSString stringWithFormat:@"-%@",STLToString(obj.paid_amount)];
//        }
//    }else{
        [self.totalPartyPayCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
//    }
    
    //支付方式优惠金额
    if ([self isZero:obj.money_info.pay_discount_amount]) {
        [self.totalDiscountCostView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_offset(0);
        }];
    } else {
        self.totalDiscountCostView.hidden = NO;
        self.totalDiscountCostView.priceLabel.text = [NSString stringWithFormat:formatStrminus,STLToString(obj.money_info.pay_discount_amount_converted_symbol)];
    }
    
    if (hasBuyAgain || hasReview || hasPay || hasCancel) {
        payBottomViewH = 48;
    }
    
    self.payBottomView.hidden = payBottomViewH > 0 ? NO : YES;
    [self.payBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(payBottomViewH);
    }];

    if (payBottomViewH > 0) {


        self.payBottomView.payNowBtn.hidden = !hasPay;
        self.payBottomView.reviewBtn.hidden = !hasReview;
        self.payBottomView.buyAgainBtn.hidden = !hasBuyAgain;
        self.payBottomView.cancelBtn.hidden = !hasCancel;

        NSMutableArray *btnMutableArray = [NSMutableArray array];
        if (hasPay) {
            [btnMutableArray addObject:self.payBottomView.payNowBtn];
        }
        if (hasBuyAgain) {
            [btnMutableArray addObject:self.payBottomView.buyAgainBtn];
        }
        if (hasReview) {
            [btnMutableArray addObject:self.payBottomView.reviewBtn];
        }
        if (hasCancel) {
            [btnMutableArray addObject:self.payBottomView.cancelBtn];
        }

        UIButton *tempBtn;
        for (UIButton *eventBtn in btnMutableArray) {
            if (tempBtn) {
                [eventBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.payBottomView.mas_centerY);
                    make.trailing.mas_equalTo(tempBtn.mas_leading).offset(-12);
                    make.height.mas_equalTo(@36);
                }];
            } else {
                [eventBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.centerY.mas_equalTo(self.payBottomView.mas_centerY);
                    make.trailing.mas_equalTo(self.payBottomView.mas_trailing).offset(-12);
                    make.height.mas_equalTo(@36);
                }];
            }
            tempBtn = eventBtn;
        }
        
        if (hasBuyAgain && !hasPay) {
            [self.payBottomView.buyAgainBtn setBackgroundColor:[STLThemeColor col_0D0D0D]];
            [self.payBottomView.buyAgainBtn setTitleColor:[STLThemeColor stlWhiteColor] forState:UIControlStateNormal];
        }
        
    }
}

/*取消支付信息提示*/
- (void)showAlertViewWithTitle:(NSString *)title Message:(NSString *)message {
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:APP_TYPE == 3 ? STLLocalizedString_(@"ok", nil) : STLLocalizedString_(@"ok", nil).uppercaseString style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    [self presentViewController:alertController animated:YES completion:nil];
}


#pragma mark ------处理 物流信息
- (void)handleTrackInfor:(AccountMyOrdersDetailModel *)obj {
    
    //根据订单详情shipping 的waitingShip(待发货字段)来判断是否有物流信息
//    if (obj.shipping.waitingShip) {
        
#if DEBUG
    
    ///occ
//    STLTrackingWaitingShipMode *moddd = [[STLTrackingWaitingShipMode alloc] init];
//    moddd.desc = @"ddddd dfa fda fda fda fdafdafdas fds fds fdsa fdasfdsafdsa fdsafd";
//    moddd.date = @"12321";
//    moddd.logistics_status = @"Ready for shipping";
//    obj.shipping.waitingShip = moddd;
//    obj.is_split = @"0";
//
//    STLTransportingModel *ttModel = [[STLTransportingModel alloc] init];
//    ttModel.desc = @"ddddd dfa fda fda fda fdafdafdas fds fds fdsa fdasfdsafdsa fdsafd";
//    ttModel.date = @"12321";
//    ttModel.logistics_status = @"Ready for shipping";
//    //ttModel.status = @"Dancel";
//    ttModel.loc = @"dsaj idoj oidjfsioa jd adddress 12 3243 3424 32432432 4532";
//
////    obj.shipping.waitingShip = ttModel;
//    obj.shipping.transport = ttModel;
#endif
    
        //是否有物流拆单  1:是   0： 否
        if ([STLToString(obj.is_split) isEqualToString:@"1"]) {
            @weakify(self)

            STLTransportSplitView *splitView = [[STLTransportSplitView alloc] init];
            splitView.backgroundColor = STLThemeColor.col_FFFFFF;
            splitView.userInteractionEnabled = YES;
            [splitView whenTapped:^{
                @strongify(self)
                [self jumpToTransportSplitViewController];
            }];
            splitView.detail.text = STLToString(obj.split_text);
            [self.trackingBottomView addSubview:splitView];
            
            [self.trackingBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(8);
                make.leading.mas_equalTo(self.containerView.mas_leading);
                make.trailing.mas_equalTo(self.containerView.mas_trailing);
                make.height.equalTo(60);
            }];
            [splitView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.mas_equalTo(self.trackingBottomView);
            }];
            return;
        }
        
        if (obj.shipping.waitingShip) {
            @weakify(self)
            //新增物流信息
            STLOrderTrackView *trackView = [[STLOrderTrackView alloc] init];
            trackView.backgroundColor = STLThemeColor.col_FFFFFF;
            trackView.userInteractionEnabled = YES;
            trackView.noOrderLabel.hidden = YES;
            
            [trackView whenTapped:^{
                @strongify(self)
                [self tapTrackingView];
            }];
            [self.trackingBottomView addSubview:trackView];
            [self.trackingBottomView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(8);
                make.leading.mas_equalTo(self.containerView.mas_leading);
                make.trailing.mas_equalTo(self.containerView.mas_trailing);
                make.height.equalTo(91);
            }];
            [trackView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.top.bottom.mas_equalTo(self.trackingBottomView);
            }];
            //************自上而下去判断更新物流模块数据*******************//
            if (obj.shipping.alreadySign) {
                //已签收
                trackView.tradingStatusLabel.text = STLToString(obj.shipping.alreadySign.desc);
                trackView.transitLabel.text = STLToString(obj.shipping.alreadySign.logistics_status);
                trackView.addressImg.hidden = YES;
                trackView.addressLabel.hidden = YES;
                trackView.trackCarImgView.image = [UIImage imageNamed:@"already_sign12"];
                if (STLToString(obj.shipping.trackingNumber).length) {
                    trackView.trackCodeNum.text = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"TrackingNo",nil),STLToString(obj.shipping.trackingNumber)];

                } else {
                    trackView.noOrderLabel.hidden = NO;
                }
                trackView.timeLabel.text    = STLToString(obj.shipping.alreadySign.date);
                return;
            }
            
            ///拒绝签收
            if (obj.shipping.refuseSign) {
                //拒签收
                trackView.tradingStatusLabel.text = STLToString(obj.shipping.refuseSign.desc);
                trackView.transitLabel.text = STLToString(obj.shipping.refuseSign.status);
                trackView.addressImg.hidden = YES;
                trackView.addressLabel.hidden = YES;
                trackView.trackCarImgView.image = [UIImage imageNamed:@"logistics_refused12"];
                if (STLToString(obj.shipping.trackingNumber).length) {
                    trackView.trackCodeNum.text = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"TrackingNo",nil),STLToString(obj.shipping.trackingNumber)];

                } else {
                    trackView.noOrderLabel.hidden = NO;
                }
                trackView.timeLabel.text    = STLToString(obj.shipping.refuseSign.date);
                return;
            }


            if (obj.shipping.transport) {
                //运输中
                trackView.tradingStatusLabel.text = STLToString(obj.shipping.transport.desc);
                trackView.transitLabel.text = STLToString(obj.shipping.transport.logistics_status);
                trackView.trackCarImgView.image = [UIImage imageNamed:@"logistics_ship12"];
                if (STLToString(obj.shipping.trackingNumber).length) {
                    trackView.trackCodeNum.text = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"TrackingNo",nil),STLToString(obj.shipping.trackingNumber)];

                } else {
                    trackView.noOrderLabel.hidden = NO;
                }
                trackView.addressLabel.hidden = NO;
                trackView.addressImg.hidden   = NO;
                //判断是否为数组
                if (STLJudgeNSArray(obj.shipping.transport.trackArray)) {
                    NSArray *trackArray = (NSArray *)obj.shipping.transport.trackArray;
                    if (trackArray.count) {
                        //取第一条最新的动态
                        STLTransportTrackMode *model = trackArray[0];
                        trackView.addressLabel.text = STLToString(model.detail);
                        trackView.timeLabel.text   = STLToString(model.date);
                    }
                }
                
                [self.trackingBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(8);
                    make.leading.mas_equalTo(self.containerView.mas_leading);
                    make.trailing.mas_equalTo(self.containerView.mas_trailing);
                    make.height.equalTo(110);
                }];
                return;
            }

            if (obj.shipping.alreadyShip) {
                //已发货
                trackView.tradingStatusLabel.text = STLToString(obj.shipping.alreadyShip.desc);
                trackView.transitLabel.text = STLToString(obj.shipping.alreadyShip.logistics_status);
                trackView.addressImg.hidden = YES;
                trackView.addressLabel.hidden = YES;
                trackView.trackCarImgView.image = [UIImage imageNamed:@"logistics_shipped12"];
                if (STLToString(obj.shipping.trackingNumber).length) {
                    trackView.trackCodeNum.text = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"TrackingNo",nil),STLToString(obj.shipping.trackingNumber)];

                } else {
                    trackView.noOrderLabel.hidden = NO;
                }
                trackView.timeLabel.text    = STLToString(obj.shipping.alreadyShip.date);
//                [trackView.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//                    make.leading.mas_equalTo(trackView.transitLabel.mas_leading);
//                    make.top.mas_equalTo(trackView.tradingStatusLabel.mas_bottom).offset(3);
//                    make.height.mas_equalTo(@13);
//                }];

                return;
            }

            //判断对象是否存在
            if (obj.shipping.waitingShip) {
                trackView.userInteractionEnabled = NO; //待发货状态不跳转到物流详情页
                trackView.arrowImg.hidden = YES;
                //待发货
                trackView.tradingStatusLabel.text = STLToString(obj.shipping.waitingShip.desc);
                trackView.transitLabel.text = STLToString(obj.shipping.waitingShip.logistics_status);
                trackView.addressImg.hidden = YES;
                trackView.addressLabel.hidden = YES;
                trackView.trackCarImgView.image = [UIImage imageNamed:@"logistics_processing12"];
                if (STLToString(obj.shipping.trackingNumber).length) {
                    trackView.trackCodeNum.text = [NSString stringWithFormat:@"%@:%@",STLLocalizedString_(@"TrackingNo",nil),STLToString(obj.shipping.trackingNumber)];

                } else {
                    trackView.trackCodeNum.text = STLLocalizedString_(@"NoTrackingNumber", nil);

                }
                trackView.timeLabel.text    = STLToString(obj.shipping.waitingShip.date);
//                [trackView.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    //make.leading.mas_equalTo(trackView.transitLabel.mas_leading);
                    //make.top.mas_equalTo(trackView.tradingStatusLabel.mas_bottom).offset(3);
//                    make.height.mas_equalTo(@13);
//                }];

                return;
            }
    } else {
        [self showTrackTips:STLLocalizedString_(@"noPackages", @"没有物流")];

    }
    
    //原来是判断订单状态为 3 或 4的时候添加物流信息
//    if (obj.orderStatus == 3 || obj.orderStatus == 4)
    // 未支付订单和失败订单不显示物流信息  -----最早的逻辑
//    if (obj.orderStatus == 0 || obj.orderStatus == 11 || obj.orderStatus == 12) {
//        [_trackingBottomView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.top.mas_equalTo(self.waitCheckView.mas_bottom).mas_offset(0);
//        }];
//    } else {
//        //没有物流的时候，需要展示一个提示语
//        [self showTrackTips:STLLocalizedString_(@"noPackages", @"没有物流")];
//    }

}


#pragma mark 处理 商品信息
- (void)handleGoodsImgae:(AccountMyOrdersDetailModel *)obj {
    
    if (obj.goodsList && [obj.goodsList count]) {
        //仓库名字
        AccountOrdersDetailGoodsModel *detailModel= obj.goodsList[0];
        self.wareHouseTitleLabel.text = detailModel.wareHouseName;
        
        /*数量为单件的时候布局*/
        if (obj.goodsList.count == 1) {
            self.goodsView = [AccountOrderDetailView new];
            /*单品数据以及订单状态->根据状态判断是否显示评论按钮*/
            [self.goodsView initWithGoodsModel:[obj.goodsList firstObject] orderStatue:obj.orderStatus];
            self.goodsView.delegate = self;
            [self.goodsBottomView addSubview:self.goodsView];
            [self.goodsView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.trailing.mas_equalTo(self.goodsBottomView);
                make.bottom.mas_equalTo(self.goodsBottomView.mas_bottom).offset(-6);
                make.top.mas_equalTo(self.wareHouseTitleLabel.mas_bottom);
            }];
        }else {
            /*当商品数量>=2件的时候布局*/
            NSMutableArray *array = [[NSMutableArray alloc] init];
            [obj.goodsList enumerateObjectsUsingBlock:^(AccountMyOrdersDetailModel * _Nonnull goodsDetail, NSUInteger idx, BOOL * _Nonnull stop) {
                self.goodsView = [AccountOrderDetailView new];
                self.goodsView.delegate = self;
                [self.goodsView initWithGoodsModel:obj.goodsList[idx] orderStatue:obj.orderStatus];
                [self.goodsBottomView addSubview:self.goodsView];
                [array addObject:self.goodsView];
            }];
            
            UIView *tempView;
            for(int i=0; i < array.count; i++) {
                UIView *goodsV = array[i];
                if (tempView) {
                    [goodsV mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.mas_equalTo(tempView);
                        make.top.mas_equalTo(tempView.mas_bottom);
                        make.width.mas_equalTo(tempView.mas_width);
                        if (i == array.count-1) {
                            make.bottom.mas_equalTo(self.goodsBottomView.mas_bottom).offset(-6);
                        }
                    }];
                } else {
                    [goodsV mas_makeConstraints:^(MASConstraintMaker *make) {
                        make.leading.trailing.mas_equalTo(self.goodsBottomView);
                        make.top.mas_equalTo(self.wareHouseTitleLabel.mas_bottom);
                        make.width.mas_equalTo(SCREEN_WIDTH-24);
                    }];
                }
                tempView = goodsV;
            }
        }
    }
    
}
-(BOOL)isZero:(NSString *)value
{
    ///<从字符串匹配数字
//    if (value) {
//        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@".*[1-9].*" options:NSRegularExpressionCaseInsensitive error:nil];
//        NSTextCheckingResult *result = [regex firstMatchInString:value options:NSMatchingReportCompletion range:NSMakeRange(0, value.length)];
//        if (result) {
//            NSString *number = [value substringWithRange:result.range];
//            if (number.floatValue > 0) {
//                return NO;
//            }
//            return YES;
//        }
//        return YES;
//    }
//    return YES;
    
    NSString *regExp = @".*[1-9].*";
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"SELF MATCHES %@", regExp];
    BOOL find = [predicate evaluateWithObject:value];
    return !find;
}

/*========================================分割线======================================*/

-(void)showTrackTips:(NSString *)tipString
{
    UILabel *tips = [[UILabel alloc] init];
    tips.text = tipString;
    tips.textColor = [STLThemeColor col_0D0D0D];
    tips.font = [UIFont systemFontOfSize:14];
    tips.numberOfLines = 0;
    tips.preferredMaxLayoutWidth = SCREEN_WIDTH - 52;
    [self.trackingBottomView addSubview:tips];
    
    [tips mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.trackingBottomView.mas_top).mas_offset(13);
        make.bottom.mas_equalTo(self.trackingBottomView.mas_bottom).mas_offset(-13);
        make.leading.mas_equalTo(self.trackingBottomView.mas_leading).mas_offset(14);
        make.trailing.mas_equalTo(self.trackingBottomView.mas_trailing).mas_offset(-14);
    }];
}

//跳转到物流轨迹
//- (void)tapTrackingView:(UITapGestureRecognizer*)sender {
//    STLTrackingListCtrl *trackingVC = [[STLTrackingListCtrl alloc] init];
//    trackingVC.orderNumber = self.orderDetailModel.orderSn;
//    [self.navigationController pushViewController:trackingVC animated:YES];
//}

//跳转到物流轨迹-----非拆单
- (void)tapTrackingView {
    STLNewTrackingListViewController *trackingVC = [[STLNewTrackingListViewController alloc] init];
    trackingVC.trackVal = self.orderDetailModel.orderSn;
    trackingVC.trackType = @"1";

    [self.navigationController pushViewController:trackingVC animated:YES];
}

//跳转到物流拆单----
- (void)jumpToTransportSplitViewController {
    STLTransportSplitViewController *splitVc = [[STLTransportSplitViewController alloc] init];
    splitVc.orderNumber = self.orderDetailModel.orderSn;
    [self.navigationController pushViewController:splitVc animated:YES];
}
/*========================================分割线======================================*/

#pragma mark - 长按订单号可以copy
- (void)actionCopyOrderNumber {
    [self becomeFirstResponder];
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.orderDetailModel.orderSn;
    [HUDManager showHUDWithMessage:STLLocalizedString_(@"successCopy", nil)];
    
    [STLAnalytics analyticsGAEventWithName:@"copy_orderNo" parameters:@{
           @"screen_group":@"OrderDetail",
           @"action":@"Copy"}];
}

/*成为第一响应者*/
-(BOOL)canBecomeFirstResponder {
    return YES;
}

/*可以响应的方法*/
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    return (action == @selector(copy:));
}

-(void)copy:(id)sender
{
    
}

#pragma mark - AccountOrderDetailViewDelegate

- (void)accountOrderDetailView:(AccountOrderDetailView *)goodsView goodsModel:(AccountOrdersDetailGoodsModel *)goodsModel {
    
    [STLAnalytics analyticsGAEventWithName:@"order_action" parameters:@{
           @"screen_group":@"OrderDetail",
           @"action":[NSString stringWithFormat:@"detail_%@",STLToString(goodsModel.goodsName)]}];
    
    OSSVDetailsVC *goodsDetailVC = [[OSSVDetailsVC alloc] init];
    goodsDetailVC.goodsId = goodsModel.goodsId;
    goodsDetailVC.wid = goodsModel.wid;
    goodsDetailVC.sourceType = STLAppsflyerGoodsSourceOrder;
    goodsDetailVC.coverImageUrl = STLToString(goodsModel.goodsThumb);
    [self.navigationController pushViewController:goodsDetailVC animated:YES];
}

/*========================================分割线======================================*/


/*========================================分割线======================================*/

#pragma mark -----------——懒加载创建视图
//-(UILabel *)codOrderTotalLabel
//{
//    if (!_codOrderTotalLabel) {
//        _codOrderTotalLabel = ({
//            UILabel *label = [UILabel new];
//            label.text = [NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"total",nil)];
//            label.font = [UIFont systemFontOfSize:12];
//            label.textColor = STLThemeColor.col_666666;
//            label;
//        });
//    }
//    return _codOrderTotalLabel;
//}
//
//-(UILabel *)codOrderTotalPriceLabel
//{
//    if (!_codOrderTotalPriceLabel) {
//        _codOrderTotalPriceLabel = ({
//            UILabel *label = [UILabel new];
//            label.text = @"";
//            label.font = [UIFont systemFontOfSize:12];
//            label.textColor = [STLThemeColor stlBlackColor];
//            label;
//        });
//    }
//    return _codOrderTotalPriceLabel;
//}
//
//-(UILabel *)codOrderDistypeLabel
//{
//    if (!_codOrderDistypeLabel) {
//        _codOrderDistypeLabel = ({
//            UILabel *label = [UILabel new];
//            label.text = [NSString stringWithFormat:@"%@ :",STLLocalizedString_(@"Price_low_to_high",nil)];
//            label.font = [UIFont systemFontOfSize:12];
//            label.textColor = STLThemeColor.col_666666;
//            label;
//        });
//    }
//    return _codOrderDistypeLabel;
//}
//
//-(UILabel *)codOrderDistypeValueLabel
//{
//    if (!_codOrderDistypeValueLabel) {
//        _codOrderDistypeValueLabel = ({
//            UILabel *label = [UILabel new];
//            label.text = @"";
//            label.font = [UIFont systemFontOfSize:12];
//            label;
//        });
//    }
//    return _codOrderDistypeValueLabel;
//}

-(STLOrdersTimeDownView *)countDownView
{
    if (!_countDownView) {
        _countDownView = [[STLOrdersTimeDownView alloc] init];
        _countDownView.hidden = YES;
        @weakify(self)
        _countDownView.timeEndBlock = ^{
            @strongify(self)
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self reloadData];
            });
        };
    }
    return _countDownView;
}

- (STLBottomButtonsView *)payBottomView {
    if (!_payBottomView) {
        _payBottomView = [[STLBottomButtonsView alloc] initWithFrame:CGRectZero];
        _payBottomView.backgroundColor = [STLThemeColor stlWhiteColor];
        _payBottomView.delegate = self;
    }
    return _payBottomView;
}


- (STLCheckOutCodMsgAlertView *)codMsgAlertView {
    if (!_codMsgAlertView) {
        _codMsgAlertView = [[STLCheckOutCodMsgAlertView alloc] initWithFrame:CGRectZero];

        @weakify(self);
        _codMsgAlertView.codAlertBlock = ^(NSString *resultId, NSString *resultStr) {
            @strongify(self);
            @weakify(self);
            
            [STLAnalytics analyticsGAEventWithName:@"cancel_order" parameters:@{
                   @"screen_group":@"OrderDetail",
                   @"action":@"Cancel_Yes"}];
            [self codCancelRequest:resultId cancelResult:resultStr completion:^(id obj) {
                @strongify(self)
                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefreshOrderList object:nil];
                [self reloadData];
            } failure:nil];
        };
        
        _codMsgAlertView.closeBlock = ^{
            [STLAnalytics analyticsGAEventWithName:@"cancel_order" parameters:@{
                   @"screen_group":@"OrderDetail",
                   @"action":@"Cancel_No"}];
        };
    }
    return _codMsgAlertView;
}

- (UIView *)waitCheckView {
    if (!_waitCheckView) {
        _waitCheckView = [[UIView alloc] initWithFrame:CGRectZero];
        _waitCheckView.backgroundColor = [STLThemeColor stlWhiteColor];
        _waitCheckView.layer.cornerRadius = 6;
        _waitCheckView.layer.masksToBounds = YES;
    }
    return _waitCheckView;
}

- (UILabel *)codCheckTipLabel {
    if (!_codCheckTipLabel) {
        _codCheckTipLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _codCheckTipLabel.textColor = [STLThemeColor col_0D0D0D];
        _codCheckTipLabel.font = [UIFont systemFontOfSize:14];
        _codCheckTipLabel.numberOfLines = 0;
        _codCheckTipLabel.text = @"";
    }
    return _codCheckTipLabel;
}


- (void)codCancelRequest:(NSString *)type cancelResult:(NSString *)resultString completion:(void (^)(id obj))completion failure:(void (^)(id))failure{
    
    NSDictionary *params = @{@"cancel_type"  :STLToString(type),
                             @"order_id"      :STLToString(self.orderDetailModel.orderId),
    };
    
    @weakify(self)
    STLCodCancelAddApi *codCancelApi = [[STLCodCancelAddApi alloc] initWithDict:params];
    [codCancelApi startWithBlockSuccess:^(__kindof STLBaseRequest *request) {
        NSLog(@"----- codCancell Success");
        @strongify(self)
        [self orderCancelSuccess:YES normal:YES cancelReason:resultString];
        if (completion) {
            completion(nil);
        }
        
    } failure:^(__kindof STLBaseRequest *request, NSError *error) {
        NSLog(@"----- codCancell failure: %@",error.debugDescription);
        
        if (failure) {
            failure(nil);
        }
        [self orderCancelSuccess:NO normal:YES cancelReason:resultString];
    }];
    
}

-(CartOrderInfoViewModel *)infoViewModel
{
    if (!_infoViewModel) {
        _infoViewModel = [[CartOrderInfoViewModel alloc] init];
        _infoViewModel.controller = self;
    }
    return _infoViewModel;
}

- (void)conConfirmAnalytics:(BOOL)state {
    
    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(self.orderDetailModel.firstName),
                          STLToString(self.orderDetailModel.lastName)];
    
    NSArray *counrty = [self.orderDetailModel.country componentsSeparatedByString:@"/"];
    NSArray *province = [self.orderDetailModel.province componentsSeparatedByString:@"/"];
    NSArray *city = [self.orderDetailModel.city componentsSeparatedByString:@"/"];
    NSArray *street = [self.orderDetailModel.district componentsSeparatedByString:@"/"];

    NSString *countryString = counrty.firstObject;
    NSString *stateString = province.firstObject;
    NSString *cityString = city.firstObject;
    NSString *streetString = street.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    NSDictionary *sensorsDic = @{@"order_sn":STLToString(self.orderDetailModel.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(self.orderDetailModel.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(self.orderDetailModel.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(self.orderDetailModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(self.orderDetailModel.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(self.orderDetailModel.coupon_code),
                                 @"discount_amount":@([STLToString(self.orderDetailModel.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(self.orderDetailModel.coupon_code) ? @(0) : @(1)),
                                 @"is_success": @(state),

    };
    [STLAnalytics analyticsSensorsEventWithName:@"ClickConfirmCod" parameters:sensorsDic];
    
}


- (void)paySuccesWithProductCod:(BOOL)state {

    
    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(self.orderDetailModel.firstName),
                          STLToString(self.orderDetailModel.lastName)];
    
    NSArray *counrty = [self.orderDetailModel.country componentsSeparatedByString:@"/"];
    NSArray *province = [self.orderDetailModel.province componentsSeparatedByString:@"/"];
    NSArray *city = [self.orderDetailModel.city componentsSeparatedByString:@"/"];
    NSArray *street = [self.orderDetailModel.district componentsSeparatedByString:@"/"];

    NSString *countryString = counrty.firstObject;
    NSString *stateString = province.firstObject;
    NSString *cityString = city.firstObject;
    NSString *streetString = street.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    BOOL isfirstOrder = [AccountManager sharedManager].account.is_first_order_time;
    NSString *payType = @"normal";
    [STLAnalytics sharedManager].analytics_uuid = [STLAnalytics appsAnalyticUUID];
    NSString *analyticsUUID = [STLAnalytics sharedManager].analytics_uuid;
    NSString *goodsSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)self.orderDetailModel.goodsList.count];
    NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                 @"order_type":payType,
                                 @"order_sn":STLToString(self.orderDetailModel.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(self.orderDetailModel.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(self.orderDetailModel.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(self.orderDetailModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(self.orderDetailModel.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(self.orderDetailModel.coupon_code),
                                 @"discount_amount":@([STLToString(self.orderDetailModel.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(self.orderDetailModel.coupon_code) ? @"0" : @"1"),
                                 @"is_success": @(state),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodsSkuCount,

    };
    [STLAnalytics analyticsSensorsEventWithName:@"ConfirmCod" parameters:sensorsDic];
    
    if (state) {
        //AB ConfirmCod
        [ABTestTools.shared confirmCodWithOrderSn:STLToString(self.orderDetailModel.orderSn)
                                orderActureAmount:[STLToString(self.orderDetailModel.money_info.payable_amount) floatValue]
                                totalPriceOfGoods:[STLToString(self.orderDetailModel.money_info.goods_amount) floatValue]
                                     goodsSnCount:self.orderDetailModel.goodsList.count
                                    paymentMethod:STLToString(self.orderDetailModel.payCode)
                                    isUseDiscount:(STLIsEmptyString(self.orderDetailModel.coupon_code) ? @"0" : @"1")
                                    confirmMethod:self.confirmMethod
        ];
    }
    
    
    NSMutableArray *goodsSnArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *priceArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *qtyArray = [[NSMutableArray alloc]initWithCapacity: 1];
    NSMutableArray *itemsGoods = [[NSMutableArray alloc] init];

    CGFloat allAmount = 0;
    for (NSInteger i = 0; i < self.orderDetailModel.goodsList.count; i ++) {
        AccountOrdersDetailGoodsModel *goodsModel = (AccountOrdersDetailGoodsModel*)self.orderDetailModel.goodsList[i];
        [goodsSnArray addObject:STLToString(goodsModel.goods_sn)];
        [priceArray addObject:STLToString(goodsModel.money_info.goods_price)];
        [qtyArray addObject:STLToString(goodsModel.goodsNumber)];
        
        CGFloat price = [goodsModel.money_info.goods_price floatValue];
        
        NSDictionary *items = @{
            kFIRParameterItemID: STLToString(goodsModel.goods_sn),
            kFIRParameterItemName: STLToString(goodsModel.goodsName),
            kFIRParameterItemCategory: STLToString(goodsModel.cat_name),
            kFIRParameterPrice: @(price),
            kFIRParameterQuantity: STLToString(goodsModel.goodsNumber),
            kFIRParameterItemVariant:STLToString(goodsModel.goodsAttr),
            kFIRParameterItemBrand:@"",
        };
        
        [itemsGoods addObject:items];
        
        BOOL isfirstOrder = [AccountManager sharedManager].account.is_first_order_time;
        NSString *payType = @"normal";
        NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                     @"order_type":payType,
                                     @"order_sn":STLToString(self.orderDetailModel.orderSn),
                                     @"goods_sn"        :   STLToString(goodsModel.goods_sn),
                                     @"goods_name"        :   STLToString(goodsModel.goodsName),
                                     @"cat_id"        :   STLToString(goodsModel.cat_id),
                                     @"cat_name"      :   STLToString(goodsModel.cat_name),
                                     @"currency":@"USD",
                                     @"original_price"      :   @([STLToString(goodsModel.money_info.market_price) floatValue]),
                                     @"present_price"        :   @([STLToString(goodsModel.money_info.goods_price) floatValue]),
                                     @"goods_color"           :   @"",
                                     @"goods_size" :@"",
                                     @"goods_quantity"   :   @([STLToString(goodsModel.goodsNumber) integerValue]),
                                     @"is_success": @(state),
                                     @"uu_id":analyticsUUID,
                                          
        };
        [STLAnalytics analyticsSensorsEventWithName:@"ConfirmCodDetail" parameters:sensorsDic];
    }
    allAmount += [self.orderDetailModel.money_info.payable_amount floatValue];

    
    if (state) {
        
        NSString *goodsSnStrings = [(NSArray *)goodsSnArray componentsJoinedByString:@","];
        NSString *priceStrings = [(NSArray *)priceArray componentsJoinedByString:@","];
        NSString *qtyStrings = [(NSArray *)qtyArray componentsJoinedByString:@","];
        
        NSDictionary *dic = @{
            @"af_content_id":goodsSnStrings,
            @"af_order_id":STLToString(self.orderDetailModel.orderSn),
            @"af_price":priceStrings,
            @"af_quantity":qtyStrings,
            @"af_currency":@"USD",
            @"af_revenue":[NSString stringWithFormat:@"%@",self.orderDetailModel.money_info.payable_amount],
        };
        [STLAnalytics appsFlyerOrderPaySuccess:dic];
        
        //数据GA埋点曝光 支付成功事件
        //GA
        NSDictionary *itemsDic = @{kFIRParameterItems:itemsGoods,
                                   kFIRParameterCurrency: @"USD",
                                   kFIRParameterValue: @(allAmount),
                                   kFIRParameterCoupon:STLToString(self.orderDetailModel.coupon_code),
                                   kFIRParameterPaymentType:STLToString(self.orderDetailModel.payCode),
                                   kFIRParameterTransactionID:STLToString(self.orderDetailModel.orderSn),
                                   kFIRParameterShipping:STLToString(self.orderDetailModel.money_info.shipping_fee),
                                   kFIRParameterDiscount:@"",
                                   kFIRParameterTax:@"",
                                   @"cod_cost": STLToString(self.orderDetailModel.money_info.cod_cost),
                                   @"cod_discount":STLToString(self.orderDetailModel.money_info.cod_discount),
                                   @"screen_group":@"PaymentSuccess",
        };
        
        [STLAnalytics analyticsGAEventWithName:kFIREventPurchase parameters:itemsDic];
        [STLBranchTools logPurchaseGMV:itemsDic];
        
        [DotApi payOrder];
    }
}

- (void)orderCancelSuccess:(BOOL)isSuccess normal:(BOOL)isNormal cancelReason:(NSString *)cancelReason{
    
    if (isSuccess) {
        NSMutableArray *snArray = [[NSMutableArray alloc]initWithCapacity: 1];
        NSMutableArray *priceArray = [[NSMutableArray alloc]initWithCapacity: 1];
        NSMutableArray *qtyArray = [[NSMutableArray alloc]initWithCapacity: 1];
        

    //    CGFloat allAmount = 0;
        for (NSInteger i = 0; i < self.orderDetailModel.goodsList.count; i ++) {
            AccountOrdersDetailGoodsModel *goodsModel = (AccountOrdersDetailGoodsModel*)self.orderDetailModel.goodsList[i];
            [snArray addObject:STLToString(goodsModel.goods_sn)];
            [priceArray addObject:STLToString(goodsModel.money_info.goods_price)];
            [qtyArray addObject:STLToString(goodsModel.goodsNumber)];
        }

        
        NSString *snStrings = [(NSArray *)snArray componentsJoinedByString:@","];
        NSString *priceStrings = [(NSArray *)priceArray componentsJoinedByString:@","];
        NSString *qtyStrings = [(NSArray *)qtyArray componentsJoinedByString:@","];
        
        NSDictionary *dic = @{
          @"af_content_id":snStrings,
          @"af_order_id":STLToString(self.orderDetailModel.orderSn),
          @"af_price":priceStrings,
          @"af_quantity":qtyStrings,
          @"af_currency":@"USD",
            @"af_revenue":[NSString stringWithFormat:@"%@",self.orderDetailModel.money_info.payable_amount],
          //@"af_payment":payStrings
        };
        
        [STLAnalytics appsFlyerOrderCancel:dic];
    }
    
    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(self.orderDetailModel.firstName),
                          STLToString(self.orderDetailModel.lastName)];
    
    
    NSArray *counrtyArray = [self.orderDetailModel.country componentsSeparatedByString:@"/"];
    NSArray *stateArray = [self.orderDetailModel.province componentsSeparatedByString:@"/"];
    NSArray *cityArray = [self.orderDetailModel.city componentsSeparatedByString:@"/"];
    NSArray *streetArray = [self.orderDetailModel.street componentsSeparatedByString:@"/"];

    NSString *countryString = counrtyArray.firstObject;
    NSString *stateString = stateArray.firstObject;
    NSString *cityString = cityArray.firstObject;
    NSString *streetString = streetArray.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    //cancel_button--点击取消按钮；repurchase--点击重新购买取消
    NSString *payType = [STLToString(self.orderDetailModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    NSString *cancel_type = isNormal ? @"cancel_button" : @"repurchase";
    BOOL flag = isSuccess;
    
    [STLAnalytics sharedManager].analytics_uuid = [STLAnalytics appsAnalyticUUID];
    NSString *analyticsUUID = [STLAnalytics sharedManager].analytics_uuid;
    NSString *goodSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)self.orderDetailModel.goodsList.count];
    
    NSDictionary *sensorsDic = @{@"order_type":payType,
                                 @"cancel_type":cancel_type,
                                 @"order_sn":STLToString(self.orderDetailModel.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(self.orderDetailModel.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(self.orderDetailModel.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(self.orderDetailModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(self.orderDetailModel.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(self.orderDetailModel.coupon_code),
                                 @"discount_amount":@([STLToString(self.orderDetailModel.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(self.orderDetailModel.coupon_code) ? @(0) : @(1)),
                                 @"is_success": @(flag),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodSkuCount,
                                 @"cancel_reason":STLToString(cancelReason),

    };
    [STLAnalytics analyticsSensorsEventWithName:@"CancelOrder" parameters:sensorsDic];
    
    
    [self.orderDetailModel.goodsList enumerateObjectsUsingBlock:^(AccountOrdersDetailGoodsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSString *payType = [STLToString(self.orderDetailModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
        NSDictionary *sensorsDic = @{
                                     @"order_type":payType,
                                     @"order_sn"        :   STLToString(self.orderDetailModel.orderSn),
                                     @"goods_sn"      :   STLToString(obj.goods_sn),
                                     @"goods_name"      :   STLToString(obj.goodsName),
                                     @"cat_id"           :   STLToString(obj.cat_id),
                                     @"cat_name"        :   STLToString(obj.cat_name),
                                     @"original_price"   :   @([STLToString(obj.money_info.market_price) floatValue]),
                                     @"present_price"   :   @([STLToString(obj.money_info.goods_price) floatValue]),
                                     @"goods_quantity"        :   @([STLToString(obj.goodsNumber) integerValue]),
                                     @"goods_size":@"",
                                     @"goods_color":@"",
                                     @"currency":@"USD",
                                     @"payment_method"        :   STLToString(self.orderDetailModel.payCode),
                                     @"is_success": @(flag),
                                     @"uu_id":analyticsUUID,
                                     @"cancel_reason":STLToString(cancelReason),

        };
        [STLAnalytics analyticsSensorsEventWithName:@"CancelOrderDetail" parameters:sensorsDic];
        
    }];
    
}


- (AccountMyOrdersViewModel *)myOrderlistModel {
    if (!_myOrderlistModel) {
        _myOrderlistModel = [[AccountMyOrdersViewModel alloc] init];
    }
    return _myOrderlistModel;
}






- (void)orderOnlePayResultAnalyticsState:(BOOL)flag {

    ////
    NSString *contacts = [NSString stringWithFormat:@"%@ %@",
                          STLToString(self.orderDetailModel.firstName),
                          STLToString(self.orderDetailModel.lastName)];
    
    
    NSArray *counrtyArray = [self.orderDetailModel.country componentsSeparatedByString:@"/"];
    NSArray *stateArray = [self.orderDetailModel.province componentsSeparatedByString:@"/"];
    NSArray *cityArray = [self.orderDetailModel.city componentsSeparatedByString:@"/"];
    NSArray *streetArray = [self.orderDetailModel.street componentsSeparatedByString:@"/"];

    NSString *countryString = counrtyArray.firstObject;
    NSString *stateString = stateArray.firstObject;
    NSString *cityString = cityArray.firstObject;
    NSString *streetString = streetArray.firstObject;

    NSArray *addressArray = @[streetString,cityString,stateString,countryString];
    NSString *addressString = [addressArray componentsJoinedByString:@","];
    
    BOOL isfirstOrder = [AccountManager sharedManager].account.is_first_order_time;
    NSString *payType = [STLToString(self.orderDetailModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    
    [STLAnalytics sharedManager].analytics_uuid = [STLAnalytics appsAnalyticUUID];
    NSString *analyticsUUID = [STLAnalytics sharedManager].analytics_uuid;
    NSString *goodSkuCount = [NSString stringWithFormat:@"%lu",(unsigned long)self.orderDetailModel.goodsList.count];
 
    NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                 @"order_type":payType,
                                 @"order_sn":STLToString(self.orderDetailModel.orderSn),
                                 @"order_actual_amount"        :   @([STLToString(self.orderDetailModel.money_info.payable_amount) floatValue]),
                                 @"total_price_of_goods"        :   @([STLToString(self.orderDetailModel.money_info.goods_amount) floatValue]),
                                 @"payment_method"        :   STLToString(self.orderDetailModel.payCode),
                                 @"currency":@"USD",
                                 @"receiver_name"      :   STLToString(contacts),
                                 @"receiver_country"      :   STLToString(countryString),
                                 @"receiver_province"        :   STLToString(stateString),
                                @"receiver_city"           :   STLToString(cityString),
                                 @"receiver_district"   :   STLToString(streetString),
                                 @"receiver_address"   :   STLToString(addressString),
                                 @"shipping_fee"        :   @([STLToString(self.orderDetailModel.money_info.shipping_fee) floatValue]),
                                 @"discount_id":STLToString(self.orderDetailModel.coupon_code),
                                 @"discount_amount":@([STLToString(self.orderDetailModel.money_info.coupon_save) floatValue]),
                                 @"is_use_discount":(STLIsEmptyString(self.orderDetailModel.coupon_code) ? @(0) : @(1)),
                                 @"is_success": @(flag),
                                 @"uu_id":analyticsUUID,
                                 @"goods_sn_count":goodSkuCount,

    };
    [STLAnalytics analyticsSensorsEventWithName:@"OnlinePayOrder" parameters:sensorsDic];
    
    
    if (flag) {
        [ABTestTools.shared onlinePayOrderWithOrderSn:STLToString(self.orderDetailModel.orderSn)
                                    orderActureAmount:[STLToString(self.orderDetailModel.money_info.payable_amount) floatValue]
                                    totalPriceOfGoods:[STLToString(self.orderDetailModel.money_info.goods_amount) floatValue]
                                         goodsSnCount:self.orderDetailModel.goodsList.count
                                        paymentMethod:STLToString(self.orderDetailModel.payCode)
                                        isUseDiscount:(STLIsEmptyString(self.orderDetailModel.coupon_code) ? @"0" : @"1")];
    }

    
    [self.orderDetailModel.goodsList enumerateObjectsUsingBlock:^(AccountOrdersDetailGoodsModel *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        BOOL isfirstOrder = [AccountManager sharedManager].account.is_first_order_time;
        NSString *payType = [STLToString(self.orderDetailModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
        NSDictionary *sensorsDic = @{@"is_first_time":(isfirstOrder ? @(1) : @(0)),
                                     @"order_type":payType,
                                     @"order_sn"        :   STLToString(self.orderDetailModel.orderSn),
                                     @"goods_sn"      :   STLToString(obj.goods_sn),
                                     @"goods_name"      :   STLToString(obj.goodsName),
                                     @"cat_id"           :   STLToString(obj.cat_id),
                                     @"cat_name"        :   STLToString(obj.cat_name),
                                     @"original_price"   :   @([STLToString(obj.money_info.market_price) floatValue]),
                                     @"present_price"   :   @([STLToString(obj.money_info.goods_price) floatValue]),
                                     @"goods_quantity"        :   @([STLToString(obj.goodsNumber) integerValue]),
                                     @"goods_size":@"",
                                     @"goods_color":@"",
                                     @"currency":@"USD",
                                     @"payment_method"        :   STLToString(self.orderDetailModel.payCode),
                                     @"is_success": @(flag),
                                     @"uu_id":analyticsUUID,

        };
        [STLAnalytics analyticsSensorsEventWithName:@"OnlinePayOrderDetail" parameters:sensorsDic];
        
    }];
}

- (void)repurchaseAnalytics:(BOOL)flag {
    
    NSString *payType = [STLToString(self.orderDetailModel.payCode) isEqualToString:@"Influencer"] ? @"kol" : @"normal";
    NSDictionary *sensorsDic = @{
                                 @"order_type"          :   payType,
                                 @"order_sn"            :   STLToString(self.orderDetailModel.orderSn),
                                 @"payment_method"      :   STLToString(self.orderDetailModel.payCode),
                                 @"is_success"          :  @(flag),
                                 @"order_status"        :  [NSString stringWithFormat:@"%ld",(long)self.orderDetailModel.orderStatus],

    };
    [STLAnalytics analyticsSensorsEventWithName:@"ClickRepurchase" parameters:sensorsDic];
    
}
@end
