//
//  ZFGoodsDetailNavigationView.m
//  ZZZZZ
//
//  Created by YW on 2017/11/23.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFGoodsDetailNavigationView.h"
#import "ZFInitViewProtocol.h"
#import <Lottie/Lottie.h>
#import "ZFGoodsDetailCartInfoPopView.h"
#import "UIImage+ZFExtended.h"
#import "ZFThemeManager.h"
#import <YYWebImage/YYWebImage.h>
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "YWCFunctionTool.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFBTSManager.h"

@interface ZFGoodsDetailNavigationView() <ZFInitViewProtocol>

@property (nonatomic, assign) BOOL                    hasChangeSkin;
@property (nonatomic, strong) UIImageView             *backgroundImagewView;
@property (nonatomic, strong) UIButton                *backButton;
@property (nonatomic, strong) UIImageView             *goodsImageView;
@property (nonatomic, strong) UIButton                *customerButton;
@property (nonatomic, strong) UIView                  *cartBgView;
@property (nonatomic, strong) UIButton                *cartButton;
@property (nonatomic, strong) UIButton                *shareButton;
@property (nonatomic, strong) UIView                  *lineView;
@end

@implementation ZFGoodsDetailNavigationView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - init methods

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        [self changeCartNumberInfo];
        [self addNotification];
    }
    return self;
}

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeCartNumberInfo) name:kCartNotification object:nil];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self addSubview:self.backgroundImagewView];
    [self addSubview:self.backButton];
    [self addSubview:self.goodsImageView];
    [self addSubview:self.customerButton];
    [self addSubview:self.cartBgView];
    [self addSubview:self.cartButton];
    [self addSubview:self.shareButton];
    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.backgroundImagewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(12);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-6);
        make.size.mas_equalTo(self.shareButton);
    }];
    
    [self.goodsImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self);
        make.centerY.mas_equalTo(self.backButton.mas_centerY).offset(5);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
    
    [self.customerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.shareButton.mas_leading).offset(-12);
        make.centerY.mas_equalTo(self.backButton);
        make.size.mas_equalTo(self.shareButton);
    }];
    
    [self.shareButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.cartBgView.mas_leading).offset(-12);
        make.centerY.mas_equalTo(self.backButton);
        make.size.mas_equalTo(CGSizeMake(36, 36));
    }];
    
    [self.cartBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
        make.centerY.mas_equalTo(self.backButton);
        make.size.mas_equalTo(self.shareButton);
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.cartBgView.mas_centerX);
        make.centerY.mas_equalTo(self.cartBgView.mas_centerY);
        make.size.mas_equalTo(self.shareButton);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - Public Method

- (void)setRefreshAlpha:(CGFloat)refreshAlpha {
    _refreshAlpha = refreshAlpha;
    self.backgroundImagewView.alpha = refreshAlpha;
    
    //更新导航栏背景透明度， 移动图片位置
    self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:refreshAlpha];
    self.goodsImageView.alpha = refreshAlpha;
    self.lineView.alpha = refreshAlpha < .85 ? 0 : refreshAlpha;
    
    CGFloat btnBgAlpha = (0.7-refreshAlpha) < 0 ? 0 : 0.7 - refreshAlpha;
    UIColor *bgColor = [UIColor colorWithWhite:1 alpha:btnBgAlpha];
    
    self.backButton.backgroundColor = bgColor;
    self.customerButton.backgroundColor = bgColor;
    self.cartBgView.backgroundColor = bgColor;
    self.shareButton.backgroundColor = bgColor;
    
    // 处理按钮色
    [self changeNavigationViewSkin];
}

// 刚滑动时切换导航背景色
- (void)changeNavigationViewSkin {
    if (self.hasChangeSkin) return;
    self.hasChangeSkin = YES;
    if ([AccountManager sharedManager].needChangeAppSkin) {
        UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
        UIImage *headImage = [AccountManager sharedManager].appNavBgImage;
        [self.backgroundImagewView zfChangeCustomViewSkin:navBgColor skinImage:headImage];
    } else {
        self.backgroundImagewView.image = nil;
        self.backgroundImagewView.backgroundColor = ZFCOLOR_WHITE;
    }
}

- (UIImage *)fetchGoodsImage {
    return self.goodsImageView.image ? : [UIImage imageNamed:@"loading_cat_list"];
}

- (void)changeCartNumberInfo {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.cartButton showShoppingCarsBageValue:[badgeNum integerValue]];
}

#pragma mark -====== 更新数据源 ======

- (void)setImageUrl:(NSString *)imageUrl {
    _imageUrl = imageUrl;
    self.shareButton.hidden = NO;
    [self.goodsImageView yy_setImageWithURL:[NSURL URLWithString:_imageUrl]
                          placeholder:[UIImage imageNamed:@"loading_cat_list"]
                               options:YYWebImageOptionProgressiveBlur | YYWebImageOptionSetImageWithFadeAnimation
                              progress:nil
                             transform:nil
                            completion:nil];
    
    // 是否显示客服入口
    self.customerButton.hidden = ![self showOnlineButtonState];
    
    //V5.5.0商详优化Bts实验
    ZFBTSModel *btsModel = [ZFBTSManager getBtsModel:kZFBtsIosxaddbag defaultPolicy:kZFBts_A];
    self.cartButton.hidden = [btsModel.policy isEqualToString:kZFBts_A];
    self.cartBgView.hidden = self.cartButton.hidden;
    
    if (self.cartButton.hidden) {
        [self.shareButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.trailing.mas_equalTo(self.mas_trailing).offset(-12);
            make.centerY.mas_equalTo(self.backButton);
            make.size.mas_equalTo(CGSizeMake(36, 36));
        }];
    }
}

/**
 * Bts是断菲律宾地区显示客服按钮入口
 * 菲律宾地区，商品详情页，保留客服访问入口，其他国家入口去掉。
 */
- (BOOL)showOnlineButtonState {
    ZFAddressCountryModel *countryModel = [AccountManager sharedManager].accountCountryModel;
    return [countryModel.region_code containsString:@"PH"];
}

#pragma mark -====== 按钮点击事件 ======

- (void)itemBtnAction:(UIButton *)button {
    if (button.tag < 2019) return;
    if (self.navigationBlcok) {
        self.navigationBlcok(button.tag);
    }
}

#pragma mark - getter

- (UIImageView *)backgroundImagewView {
    if (!_backgroundImagewView) {
        _backgroundImagewView = [[UIImageView alloc] init];
        _backgroundImagewView.userInteractionEnabled = YES;
    }
    return _backgroundImagewView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        _backButton.clipsToBounds = YES;
        _backButton.layer.cornerRadius = 18;
        _backButton.adjustsImageWhenHighlighted = NO;
        [_backButton addTarget:self action:@selector(itemBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [_backButton convertUIWithARLanguage];
        _backButton.tag = ZFDetailNavButtonAction_BackType;
        
        UIImage *backImage = ZFImageWithName(@"nav_arrow_left");
        [_backButton setImage:backImage forState:UIControlStateNormal];
    }
    return _backButton;
}

- (UIImageView *)goodsImageView {
    if (!_goodsImageView) {
        _goodsImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _goodsImageView.contentMode = UIViewContentModeScaleAspectFill;
        _goodsImageView.alpha = 0;
        _goodsImageView.layer.cornerRadius = 15;
        _goodsImageView.clipsToBounds = YES;
        _goodsImageView.tag = 2018; //此tag特殊处理过滤不换肤的控件
        _goodsImageView.userInteractionEnabled = YES;
        @weakify(self)
        [_goodsImageView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self)
            if (self.navigationBlcok) {
                self.navigationBlcok(ZFDetailNavButtonAction_TapImageType);
            }
        }];
    }
    return _goodsImageView;
}

- (UIButton *)customerButton {
    if (!_customerButton) {
        _customerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _customerButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        _customerButton.clipsToBounds = YES;
        _customerButton.layer.cornerRadius = 18;
        _customerButton.adjustsImageWhenHighlighted = NO;
        [_customerButton addTarget:self action:@selector(itemBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        UIImage *customerImage = ZFImageWithName(@"goods_detail_onelineservice");
        [_customerButton setImage:customerImage forState:UIControlStateNormal];
        _customerButton.tag = ZFDetailNavButtonAction_CustomerType;
        _customerButton.hidden = YES;
    }
    return _customerButton;
}

/// 因为购物车按钮会裁掉圆角数量
- (UIView *)cartBgView {
    if (!_cartBgView) {
        _cartBgView = [[UIView alloc] initWithFrame:CGRectZero];
        _cartBgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        _cartBgView.clipsToBounds = YES;
        _cartBgView.layer.cornerRadius = 18;
        _cartBgView.hidden = YES;
    }
    return _cartBgView;
}

- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cartButton.backgroundColor = [UIColor clearColor];
        [_cartButton setImage:[UIImage imageNamed:@"public_bag"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(itemBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.tag = ZFDetailNavButtonAction_CartType;
        _cartButton.hidden = YES;
    }
    return _cartButton;
}

- (UIButton *)shareButton {
    if (!_shareButton) {
        _shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _shareButton.backgroundColor = [UIColor colorWithWhite:1 alpha:0.7];
        _shareButton.clipsToBounds = YES;
        _shareButton.layer.cornerRadius = 18;
        _shareButton.adjustsImageWhenHighlighted = NO;
        [_shareButton addTarget:self action:@selector(itemBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        UIImage *shareImage = ZFImageWithName(@"GoodsDetail_shareIcon");
        [_shareButton setImage:shareImage forState:UIControlStateNormal];
        _shareButton.tag = ZFDetailNavButtonAction_ShareType;
        _shareButton.hidden = YES;
    }
    return _shareButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1.f);
        _lineView.alpha = 0;
    }
    return _lineView;
}

@end
