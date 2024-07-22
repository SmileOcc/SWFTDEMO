//
//  ZFCommunityTopicNavbarView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/18.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "Constants.h"
#import "ZFCommunityTopicNavbarView.h"
#import "UIImage+ZFExtended.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIView+LayoutMethods.h"
#import "UIColor+ExTypeChange.h"
#import "AccountManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"

@interface ZFCommunityTopicNavbarView ()

@property (nonatomic, assign) BOOL     hasChangeSkin;
@property (nonatomic, strong) UIImageView *backgroundImagewView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *rightButton;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIView   *bottomLineView;
@end

@implementation ZFCommunityTopicNavbarView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];        
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setupView {
    [self addSubview:self.backgroundImagewView];
    [self addSubview:self.backButton];
    [self addSubview:self.rightButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.bottomLineView];
}

- (void)layout {
    [self.backgroundImagewView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self).offset(17.0 * ScreenWidth_SCALE);
        make.centerY.mas_equalTo(self.mas_centerY).offset(kiphoneXTopOffsetY / 2);
        make.height.width.mas_equalTo(36.0);
    }];
    
    [self.rightButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self).offset(-17.0 * ScreenWidth_SCALE);
        make.centerY.mas_equalTo(self.mas_centerY).offset(kiphoneXTopOffsetY / 2);
        make.height.width.mas_equalTo(36.0);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.leading.mas_equalTo(self.backButton.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.rightButton.mas_leading).offset(-10);
    }];
    
    [self.bottomLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
    }];
}

#pragma mark - event
- (void)backItemAction {
    if (self.backItemHandle) {
        self.backItemHandle();
    }
}

- (void)rightItemAction {
    if (self.rightItemHandle) {
        self.rightItemHandle();
    }
}

- (void)hideBottomLine {
    self.bottomLineView.hidden = YES;
}

#pragma mark -====== 处理换肤逻辑 ======
// 切换导航背景色
- (void)changeTopicNavSkin {
    if (self.hasChangeSkin) return;
    self.hasChangeSkin = YES;
    if ([AccountManager sharedManager].needChangeAppSkin) {
        UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
        UIImage *headImage = [AccountManager sharedManager].appNavBgImage;
        [self.backgroundImagewView zfChangeCustomViewSkin:navBgColor skinImage:headImage];
    }
}

#pragma mark - getter/setter

- (void)setTitle:(NSString *)title {
    _title = title;
    self.titleLabel.text = ZFToString(_title);
}

/**
 * 换肤背景图
 */
- (UIImageView *)backgroundImagewView {
    if (!_backgroundImagewView) {
        _backgroundImagewView = [[UIImageView alloc] init];
        _backgroundImagewView.userInteractionEnabled = YES;
        _backgroundImagewView.image = nil;
        _backgroundImagewView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _backgroundImagewView;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _backButton.backgroundColor = ZFC0xFFFFFF_A(0.5);
        _backButton.layer.cornerRadius = 36.0 / 2;
        [_backButton setImage:[UIImage imageNamed:@"nav_arrow_left"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"nav_arrow_left"] forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(backItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_backButton convertUIWithARLanguage];
    }
    return _backButton;
}

- (UIButton *)rightButton {
    if (!_rightButton) {
        _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _rightButton.backgroundColor = ZFC0xFFFFFF_A(0.5);
        _rightButton.layer.cornerRadius = 36.0 / 2;
        _rightButton.hidden = YES;
        [_rightButton addTarget:self action:@selector(rightItemAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightButton;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.font = ZFFontBoldSize(16);
        _titleLabel.textColor = ColorHex_Alpha(0x030303, 1.0);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _titleLabel;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1.0);
    }
    return _bottomLineView;
}

- (void)setbackgroundAlpha:(CGFloat)alpha {
    self.backgroundColor   = [UIColor colorWithHex:0xffffff alpha:alpha];
    self.backButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:(0.5-alpha)];
    self.rightButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:(0.5-alpha)];
    self.titleLabel.alpha = alpha;
    self.bottomLineView.alpha = alpha;
    self.backgroundImagewView.alpha = alpha;
    
    // 处理导航栏换肤
    [self changeTopicNavSkin];
}

- (void)setRightItemImage:(UIImage *)image isHidden:(BOOL)isHidden {
    self.rightButton.hidden = isHidden;
    [self.rightButton setImage:image forState:UIControlStateNormal];
    [self.rightButton setImage:image forState:UIControlStateSelected];
    [self.rightButton zfChangeButtonSkin];//换肤
}


@end
