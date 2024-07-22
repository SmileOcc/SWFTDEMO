//
//  ZFCommunityPostDetailNavigationView.m
//  ZZZZZ
//
//  Created by YW on 2018/7/9.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCommunityPostDetailNavigationView.h"
#import "UIImage+ZFExtended.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "UINavigationItem+ZFChangeSkin.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFCommunityPostDetailNavigationView ()

@property (nonatomic, strong) UIImageView *backgroundImagewView;
@property (nonatomic, strong) UIButton *backButton;
@property (nonatomic, strong) UIButton *shareButton;
@property (nonatomic, strong) UIView   *rightView;
@property (nonatomic, strong) UILabel  *titleLabel;
@property (nonatomic, strong) UIView   *bottomLineView;
@property (nonatomic, assign) BOOL     hasChangeSkin;
@end

@implementation ZFCommunityPostDetailNavigationView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        [self setupView];
        [self layout];
    }
    return self;
}

- (void)setRightItemButton:(NSArray <UIButton*> *)items cart:(UIButton *)cartButton {

    [self.rightView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj mas_remakeConstraints:^(MASConstraintMaker *make) {
        }];
        [obj removeFromSuperview];
    }];
    
    [items enumerateObjectsUsingBlock:^(UIButton *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [self.rightView addSubview:obj];
        if (cartButton && obj == cartButton) {
            self.cartButton = cartButton;
        } else {
            self.shareButton = obj;
        }
        // 按钮换肤
        [obj zfChangeButtonSkin];
    }];
    
    if (items.count <= 0) {
        return;
    }
    UIButton *tempButton;
    NSInteger count = items.count - 1;
    for(NSInteger i = count; i >= 0; i--) {
        
        UIButton *subButton = items[i];
        subButton.tag = 1000 + i;
        if (tempButton) {
            [subButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(tempButton.mas_leading).offset(-12);
                make.centerY.mas_equalTo(self.rightView.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(36, 36));
                if (i == 0) {
                    make.leading.mas_equalTo(self.rightView.mas_leading);
                }
            }];
            
        } else {
            [subButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.mas_equalTo(self.rightView.mas_centerY);
                make.size.mas_equalTo(CGSizeMake(36, 36));
                make.trailing.mas_equalTo(self.rightView.mas_trailing);
            }];
            
        }
        tempButton = subButton;
    }
    
    CGFloat rightW = items.count * 36 + count * 12;
    [self.rightView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(rightW);
    }];
    
    //为了让标题居中
    CGFloat leftSpace = (items.count - 1) * (36 + 12) + 8;
    [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.backButton.mas_trailing).offset(leftSpace);
    }];
}

- (UIButton *)currentIndexButton:(NSInteger )index {
    UIButton *currentBtn = [self.rightView viewWithTag:1000 + index];
    return currentBtn;
}

- (CGRect)rectFrameToWindowIndexButton:(NSInteger)index {
    UIButton *indexButton = [self currentIndexButton:index];
    if (indexButton) {
        CGRect buttonRect = [self.rightView convertRect:indexButton.frame toView:WINDOW];
        
        //这不是应为在获取坐标的时候，大小还没绘制好
        if (buttonRect.size.height <= 0.0 || buttonRect.size.width <= 0.0) {
            buttonRect.size = CGSizeMake(36, 36);
        }
        return buttonRect;
    }
    return CGRectZero;
}

- (void)setCartBagValues {
    if (self.cartButton) {
        [self.cartButton showShoppingCarsBageValue:[GetUserDefault(kCollectionBadgeKey) integerValue]];
    }
}

#pragma mark -====== 初始化 UI ======

- (void)setupView {
    [self addSubview:self.backgroundImagewView];
    [self addSubview:self.backButton];
    [self addSubview:self.titleLabel];
    [self addSubview:self.rightView];
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
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.mas_trailing).offset(-17.0 * ScreenWidth_SCALE);
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
        make.height.mas_equalTo(36.0);
        make.width.mas_equalTo(0);
    }];
    

    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton.mas_centerY);
        make.leading.mas_equalTo(self.backButton.mas_trailing).offset(8);
        make.trailing.mas_equalTo(self.rightView.mas_leading).offset(-8);
        make.height.mas_equalTo(36.0);
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

#pragma mark - getter/setter

- (void)setbackgroundAlpha:(CGFloat)alpha {
    self.backgroundColor   = [UIColor colorWithHex:0xffffff alpha:alpha];
    self.backButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:(0.5-alpha)];
    self.cartButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:(0.5-alpha)];
    self.shareButton.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:(0.5-alpha)];
    
    self.titleLabel.alpha  = alpha;
    self.bottomLineView.alpha = alpha;
    self.backgroundImagewView.alpha = alpha;
    // 处理导航栏换肤
    [self changeCommunityDetailNavSkin];
}

#pragma mark -====== 处理换肤逻辑 ======
// 处理导航背景色
- (void)changeCommunityDetailNavSkin {
    if (self.hasChangeSkin) return;
    self.hasChangeSkin = YES;
    if ([AccountManager sharedManager].needChangeAppSkin) {
        UIColor *navBgColor = [AccountManager sharedManager].appNavBgColor;
        UIImage *headImage = [AccountManager sharedManager].appNavBgImage;
        [self.backgroundImagewView zfChangeCustomViewSkin:navBgColor skinImage:headImage];
    }
}

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
        UIImage *backImage = [UIImage imageNamed:@"nav_arrow_left"];
        [_backButton setImage:backImage forState:UIControlStateNormal];
        [_backButton setImage:backImage forState:UIControlStateSelected];
        [_backButton addTarget:self action:@selector(backItemAction) forControlEvents:UIControlEventTouchUpInside];
        [_backButton convertUIWithARLanguage];
    }
    return _backButton;
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

- (UIView *)rightView {
    if (!_rightView) {
        _rightView = [[UIView alloc] initWithFrame:CGRectZero];
        _rightView.backgroundColor = [UIColor clearColor];
    }
    return _rightView;
}

- (UIView *)bottomLineView {
    if (!_bottomLineView) {
        _bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
        _bottomLineView.backgroundColor = ColorHex_Alpha(0xDDDDDD, 1.0);
    }
    return _bottomLineView;
}
@end
