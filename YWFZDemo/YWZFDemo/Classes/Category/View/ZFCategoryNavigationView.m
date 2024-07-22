
//
//  ZFCategoryNavigationView.m
//  ZZZZZ
//
//  Created by YW on 2018/6/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFCategoryNavigationView.h"
#import "ZFInitViewProtocol.h"
#import "UIView+ZFBadge.h"
#import "ZFThemeManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "BigClickAreaButton.h"
#import "Masonry.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"

#define kCarBtnSize        (44)

@interface ZFCategoryNavigationView() <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) BigClickAreaButton    *backButton;
@property (nonatomic, strong) UIView                *maskInputView;
@property (nonatomic, strong) UIImageView           *searchView;
@property (nonatomic, strong) UITextField           *inputField;
@property (nonatomic, strong) BigClickAreaButton    *searchImageButton;
@property (nonatomic, strong) UIButton              *cartButton;
@property (nonatomic, strong) UIView                *separetorView;
@end

@implementation ZFCategoryNavigationView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - action methods
- (void)backButtonAction:(UIButton *)sender {
    if (self.categoryBackCompletionHandler) {
        self.categoryBackCompletionHandler();
    }
}

- (void)cartButtonAction:(UIButton *)sender {
    if (self.categoryJumpCartCompletionHandler) {
        self.categoryJumpCartCompletionHandler();
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (self.categoryActionSearchInputCompletionHandler) {
        self.categoryActionSearchInputCompletionHandler();
    }
}

- (void)showPickerViewController {
    if (self.categoryActionSearchImageCompletionHandler) {
        self.categoryActionSearchImageCompletionHandler();
    }
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.backButton];
    [self addSubview:self.maskInputView];
    [self.maskInputView addSubview:self.searchView];
    [self.maskInputView addSubview:self.inputField];
    [self.maskInputView addSubview:self.searchImageButton];
    [self addSubview:self.cartButton];
    [self addSubview:self.separetorView];
}

- (void)zfAutoLayoutView {
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
    }];
    
    [self.maskInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton).offset(0.5);
        make.leading.mas_equalTo(self.backButton.mas_trailing).offset(-2);
        make.trailing.mas_equalTo(self.cartButton.mas_leading).offset(-14);
        make.height.mas_equalTo(NavBarButtonSize);
    }];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.maskInputView);
        make.leading.mas_equalTo(self.maskInputView.mas_leading).offset(5);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.maskInputView);
        make.top.bottom.mas_equalTo(self.maskInputView);
        make.leading.mas_equalTo(self.searchView.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.maskInputView.mas_trailing).offset(-5);
    }];
    
    [self.searchImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-5);
        make.centerY.mas_equalTo(self.maskInputView);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton).offset(0.5);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-14);
        make.size.mas_equalTo(CGSizeMake(NavBarButtonSize, NavBarButtonSize));
    }];
    
    [self.separetorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(0.5);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}

#pragma mark - Public method
- (void)subViewWithAlpa:(CGFloat)alpha {
    self.alpha = alpha;
}

#pragma mark - setter
- (void)setBadgeCount:(NSString *)badgeCount {
    _badgeCount = badgeCount;
    [self.cartButton showShoppingCarsBageValue:[badgeCount integerValue]];
}

- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    self.inputField.text = inputPlaceHolder;
    self.inputField.textColor = ZFCOLOR(153, 153, 153, 1);
}

- (void)setShowBackButton:(BOOL)showBackButton {
    _showBackButton = showBackButton;
    self.backButton.hidden = !showBackButton;
    
    if (!showBackButton) {
        [self.maskInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backButton).offset(0.5);
            make.leading.mas_equalTo(self.mas_leading).offset(14);
            make.trailing.mas_equalTo(self.cartButton.mas_leading).offset(-14);
            make.height.mas_equalTo(36);
        }];
    }
}

#pragma mark - getter
- (BigClickAreaButton *)backButton {
    if (!_backButton) {
        _backButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _backButton.adjustsImageWhenHighlighted = NO;
        [_backButton addTarget:self action:@selector(backButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_backButton setImage:[UIImage imageNamed:@"nav_arrow_left"] forState:UIControlStateNormal];
        [_backButton setImage:[UIImage imageNamed:@"nav_arrow_left"] forState:UIControlStateSelected];
        _backButton.clipsToBounds = YES;
        _backButton.clickAreaRadious = 64;
        [_backButton convertUIWithARLanguage];
    }
    return _backButton;
}

- (BigClickAreaButton *)searchImageButton {
    if (!_searchImageButton) {
        _searchImageButton = [BigClickAreaButton buttonWithType:UIButtonTypeCustom];
        _searchImageButton.adjustsImageWhenHighlighted = NO;
        [_searchImageButton setImage:[UIImage imageNamed:@"category_searchImage"] forState:UIControlStateNormal];
        [_searchImageButton addTarget:self action:@selector(showPickerViewController) forControlEvents:UIControlEventTouchUpInside];
        _searchImageButton.clickAreaRadious = 64;
    }
    return _searchImageButton;
}

- (UIView *)maskInputView {
    if (!_maskInputView) {
        _maskInputView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskInputView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
        @weakify(self);
        [_maskInputView addTapGestureWithComplete:^(UIView * _Nonnull view) {
            @strongify(self);
            if (self.categoryActionSearchInputCompletionHandler) {
                self.categoryActionSearchInputCompletionHandler();
            }
        }];
    }
    return _maskInputView;
}

- (UIImageView *)searchView {
    if (!_searchView) {
        _searchView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"category_search"]];
    }
    return _searchView;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputField.delegate = self;
        _inputField.font = [UIFont systemFontOfSize:14];
        _inputField.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputField.placeholder = ZFLocalizedString(@"Search_PlaceHolder_Search", nil);
        _inputField.userInteractionEnabled = NO;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _inputField.textAlignment = NSTextAlignmentRight;
        }
    }
    return _inputField;
}

- (UIButton *)cartButton {
    if (!_cartButton) {
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cartButton setImage:[UIImage imageNamed:@"public_bag"] forState:UIControlStateNormal];
        [_cartButton addTarget:self action:@selector(cartButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cartButton;
}

- (UIView *)separetorView {
    if (!_separetorView) {
        _separetorView = [[UIView alloc] init];
        _separetorView.backgroundColor = [UIColor colorWithHex:0xdddddd];
        _separetorView.hidden = YES;
    }
    return _separetorView;
}

@end
