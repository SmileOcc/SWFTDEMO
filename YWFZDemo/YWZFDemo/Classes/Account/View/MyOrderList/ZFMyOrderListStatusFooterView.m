

//
//  ZFMyOrderListStatusFooterView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/6.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFMyOrderListStatusFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"

typedef NS_ENUM(NSInteger, StatusButtonType) {
    StatusButtonTypePayNow = 0,     //立即支付事件
    StatusButtonTypeTrackingInfo,   //物流追踪
    StatusButtonTypeBoleto,         //也是一种支付事件
    StatusButtonTypeBackToCart,     //回购
    StatusButtonTypeReview,         //评论
    StatusButtonTypeRefund,         //退款
    StatusButtonTypeCODCheckAddress,//COD订单确认
};

@interface ZFMyOrderListStatusFooterView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIView            *lineView;
@property (nonatomic, strong) UIButton          *leftButton;       //第一个按钮
@property (nonatomic, strong) UIButton          *rightButton;      //第二个按钮
@end

@implementation ZFMyOrderListStatusFooterView
#pragma mark - init methods
- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
//        self.clipsToBounds = YES;//修复bug Again可能会显示在FooterView以外的地方显示
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods

- (void)statusButtonAction:(UIButton *)sender {
    StatusButtonType type = sender.tag;
    switch (type) {
        case StatusButtonTypePayNow: {
            if (self.orderListOrderPayNowCompletionHandler) {
                self.orderListOrderPayNowCompletionHandler();
            }
        }
            break;
        case StatusButtonTypeTrackingInfo: {
            if (self.orderListOrderTrakingInfoCompletionHandler) {
                self.orderListOrderTrakingInfoCompletionHandler();
            }
        }
            break;
        case StatusButtonTypeBoleto: {
            if (self.orderListOrderPayNowCompletionHandler) {
                self.orderListOrderPayNowCompletionHandler();
            }
        }
            break;
        case StatusButtonTypeBackToCart: {
            if (self.orderListOrderBackToCartCompletionHandler) {
                self.orderListOrderBackToCartCompletionHandler();
            }
        }
            break;
        case StatusButtonTypeReview: {
            if (self.orderListReviewShowCompletionHandler) {
                self.orderListReviewShowCompletionHandler();
            }
        }
            break;
        case StatusButtonTypeRefund: {
            if (self.orderListRefundCompletionHandler) {
                self.orderListRefundCompletionHandler();
            }
        }
            break;
        case StatusButtonTypeCODCheckAddress: {
            if (self.orderListCODCheckAddressCompletionHandler) {
                self.orderListCODCheckAddressCompletionHandler();
            }
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.leftButton];
    [self.contentView addSubview:self.rightButton];
    [self.contentView addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-12);
        make.height.mas_equalTo(32);
    }];
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top).offset(8);
        make.trailing.mas_equalTo(self.rightButton.mas_leading).offset(-12);
        make.leading.mas_greaterThanOrEqualTo(self.contentView.mas_leading).offset(12);
        make.height.mas_equalTo(32);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self.contentView);
        make.height.mas_equalTo(10);
    }];
}

#pragma mark - setter

- (void)setModel:(MyOrdersModel *)model {
    _model = model;
    NSString *payMethod = _model.pay_id;
    NSInteger orderStatus = [model.order_status integerValue];
    
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    
    [self.leftButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
    [self.rightButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
    self.rightButton.layer.borderWidth = 1;
    
    self.leftButton.backgroundColor = ZFCOLOR_WHITE;
    self.rightButton.backgroundColor = ZFCOLOR_WHITE;
    
    if ([payMethod isEqualToString:@"boletoBancario"]) {
        self.rightButton.tag = StatusButtonTypeBoleto;
        if ([_model.pay_status isEqualToString:@"0"]) {
            [self.rightButton setTitle:ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_Contiue",nil) forState:UIControlStateNormal];
            
        } else if ([_model.pay_status isEqualToString:@"1"]) {
            [self.rightButton setTitle:ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_Check",nil) forState:UIControlStateNormal];
        }
    }
    
    if ([payMethod isEqualToString:@"Cod"]) { // COD订单
        
        if (orderStatus == 0 || orderStatus == 3 || orderStatus == 4) {
            /** 显示【Reviews&Show】按钮的情况
             0:未付款WaitingForPayment
             3:完全发货Shipped
             4:已收到货Delivered
             */
            //self.leftButton.hidden = NO;
            //@张思杰 V5.5.0需要根据订单中的全部商品是否都已评论吗来判断显示评论按钮
            self.leftButton.hidden = [self.class canShowReviewsBtn:self.model.goods] ? NO : YES;
            
            self.leftButton.tag = StatusButtonTypeReview;
            [self.leftButton setTitle:ZFLocalizedString(@"Order_Comment", nil) forState:UIControlStateNormal];
        }
        
        if (orderStatus == 0 || orderStatus == 1 || orderStatus == 2 ||
            orderStatus == 3 || orderStatus == 4 || orderStatus == 15 ||
            orderStatus == 16 || orderStatus == 20 ) {
            /** 显示【Tracking info】按钮的情况
             0:未付款WaitingForPayment, 1:已付款Paid, 2:备货Processing
             3:完全发货Shipped out, 4:已收到货Delivered, 15:部分配货PartialOrderDispatched
             16:完全配货Dispatched, 20:部分发货PartialOrderShipped
             */
            self.rightButton.hidden = NO;
            if (model.confirm_btn_show) {
                self.rightButton.tag = StatusButtonTypeCODCheckAddress;
                self.rightButton.backgroundColor = ZFCOLOR(45, 45, 45, 1);
                [self.rightButton setTitleColor:ZFCOLOR(255, 255, 255, 1.0) forState:UIControlStateNormal];
                [self.rightButton setTitle:ZFLocalizedString(@"OrderList_COD_checkAddress", nil) forState:UIControlStateNormal];
            } else {
                self.rightButton.tag = StatusButtonTypeTrackingInfo;
                self.rightButton.backgroundColor = [UIColor whiteColor];
                [self.rightButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
                [self.rightButton setTitle:ZFLocalizedString(@"ZFTracking_information_title", nil) forState:UIControlStateNormal];
            }
        }
        
        if (_model.add_to_cart.integerValue == 1 && orderStatus != 0) {
            /** 显示【回购】按钮的情况
             0:未付款WaitingForPayment, 1:已付款Paid, 2:备货Processing
             */
            self.leftButton.hidden = NO;
            self.leftButton.tag = StatusButtonTypeBackToCart;
            [self.leftButton setTitle:ZFLocalizedString(@"ReturnToBag",nil) forState:UIControlStateNormal];
        }
        
    } else { // 非COD订单
        
        if (orderStatus == 1 || orderStatus == 2 ||
            orderStatus == 15 || orderStatus == 16 || orderStatus == 20) {
            /** 只显示【Tracking info】按钮的情况
             *  1:已付款Paid, 2:备货Processing, 15:部分配货PartialOrderDispatched
             *  16:完全配货Dispatched,20:部分发货PartialOrderShipped
             */
            self.rightButton.hidden = NO;
            self.rightButton.tag = StatusButtonTypeTrackingInfo;
            [self.rightButton setTitle:ZFLocalizedString(@"ZFTracking_information_title", nil) forState:UIControlStateNormal];
            
        } else if (orderStatus == 0 || orderStatus == 8) {
            /** 只显示【Pay】按钮的情况
             *  0:未付款WaitingForPayment, 4:已收到货Delivered
             */
            self.rightButton.hidden = NO;
            self.rightButton.tag = StatusButtonTypePayNow;
            [self.rightButton setTitle:ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_PayNow",nil) forState:UIControlStateNormal];
            self.rightButton.layer.borderWidth = 0;
            
            //支付时按钮颜色和标题颜色单独设置
            self.rightButton.backgroundColor = ZFC0x2D2D2D();
            [self.rightButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
            
        } else if (orderStatus == 3 || orderStatus == 4) {
            /** 显示【Reviews&Show】【Tracking info】按钮的情况
             *  3:完全发货Shipped, 4:已收到货Delivered
             */
            
            //self.leftButton.hidden = NO;
            //@张思杰 V5.5.0需要根据订单中的全部商品是否都已评论吗来判断显示评论按钮
            self.leftButton.hidden = [self.class canShowReviewsBtn:self.model.goods] ? NO : YES;
            
            self.leftButton.tag = StatusButtonTypeReview;
            [self.leftButton setTitle:ZFLocalizedString(@"OrderDetail_Goods_Cell_SubmitReview", nil) forState:UIControlStateNormal];
            
            self.rightButton.hidden = NO;
            self.rightButton.tag = StatusButtonTypeTrackingInfo;
            [self.rightButton setTitle:ZFLocalizedString(@"ZFTracking_information_title", nil) forState:UIControlStateNormal];
        }
        //未付款状态显示回购按钮
        //v4.4.0 付款失败显示回购按钮
        if (_model.add_to_cart.integerValue == 1) {
            if (self.rightButton.hidden) {
                //显示 ------- buy again
                self.leftButton.hidden = YES;
                self.rightButton.hidden = NO;
                self.rightButton.tag = StatusButtonTypeBackToCart;
                self.rightButton.backgroundColor = ZFCOLOR_WHITE;
                [self.rightButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
                [self.rightButton setTitle:ZFLocalizedString(@"ReturnToBag",nil) forState:UIControlStateNormal];
            }else{
                //显示 buy again -- pay
                self.leftButton.hidden = NO;
                self.leftButton.tag = StatusButtonTypeBackToCart;
                [self.leftButton setTitle:ZFLocalizedString(@"ReturnToBag",nil) forState:UIControlStateNormal];
            }
        }
    }
    ///减少lable的渲染时间
    _rightButton.titleLabel.backgroundColor = _rightButton.backgroundColor;
    _leftButton.titleLabel.backgroundColor = _leftButton.backgroundColor;
}

///@张思杰 V5.5.0需要根据订单中的全部商品是否都已评论吗来判断显示评论按钮
+ (BOOL)canShowReviewsBtn:(NSArray<MyOrderGoodListModel *> *)goodsListModel {
   if (![goodsListModel isKindOfClass:[NSArray class]]) return YES;
    
    BOOL canShowReview = NO;
    for (MyOrderGoodListModel *model in goodsListModel) {
        if (![model isKindOfClass:[MyOrderGoodListModel class]]) continue;
        if (model.is_review <= 0) {
            canShowReview = YES;
            break;
        }
    }
    return canShowReview;
}

#pragma mark - getter

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _leftButton.titleLabel.contentMode = NSTextAlignmentCenter;
        _leftButton.titleLabel.layer.masksToBounds = YES;
        _leftButton.layer.borderWidth = 1.f;
        _leftButton.layer.cornerRadius = 2;
        _leftButton.layer.masksToBounds = YES;
        _leftButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        _leftButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1.0).CGColor;
        [_leftButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightButton.titleLabel.contentMode = NSTextAlignmentCenter;
        _rightButton.titleLabel.layer.masksToBounds = YES;
        _rightButton.layer.cornerRadius = 2;
        _rightButton.layer.masksToBounds = YES;
        _rightButton.layer.borderWidth = 1.f;
        _rightButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        _rightButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1.0).CGColor;
        [_rightButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(statusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(245, 245, 245, 1.0);
    }
    return _lineView;
}

@end
