//
//  ZFCarHeaderInfoView.m
//  ZZZZZ
//
//  Created by YW on 2019/2/14.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCarHeaderInfoView.h"
#import "ZFMyOrderListGoodsImageView.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "MyOrdersModel.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFBlankPageTipView.h"
#import "UIImage+ZFExtended.h"
#import <YYImage/YYImage.h>
#import "YWCFunctionTool.h"
#import "ZFBannerTimeView.h"

@interface ZFCarHeaderInfoView()

@property (nonatomic, copy) void (^headerViewActionBlock)(ZFCarHeaderInfoViewActionType type);

@property (nonatomic, strong) UIView        *forNewUserContentView;
@property (nonatomic, strong) UIImageView   *emptyImageView;
@property (nonatomic, strong) UILabel       *descLabel;
@property (nonatomic, strong) UIButton      *shopWomenButton;
@property (nonatomic, strong) UIButton      *shopmenButton;
@property (nonatomic, strong) UIButton      *forUserButton;

@property (nonatomic, strong) MyOrdersModel *orderModel;
@property (nonatomic, strong) UIView        *waitingPaymentBgView;
@property (nonatomic, strong) UIView        *tagIconView;
@property (nonatomic, strong) UILabel       *statusLabel;
@property (nonatomic, strong) ZFBannerTimeView *countDownView;
@property (nonatomic, strong) UIView        *imageContentView;
@property (nonatomic, strong) UILabel       *timeLabel;
@property (nonatomic, strong) UILabel       *totalCountLabel;
@property (nonatomic, strong) UILabel       *totalPriceLabel;
@property (nonatomic, strong) UILabel       *priceLabel;
@property (nonatomic, strong) UIButton      *buyAgainButton;
@property (nonatomic, strong) UIButton      *payButton;
@end

@implementation ZFCarHeaderInfoView

- (instancetype)initWithFrame:(CGRect)frame
                   showUIType:(ZFCarHeaderInfoShowUIType)showUIType
                   orderModel:(MyOrdersModel *)orderModel
        headerViewActionBlock:(void (^)(ZFCarHeaderInfoViewActionType type))headerViewActionBlock
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = ZFC0xF2F2F2();
        self.headerViewActionBlock = headerViewActionBlock;
        [self initHeaderInfoAllView:showUIType orderModel:orderModel];
    }
    return self;
}

- (void)headerViewAction:(UIButton *)button {
    if (self.headerViewActionBlock) {
        self.headerViewActionBlock(button.tag);
    }
}

- (void)initHeaderInfoAllView:(ZFCarHeaderInfoShowUIType)showUIType orderModel:(MyOrdersModel *)orderModel
{
    switch (showUIType) {
        case ZFCarHeaderUI_EmptyData:
        {
            [self initEmptyDataView];
        }
            break;
            
        case ZFCarHeaderUI_WaitingPayment:
        {
            if ([orderModel isKindOfClass:[MyOrdersModel class]]) {
                [self zfInitWaitingPaymentView];
                [self zfAutoLayoutWaitingPaymentView];
                self.orderModel = orderModel;
            } else {
                [self initEmptyDataView];
            }
        }
            break;
            
        case ZFCarHeaderUI_ForNewUser:
        {
            [self zfInitForNewUserView];
            [self zfAutoLayoutForNewUserView];
        }
            break;
        default:
            break;
    }
}

#pragma mark -============== ZFCarHeaderUI_NewUserContentView ==============

- (void)zfInitForNewUserView {
    [self.contentView addSubview:self.forNewUserContentView];
    [self.forNewUserContentView addSubview:self.emptyImageView];
    [self.forNewUserContentView addSubview:self.descLabel];
    [self.forNewUserContentView addSubview:self.shopWomenButton];
    [self.forNewUserContentView addSubview:self.shopmenButton];
    [self.forNewUserContentView addSubview:self.forUserButton];
}

- (void)zfAutoLayoutForNewUserView {
    [self.emptyImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.forNewUserContentView.mas_top);
        make.centerX.mas_equalTo(self.forNewUserContentView.mas_centerX);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.emptyImageView.mas_bottom).offset(16);
        make.centerX.mas_equalTo(self.forNewUserContentView.mas_centerX);
    }];
    
    [self.shopWomenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(20);
        make.trailing.mas_equalTo(self.forNewUserContentView.mas_centerX).offset(-12);
        make.size.mas_equalTo(CGSizeMake(130, 40));
    }];
    
    [self.shopmenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.descLabel.mas_bottom).offset(20);
        make.leading.mas_equalTo(self.forNewUserContentView.mas_centerX).offset(12);
        make.size.mas_equalTo(CGSizeMake(130, 40));
    }];
    
    [self.forUserButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shopmenButton.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.shopWomenButton.mas_leading);
        make.trailing.mas_equalTo(self.shopmenButton.mas_trailing);
        make.height.mas_equalTo(40);
        make.bottom.mas_equalTo(self.forNewUserContentView.mas_bottom);
    }];
    
    [self.forNewUserContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
        make.width.mas_equalTo(self.mas_width);
    }];
}

- (UIView *)forNewUserContentView {
    if (!_forNewUserContentView) {
        _forNewUserContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _forNewUserContentView.backgroundColor = ZFC0xF2F2F2();
    }
    return _forNewUserContentView;
}

- (UIImageView *)emptyImageView {
    if (!_emptyImageView) {
        _emptyImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"blankPage_noCart"]];
    }
    return _emptyImageView;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColor = ZFCOLOR(45, 45, 45, 1.0);
        _descLabel.textAlignment = NSTextAlignmentCenter;
        _descLabel.font = [UIFont systemFontOfSize:16.0];
        _descLabel.numberOfLines = 0;
        NSString *topText = ZFLocalizedString(@"CartViewModel_NoData_TitleLabel", nil);
        NSString *bottonText = ZFLocalizedString(@"Car_Empty_PickYouLike", nil);
        _descLabel.text = [NSString stringWithFormat:@"%@\n%@",topText ,bottonText];
    }
    return _descLabel;
}

- (UIButton *)shopWomenButton {
    if (!_shopWomenButton) {
        _shopWomenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shopWomenButton setBackgroundColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_shopWomenButton setBackgroundColor:ZFC0xDDDDDD() forState:UIControlStateHighlighted];
        _shopWomenButton.layer.cornerRadius = 20;
        _shopWomenButton.layer.masksToBounds = YES;
        
        _shopWomenButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _shopWomenButton.titleLabel.contentMode = NSTextAlignmentCenter;
        [_shopWomenButton setTitleColor:ZFCOLOR(34, 34, 34, 1.0) forState:UIControlStateNormal];
        [_shopWomenButton addTarget:self action:@selector(headerViewAction:) forControlEvents:UIControlEventTouchUpInside];
        _shopWomenButton.tag = ZFCarHeaderAction_ShopWomen;
        [_shopWomenButton setTitle:[ZFLocalizedString(@"Car_Empty_Women",nil) uppercaseString] forState:UIControlStateNormal];
    }
    return _shopWomenButton;
}

- (UIButton *)shopmenButton {
    if (!_shopmenButton) {
        _shopmenButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shopmenButton setBackgroundColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_shopmenButton setBackgroundColor:ZFC0xDDDDDD() forState:UIControlStateHighlighted];
        _shopmenButton.layer.cornerRadius = 20;
        _shopmenButton.layer.masksToBounds = YES;
        
        _shopmenButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _shopmenButton.titleLabel.contentMode = NSTextAlignmentCenter;
        [_shopmenButton setTitleColor:ZFCOLOR(34, 34, 34, 1.0) forState:UIControlStateNormal];
        [_shopmenButton addTarget:self action:@selector(headerViewAction:) forControlEvents:UIControlEventTouchUpInside];
        _shopmenButton.tag = ZFCarHeaderAction_ShopMen;
        [_shopmenButton setTitle:[ZFLocalizedString(@"Car_Empty_Men",nil) uppercaseString] forState:UIControlStateNormal];
    }
    return _shopmenButton;
}

- (UIButton *)forUserButton {
    if (!_forUserButton) {
        _forUserButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forUserButton setBackgroundColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_forUserButton setBackgroundColor:ZFC0xDDDDDD() forState:UIControlStateHighlighted];
        _forUserButton.layer.cornerRadius = 20;
        _forUserButton.layer.masksToBounds = YES;
        
        _forUserButton.titleLabel.numberOfLines = 0;
        _forUserButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        _forUserButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        [_forUserButton setTitleColor:ZFCOLOR(34, 34, 34, 1.0) forState:UIControlStateNormal];
        [_forUserButton addTarget:self action:@selector(headerViewAction:) forControlEvents:UIControlEventTouchUpInside];
        _forUserButton.tag = ZFCarHeaderAction_ForNewUser;
        [_forUserButton setTitle:[ZFLocalizedString(@"Car_Empty_ForNewUser",nil) uppercaseString] forState:UIControlStateNormal];
    }
    return _forUserButton;
}


#pragma mark -============== ZFCarHeaderUI_EmptyData ==============

- (void)initEmptyDataView {
    UIImage *emptyDataImage = [UIImage imageNamed:@"blankPage_noCart"];
    NSString *emptyDataTitle = ZFLocalizedString(@"CartViewModel_NoData_TitleLabel", nil);
    NSString *emptyDataBtnTitle = ZFLocalizedString(@"CartViewModel_NoData_TitleButton", nil);
    
    @weakify(self);
    ZFBlankPageTipView *tipBgView = [ZFBlankPageTipView tipViewByFrame:self.bounds
                                                           moveOffsetY:0
                                                              topImage:emptyDataImage
                                                                 title:emptyDataTitle
                                                              subTitle:nil
                                                           actionTitle:emptyDataBtnTitle
    actionBlock:^{
        @strongify(self);
        if (self.headerViewActionBlock){
            self.headerViewActionBlock(ZFCarHeaderAction_EmptyData);
    }}];
    [self.contentView addSubview:tipBgView];

    CGRect rect = CGRectMake(0, self.bounds.size.height-14, KScreenWidth, 14);
    UIView *bottomLine = [[UIView alloc] initWithFrame:rect];
    bottomLine.backgroundColor = self.contentView.backgroundColor;
    [tipBgView addSubview:bottomLine];
}

#pragma mark -============== ZFCarHeaderUI_WaitingPayment ==============

- (void)setOrderModel:(MyOrdersModel *)orderModel {
    _orderModel = orderModel;
    
    [self.imageContentView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.hidden = YES;
    }];
    [_orderModel.goods enumerateObjectsUsingBlock:^(MyOrderGoodListModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx > self.imageContentView.subviews.count - 1) {
            *stop = YES;
        } else {
            ZFMyOrderListGoodsImageView *imageView = self.imageContentView.subviews[idx];
            imageView.hidden = NO;
            imageView.imageUrl = obj.wp_image;
            imageView.goodsNumber = obj.goods_number;
            imageView.leaveCount = [NSString stringWithFormat:@"%lu", idx == 3 ? orderModel.leaveCount : 0];
        }
    }];
    self.totalCountLabel.text = [NSString stringWithFormat:ZFLocalizedString(@"ZFOrderList_Total_Items", nil), _orderModel.totalCount];
    self.priceLabel.text = [ExchangeManager transAppendPrice:_orderModel.total_fee currency:self.orderModel.order_currency rateModel:_orderModel.order_exchange];//[self showCurrency:_orderModel.total_fee];
    
    // add_to_cart = 1 才显示再次购买按钮
    self.buyAgainButton.hidden = ![orderModel.add_to_cart isEqualToString:@"1"];
    
    [self showCarHeaderCountDownView:orderModel];
}

/**
 * 显示倒计时数据countDownCartTimerKey
 */
- (void)showCarHeaderCountDownView:(MyOrdersModel *)orderModel {
    if (_countDownView) {
        self.countDownView.hidden = YES;
    }
    
    unsigned long long timcountdownTime = [orderModel.pay_left_time longLongValue];
    if (timcountdownTime > 0 && !ZFIsEmptyString(orderModel.countDownCartTimerKey)) {
        YWLog(@"更新购物车配置倒计时位置===%@", orderModel.countDownCartTimerKey);
        self.countDownView.hidden = NO;
        //开启倒计时任务
        [self.countDownView startCountDownTimerStamp:orderModel.pay_left_time
                                        withTimerKey:orderModel.countDownCartTimerKey];
    }
}

- (void)zfInitWaitingPaymentView {
    [self.contentView addSubview:self.waitingPaymentBgView];
    [self.waitingPaymentBgView addSubview:self.tagIconView];
    [self.waitingPaymentBgView addSubview:self.statusLabel];
    [self.waitingPaymentBgView addSubview:self.countDownView];
    
    [self.waitingPaymentBgView addSubview:self.imageContentView];
    [self.waitingPaymentBgView addSubview:self.totalCountLabel];
    [self.waitingPaymentBgView addSubview:self.totalPriceLabel];
    [self.waitingPaymentBgView addSubview:self.priceLabel];

    [self.waitingPaymentBgView addSubview:self.buyAgainButton];
    [self.waitingPaymentBgView addSubview:self.payButton];
}

- (void)zfAutoLayoutWaitingPaymentView {
    [self.waitingPaymentBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(12, 12, 12, 12));
    }];
    
    [self.tagIconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.waitingPaymentBgView.mas_top).offset(20);
        make.leading.mas_equalTo(self.waitingPaymentBgView.mas_leading).offset(12);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
    
    [self.statusLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.tagIconView.mas_trailing).offset(12);
        make.trailing.mas_equalTo(self.waitingPaymentBgView);
        make.centerY.mas_equalTo(self.tagIconView.mas_centerY);
    }];
    
    [self.countDownView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.waitingPaymentBgView.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.tagIconView.mas_centerY);
        //make.size.mas_equalTo(CGSizeMake(120, 30));
    }];
    
    [self.imageContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.statusLabel.mas_bottom).offset(15);
        make.leading.trailing.mas_equalTo(self.waitingPaymentBgView);
        make.height.mas_equalTo(80);
    }];
    
    [self.totalCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.imageContentView.mas_bottom).offset(10);
        make.leading.mas_equalTo(self.waitingPaymentBgView.mas_leading).offset(12);
        make.height.mas_equalTo(18);
    }];
    
    [self.totalPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.totalCountLabel.mas_trailing).offset(25);
        make.centerY.mas_equalTo(self.totalCountLabel);
        make.height.mas_equalTo(18);
    }];
    
    [self.priceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.totalPriceLabel.mas_trailing);
        make.bottom.mas_equalTo(self.totalPriceLabel);
        make.height.mas_equalTo(18);
        make.trailing.mas_equalTo(self.waitingPaymentBgView.mas_trailing).offset(-12);
    }];
    
    [self.payButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totalCountLabel.mas_bottom).offset(12);
        make.trailing.mas_equalTo(self.waitingPaymentBgView.mas_trailing).offset(-12);
        make.leading.mas_greaterThanOrEqualTo(self.waitingPaymentBgView.mas_leading).offset(12);
        make.height.mas_equalTo(32);
    }];
    
    [self.buyAgainButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.payButton.mas_top);
        make.leading.mas_greaterThanOrEqualTo(self.waitingPaymentBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.payButton.mas_leading).offset(-12);
        make.height.mas_equalTo(32);
    }];
    
    for (int idx = 0; idx < 4; idx++) {
        ZFMyOrderListGoodsImageView *imageView = [[ZFMyOrderListGoodsImageView alloc] initWithFrame:CGRectZero];
        imageView.frame = CGRectMake(12 * (idx+1) + 60 * idx, 0, 60, 80);
        imageView.hidden = YES;
        @weakify(self);
        [imageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.headerViewActionBlock) {
                self.headerViewActionBlock(ZFCarHeaderAction_waitingForPayment);
            }
        }];
        [self.imageContentView addSubview:imageView];
    }
    
    //2019年10月16日13:58:01 杰哥说运营提需求说 商品底层视图点击也要进入到订单详情
    @weakify(self)
    [self.imageContentView addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self)
        if (self.headerViewActionBlock) {
            self.headerViewActionBlock(ZFCarHeaderAction_waitingForPayment);
        }
    }];
    
    [self.totalPriceLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.totalPriceLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.totalCountLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.totalCountLabel setContentHuggingPriority:260 forAxis:UILayoutConstraintAxisHorizontal];
}

- (UIView *)waitingPaymentBgView {
    if (!_waitingPaymentBgView) {
        _waitingPaymentBgView = [[UIView alloc] init];
        _waitingPaymentBgView.backgroundColor = ZFCOLOR_WHITE;
        _waitingPaymentBgView.layer.cornerRadius = 8;
        _waitingPaymentBgView.layer.masksToBounds = YES;
    }
    return _waitingPaymentBgView;
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
        _statusLabel.text = ZFLocalizedString(@"ZFPayStateWaiting", nil);
        _statusLabel.font = [UIFont boldSystemFontOfSize:14.0];
        _statusLabel.backgroundColor = ZFCOLOR_WHITE;
        @weakify(self);
        [_statusLabel addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.headerViewActionBlock) {
                self.headerViewActionBlock(ZFCarHeaderAction_waitingForPayment);
            }
        }];
    }
    return _statusLabel;
}

- (ZFBannerTimeView *)countDownView {
    if (!_countDownView) {
        _countDownView = [[ZFBannerTimeView alloc] init];
        _countDownView.hidden = YES;
    }
    return _countDownView;
}

- (UIView *)imageContentView {
    if (!_imageContentView) {
        _imageContentView = [[UIView alloc] initWithFrame:CGRectZero];
        _imageContentView.backgroundColor = ZFCOLOR_WHITE;
        _imageContentView.clipsToBounds = YES;
    }
    return _imageContentView;
}

- (UILabel *)totalCountLabel {
    if (!_totalCountLabel) {
        _totalCountLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalCountLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _totalCountLabel.font = [UIFont systemFontOfSize:14.0];
        _totalCountLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _totalCountLabel;
}

- (UILabel *)totalPriceLabel {
    if (!_totalPriceLabel) {
        _totalPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totalPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1.0);
        _totalPriceLabel.font = [UIFont systemFontOfSize:14.0];
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
        _priceLabel.font = [UIFont boldSystemFontOfSize:14.0];
        //_priceLabel.textAlignment = NSTextAlignmentLeft;
        _priceLabel.backgroundColor = ZFCOLOR_WHITE;
    }
    return _priceLabel;
}

- (UIButton *)buyAgainButton {
    if (!_buyAgainButton) {
        _buyAgainButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _buyAgainButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _buyAgainButton.titleLabel.contentMode = NSTextAlignmentCenter;
        _buyAgainButton.titleLabel.layer.masksToBounds = YES;
        _buyAgainButton.layer.cornerRadius = 2;
        _buyAgainButton.layer.masksToBounds = YES;
        _buyAgainButton.layer.borderWidth = 1.f;
        _buyAgainButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        _buyAgainButton.layer.borderColor = ZFCOLOR(45, 45, 45, 1.0).CGColor;
        [_buyAgainButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
        [_buyAgainButton addTarget:self action:@selector(headerViewAction:) forControlEvents:UIControlEventTouchUpInside];
        _buyAgainButton.tag = ZFCarHeaderAction_BuyAgain;
        [_buyAgainButton setTitle:ZFLocalizedString(@"ReturnToBag",nil) forState:UIControlStateNormal];
    }
    return _buyAgainButton;
}

- (UIButton *)payButton {
    if (!_payButton) {
        _payButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_payButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_payButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        _payButton.titleLabel.font = [UIFont systemFontOfSize:14];
        _payButton.titleLabel.contentMode = NSTextAlignmentCenter;
        _payButton.contentEdgeInsets = UIEdgeInsetsMake(5, 8, 5, 8);
        [_payButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_payButton addTarget:self action:@selector(headerViewAction:) forControlEvents:UIControlEventTouchUpInside];
        _payButton.tag = ZFCarHeaderAction_PayButton;
        _payButton.layer.cornerRadius = 2;
        _payButton.layer.masksToBounds = YES;
        [_payButton setTitle:ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_PayNow",nil) forState:UIControlStateNormal];
    }
    return _payButton;
}

@end

