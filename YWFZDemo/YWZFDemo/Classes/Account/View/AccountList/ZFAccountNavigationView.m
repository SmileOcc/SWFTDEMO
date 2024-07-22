//
//  ZFAccountNavigationView.m
//  ZZZZZ
//
//  Created by YW on 2018/5/7.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFAccountNavigationView.h"
#import "ZFInitViewProtocol.h"
#import "UIView+ZFBadge.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "BigClickAreaButton.h"
#import "ZFFrameDefiner.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "Constants.h"
#import "AccountManager.h"
#import "UIImage+ZFExtended.h"
#import "YWCFunctionTool.h"
#import <YYWebImage/YYWebImage.h>
#import <Masonry/Masonry.h>

@interface ZFAccountNavigationView() <ZFInitViewProtocol>
@property (nonatomic, strong) UIImageView           *backgroundImagewView; //换肤的背景图
@property (nonatomic, strong) UIButton              *userImageBtn;
@property (nonatomic, strong) UIButton              *userInfoButn;
@property (nonatomic, strong) BigClickAreaButton    *cartButton;
@property (nonatomic, strong) BigClickAreaButton    *helpButton;
@property (nonatomic, strong) BigClickAreaButton    *settingButton;
@property (nonatomic, assign) BOOL                  hasChangeSkin;
@property (nonatomic, assign) BOOL                  hasRollbackSkin;
@end

@implementation ZFAccountNavigationView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = ZFC0xEEEEEE();
        [self zfInitView];
        [self zfAutoLayoutView];
        [self refreshBackgroundColorAlpha:0.0];
    }
    return self;
}

- (void)refreshBackgroundColorAlpha:(CGFloat)alpha {
    self.backgroundColor = [self.backgroundColor colorWithAlphaComponent:alpha];
    self.backgroundImagewView.alpha = alpha;
    if (self.hasChangeSkin) {
        //self.bottomLine.backgroundColor = ZFCOLOR(209, 209, 209, alpha);
    }
    // 处理导航背景色
    [self changeAccountNavigationNavSkin];
    
    self.userImageBtn.alpha = alpha;
    self.userInfoButn.alpha = alpha;
    
    //V5.5.0:渐变头像
//    if (self.userImageBtn.alpha < 1 && alpha>= 1) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.userImageBtn.alpha = 1;
//            self.userInfoButn.alpha = 1;
//        }];
//    }
//    if (self.userImageBtn.alpha >= 1 && alpha <= 0.5) {
//        [UIView animateWithDuration:0.3 animations:^{
//            self.userImageBtn.alpha = 0;
//            self.userInfoButn.alpha = 0;
//        }];
//    }
}

- (void)configNavgationUserInfo {
    self.userInfoButn.hidden = !ISLOGIN;
    self.userImageBtn.hidden = !ISLOGIN;
    
    AccountModel *accountModel = [AccountManager sharedManager].account;
    [self.userInfoButn setTitle:ZFToString(accountModel.nickname) forState:UIControlStateNormal];
    
    NSURL *url = [NSURL URLWithString:[AccountManager sharedManager].account.avatar];
    [self.userImageBtn yy_setImageWithURL:url
                                 forState:UIControlStateNormal
                              placeholder:[UIImage imageNamed:@"public_user_small"]];
}

#pragma mark -====== 处理换肤逻辑 ======
// 处理导航背景色
- (void)changeAccountNavigationNavSkin {
    if ([AccountManager sharedManager].needChangeAppSkin) {
        if (self.hasChangeSkin) return;
        UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
        UIImage *headImage = [AccountManager sharedManager].appNavBgImage;
        [self.backgroundImagewView zfChangeCustomViewSkin:navBgColor skinImage:headImage];//背景换肤
        [self zfChangeSkinToShadowNavgationBar];// 按钮换肤
        self.hasChangeSkin = YES;
    } else {
        if (self.hasRollbackSkin) return;
        self.backgroundImagewView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0f);
        self.backgroundImagewView.image = nil;
        self.hasRollbackSkin = YES;
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    [self addSubview:self.backgroundImagewView];
    [self addSubview:self.userImageBtn];
    [self addSubview:self.userInfoButn];
    [self addSubview:self.cartButton];
    [self addSubview:self.helpButton];
    [self addSubview:self.settingButton];
}

- (void)zfAutoLayoutView {
    [self.backgroundImagewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    CGFloat offsetY = STATUSHEIGHT;
    self.userImageBtn.layer.cornerRadius = 15;
    [self.userImageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(13);
        make.centerY.mas_equalTo(self.mas_centerY).offset(offsetY/2);
        make.size.mas_equalTo(CGSizeMake(30, 30));
    }];
        
    [self.userInfoButn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.userImageBtn.mas_trailing).offset(5);
        make.centerY.mas_equalTo(self.userImageBtn.mas_centerY);
        make.width.mas_lessThanOrEqualTo(KScreenWidth / 2.0);
    }];
        
    [self.settingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-13);
        make.centerY.mas_equalTo(self.userImageBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(NavBarButtonSize, NavBarButtonSize));
    }];

    [self.helpButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.settingButton.mas_leading).offset(-8);
        make.centerY.mas_equalTo(self.userImageBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(NavBarButtonSize, NavBarButtonSize));
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.helpButton.mas_leading).offset(-8);
        make.centerY.mas_equalTo(self.userImageBtn.mas_centerY);
        make.size.mas_equalTo(CGSizeMake(NavBarButtonSize, NavBarButtonSize));
    }];
}

#pragma mark - 外部方法

- (void)refreshCartNumberInfo {
    NSNumber *badgeNum = [[NSUserDefaults standardUserDefaults] valueForKey:kCollectionBadgeKey];
    [self.cartButton showShoppingCarsBageValue:[badgeNum integerValue]
                                   bageBgColor:ZFC0xFE5269()
                                 bageTextColor:ZFC0xFFFFFF()
                               bageBorderWidth:0
                               bageBorderColor:nil];
}

#pragma mark - getter

- (UIImageView *)backgroundImagewView {
    if (!_backgroundImagewView) {
        _backgroundImagewView = [[UIImageView alloc] init];
        _backgroundImagewView.frame = CGRectMake(0, 0, KScreenWidth, 44 + STATUSHEIGHT);
        _backgroundImagewView.userInteractionEnabled = YES;
        _backgroundImagewView.backgroundColor = ZFCOLOR(255, 255, 255, 1.0f);
        _backgroundImagewView.image = nil;
    }
    return _backgroundImagewView;
}

- (UIButton *)userImageBtn {
    if (!_userImageBtn) {
        _userImageBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [_userImageBtn addTarget:self action:@selector(subButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _userImageBtn.adjustsImageWhenHighlighted = NO;
        _userImageBtn.layer.cornerRadius = 15;
        _userImageBtn.layer.masksToBounds = YES;
        _userImageBtn.clipsToBounds = YES;
        _userImageBtn.tag = ZFAccountNavigationAction_UserNameType;
    }
    return _userImageBtn;
}

- (UIButton *)userInfoButn {
    if (!_userInfoButn) {
        _userInfoButn = [[UIButton alloc] initWithFrame:CGRectZero];
        _userInfoButn.titleLabel.font = [UIFont systemFontOfSize:18];
        [_userInfoButn setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateNormal];
        [_userInfoButn addTarget:self action:@selector(subButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _userInfoButn.adjustsImageWhenHighlighted = NO;
        _userInfoButn.tag = ZFAccountNavigationAction_UserNameType;
    }
    return _userInfoButn;
}

- (BigClickAreaButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:[[UIImage imageNamed:@"account_bag"] imageWithColor:ZFC0x2D2D2D()] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(subButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _cartButton.badgeBgColor = ZFC0xFE5269();
        _cartButton.badgeTextColor = ZFC0xFFFFFF();
        _cartButton.badgeFont = [UIFont systemFontOfSize:14];
        _cartButton.badgeCenterOffset = CGPointMake(28, 8);
        _cartButton.clickAreaRadious = 64;
        _cartButton.adjustsImageWhenHighlighted = NO;
        _cartButton.tag = ZFAccountNavigationAction_CartType;
    }
    return _cartButton;
}

- (BigClickAreaButton *)helpButton {
    if (!_helpButton) {
        _helpButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_helpButton setImage:[[UIImage imageNamed:@"contact_us_white"] imageWithColor:ZFC0x2D2D2D()] forState:UIControlStateNormal];
        [_helpButton addTarget:self action:@selector(subButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _helpButton.clipsToBounds = YES;
        _helpButton.clickAreaRadious = 64;
        _helpButton.adjustsImageWhenHighlighted = NO;
        _helpButton.tag = ZFAccountNavigationAction_HelpType;
    }
    return _helpButton;
}

- (BigClickAreaButton *)settingButton {
    if (!_settingButton) {
        _settingButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        [_settingButton setImage:[[UIImage imageNamed:@"account_home_setting"] imageWithColor:ZFC0x2D2D2D()] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(subButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _settingButton.clipsToBounds = YES;
        _settingButton.clickAreaRadious = 64;
        _settingButton.adjustsImageWhenHighlighted = NO;
        _settingButton.tag = ZFAccountNavigationAction_SettingType;
    }
    return _settingButton;
}

- (void)subButtonAction:(UIButton *)button {
    if (button.tag == 0)return;
    if (self.actionTypeBlock) {
        self.actionTypeBlock(button.tag);
    }
}

@end
