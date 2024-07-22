//
//  ZFSearchResultNavigationView.m
//  ZZZZZ
//
//  Created by YW on 2018/3/10.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchResultNavigationView.h"
#import "ZFInitViewProtocol.h"
#import "BigClickAreaButton.h"
#import "UIView+ZFBadge.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "ZFPopDownAnimation.h"
#import "SystemConfigUtils.h"

typedef NS_ENUM(NSInteger, SearchResultRightNavBarType) {
    SearchResultRightNavBarTypeCancel = 0,
    SearchResultRightNavBarTypeCart,
};

#define kCarBtnSize        (44)

@interface ZFSearchResultNavigationView() <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) BigClickAreaButton    *backButton;
@property (nonatomic, strong) UIView                *maskInputView;
@property (nonatomic, strong) UITextField           *inputField;
@property (nonatomic, strong) UIButton              *cartButton;
@property (nonatomic, strong) UIButton              *cancelButton;
@property (nonatomic, strong) UIView                *separetorView;
@end

@implementation ZFSearchResultNavigationView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - private methods
- (void)cancelOptionRefreshLayout {
    self.cancelButton.hidden = YES;
    self.cartButton.hidden = NO;
    [self.maskInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton);
        make.leading.mas_equalTo(self.backButton.mas_trailing);
        make.trailing.mas_equalTo(self.cartButton.mas_leading).offset(-8);
        make.height.mas_equalTo(36);
    }];
}


#pragma mark - action methods
- (void)backButtonAction:(UIButton *)sender {
    if (self.searchResultBackCompletionHandler) {
        [self cancelOptionRefreshLayout];
        self.searchResultBackCompletionHandler();
    }
}

- (void)cancelButtonAction:(UIButton *)sender {
    if (self.searchResultCancelSearchCompletionHandler) {
        [self cancelOptionRefreshLayout];
        self.searchResultCancelSearchCompletionHandler();
    }
}

- (void)cartButtonAction:(UIButton *)sender {
    if (self.searchResultJumpCartCompletionHandler) {
        self.searchResultJumpCartCompletionHandler();
    }
}


- (void)searchDoneButtonAction:(UIButton *)sender {
    if (self.searchResultReturnCompletionHandler) {
        [self cancelOptionRefreshLayout];
        self.searchResultReturnCompletionHandler(self.inputField.text);
    }
}
                                  
#pragma mark - <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *key;
    if ([string isEqualToString:@""]) {
        key = [textField.text substringToIndex:textField.text.length - 1];
    } else {
        key = [NSString stringWithFormat:@"%@%@", textField.text, string];
    }
    
    if ([string isEqualToString:@"\n"]) {
        [self searchDoneButtonAction:nil];
    } else {
        if (self.searchResultSearchKeyCompletionHandler) {
            self.searchResultSearchKeyCompletionHandler(key);
        }
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    
    self.cartButton.hidden = YES;
    self.cancelButton.hidden = NO;
    //更新布局
    [self.maskInputView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton);
        make.leading.mas_equalTo(self.backButton.mas_trailing);
        make.trailing.mas_equalTo(self.cancelButton.mas_leading).offset(-8);
        make.height.mas_equalTo(36);
        make.width.priorityLow();
    }];
    //设置，输入框随着文字输入，宽度不变，按钮位置不变
    [self.maskInputView setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    [self.cancelButton setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    
    if (self.searchResultCancelNormalCompletionHandler) {
        self.searchResultCancelNormalCompletionHandler();
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
//    [self cancelOptionRefreshLayout];
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.backButton];
    [self addSubview:self.maskInputView];
    [self.maskInputView addSubview:self.inputField];
    [self addSubview:self.cartButton];
    [self addSubview:self.cancelButton];
    [self addSubview:self.separetorView];
}

- (void)zfAutoLayoutView {
    
    [self.backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(0);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.bottom.mas_equalTo(self.mas_bottom).offset(0);
    }];
    
    [self.maskInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton);
        make.leading.mas_equalTo(self.backButton.mas_trailing);
        make.trailing.mas_equalTo(self.cartButton.mas_leading).offset(-8);
        make.height.mas_equalTo(36);
    }];
    
    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.maskInputView);
        make.top.bottom.mas_equalTo(self.maskInputView);
        make.leading.mas_equalTo(self.maskInputView.mas_leading).offset(12);
        make.trailing.mas_equalTo(self.maskInputView.mas_trailing).offset(-5);
    }];
    
    [self.cartButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
        make.size.mas_equalTo(CGSizeMake(kCarBtnSize, kCarBtnSize));
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.backButton);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-8);
        make.width.priorityHigh();
    }];

    [self.separetorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self);
        make.height.mas_equalTo(1.0);
        make.bottom.mas_equalTo(self.mas_bottom);
    }];
}

- (void)hideBottomSeparateLine {
    self.separetorView.hidden = YES;
}
#pragma mark - setter
- (void)setSearchTitle:(NSString *)searchTitle {
    _searchTitle = searchTitle;
    if (_searchTitle.length > 25) {
        _searchTitle = [NSString stringWithFormat:@"%@...", [_searchTitle substringToIndex:25]];
    }
    self.inputField.text = _searchTitle;
}

- (void)setBadgeCount:(NSString *)badgeCount {
    _badgeCount = badgeCount;
    [self.cartButton showShoppingCarsBageValue:[badgeCount integerValue]];
}

- (void)refreshCartCountAnimation {
    [ZFPopDownAnimation popDownRotationAnimation:self.cartButton];
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

- (UIView *)maskInputView {
    if (!_maskInputView) {
        _maskInputView = [[UIView alloc] initWithFrame:CGRectZero];
        _maskInputView.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
    }
    return _maskInputView;
}

- (UITextField *)inputField {
    if (!_inputField) {
        _inputField = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputField.delegate = self;
        _inputField.font = [UIFont systemFontOfSize:14];
        _inputField.textColor = ZFCOLOR(45, 45, 45, 1.f);
        _inputField.textAlignment = [SystemConfigUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
        _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputField.placeholder = ZFLocalizedString(@"Search_PlaceHolder_Search", nil);
        [_inputField addDoneOnKeyboardWithTarget:self action:@selector(searchDoneButtonAction:)];
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

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_cancelButton setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateNormal];
        [_cancelButton setTitle:ZFLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.hidden = YES;
    }
    return _cancelButton;
}

- (UIView *)separetorView {
    if (!_separetorView) {
        _separetorView = [[UIView alloc] init];
        _separetorView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    }
    return _separetorView;
}

@end
