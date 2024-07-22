//
//  ZFGoodsShowsAddCartView.m
//  ZZZZZ
//
//  Created by YW on 2019/3/4.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGoodsShowsAddCartView.h"
#import "GoodsDetailModel.h"
#import "ZFInitViewProtocol.h"
#import "UIView+ZFBadge.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFPubilcKeyDefiner.h"
#import "ExchangeManager.h"
#import "Constants.h"
#import "NSString+Extended.h"
#import "ZFFrameDefiner.h"
#import "YWCFunctionTool.h"
#import "ZFPopDownAnimation.h"

#define kCarBtnWidth        (120)
#define kCarBtnHeight       (50)

@interface ZFGoodsShowsAddCartView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIView            *lineView;
@property (nonatomic, strong) UIButton          *cartButton;
@property (nonatomic, strong) UIButton          *addCartButton;
@end

@implementation ZFGoodsShowsAddCartView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self refreshCartNumberInfo];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self addDropShadowWithOffset:CGSizeMake(0, -2)
                           radius:2
                            color:[UIColor blackColor]
                          opacity:0.1];
}

#pragma mark - interface methods
- (void)refreshCartNumberInfo {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.cartButton showShoppingCarsBageValue:[badgeNum integerValue]];
}

- (void)refreshCartCountWithAnimation {
    [self refreshCartNumberInfo];
    [ZFPopDownAnimation popDownRotationAnimation:self.cartButton];
}

#pragma mark - action methods
- (void)buttonAction:(UIButton *)sender {
    if (self.showBottomViewBlock) {
        self.showBottomViewBlock(sender.tag);
    }
}

#pragma mark -<ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.cartButton];
    [self addSubview:self.addCartButton];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.mas_equalTo(self);
        make.width.mas_equalTo(kCarBtnWidth);
        make.height.mas_equalTo(kCarBtnHeight);
    }];
    
    [self.addCartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.trailing.mas_equalTo(self);
        make.leading.mas_equalTo(self.cartButton.mas_trailing);
        make.height.mas_equalTo(50);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - setter
- (void)setModel:(GoodsDetailModel *)model {
    _model = model;
    if (![_model.is_on_sale boolValue] || self.model.goods_number <= 0) {
        //下架，没有货
        self.addCartButton.enabled = NO;
    } else {
        self.addCartButton.enabled = YES;
    }
}

#pragma mark - getter
- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _lineView;
}

- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:[UIImage imageNamed:@"public_bag"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.tag = GoodsShowsAddCart_pushCarType;
    }
    return _cartButton;
}

- (UIButton *)addCartButton {
    if (!_addCartButton) {
        _addCartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_addCartButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        [_addCartButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
        [_addCartButton setBackgroundColor:ColorHex_Alpha(0xcccccc, 1) forState:UIControlStateDisabled];
        [_addCartButton setTitle:ZFLocalizedString(@"Detail_Product_AddToBag", nil) forState:UIControlStateNormal];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        [_addCartButton setTitle:ZFLocalizedString(@"Detail_Product_OutOfStock", nil) forState:UIControlStateDisabled];
        [_addCartButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateDisabled];
        [_addCartButton addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        _addCartButton.tag = GoodsShowsAddCart_addCartType;
        _addCartButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _addCartButton;
}
@end
