
//
//  ZFHomeSearchView.m
//  ZZZZZ
//
//  Created by YW on 2018/6/1.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFHomeSearchView.h"
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

@interface ZFHomeSearchView() <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UIView                *maskInputView;
@property (nonatomic, strong) UIImageView           *searchView;
@property (nonatomic, strong) UITextField           *inputField;
@property (nonatomic, strong) BigClickAreaButton    *searchImageButton;
@end

@implementation ZFHomeSearchView

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
    self.backgroundColor = ZFCOLOR(247, 247, 247, 1);
    [self addSubview:self.maskInputView];
    [self.maskInputView addSubview:self.searchView];
    [self.maskInputView addSubview:self.inputField];
    [self.maskInputView addSubview:self.searchImageButton];
}

- (void)zfAutoLayoutView {
    [self.maskInputView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self);
        make.leading.mas_equalTo(self).offset(5);
        make.trailing.mas_equalTo(self).offset(-5);
        make.height.mas_equalTo(NavBarButtonSize);
    }];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.maskInputView);
        make.leading.mas_equalTo(self.maskInputView.mas_leading).offset(0);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
    
    [self.inputField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.maskInputView);
        make.top.bottom.mas_equalTo(self.maskInputView);
        make.leading.mas_equalTo(self.searchView.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.maskInputView.mas_trailing).offset(-5);
    }];
    
    [self.searchImageButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(0);
        make.centerY.mas_equalTo(self.maskInputView);
        make.size.mas_equalTo(CGSizeMake(24, 24));
    }];
}

#pragma mark - Public method
- (void)subViewWithAlpa:(CGFloat)alpha {
    self.alpha = alpha;
}

#pragma mark - setter
- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    self.inputField.text = inputPlaceHolder;
    self.inputField.textColor = ZFCOLOR(153, 153, 153, 1);
}

#pragma mark - getter
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
        _maskInputView.backgroundColor = ZFCOLOR(247, 247, 247, 1);
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
        _inputField.backgroundColor = ZFCOLOR(247, 247, 247, 1);
        _inputField.delegate = self;
        _inputField.font = [UIFont systemFontOfSize:14];
        _inputField.textColor = ZFCOLOR(204, 204, 204, 1);
        _inputField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _inputField.placeholder = ZFLocalizedString(@"Search_PlaceHolder_Search", nil);
        _inputField.userInteractionEnabled = NO;
        if ([SystemConfigUtils isRightToLeftShow]) {
            _inputField.textAlignment = NSTextAlignmentRight;
        }
    }
    return _inputField;
}

@end
