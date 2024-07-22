//
//  ZFOrderPlaceBottomView.m
//  ZZZZZ
//
//  Created by YW on 2018/8/13.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFOrderPlaceBottomView.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "UILabel+HTML.h"
#import "NSAttributedString+YYText.h"
#import "ExchangeManager.h"
#import "FilterManager.h"

@interface ZFOrderPlaceBottomView ()
@property (nonatomic, strong) UILabel *priceTipsLabel;
@property (nonatomic, strong) UILabel *priceValueLabel;
@property (nonatomic, strong) UIButton *placeOrderButton;
@property (nonatomic, strong) UIView *priceView;
@property (nonatomic, strong) UILabel *rewardPointsLabel;
@property (nonatomic, strong) UILabel *rewardCouponLabel;
// 居中布局
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UILabel *centerPriceTipsLabel;
@property (nonatomic, strong) UILabel *centerPriceValueLabel;

@property (nonatomic, strong) MASConstraint *priceViewConsHeight;
@end

@implementation ZFOrderPlaceBottomView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.clipsToBounds = NO;
        [self initUI];
    }
    return self;
}

-(void)initUI {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.placeOrderButton];
    [self addSubview:self.priceView];
    
    ///为了遮挡往下移的 priceView
    UIView *buttonMaskView = [[UIView alloc] init];
    buttonMaskView.backgroundColor = [UIColor whiteColor];
    [self addSubview:buttonMaskView];
    [self sendSubviewToBack:buttonMaskView];
    [buttonMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];

    [self.priceView addSubview:self.priceTipsLabel];
    [self.priceView addSubview:self.priceValueLabel];
    [self.priceView addSubview:self.rewardPointsLabel];
    [self.priceView addSubview:self.rewardCouponLabel];
    [self.priceView addSubview:self.centerView];
    [self.centerView addSubview:self.centerPriceTipsLabel];
    [self.centerView addSubview:self.centerPriceValueLabel];
    [self sendSubviewToBack:self.priceView];
    
//    ///为了子视图居中布局
//    UIView *maskView = [[UIView alloc] init];
//    maskView.backgroundColor = [UIColor redColor];
//    [self.priceView addSubview:maskView];
//    [self sendSubviewToBack:self.priceView];
//    [maskView addSubview:self.priceValueLabel];
//    [maskView addSubview:self.priceTipsLabel];
//    [maskView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.mas_equalTo(self.priceView);
//        make.bottom.mas_equalTo(self.priceView);
//    }];

    [self.priceView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(self.mas_top).mas_offset(0);
        make.leading.trailing.mas_equalTo(self);
        self.priceViewConsHeight = make.height.mas_offset(38);
    }];
    
    [self.priceTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceView).offset(6);
        make.trailing.mas_equalTo(self.priceView.mas_trailing).offset(-16);
        make.height.mas_offset(16);
    }];
    
    [self.priceValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceTipsLabel.mas_bottom);
        make.trailing.mas_equalTo(self.priceTipsLabel.mas_trailing);
        make.height.mas_offset(16);
    }];
    
    [self.rewardPointsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.priceView.mas_top).offset(8);
        make.leading.mas_equalTo(self.priceView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.priceTipsLabel.mas_leading);
        make.height.mas_equalTo(15);
    }];
    [self.rewardPointsLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.rewardCouponLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.rewardPointsLabel.mas_bottom).offset(0);
        make.leading.mas_equalTo(self.priceView.mas_leading).offset(16);
        make.trailing.mas_equalTo(self.priceValueLabel.mas_leading).offset(-5);
        make.height.mas_equalTo(15);
    }];
    [self.rewardCouponLabel setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];

    [self.placeOrderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).mas_offset(16);
        make.trailing.mas_equalTo(self).mas_offset(-16);
        make.height.mas_offset(40);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-(kiphoneXHomeBarHeight + 8));
    }];
    
    // 局中布局
     [self.centerView mas_makeConstraints:^(MASConstraintMaker *make) {
           make.centerX.mas_equalTo(self.priceView);
           make.bottom.mas_equalTo(self.priceView);
       }];
    
    [self.centerPriceTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.bottom.mas_equalTo(self.centerView);
        make.height.mas_equalTo(20);
    }];
    
    [self.centerPriceValueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.bottom.mas_equalTo(0);
        make.height.mas_equalTo(20);
        make.leading.mas_equalTo(self.centerPriceTipsLabel.mas_trailing);
    }];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self.priceView addDropShadowWithOffset:CGSizeMake(0, -2)
                                     radius:2
                                      color:[UIColor blackColor]
                                    opacity:0.1];
//
//    [self addDropShadowWithOffset:CGSizeMake(0, -2)
//                           radius:2
//                            color:[UIColor blackColor]
//                          opacity:0.1];
}

#pragma mark - public method

- (void)exchangePriceViewStatus:(BOOL)status
{
    __block CGFloat offSet = 0;
    __block CGFloat alpha = 0;
    if (status) {
        offSet = 44;
        alpha = 0;
    } else {
        offSet = 0;
        alpha = 1;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.priceView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.mas_top).mas_offset(offSet);
        }];
//        self.priceView.alpha = alpha;
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }];
}

#pragma mark - target

-(void)placeOrderButtonAction {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFOrderPlaceBottomViewDidClickPlaceOrderButton)]) {
        [self.delegate ZFOrderPlaceBottomViewDidClickPlaceOrderButton];
    }
}

#pragma mark - setter and getter

-(void)setDetailModel:(ZFOrderAmountDetailModel *)detailModel {
    _detailModel = detailModel;
    if (_detailModel.attriValue) {
        self.priceValueLabel.text = nil;
        self.priceValueLabel.attributedText = _detailModel.attriValue;
        self.centerPriceValueLabel.text = nil;
        self.centerPriceValueLabel.attributedText = _detailModel.attriValue;
    } else {
        self.priceValueLabel.attributedText = nil;
        self.priceValueLabel.text = _detailModel.value;
        self.centerPriceValueLabel.attributedText = nil;
        self.centerPriceValueLabel.text = _detailModel.value;
    }
    
//    if (!self.manager.isUsePoint) {
//        [self.sectionArray addObject:@[[ZFOrderRewardPointsCell class]]];
//    }
}

-(void)setIsFast:(BOOL)isFast {
    _isFast = isFast;
    NSString *title = _isFast ? ZFLocalizedString(@"MyOrders_Cell_PayNow",nil) : ZFLocalizedString(@"CartOrderInformationBottomView_PlaceOrderBtn",nil);
    [self.placeOrderButton setTitle:title forState:UIControlStateNormal];
}

-(void)setPlaceOrderButtonState:(BOOL)placeOrderButtonState {
    if (placeOrderButtonState) {
        self.placeOrderButton.enabled = NO;
        [self.placeOrderButton setBackgroundColor:ZFCOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
    } else{
        self.placeOrderButton.enabled = YES;
        [self.placeOrderButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [self.placeOrderButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
    }
}

-(void)setCurrentPaymentType:(CurrentPaymentType)currentPaymentType
{
    _currentPaymentType = currentPaymentType;
    NSString *maohao = @": ";
    if (currentPaymentType == CurrentPaymentTypeCOD) {
        self.priceTipsLabel.text = [ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_TotalPayable", nil) stringByAppendingString:maohao];
        self.centerPriceTipsLabel.text = [ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_TotalPayable", nil) stringByAppendingString:maohao];
    }else{
        self.priceTipsLabel.text = [ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_GrandTotal", nil) stringByAppendingString:maohao];
        self.centerPriceTipsLabel.text = [ZFLocalizedString(@"OrderDetail_TotalPrice_Cell_GrandTotal", nil) stringByAppendingString:maohao];
    }
}

- (void)setIsShowRewardPoints:(BOOL)isShowRewardPoints {
    _isShowRewardPoints = isShowRewardPoints;
    self.rewardPointsLabel.hidden = !isShowRewardPoints;
}

- (void)setCheckOutModel:(ZFOrderCheckInfoDetailModel *)checkOutModel {
    _checkOutModel = checkOutModel;
    if ([ZFToString(checkOutModel.first_order_bts_result.policy) isEqualToString:@"1"]) {
        self.rewardCouponLabel.hidden = NO;
        NSString *couponTip = self.checkOutModel.first_order_Coupon;
        if (!ZFIsEmptyString(self.checkOutModel.first_order_Coupon_amount)) {
            NSString *currency = self.currentPaymentType == CurrentPaymentTypeCOD ? [FilterManager tempCurrency] : [ExchangeManager localCurrency];
            NSString *priceString = [ExchangeManager transPurePriceforCurrencyPrice:self.checkOutModel.first_order_Coupon_amount currency:currency priceType:PriceType_Coupon];
            NSRange originalRange = [self.checkOutModel.first_order_Coupon rangeOfString:self.checkOutModel.first_order_Coupon_amount];
            if (originalRange.location != NSNotFound) {
                couponTip = [couponTip stringByReplacingCharactersInRange:originalRange withString:priceString];
            }
        }
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithData:[couponTip dataUsingEncoding:NSUnicodeStringEncoding] options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType, NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)} documentAttributes:nil error:nil];
        attr.yy_font = [UIFont systemFontOfSize:11];
        attr.yy_lineBreakMode = NSLineBreakByTruncatingTail;
        _rewardCouponLabel.attributedText = attr;
    } else {
        self.rewardCouponLabel.hidden = YES;
    }
    
    [_rewardPointsLabel zf_setHTMLFromString:self.checkOutModel.get_points];
}

- (void)setIsCenterShow:(BOOL)isCenterShow {
    _isCenterShow = isCenterShow;
    self.centerView.hidden = !isCenterShow;
    self.priceTipsLabel.hidden = isCenterShow;
    self.priceValueLabel.hidden = isCenterShow;
    CGFloat height = isCenterShow ? 28 : 38;
    self.priceViewConsHeight.mas_equalTo(height);
}

- (UILabel *)priceValueLabel {
    if (!_priceValueLabel) {
        _priceValueLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = ZFCOLOR(45, 45, 45, 1);
            label.font = ZFFontBoldSize(16);
            label;
        });
    }
    return _priceValueLabel;
}

-(UILabel *)priceTipsLabel {
    if (!_priceTipsLabel) {
        _priceTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.textAlignment = NSTextAlignmentRight;
            label.textColor = ZFCOLOR(153, 153, 153, 1);
            label.font = ZFFontSystemSize(10);
            label;
        });
    }
    return _priceTipsLabel;
}

-(UIButton *)placeOrderButton {
    if (!_placeOrderButton) {
        _placeOrderButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.layer.cornerRadius = 3;
            button.layer.masksToBounds = YES;
            [button setTitle:ZFLocalizedString(@"CartOrderInformationBottomView_PlaceOrderBtn", nil) forState:UIControlStateNormal];
            button.titleLabel.font = ZFFontBoldSize(16);
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(placeOrderButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _placeOrderButton;
}

- (UIView *)priceView
{
    if (!_priceView) {
        _priceView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            view;
        });
    }
    return _priceView;
}

- (UILabel *)rewardPointsLabel {
    if (!_rewardPointsLabel) {
        _rewardPointsLabel = [[UILabel alloc] init];
        _rewardPointsLabel.font = [UIFont systemFontOfSize:11];
        _rewardPointsLabel.textColor = ZFCOLOR(153, 153, 153, 1);
//        _rewardPointsLabel.hidden = YES;
    }
    return _rewardPointsLabel;
}

- (UILabel *)rewardCouponLabel {
    if (!_rewardCouponLabel) {
        _rewardCouponLabel = [[UILabel alloc] init];
        _rewardCouponLabel.font = [UIFont systemFontOfSize:11];
        _rewardCouponLabel.textColor = ZFCOLOR(153, 153, 153, 1);
        _rewardCouponLabel.numberOfLines = 1;
        _rewardCouponLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _rewardCouponLabel;
}

- (UIView *)centerView {
    if (!_centerView) {
        _centerView = [[UIView alloc] init];
        _centerView.hidden = YES;
    }
    return _centerView;
}

-(UILabel *)centerPriceTipsLabel {
    if (!_centerPriceTipsLabel) {
        _centerPriceTipsLabel = [[UILabel alloc] init];
        _centerPriceTipsLabel.font = ZFFontBoldSize(16);
        _centerPriceTipsLabel.textColor = [UIColor blackColor];
    }
    return _centerPriceTipsLabel;
}

- (UILabel *)centerPriceValueLabel {
    if (!_centerPriceValueLabel) {
        _centerPriceValueLabel = [[UILabel alloc] init];
        _centerPriceValueLabel.font = ZFFontBoldSize(16);
        _centerPriceValueLabel.textColor = [UIColor blackColor];
    }
    return _centerPriceValueLabel;
}

@end
