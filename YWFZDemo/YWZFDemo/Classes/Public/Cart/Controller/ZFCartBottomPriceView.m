//
//  ZFCartBottomPriceView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartBottomPriceView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCartListResultModel.h"
#import "ZFCartGoodsListModel.h"
#import "ZFCartGoodsModel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "UIButton+ZFButtonCategorySet.h"

static NSInteger kBottomTextHeight = 15;

@interface ZFCartBottomPriceView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIView                *lineView;
@property (nonatomic, strong) UIView                *totolNewPriceView;
@property (nonatomic, strong) UILabel               *totolNewNameLabel;
@property (nonatomic, strong) UILabel               *totolNewPriceLabel;

//@property (nonatomic, strong) UILabel               *totolPriceLabel;
@property (nonatomic, strong) UILabel               *discountPriceLabel;
@property (nonatomic, strong) UIButton              *checkOutButton;
@property (nonatomic, strong) UIButton              *fastPayButton;
@property (nonatomic, strong) UIView                *bottomTipBgView;
@property (nonatomic, strong) UILabel               *bottomFirstLabel;
@property (nonatomic, strong) UILabel               *bottomSecondLabel;
@property (nonatomic, strong) NSTimer               *tipTimer;
@end

@implementation ZFCartBottomPriceView

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
//    [self addSubview:self.lineView];
//    [self addSubview:self.totolPriceLabel];
    [self addSubview:self.totolNewPriceView];
    [self.totolNewPriceView addSubview:self.totolNewNameLabel];
    [self.totolNewPriceView addSubview:self.totolNewPriceLabel];
    
    [self addSubview:self.discountPriceLabel];
    [self addSubview:self.checkOutButton];
    [self addSubview:self.fastPayButton];
    [self addSubview:self.bottomTipBgView];
    [self addSubview:self.bottomFirstLabel];
    [self addSubview:self.bottomSecondLabel];
}

- (void)zfAutoLayoutView {
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.leading.trailing.mas_equalTo(self);
//        make.height.mas_equalTo(0.5);
//    }];
    
//    [self.totolPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.mas_top).offset(5);
//        make.centerX.mas_equalTo(self.mas_centerX);
//    }];
    
//    [self.discountPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.totolPriceLabel.mas_bottom);
//        make.centerX.mas_equalTo(self.mas_centerX);
//    }];
    
    [self.totolNewPriceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(5);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.totolNewNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.totolNewPriceView);
        make.leading.mas_equalTo(self.totolNewPriceView.mas_leading);
    }];
    
    [self.totolNewPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.totolNewPriceView);
        make.leading.mas_equalTo(self.totolNewNameLabel.mas_trailing);
        make.trailing.mas_equalTo(self.totolNewPriceView.mas_trailing);
    }];
    
    [self.discountPriceLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totolNewPriceView.mas_bottom);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.fastPayButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.discountPriceLabel.mas_bottom).offset(3);
        make.leading.mas_equalTo(self);
        make.size.mas_equalTo(CGSizeMake(KScreenWidth / 2, 40));
    }];
    
    [self.checkOutButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.fastPayButton.mas_top);
        make.leading.mas_equalTo(self.fastPayButton.mas_trailing);
        make.trailing.mas_equalTo(self);
        make.height.mas_equalTo(40);
    }];
    
    [self.bottomTipBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.checkOutButton.mas_bottom).offset(4);
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(kBottomTextHeight);
        make.bottom.mas_equalTo(self.mas_bottom).offset(IPHONE_X_5_15 ? 0 : -4);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addDropShadowWithOffset:CGSizeMake(0, -1)
                           radius:2
                            color:[UIColor blackColor]
                          opacity:0.1];
}

#pragma mark - setter
- (void)setModel:(ZFCartListResultModel *)model {
    _model = model;
    
    CGFloat totalPrice = 0.0;
    NSInteger availableGoodsCount = 0;
    NSInteger payoffCount = 0;
    
    for (int i = 0; i < [_model.goodsBlockList count]; i++) {
        ZFCartGoodsListModel *listModel = _model.goodsBlockList[i];
        if ([listModel.goodsModuleType integerValue] == ZFCartListBlocksTypeUnavailable) {
            continue;
        }
        
        BOOL isFreeGiftType = ([listModel.goodsModuleType integerValue] == ZFCartListBlocksTypeFreeGift) ? YES : NO;
        if (listModel.cartList.count > 0 && isFreeGiftType == NO) {
            availableGoodsCount += 1;
        }
        for (int j = 0; j < [listModel.cartList count]; j++) {
            ZFCartGoodsModel *goodsModel = listModel.cartList[j];
            if (goodsModel.is_selected == NO) continue;
            
            if (isFreeGiftType == NO) {
                double price = [ExchangeManager transPurePriceforPrice:goodsModel.shop_price currency:nil priceType:PriceType_ProductPrice].doubleValue;
                totalPrice += price * (double)goodsModel.buy_number;
                
                payoffCount += goodsModel.buy_number;
            } else { // 赠品
                // 未达到满赠金额不能算结算件数
                if (ZFIsEmptyString(listModel.diff_msg) || ZFIsEmptyString(listModel.diff_amount)) {
                    payoffCount += goodsModel.buy_number;
                }
            }
        }
    }
    
    // 优惠券栏用到
    _model.isAllUnavailableGoodsOrNoGoods = (availableGoodsCount == 0) ? YES : NO;
    
    // 所有商品总价
    _model.productsTotalPrice = [NSString stringWithFormat:@"%.2f", totalPrice];
    
    // 减去Event Discount
    CGFloat allDiscountPrice = 0.00;
    if (model.cart_discount_amount.doubleValue > 0.0) {
        allDiscountPrice += model.cart_discount_amount.doubleValue;
    }
    // 减去Coupon
    allDiscountPrice += model.cart_coupon_amount.doubleValue;
    
    // 减去Student Discount
    if (model.student_discount_amount.doubleValue > 0.0) {
        allDiscountPrice += model.student_discount_amount.doubleValue;
    }
    allDiscountPrice = [ExchangeManager transPurePriceforPrice:[NSString stringWithFormat:@"%.2f", allDiscountPrice] currency:nil priceType:PriceType_Off].doubleValue;
    
    _model.totalAmount =  [NSString stringWithFormat:@"%.2f", (totalPrice - allDiscountPrice)];
    
    //显示总价格 V4.5.3
    NSString *totalAmount = [ExchangeManager transAppendPrice:_model.totalAmount currency:nil];
    
    self.totolNewNameLabel.text = ZFLocalizedString(@"Bag_Total", nil);
    self.totolNewPriceLabel.text = totalAmount;
    
    // V4.7.0不显示折扣价格
    self.discountPriceLabel.hidden = YES;
    
    // 是否显示快捷支付按钮
    self.checkOutButton.hidden = (self.model.goodsBlockList.count == 0);
    self.fastPayButton.hidden = !(self.model.is_show_fast_payment);
    
    [self.totolNewPriceView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mas_top).offset(8);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.checkOutButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.totolNewPriceView.mas_bottom).offset(6);
        make.height.mas_equalTo(40);
        if (self.fastPayButton.hidden) {
            make.leading.mas_equalTo(self).offset(12);
            make.trailing.mas_equalTo(self).offset(-12);;
        } else {
            make.leading.mas_equalTo(self.fastPayButton.mas_trailing).offset(12);
            make.trailing.mas_equalTo(self).offset(-12);
        }
    }];
    
    if (!self.fastPayButton.hidden) {
        [self.fastPayButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.checkOutButton.mas_top);
            make.leading.mas_equalTo(self).offset(12);
            make.size.mas_equalTo(CGSizeMake((KScreenWidth - 36) / 2, 40));
        }];
        self.checkOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    } else {
        self.checkOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
    }
    
    // 是否显示底部提示文案
    _bottomFirstLabel.hidden = YES;
    if (!ZFIsEmptyString(self.model.cartUserHint)) {
        self.bottomFirstLabel.text = ZFToString(self.model.cartUserHint);//显示底部优惠券提示: "下一步..."
        self.bottomFirstLabel.frame = CGRectMake(0, 0, KScreenWidth, kBottomTextHeight);
        self.bottomFirstLabel.hidden = NO;
    }
    
    _bottomSecondLabel.hidden = YES;
    NSString *tips = self.model.offerMessageModel.tips;
    NSString *amount = self.model.offerMessageModel.amount;
    if (!ZFIsEmptyString(tips) && !ZFIsEmptyString(amount)) {
        if ([tips containsString:amount]) {
            NSString *showAmount = [ExchangeManager transforPrice:amount];
            tips = [tips stringByReplacingOccurrencesOfString:amount withString:showAmount];
        }
        self.bottomSecondLabel.text = ZFToString(tips);
        self.bottomSecondLabel.text = ZFToString(tips);
        CGFloat secondLabelY = self.bottomFirstLabel.isHidden ? 0 : kBottomTextHeight;
        self.bottomSecondLabel.frame = CGRectMake(0, secondLabelY, KScreenWidth, kBottomTextHeight);
        self.bottomSecondLabel.hidden = NO;
    }
    
    BOOL showTipView = (!_bottomFirstLabel.isHidden || !_bottomSecondLabel.isHidden);
    self.bottomTipBgView.hidden = !showTipView;
    [self.bottomTipBgView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(showTipView ? kBottomTextHeight : 0);//是否隐藏底部提示
    }];
    
    if (showTipView) {
        [self.bottomTipBgView addSubview:self.bottomFirstLabel];
        [self.bottomTipBgView addSubview:self.bottomSecondLabel];
    }
    if ((!_bottomFirstLabel.isHidden && !_bottomSecondLabel.isHidden)) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.tipTimer fire];
        });
    } else {
        [self invalidateTipTimer];
    }
    
    // 结算按钮需要显示数量
    NSString *title = [NSString stringWithFormat:@"%@(%zd)",ZFLocalizedString(@"Bag_CheckOut",nil), payoffCount];
    [self.checkOutButton setTitle:title forState:UIControlStateNormal];
}

- (void)setScrollText {
    if (self.bottomFirstLabel.y <= -kBottomTextHeight) {
        self.bottomFirstLabel.y = kBottomTextHeight;
    }
    if (self.bottomSecondLabel.y <= -kBottomTextHeight) {
        self.bottomSecondLabel.y = kBottomTextHeight;
    }
    [UIView animateWithDuration:0.5 animations:^{
        self.bottomFirstLabel.y -= kBottomTextHeight;
        self.bottomSecondLabel.y -= kBottomTextHeight;
    }];
}

- (NSTimer *)tipTimer {
    if (!_tipTimer) {
        _tipTimer = [NSTimer scheduledTimerWithTimeInterval:2
                                                     target:self
                                                   selector:@selector(setScrollText)
                                                   userInfo:nil
                                                    repeats:YES];
    }
    return _tipTimer;
}

- (void)invalidateTipTimer {
    if (_tipTimer) {
        [self.tipTimer invalidate];
        self.tipTimer = nil;
    }
}

/**
 * 刷新按钮状态
 */
- (void)refreshButtonEnabledStatus:(BOOL)isEnabled {
    self.fastPayButton.enabled = isEnabled;
    self.checkOutButton.enabled = isEnabled;
}

#pragma mark - action methods
- (void)optionViewActionAction:(UIButton *)sender {
    ZFCartBottomPriceViewActionType actionType = sender.tag;
    if (self.cartOptionViewActionBlock) {
        self.cartOptionViewActionBlock(actionType);
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

//- (UILabel *)totolPriceLabel {
//    if (!_totolPriceLabel) {
//        _totolPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
//        _totolPriceLabel.font = [UIFont boldSystemFontOfSize:16];
//        _totolPriceLabel.textAlignment = NSTextAlignmentCenter; //V4.5.3以后 需要居中总价
//        _totolPriceLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
//    }
//    return _totolPriceLabel;
//}

- (UILabel *)discountPriceLabel {
    if (!_discountPriceLabel) {
        _discountPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _discountPriceLabel.textColor = ZFCOLOR(153, 153, 153, 1.f);
        _discountPriceLabel.font = [UIFont systemFontOfSize:12];
        _discountPriceLabel.textAlignment = NSTextAlignmentCenter;//V4.5.3以后 需要居中折扣价
    }
    return _discountPriceLabel;
}

- (UIButton *)fastPayButton {
    if (!_fastPayButton) {
        _fastPayButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _fastPayButton.layer.cornerRadius = 3;
        _fastPayButton.layer.masksToBounds = YES;
        _fastPayButton.backgroundColor = ZFC0xFFC439();
        [_fastPayButton setImage:[UIImage imageNamed:@"fast_paypal"] forState:UIControlStateNormal];
        [_fastPayButton setImage:[UIImage imageNamed:@"fast_paypal_disable"] forState:UIControlStateDisabled];
        [_fastPayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_fastPayButton addTarget:self action:@selector(optionViewActionAction:) forControlEvents:UIControlEventTouchUpInside];
        _fastPayButton.tag = PayPalBtnActionType;
    }
    return _fastPayButton;
}

- (UIButton *)checkOutButton {
    if (!_checkOutButton ) {
        _checkOutButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _checkOutButton.layer.cornerRadius = 3;
        _checkOutButton.layer.masksToBounds = YES;
        _checkOutButton.titleLabel.font = [UIFont boldSystemFontOfSize:16.0];
        //_checkOutButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        _checkOutButton.titleLabel.numberOfLines = 0;
        [_checkOutButton.titleLabel setTextAlignment:NSTextAlignmentCenter];
        [_checkOutButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_checkOutButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_checkOutButton setBackgroundColor:ZFCOLOR(135, 135, 135, 1.f) forState:UIControlStateDisabled];
        
        [_checkOutButton setTitle:ZFLocalizedString(@"Bag_CheckOut",nil) forState:UIControlStateDisabled];
        [_checkOutButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateDisabled];
        [_checkOutButton setTitle:ZFLocalizedString(@"Bag_CheckOut",nil) forState:UIControlStateNormal];
        [_checkOutButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_checkOutButton addTarget:self action:@selector(optionViewActionAction:) forControlEvents:UIControlEventTouchUpInside];
        _checkOutButton.contentEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 8);
        _checkOutButton.tag = CheckoutOutBtnActionType;
    }
    return _checkOutButton;
}

- (UILabel *)bottomFirstLabel {
    if (!_bottomFirstLabel) {
        _bottomFirstLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bottomFirstLabel.font = ZFFontSystemSize(10.0);
        _bottomFirstLabel.numberOfLines = 0;
        _bottomFirstLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _bottomFirstLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomFirstLabel;
}

- (UILabel *)bottomSecondLabel {
    if (!_bottomSecondLabel) {
        _bottomSecondLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _bottomSecondLabel.font = ZFFontSystemSize(10.0);
        _bottomSecondLabel.numberOfLines = 0;
        _bottomSecondLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _bottomSecondLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _bottomSecondLabel;
}

- (UIView *)bottomTipBgView {
    if (!_bottomTipBgView) {
        _bottomTipBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomTipBgView.backgroundColor = [UIColor whiteColor];
        _bottomTipBgView.clipsToBounds = YES;
    }
    return _bottomTipBgView;
}

- (UIView *)totolNewPriceView {
    if (!_totolNewPriceView) {
        _totolNewPriceView = [[UIView alloc] initWithFrame:CGRectZero];
    }
    return _totolNewPriceView;
}

- (UILabel *)totolNewNameLabel {
    if (!_totolNewNameLabel) {
        _totolNewNameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totolNewNameLabel.font = [UIFont boldSystemFontOfSize:16];
        _totolNewNameLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
    }
    return _totolNewNameLabel;
}

- (UILabel *)totolNewPriceLabel {
    if (!_totolNewPriceLabel) {
        _totolNewPriceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _totolNewPriceLabel.font = [UIFont boldSystemFontOfSize:16];
        _totolNewPriceLabel.textColor = ZFCOLOR(51, 51, 51, 1.f);
    }
    return _totolNewPriceLabel;
}
@end
