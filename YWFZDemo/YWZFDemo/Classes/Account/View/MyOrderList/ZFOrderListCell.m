//
//  ZFOrderListCell.m
//  ZZZZZ
//
//  Created by 602600 on 2020/1/7.
//  Copyright © 2020 ZZZZZ. All rights reserved.
//

#import "ZFOrderListCell.h"
#import "ZFInitViewProtocol.h"
#import "ZFMyOrderListGoodsImageView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "ZFCountDownView.h"
#import "ZFTimerManager.h"
#import "Constants.h"

typedef NS_ENUM(NSInteger, StatusButtonType) {
    StatusButtonTypePayNow = 0,     //立即支付事件
    StatusButtonTypeTrackingInfo,   //物流追踪
    StatusButtonTypeBoleto,         //也是一种支付事件
    StatusButtonTypeBackToCart,     //回购
    StatusButtonTypeReview,         //评论
    StatusButtonTypeRefund,         //退款
    StatusButtonTypeCODCheckAddress,//COD订单确认
};

@interface ZFOrderListCell ()

@property (nonatomic, strong) UIView            *container;
@property (nonatomic, strong) UIView            *tagIconView;
@property (nonatomic, strong) UILabel           *statusLabel;
@property (nonatomic, strong) ZFCountDownView   *countDownView;

@property (nonatomic, strong) UIView            *imageContentView;
@property (nonatomic, strong) UILabel           *timeLabel;
@property (nonatomic, strong) UILabel           *totalCountLabel;
@property (nonatomic, strong) UILabel           *totalCountItemsLabel;
@property (nonatomic, strong) UILabel           *totalPriceLabel;
@property (nonatomic, strong) UILabel           *priceLabel;
@property (nonatomic, strong) UILabel           *deliveryLabel;

@property (nonatomic, strong) UIButton          *leftButton;       //第一个按钮
@property (nonatomic, strong) UIButton          *rightButton;      //第二个按钮

@end

@implementation ZFOrderListCell

#pragma mark - init methods
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

-(void)prepareForReuse
{
    [super prepareForReuse];
    NSString *key = [NSString stringWithFormat:@"%@%@", self.model.order_id, @"OrderListCountTime"];
    [[ZFTimerManager shareInstance] stopTimer:key];
}

///@张思杰 V5.5.0需要根据订单中的全部商品是否都已评论吗来判断显示评论按钮
- (BOOL)canShowReviewsBtn:(NSArray<MyOrderGoodListModel *> *)goodsListModel {
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

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF7F7F7();
    [self.contentView addSubview:self.container];
    [self.container addSubview:self.tagIconView];
    [self.container addSubview:self.statusLabel];
    [self.container addSubview:self.countDownView];
    
    [self.container addSubview:self.imageContentView];
    [self.container addSubview:self.timeLabel];
    [self.container addSubview:self.totalCountLabel];
    [self.container addSubview:self.totalCountItemsLabel];
    [self.container addSubview:self.totalPriceLabel];
    [self.container addSubview:self.priceLabel];
    [self.container addSubview:self.deliveryLabel];
    
    [self.container addSubview:self.leftButton];
    [self.container addSubview:self.rightButton];
}

- (void)zfAutoLayoutView {
    
    [self.container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(12, 12, 0, 12));
    }];
    
    [self.tagIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(6, 6));
        make.centerY.mas_equalTo(self.statusLabel);
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tagIconView.mas_trailing).offset(5);
        make.top.mas_equalTo(self.container.mas_top).offset(10);
        make.height.mas_equalTo(18);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.container.mas_trailing).mas_offset(-12);
        make.centerY.mas_equalTo(self.statusLabel);
    }];
    
    
    [self.imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(0);
        make.leading.trailing.mas_equalTo(self.container);
        make.height.mas_equalTo(92).priorityHigh();
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container.mas_leading).offset(12);
        make.top.mas_equalTo(self.imageContentView.mas_bottom).offset(10);
        make.trailing.mas_equalTo(self.container.mas_trailing).offset(-12);
        make.height.mas_equalTo(18);
    }];
    
    [self.totalCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container.mas_leading).offset(12);
        make.top.mas_equalTo(self.timeLabel.mas_bottom).offset(10);
        make.height.mas_equalTo(18);
    }];
    
    [self.totalCountItemsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.totalCountLabel.mas_trailing);
        make.centerY.mas_equalTo(self.totalCountLabel);
        make.height.mas_equalTo(18);
    }];
    
    [self.totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.totalCountItemsLabel.mas_trailing).offset(25);
        make.centerY.mas_equalTo(self.totalCountLabel);
        //make.width.mas_equalTo(90);
        make.height.mas_equalTo(18);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.totalPriceLabel.mas_trailing);
        make.bottom.mas_equalTo(self.totalPriceLabel);
        make.height.mas_equalTo(18);
        make.trailing.mas_equalTo(-12);
    }];
    
    [self.deliveryLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.container.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.container.mas_trailing).offset(-12);
        make.top.mas_equalTo(self.totalCountLabel.mas_bottom).offset(10);
//        make.bottom.mas_equalTo(self.container.mas_bottom).offset(-12);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.deliveryLabel.mas_bottom).offset(10);
        make.trailing.mas_equalTo(self.container.mas_trailing).offset(-12);
        make.height.mas_equalTo(32);
        make.bottom.mas_equalTo(self.container.mas_bottom).offset(-12);
    }];
    
    [self.leftButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.rightButton.mas_leading).offset(-12);
        make.leading.mas_greaterThanOrEqualTo(self.container.mas_leading).offset(12);
        make.height.mas_equalTo(32);
        make.centerY.mas_equalTo(self.rightButton);
    }];

    for (int idx = 0; idx < 4; idx++) {
        ZFMyOrderListGoodsImageView *imageView = [[ZFMyOrderListGoodsImageView alloc] initWithFrame:CGRectZero];
        imageView.frame = CGRectMake(12 * (idx+1) + 60 * idx, 12, 60, 80);
        imageView.hidden = YES;
        [self.imageContentView addSubview:imageView];
    }
    
    [self.totalPriceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.totalPriceLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];

    [self.totalCountLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.totalCountLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.totalCountItemsLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
}

#pragma mark - Action
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

#pragma mark - setter
- (void)setModel:(MyOrdersModel *)model {
    _model = model;
    
    self.statusLabel.text = _model.order_status_str;
        
    self.countDownView.hidden = YES;
    if ([_model.pay_id isEqualToString:@"Cod"]) {
        if ([_model.order_status integerValue] == 2 || [_model.order_status integerValue] == 6) { // Processing  Pending
            self.statusLabel.textColor = ZFC0xFE5269();
            self.tagIconView.backgroundColor = ZFC0xFE5269();
        } else if ([_model.order_status integerValue] == 4) {  // 已收到货    Delivered
            self.statusLabel.textColor = ZFCOLOR(6, 177, 144, 1.f);
            self.tagIconView.backgroundColor = ZFCOLOR(6, 177, 144, 1.f);
        } else {
            self.statusLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
            self.tagIconView.backgroundColor = ZFCOLOR(45, 45, 45, 1.f);
        }
    }else{
        if ([_model.order_status integerValue] == 0) {  // 显示 payNow
            self.statusLabel.textColor = ZFC0xFE5269();
            self.tagIconView.backgroundColor = ZFC0xFE5269();
            self.countDownView.hidden = NO;
            NSString *key = [NSString stringWithFormat:@"%@%@", model.order_id, @"OrderListCountTime"];
            if (_model.pay_left_time.integerValue > 0) {
                [[ZFTimerManager shareInstance] startTimer:key];
                YWLog(@"orderListCountDown %@ - %ld",self.model.order_id, (long)self.model.pay_left_time.integerValue);
                [self.countDownView startTimerWithStamp:_model.pay_left_time timerKey:key completeBlock:^{
                }];
            } else {
                [[ZFTimerManager shareInstance] stopTimer:key];
                self.countDownView.hidden = YES;
            }
        } else if ([_model.order_status integerValue] == 11) {  // Cancel
            self.statusLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
            self.tagIconView.backgroundColor = ZFCOLOR(153, 153, 153, 1.f);
        } else if ([_model.order_status integerValue] == 2 || [_model.order_status integerValue] == 6) { // Processing  Pending
            self.statusLabel.textColor = ZFC0xFE5269();
            self.tagIconView.backgroundColor = ZFC0xFE5269();
        } else if ([_model.order_status integerValue] == 4) {  // 已收到货    Delivered
            self.statusLabel.textColor = ZFCOLOR(6, 177, 144, 1.f);
            self.tagIconView.backgroundColor = ZFCOLOR(6, 177, 144, 1.f);
        } else { // 显示 物流追踪
            self.statusLabel.textColor = ZFCOLOR(45, 45, 45, 1.f);
            self.tagIconView.backgroundColor = ZFCOLOR(45, 45, 45, 1.f);
        }
    }
    
    self.timeLabel.text = _model.order_time;

    [self.imageContentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    [_model.goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > self.imageContentView.subviews.count - 1) {
            *stop = YES;
        }else{
            ZFMyOrderListGoodsImageView *imageView = self.imageContentView.subviews[idx];
            imageView.hidden = NO;
            imageView.imageUrl = obj.wp_image;
            imageView.goodsNumber = obj.goods_number;
            imageView.leaveCount = [NSString stringWithFormat:@"%ld", (long)(idx == 3 ? model.leaveCount : 0)];
        }
    }];
    
    if ([_model.order_status integerValue] == 11) {  // Cancel
        self.totalCountItemsLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        self.priceLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    } else {
        self.totalCountItemsLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        self.priceLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
    }
    self.totalCountLabel.text = ZFLocalizedString(@"ZFOrderList_Total", nil);
    self.totalCountItemsLabel.text = [NSString stringWithFormat:@" %ld %@", (long)_model.totalCount, ZFLocalizedString(@"ZFOrderList_Total_Items", nil)];
    
    self.priceLabel.text = [ExchangeManager transAppendPrice:_model.total_fee currency:_model.order_currency rateModel:_model.order_exchange];//[self showCurrency:_model.total_fee];
 
    if (([_model.pay_id isEqualToString:@"Cod"] && [_model.order_status integerValue] != 13) || [_model.show_refund integerValue] == 2) {
        self.deliveryLabel.text = [_model.show_refund integerValue] == 2 ? ZFLocalizedString(@"OrderRefundTips", nil) :  ZFLocalizedString(@"DeliveryShippingView_deliveryLabel", nil);
    } else {
        self.deliveryLabel.text = @"";
    }
    
    CGFloat topSpace = (self.deliveryLabel.text.length > 0) ? 10 : 0;
    [self.deliveryLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalCountLabel.mas_bottom).offset(topSpace);
    }];
    
    // 底部按钮
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
            self.leftButton.hidden = [self canShowReviewsBtn:self.model.goods] ? NO : YES;
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
            self.leftButton.hidden = [self canShowReviewsBtn:self.model.goods] ? NO : YES;
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
    
    
    if (self.leftButton.hidden && self.rightButton.hidden) {
        [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.deliveryLabel.mas_bottom).offset(0);
            make.height.mas_equalTo(0);
        }];
    } else {
        [self.rightButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.deliveryLabel.mas_bottom).offset(10);
            make.height.mas_equalTo(32);
        }];
    }
}

#pragma mark - getter
- (UIView *)container {
    if (!_container) {
        _container = [[UIView alloc] init];
        _container.backgroundColor = [UIColor whiteColor];
        _container.layer.cornerRadius = 8;
        _container.layer.masksToBounds = YES;
    }
    return _container;
}

- (UIView *)tagIconView {
    if (!_tagIconView) {
        _tagIconView = [[UIView alloc] initWithFrame:CGRectZero];
        _tagIconView.backgroundColor = ZFC0xFE5269();
        _tagIconView.layer.cornerRadius = 3;
        _tagIconView.layer.masksToBounds = YES;
    }
    return _tagIconView;
}

- (UILabel *)statusLabel {
    if (!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.textColor = ZFC0xFE5269();
        _statusLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _statusLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _statusLabel;
}

- (ZFCountDownView *)countDownView
{
    if (!_countDownView) {
        _countDownView = ({
            ZFCountDownView *countDown = [[ZFCountDownView alloc] initWithFrame:CGRectZero tierSizeHeight:20 showDay:YES];
            countDown.timerBackgroundColor = [UIColor clearColor];
            countDown.timerTextColor = [UIColor whiteColor];
            countDown.timerDotColor = [UIColor blackColor];
            countDown.timerTextBackgroundColor = [UIColor blackColor];
            countDown.timerCircleRadius = 4;
            countDown;
        });
    }
    return _countDownView;
}

- (UIView *)imageContentView {
    if (!_imageContentView) {
        _imageContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _imageContentView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _imageContentView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _timeLabel.font = [UIFont systemFontOfSize:12.0];
        _timeLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _timeLabel;
}

- (UILabel *)totalCountLabel {
    if (!_totalCountLabel) {
        _totalCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalCountLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _totalCountLabel.font = [UIFont systemFontOfSize:12.0];
        _totalCountLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _totalCountLabel;
}

- (UILabel *)totalCountItemsLabel {
    if (!_totalCountItemsLabel) {
        _totalCountItemsLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalCountItemsLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _totalCountItemsLabel.font = [UIFont systemFontOfSize:12.0];
        _totalCountItemsLabel.backgroundColor = ZFCOLOR_WHITE;
        [_totalCountItemsLabel sizeToFit];
    }
    return _totalCountItemsLabel;
}

- (UILabel *)totalPriceLabel {
    if (!_totalPriceLabel) {
        _totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _totalPriceLabel.font = [UIFont systemFontOfSize:12.0];
        _totalPriceLabel.text = [NSString stringWithFormat:@"%@:", ZFLocalizedString(@"MyOrders_Cell_TotalPayable", nil)];
        _totalPriceLabel.backgroundColor = ZFCOLOR_WHITE;
        _totalPriceLabel.layer.masksToBounds = YES;
    }
    return _totalPriceLabel;
}

- (UILabel *)priceLabel {
    if (!_priceLabel) {
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _priceLabel.font = [UIFont boldSystemFontOfSize:12.0];
        //_priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _priceLabel;
}

- (UILabel *)deliveryLabel {
    if (!_deliveryLabel) {
        _deliveryLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _deliveryLabel.text = ZFLocalizedString(@"DeliveryShippingView_deliveryLabel", nil);
        _deliveryLabel.textColor = ZFCOLOR(52, 52, 52, 1.0);
        _deliveryLabel.preferredMaxLayoutWidth = KScreenWidth - 24;
        _deliveryLabel.numberOfLines = 0;
        _deliveryLabel.font = [UIFont systemFontOfSize:12];
        _deliveryLabel.backgroundColor = ZFCOLOR_WHITE;
//        _deliveryLabel.hidden = YES;
    }
    return _deliveryLabel;
}

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

@end
