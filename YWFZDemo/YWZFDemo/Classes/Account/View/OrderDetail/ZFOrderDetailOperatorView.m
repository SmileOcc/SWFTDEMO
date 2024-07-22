
//
//  ZFOrderDetailOperatorView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFOrderDetailOperatorView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "Masonry.h"

typedef NS_ENUM(NSInteger, StatusButtonType) {
    StatusButtonTypePayNow = 0,     //立即支付事件
    StatusButtonTypeTrackingInfo,   //物流追踪
    StatusButtonTypeCancel,         //取消支付
    StatusButtonTypeBackToCart,     //回购
    StatusButtonTypeReview,         //评论
    StatusButtonTypeRefund,         //退款
};

@interface ZFOrderDetailOperatorView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIView            *lineView;
@property (nonatomic, strong) UILabel           *totalLabel;
@property (nonatomic, strong) UILabel           *priceLabel;
@property (nonatomic, strong) UIButton          *leftButton;       //第一个按钮
@property (nonatomic, strong, readwrite) UIButton          *rightButton;      //第二个按钮
@end

@implementation ZFOrderDetailOperatorView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods
- (NSString *)showCurrency:(NSString *)price {
    NSString *priceString = [ExchangeManager transAppendPrice:price currency:self.model.order_currency rateModel:self.model.order_exchange];
    return priceString;
}

#pragma mark - action methods

- (void)operatorViewButtonAction:(UIButton *)sender {
    switch (sender.tag) {
        case StatusButtonTypePayNow:
            if (self.orderDetailOrderPayNowCompletionHandler) {
                self.orderDetailOrderPayNowCompletionHandler();
            }
            break;
        case StatusButtonTypeTrackingInfo:
            if (self.orderDetailOrderTrakingInfoCompletionHandler) {
                self.orderDetailOrderTrakingInfoCompletionHandler();
            }
            break;
        case StatusButtonTypeBackToCart:
            if (self.orderDetailOrderBackToCartCompletionHandler) {
                self.orderDetailOrderBackToCartCompletionHandler();
            }
            break;
            
        case StatusButtonTypeCancel:
            if (self.orderDetailCancelCompletionHandler) {
                self.orderDetailCancelCompletionHandler();
            }
            break;
        case StatusButtonTypeReview:
            if (self.orderDetailCheckReviewCompletionHandler) {
                self.orderDetailCheckReviewCompletionHandler();
            }
            break;
        case StatusButtonTypeRefund:
            if (self.orderDetailRefundCompletionHandler) {
                self.orderDetailRefundCompletionHandler();
            }
            break;
        default:
            break;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.lineView];
    [self addSubview:self.totalLabel];
    [self addSubview:self.priceLabel];
    [self addSubview:self.leftButton];
    [self addSubview:self.rightButton];
}

- (void)zfAutoLayoutView {
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.height.mas_equalTo(1.f);
    }];
    
    [self.totalLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.top.mas_equalTo(self.mas_top).offset(8);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalLabel.mas_bottom).offset(4);
        make.leading.mas_equalTo(self.totalLabel);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(8);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.height.mas_equalTo(32);
    }];
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(8);
        make.trailing.mas_equalTo(self.rightButton.mas_leading).offset(-12);
        make.height.mas_equalTo(32);
    }];
}

#pragma mark - public method

-(void)operatorViewExchangePriceViewStatus:(BOOL)status
{
    NSInteger orderStatus = [self.model.order_status integerValue];
    if (orderStatus == 0) {
        CGFloat alpha = 0.0;
        if (!status) {
            alpha = 1.0;
        }
        [UIView animateWithDuration:.2 animations:^{
            self.priceLabel.alpha = alpha;
            self.totalLabel.alpha = alpha;
        }];
    }
}

#pragma mark - setter
- (void)setModel:(OrderDetailOrderModel *)model {
    _model = model;
    NSString *payMethod = _model.pay_id;
    NSInteger orderStatus = [model.order_status integerValue];
    
    self.priceLabel.text = [self showCurrency:_model.grand_total];
    self.priceLabel.hidden = YES;
    self.totalLabel.hidden = YES;
    
    self.leftButton.hidden = YES;
    self.rightButton.hidden = YES;
    
    [self.leftButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
    [self.rightButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
    self.rightButton.layer.borderWidth = 1;
    
    self.leftButton.backgroundColor = ZFCOLOR_WHITE;
    self.rightButton.backgroundColor = ZFCOLOR_WHITE;
    
    if ([payMethod isEqualToString:@"boletoBancario"]) {
        self.rightButton.tag = StatusButtonTypePayNow;
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
            //self.rightButton.hidden = NO;
            self.rightButton.hidden = YES;// v5.5.0隐藏:在cell中单独显示评论按钮
            self.rightButton.tag = StatusButtonTypeReview;
            [self.rightButton setTitle:ZFLocalizedString(@"OrderDetail_Goods_Cell_SubmitReview", nil) forState:UIControlStateNormal];
        }
        
    } else { // 非COD订单
        if (orderStatus == 1 || orderStatus == 2 ||
            orderStatus == 15 || orderStatus == 16 || orderStatus == 20) {
            /** 显示【Request a refund】按钮的情况
             *  1:已付款Paid, 2:备货Processing, 15:部分配货PartialOrderDispatched
             *  16:完全配货Dispatched,20:部分发货PartialOrderShipped
             */
            self.rightButton.hidden = NO;
            self.rightButton.tag = StatusButtonTypeRefund;
            [self.rightButton setTitle:ZFLocalizedString(@"OrderRequestRefund", nil) forState:UIControlStateNormal];
            
            if ([_model isKlarnaPayment]) {
                //klarna支付，需要显示Cancel
                [self.rightButton setTitle:ZFLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
            }
        } else if (orderStatus == 0 || orderStatus == 8) {
            /** 显示【Cancel】【Pay】按钮的情况
             *  0:未付款WaitingForPayment
             *  8:部分付款
             */
            
            //未付款 要显示价格
            self.priceLabel.hidden = NO;
            self.totalLabel.hidden = NO;
            
            self.leftButton.hidden = NO;
            self.leftButton.tag = StatusButtonTypeCancel;
            [self.leftButton setTitle:ZFLocalizedString(@"OrderDetail_Bottom_Cancel", nil) forState:UIControlStateNormal];
            
            self.rightButton.hidden = NO;
            self.rightButton.tag = StatusButtonTypePayNow;
            [self.rightButton setTitle:ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_PayNow",nil) forState:UIControlStateNormal];
            self.rightButton.layer.borderWidth = 0;
            
            //支付时按钮颜色和标题颜色单独设置
            self.rightButton.backgroundColor = ZFC0x2D2D2D();
            [self.rightButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
            if (orderStatus == 8) {
                self.leftButton.hidden = YES;
            }
            
        } else if (orderStatus == 3 || orderStatus == 4 ) {
            /** 显示【Reviews&Show】按钮的情况
             *  3:完全发货Shipped, 4:已收到货Delivered
             */
            //self.rightButton.hidden = NO;
            self.rightButton.hidden = YES;// v5.5.0隐藏:在cell中单独显示评论按钮
            self.rightButton.tag = StatusButtonTypeReview;
            [self.rightButton setTitle:ZFLocalizedString(@"OrderDetail_Goods_Cell_SubmitReview", nil) forState:UIControlStateNormal];
            
        } else if (orderStatus == 13) {
            //v4.1.0需求，当订单状态为13(付款失败)，隐藏支付按钮，因为后台找不到失败的原因，导致用户每次点击失败都会报错
            self.rightButton.hidden = NO;
            self.rightButton.tag = StatusButtonTypeCancel;
            [self.rightButton setTitle:ZFLocalizedString(@"OrderDetail_Bottom_Cancel", nil) forState:UIControlStateNormal];
            [self.rightButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
            self.rightButton.backgroundColor = ZFCOLOR_WHITE;
        }
    }
}

#pragma mark - getter
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
    }
    return _lineView;
}

- (UILabel *)totalLabel {
    if (!_totalLabel) {
        _totalLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalLabel.font = [UIFont boldSystemFontOfSize:12];
        _totalLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _totalLabel.text = ZFLocalizedString(@"TotalPrice_Cell_GrandTotal", nil);
    }
    return _totalLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.font = [UIFont boldSystemFontOfSize:16];
        _priceLabel.textColor = ZFC0x2D2D2D();
    }
    return _priceLabel;
}

- (UIButton *)leftButton {
    if (!_leftButton) {
        _leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _leftButton.titleLabel.contentMode = NSTextAlignmentCenter;
        _leftButton.layer.borderWidth = 1.f;
        _leftButton.layer.cornerRadius = 2;
        _leftButton.layer.masksToBounds = YES;
        _leftButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        _leftButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1.0).CGColor;
        [_leftButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
        [_leftButton addTarget:self action:@selector(operatorViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _rightButton.titleLabel.contentMode = NSTextAlignmentCenter;
        _rightButton.layer.borderWidth = 1.f;
        _rightButton.layer.cornerRadius = 2;
        _rightButton.layer.masksToBounds = YES;
        _rightButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        _rightButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1.0).CGColor;
        [_rightButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
        [_rightButton addTarget:self action:@selector(operatorViewButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

@end
