//
//  ZFCarCouponDetailsCodeHeaderView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/12.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCarCouponDetailsCodeHeaderView.h"
#import "ZFInitViewProtocol.h"
#import "ZFCartGoodsListModel.h"
#import "UILabel+HTML.h"
#import "ZFCartListResultModel.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFCartGoodsModel.h"
#import "UIImage+ZFExtended.h"
#import "NSString+Extended.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "SystemConfigUtils.h"

@interface ZFCarCouponDetailsCodeHeaderView () <ZFInitViewProtocol>
@property (nonatomic, strong) UILabel               *addCodesLabel;
@property (nonatomic, strong) UIButton              *nextButton;
@property (nonatomic, strong) UIImageView           *nextImageView;
@property (nonatomic, strong) UIView                *topCornerBgView;
@property (nonatomic, strong) UIView                *bottomCornerBgView;
@property (nonatomic, strong) UIButton              *leftPriceButton;
@property (nonatomic, strong) UIButton              *rightPriceButton;
//购物车不存在有效商品，只有失效商品或赠品时；优惠券模板置灰，无法点击
@property (nonatomic, strong) UIView                *topMaskView;
@end

@implementation ZFCarCouponDetailsCodeHeaderView
#pragma mark - init methods

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithReuseIdentifier:reuseIdentifier];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self addTapGestureBock];
    }
    return self;
}

//- (void)drawRect:(CGRect)rect {
//    [super drawRect:rect];
//    [self addTopLeftRightCorners];
//}
//
//- (void)addTopLeftRightCorners {
//    [self.topCornerBgView zfAddCorners:(UIRectCornerTopLeft | UIRectCornerTopRight) cornerRadii:CGSizeMake(8, 8)];
//}

- (void)addTapGestureBock {
    @weakify(self);
    [self.addCodesLabel addTapGestureWithComplete:^(UIView * _Nonnull view) {
        @strongify(self);
        if (self.addCodesHandler) {
            self.addCodesHandler();
        }
    }];
}

#pragma mark - action methods
- (void)nextButtonAction:(UIButton *)sender {
    if (self.addCodesHandler) {
        self.addCodesHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.contentView.backgroundColor = ZFC0xF2F2F2();
    
    [self.contentView addSubview:self.topCornerBgView];
    [self.topCornerBgView addSubview:self.addCodesLabel];
    [self.topCornerBgView addSubview:self.nextButton];
    [self.topCornerBgView addSubview:self.nextImageView];
    [self.topCornerBgView addSubview:self.topMaskView];
    
    [self.contentView addSubview:self.bottomCornerBgView];
    [self.bottomCornerBgView addSubview:self.leftPriceButton];
    [self.bottomCornerBgView addSubview:self.rightPriceButton];
}

- (void)zfAutoLayoutView {
//=============================Top Corner View==================================
    CGFloat topH = 48;
    [self.topCornerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView.mas_top);
        make.leading.trailing.mas_equalTo(self.contentView);
        make.height.mas_equalTo(topH);
    }];
    
    [self.addCodesLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topCornerBgView.mas_centerY);
        make.leading.mas_equalTo(self.topCornerBgView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.topCornerBgView).offset(-12);
        make.height.mas_equalTo(topH);
    }];
    
    [self.nextImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topCornerBgView.mas_centerY);
        make.trailing.mas_equalTo(self.topCornerBgView.mas_trailing).offset(-12);
        make.size.mas_equalTo(CGSizeMake(7, 10));
    }];
    
    [self.nextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.topCornerBgView.mas_centerY);
        make.trailing.mas_equalTo(self.nextImageView.mas_leading).offset(-5);
        make.height.mas_equalTo(topH);
        //make.bottom.mas_equalTo(self.topCornerBgView.mas_bottom);//撑高父视图
    }];
    
//=============================Bottom Corner View==================================
    
    [self.bottomCornerBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topCornerBgView.mas_bottom).offset(12);
        make.leading.trailing.mas_equalTo(self.contentView);
    }];
    
    [self.leftPriceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomCornerBgView.mas_top).offset(12);
        make.leading.mas_equalTo(self.addCodesLabel.mas_leading);
        make.width.mas_equalTo(KScreenWidth * 0.6);
        make.bottom.mas_equalTo(self.bottomCornerBgView.mas_bottom).offset(0);
    }];
    
    [self.rightPriceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftPriceButton.mas_top);
        // make.leading.mas_equalTo(self.leftPriceButton.mas_trailing);
        make.trailing.mas_equalTo(self.bottomCornerBgView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.bottomCornerBgView.mas_bottom);
    }];
    
    [self.topMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
}

#pragma mark - setter
- (void)setCartListResultModel:(ZFCartListResultModel *)cartListResultModel {
    _cartListResultModel = cartListResultModel;
    
    UIColor *defaultBlackColor = ZFCOLOR(45, 45, 45, 1);//黑色价格
    UIColor *grayColor = ZFCOLOR(204, 204, 204, 1); // 灰色价格
    UIColor *redPriceColor = ZFC0xFE5269();// 红色价格
    UIFont *defaultFont = ZFFontSystemSize(14);
    NSMutableArray *fontArray = [NSMutableArray arrayWithObject:ZFFontSystemSize(14)];
    
    NSString *productsTotalPrice = [NSString stringWithFormat:@"%@\n", [ExchangeManager transAppendPrice:cartListResultModel.productsTotalPrice currency:nil]];
    
    // (一定显示: Product Total)
    NSMutableArray *leftTextArray = [NSMutableArray arrayWithObject:[NSString stringWithFormat:@"%@\n", ZFLocalizedString(@"TotalPrice_Cell_ProductTotal", nil)]];
    NSMutableArray *rightTextArray = [NSMutableArray arrayWithObject:productsTotalPrice];
    
    NSMutableArray *leftColorArray = [NSMutableArray arrayWithObject:defaultBlackColor];
    NSMutableArray *rightColorArray = [NSMutableArray arrayWithObject:defaultBlackColor];
    
    // (可选显示: Event Discount)
    if (cartListResultModel.cart_discount_amount.floatValue > 0.0) {
        [leftTextArray addObject:[NSString stringWithFormat:@"%@\n", ZFLocalizedString(@"TotalPrice_Cell_EventDiscount", nil)]];
        [leftColorArray addObject:defaultBlackColor];
        
        NSString *discountAmount = [ExchangeManager transPurePriceforPrice:cartListResultModel.cart_discount_amount currency:nil priceType:PriceType_Off];
        
        [rightTextArray addObject:[NSString stringWithFormat:@"-%@\n",[ExchangeManager transAppendPrice:discountAmount currency:nil] ]];
        [rightColorArray addObject:redPriceColor];
        [fontArray addObject:defaultFont];
    }
    
    
    // (一定显示: Coupon)
    NSString *couponAmountPrice = [ExchangeManager transPurePriceforPrice:cartListResultModel.cart_coupon_amount currency:nil priceType:PriceType_Off];
    [leftTextArray addObject:[NSString stringWithFormat:@"%@\n", ZFLocalizedString(@"TotalPrice_Cell_Coupon", nil)]];
    [leftColorArray addObject:defaultBlackColor];
    
    
    [rightTextArray addObject:[NSString stringWithFormat:@"-%@\n", [ExchangeManager transAppendPrice:couponAmountPrice currency:nil]]];
    [rightColorArray addObject:redPriceColor];
    [fontArray addObject:defaultFont];
    
    
    // (可选显示: Student Discount)
    if (cartListResultModel.student_discount_amount.floatValue > 0.0) {
        [leftTextArray addObject:[NSString stringWithFormat:@"%@\n", ZFLocalizedString(@"StudentVIP_Discount_Title", nil)]];
        [leftColorArray addObject:defaultBlackColor];
        
        NSString *studentDiscount = [ExchangeManager transPurePriceforPrice:cartListResultModel.student_discount_amount currency:nil priceType:PriceType_Activity];
        [rightTextArray addObject:[NSString stringWithFormat:@"-%@\n", [ExchangeManager transAppendPrice:studentDiscount currency:nil]]];
        [rightColorArray addObject:redPriceColor];
        [fontArray addObject:defaultFont];
    }
    
    
    // (一定显示: Estimated Total)
    NSString *estimatedTotal = [NSString stringWithFormat:@"%@ \n", ZFLocalizedString(@"Car_Header_Estimated_Total", nil)];
    [leftTextArray addObject:estimatedTotal];
    [leftColorArray addObject:defaultBlackColor];
    
    [rightTextArray addObject:[NSString stringWithFormat:@"%@\n", [ExchangeManager transAppendPrice:cartListResultModel.totalAmount currency:nil]]];
    [rightColorArray addObject:defaultBlackColor];
    [fontArray addObject:ZFFontBoldSize(14)];
    
    NSTextAlignment leftBtnAlignment = NSTextAlignmentLeft;
    NSTextAlignment rightBtnAlignment = NSTextAlignmentRight;
    if ([SystemConfigUtils isRightToLeftShow]) {//阿语
        leftBtnAlignment = NSTextAlignmentRight;
        rightBtnAlignment = NSTextAlignmentLeft;
    } else {
        leftBtnAlignment = NSTextAlignmentLeft;
        rightBtnAlignment = NSTextAlignmentRight;
    }
    // 底部左侧全部显示文案
    [self.leftPriceButton setAttriStrWithTextArray:leftTextArray
                                           fontArr:fontArray
                                          colorArr:leftColorArray
                                       lineSpacing:15
                                         alignment:leftBtnAlignment];
    // 底部右侧全部显示文案
    [self.rightPriceButton setAttriStrWithTextArray:rightTextArray
                                            fontArr:fontArray
                                           colorArr:rightColorArray
                                        lineSpacing:15
                                          alignment:rightBtnAlignment];
    
    BOOL hideAllPrice = cartListResultModel.isAllUnavailableGoodsOrNoGoods;
    self.topMaskView.hidden = !hideAllPrice;
    self.bottomCornerBgView.hidden = hideAllPrice;
    self.leftPriceButton.hidden = hideAllPrice;
    self.rightPriceButton.hidden = hideAllPrice;
    
    UIColor *stautusColor = hideAllPrice ? grayColor : defaultBlackColor;
    self.nextButton.enabled = !hideAllPrice;
    self.nextImageView.image = [[UIImage imageNamed:@"next-right"] imageWithColor:stautusColor];
    
    // 优惠券按钮价格,及提示文案
    NSMutableArray *leftCodeColorArr = [NSMutableArray array];
    NSMutableArray *leftCodeTextArr = [NSMutableArray array];
    UIColor *rightCouponColor = redPriceColor;
    
    NSString *addCodesText = ZFLocalizedString(@"CartOrderInfo_PromotionCodeCell_PromotionCodeLabel", nil);
    NSString *codeAppliedText = [NSString stringWithFormat:@"%@\n", ZFLocalizedString(@"Car_1Code_Applied", nil)];
    //NSString *availableCouponsText = ZFLocalizedString(@"Car_Available_Coupons", nil);
    
    NSInteger availableCount = cartListResultModel.couponListModel.available.count;
    
    NSString *rightMainText = nil;
    if (!ZFIsEmptyString(couponAmountPrice)) {
        if (couponAmountPrice.floatValue <= 0.0) {
            if (availableCount == 0) {
                rightMainText = @""; //V4.6.0 @佳佳 说要去掉
            } else {
                rightMainText = @"";//V5.4.0 @佳佳 版本去掉提示显示可用优惠券数
                //rightMainText = [NSString stringWithFormat:@"%lu %@", (unsigned long)cartListResultModel.couponListModel.available.count, availableCouponsText];
            }
            rightCouponColor = grayColor;
        } else {
            rightMainText = [NSString stringWithFormat:@"-%@", [ExchangeManager transAppendPrice:couponAmountPrice currency:nil]];
        }
    }
    if (ISLOGIN) {
        if ([AccountManager sharedManager].hasSelectedAppCoupon) {
            if (ZFIsEmptyString([AccountManager sharedManager].selectedAppCouponCode)) {
                [leftCodeTextArr addObject:addCodesText];
                [leftCodeColorArr addObject:defaultBlackColor];
                if (availableCount == 0) {
                    rightMainText = @""; //V4.6.0 @佳佳 说要去掉
                } else {
                    rightMainText = @"";//V5.4.0 @佳佳 版本去掉提示显示可用优惠券数
                    //rightMainText = [NSString stringWithFormat:@"%lu %@", availableCount, availableCouponsText];
                }
                rightCouponColor = grayColor;
                
            } else {
                [leftCodeTextArr addObjectsFromArray:@[codeAppliedText, ZFToString(cartListResultModel.coupon_code)]];
                [leftCodeColorArr addObjectsFromArray:@[defaultBlackColor, grayColor]];
            }
        } else {
            if (!ZFIsEmptyString(couponAmountPrice) && !ZFIsEmptyString(cartListResultModel.coupon_code)) {
                [leftCodeTextArr addObjectsFromArray:@[codeAppliedText, ZFToString(cartListResultModel.coupon_code)]];
                [leftCodeColorArr addObjectsFromArray:@[defaultBlackColor, grayColor]];
            } else {
                [leftCodeTextArr addObject:addCodesText];
                [leftCodeColorArr addObject:defaultBlackColor];
            }
        }
    } else {
        [leftCodeTextArr addObjectsFromArray:@[addCodesText]];
        [leftCodeColorArr addObjectsFromArray:@[defaultBlackColor]];
    }
    
    self.addCodesLabel.text = nil;
    self.addCodesLabel.attributedText = nil;
    
    if (leftCodeTextArr.count == 1) {
        self.addCodesLabel.text = ZFToString([leftCodeTextArr firstObject]);
        self.addCodesLabel.textColor = hideAllPrice ? grayColor : [leftCodeColorArr firstObject];
        self.addCodesLabel.font = ZFFontSystemSize(14);
    } else {
        
        NSTextAlignment codesAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentLeft : NSTextAlignmentRight;
        self.addCodesLabel.attributedText = [NSString getAttriStrByTextArray:leftCodeTextArr
                                                                     fontArr:@[ZFFontBoldSize(14), ZFFontSystemSize(12)]
                                                                    colorArr:leftCodeColorArr
                                                                 lineSpacing:0
                                                                   alignment:codesAlignment];
    }
    
    if (hideAllPrice) { // 不可用时不显示任何
        rightMainText = @"";
    }
    [self.nextButton setTitle:ZFToString(rightMainText) forState:0];
    [self.nextButton setTitleColor:(hideAllPrice ? grayColor : rightCouponColor) forState:0];
    [self.nextButton setTitleColor:grayColor forState:UIControlStateDisabled];
    [self.nextButton zfLayoutStyle:(ZFButtonEdgeInsetsStyleRight) imageTitleSpace:3];
}

#pragma mark - getter
//=============================Top Corner View==================================

- (UIView *)topCornerBgView {
    if (!_topCornerBgView) {
        _topCornerBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _topCornerBgView.backgroundColor = [UIColor whiteColor];
        _topCornerBgView.layer.cornerRadius = 8;
        _topCornerBgView.layer.masksToBounds = YES;
    }
    return _topCornerBgView;
}

- (UIView *)topMaskView {
    if (!_topMaskView) {
        _topMaskView = [[UIView alloc] initWithFrame:CGRectZero];
//        _topMaskView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.2];
        _topMaskView.backgroundColor = [UIColor clearColor];
        _topMaskView.userInteractionEnabled = YES;
        _topMaskView.hidden = YES;
    }
    return _topMaskView;
}

- (UILabel *)addCodesLabel {
    if (!_addCodesLabel) {
        _addCodesLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _addCodesLabel.font = [UIFont systemFontOfSize:14];
        _addCodesLabel.preferredMaxLayoutWidth = KScreenWidth - 67;
        _addCodesLabel.textColor = ZFCOLOR_BLACK;
        _addCodesLabel.numberOfLines = 0;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _addCodesLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _addCodesLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return _addCodesLabel;
}

- (UIImageView *)nextImageView {
    if (!_nextImageView) {
        _nextImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"next-right"]];
        [_nextImageView convertUIWithARLanguage];
    }
    return _nextImageView;
}

- (UIButton *)nextButton {
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_nextButton setTitleColor:ZFCOLOR(153, 153, 153, 1) forState:0];
        _nextButton.titleLabel.font = ZFFontSystemSize(14);
        [_nextButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}
    
//=============================Bottom Corner View==================================

- (UIView *)bottomCornerBgView {
    if (!_bottomCornerBgView) {
        _bottomCornerBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomCornerBgView.backgroundColor = [UIColor whiteColor];
        _bottomCornerBgView.layer.cornerRadius = 8;
        _bottomCornerBgView.layer.masksToBounds = YES;
    }
    return _bottomCornerBgView;
}

- (UIButton *)leftPriceButton {
    if (!_leftPriceButton) {
        _leftPriceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftPriceButton.backgroundColor = ZFCOLOR_WHITE;
        _leftPriceButton.titleLabel.backgroundColor = ZFCOLOR_WHITE;
        [_leftPriceButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _leftPriceButton.titleLabel.font = ZFFontSystemSize(14);
        _leftPriceButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;//标题过长换行
        if ([SystemConfigUtils isRightToLeftShow]) {//阿语
            _leftPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        } else {
            _leftPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        }
    }
    return _leftPriceButton;
}

- (UIButton *)rightPriceButton {
    if (!_rightPriceButton) {
        _rightPriceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightPriceButton.backgroundColor = ZFCOLOR_WHITE;
        _rightPriceButton.titleLabel.backgroundColor = ZFCOLOR_WHITE;
        [_rightPriceButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _rightPriceButton.titleLabel.font = ZFFontSystemSize(14);
        _rightPriceButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;//标题过长换行
        if ([SystemConfigUtils isRightToLeftShow]) {//阿语
            _rightPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        } else {
            _rightPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        }
    }
    return _rightPriceButton;
}

@end
