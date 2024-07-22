//
//  ZFCartCouponDetailsView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/13.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFCartCouponDetailsView.h"
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
#import "BigClickAreaButton.h"

#define kCartCouponContainViewHeight (185.0)

@interface ZFCartCouponDetailsView () <ZFInitViewProtocol>
@property (nonatomic, strong) UIView                *maskBgView;
@property (nonatomic, strong) UIView                *containView;
@property (nonatomic, strong) UIView                *topView;
@property (nonatomic, strong) BigClickAreaButton    *closeButton;
@property (nonatomic, strong) UILabel               *topTitleLabel;
@property (nonatomic, strong) UIButton              *leftPriceButton;
@property (nonatomic, strong) UIButton              *rightPriceButton;
@property (nonatomic, assign) CGFloat               containHeight;
@end

@implementation ZFCartCouponDetailsView

- (void)dealloc {
    YWLog(@"ZFCartCouponDetailsView dealloc");
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.clipsToBounds = YES;
    }
    return self;
}

#pragma mark - <ZFInitViewProtocol>

- (void)zfInitView {
    self.backgroundColor = [UIColor clearColor];
    [self addSubview:self.maskBgView];
    [self addSubview:self.containView];
    [self addSubview:self.topView];
    [self.topView addSubview:self.topTitleLabel];
    [self.topView addSubview:self.closeButton];
    [self.containView addSubview:self.leftPriceButton];
    [self.containView addSubview:self.rightPriceButton];
}

- (void)zfAutoLayoutView {
    [self.maskBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.containView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.top.mas_equalTo(self.mas_bottom);
        make.height.mas_equalTo(kCartCouponContainViewHeight);
    }];
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.containView);
        make.height.mas_equalTo(44);
    }];
    
    [self.topTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.topView);
        make.height.mas_equalTo(44);
    }];
    
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.top.mas_equalTo(self.topView);
        make.size.mas_equalTo(CGSizeMake(44, 44));
    }];
    
    [self.leftPriceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topTitleLabel.mas_bottom).offset(30);
        make.leading.mas_equalTo(self.containView.mas_leading).offset(12);
        make.width.mas_equalTo(KScreenWidth * 0.6);
        make.bottom.mas_equalTo(self.containView.mas_bottom).offset(0);
    }];
    
    [self.rightPriceButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.leftPriceButton.mas_top);
        make.leading.mas_equalTo(self.leftPriceButton.mas_trailing);
        make.trailing.mas_equalTo(self.containView.mas_trailing).offset(-12);
        make.bottom.mas_equalTo(self.leftPriceButton.mas_bottom);
    }];
}

#pragma mark -===========刷新数据===========

- (void)setCartListResultModel:(ZFCartListResultModel *)cartListResultModel {
    _cartListResultModel = cartListResultModel;
    
    UIColor *defaultBlackColor = ZFCOLOR(45, 45, 45, 1);//黑色价格
    //UIColor *grayColor = ZFCOLOR(153, 153, 153, 1); // 灰色价格
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
    
    
    // (可选显示: Student discount)
    if (cartListResultModel.student_discount_amount.floatValue > 0.0) {
        [leftTextArray addObject:[NSString stringWithFormat:@"%@\n", ZFLocalizedString(@"StudentVIP_Discount_Title", nil)]];
        [leftColorArray addObject:defaultBlackColor];
        
        [rightTextArray addObject:[NSString stringWithFormat:@"-%@\n", [ExchangeManager transAppendPrice:cartListResultModel.student_discount_amount currency:nil]]];
        [rightColorArray addObject:redPriceColor];
        [fontArray addObject:defaultFont];
    }
    
    
//    // (一定显示: Estimated Total)
//    NSString *estimatedTotal = [NSString stringWithFormat:@"%@ \n", ZFLocalizedString(@"Car_Header_Estimated_Total", nil)];
//    [leftTextArray addObject:estimatedTotal];
//    [leftColorArray addObject:defaultBlackColor];
//
//    [rightTextArray addObject:[NSString stringWithFormat:@"%@\n", [ExchangeManager transAppendPrice:cartListResultModel.totalAmount currency:nil]]];
//    [rightColorArray addObject:defaultBlackColor];
//    [fontArray addObject:ZFFontBoldSize(14)];
    
    // 底部左侧全部显示文案
    [self.leftPriceButton setAttriStrWithTextArray:leftTextArray
                                           fontArr:fontArray
                                          colorArr:leftColorArray
                                       lineSpacing:15
                                         alignment:NSTextAlignmentLeft];
    // 底部右侧全部显示文案
    [self.rightPriceButton setAttriStrWithTextArray:rightTextArray
                                            fontArr:fontArray
                                           colorArr:rightColorArray
                                        lineSpacing:15
                                          alignment:NSTextAlignmentRight];
}

- (void)showCouponInfoView:(BOOL)show popHeight:(CGFloat)popHeight {
    self.containHeight = popHeight;
    if (show) {
        self.hidden = NO;
    }
    [self.containView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(popHeight);
        if (show) {
            make.bottom.mas_equalTo(self.mas_bottom).offset(5);
        } else {
            make.top.mas_equalTo(self.mas_bottom);
        }
    }];
    [UIView animateWithDuration:0.3 delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:5
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         self.maskBgView.alpha = show ? 1.0 : 0.0;
                         [self layoutIfNeeded];
                     } completion:^(BOOL finished) {
                         self.hidden = !show;
                     }];
    
    if (!show && self.couponDetailsViewBlock) {
        self.couponDetailsViewBlock(ZFCartCouponDetailsView_FinishDismissActionType);
    }
}

#pragma mark -===========按钮事件===========

- (void)closeButtonAction {
    [self showCouponInfoView:NO popHeight:self.containHeight];
}

#pragma mark -===========init UI===========

- (UIView *)maskBgView {
    if (!_maskBgView) {
        _maskBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskBgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        _maskBgView.alpha = 0.0;
        @weakify(self);
        [_maskBgView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            [self showCouponInfoView:NO popHeight:self.containHeight];
        }];
    }
    return _maskBgView;
}

- (UIView *)containView {
    if (!_containView) {
        _containView = [[UIView alloc] initWithFrame:CGRectZero];
        _containView.backgroundColor = [UIColor whiteColor];
    }
    return _containView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] initWithFrame:CGRectZero];
        _topView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _topView;
}

- (UILabel *)topTitleLabel {
    if (!_topTitleLabel) {
        _topTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _topTitleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _topTitleLabel.font = ZFFontSystemSize(16);
        _topTitleLabel.textAlignment = NSTextAlignmentCenter;
        NSString *showText = ZFLocalizedString(@"Cart_summary",nil);
        _topTitleLabel.text = showText;
    }
    return _topTitleLabel;
}

- (BigClickAreaButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:[UIImage imageNamed:@"size_close"] forState:UIControlStateNormal];
        [_closeButton addTarget:self action:@selector(closeButtonAction) forControlEvents:UIControlEventTouchUpInside];
        _closeButton.clickAreaRadious = 64;
    }
    return _closeButton;
}

- (UIButton *)leftPriceButton {
    if (!_leftPriceButton) {
        _leftPriceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _leftPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_leftPriceButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _leftPriceButton.titleLabel.font = ZFFontSystemSize(14);
        //[_leftPriceButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _leftPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    }
    return _leftPriceButton;
}

- (UIButton *)rightPriceButton {
    if (!_rightPriceButton) {
        _rightPriceButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_rightPriceButton setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:0];
        _rightPriceButton.titleLabel.font = ZFFontSystemSize(14);
        //[_rightPriceButton addTarget:self action:@selector(nextButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _rightPriceButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
    }
    return _rightPriceButton;
}

@end
