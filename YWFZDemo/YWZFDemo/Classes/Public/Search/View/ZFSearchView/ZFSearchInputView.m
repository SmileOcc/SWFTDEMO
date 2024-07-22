
//
//  ZFSearchInputView.m
//  ZZZZZ
//
//  Created by YW on 2017/12/20.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFSearchInputView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "UIView+ZFViewCategorySet.h"
#import "UIColor+ExTypeChange.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"

@interface ZFSearchInputView() <ZFInitViewProtocol, UITextFieldDelegate>
@property (nonatomic, strong) UIImageView               *searchIconView;
@property (nonatomic, strong) UITextField               *searchField;
@property (nonatomic, strong) UIButton                  *cancelButton;
@property (nonatomic, strong) UIView                    *lineView;
@end

@implementation ZFSearchInputView
#pragma mark - init methods
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.searchField.inputAccessoryView = [UIView new];
    }
    return self;
}

#pragma mark - interface methods
- (void)clearSearchInfoOption {
    self.searchField.text = @"";
}

#pragma mark - action methods
- (void)cancelButtonAction:(UIButton *)sender {
    if (self.searchInputCancelCompletionHandler) {
        self.searchInputCancelCompletionHandler();
    }
}

- (void)searchDoneButtonAction:(UIButton *)sender {
    if (self.searchInputReturnCompletionHandler) {
        if (ZFIsEmptyString(self.searchField.text)) {
            self.searchInputReturnCompletionHandler(self.inputPlaceHolder);
        } else {
            self.searchInputReturnCompletionHandler(self.searchField.text);
        }
    }
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ([textField.text isEqualToString:@""] && [string isEqualToString:@" "]) {
        return NO;
    }
    NSString *key;
    if ([string isEqualToString:@""]) {
        key = [textField.text substringToIndex:textField.text.length - 1];
    } else {
        key = [NSString stringWithFormat:@"%@%@", textField.text, string];
    }
    
    if ([string isEqualToString:@"\n"]) {
        [self searchDoneButtonAction:nil];
    } else {
        if (self.searchInputSearchKeyCompletionHandler) {
            self.searchInputSearchKeyCompletionHandler(key);
        }
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    if (self.searchInputSearchKeyCompletionHandler) {
        self.searchInputSearchKeyCompletionHandler(@"");
    }
    return YES;
}

/**
 * 3DTouch进来时, 如果Window上其他视图(倒计时广告, 推送引导)不能显示键盘
 */
- (void)judgeShowKeyboardWhen3DTouchEnter
{
    //在首次安装App时,会显示注册通知,走3DTouch进入App不该出现搜索页面的键盘
    UIView *notificationView = [self.window viewWithTag:kRegisterNotificationViewTag];
    UIView *launchAdvertView = [self.window viewWithTag:kZFLaunchAdvertViewTag];
    if (![notificationView isKindOfClass:NSClassFromString(@"ZFPushAllowView")] &&
        ![launchAdvertView isKindOfClass:NSClassFromString(@"ZFLaunchAdvertView")]) {
        [self.searchField becomeFirstResponder];
    }
}

- (void)setInputPlaceHolder:(NSString *)inputPlaceHolder {
    _inputPlaceHolder = inputPlaceHolder;
    self.searchField.placeholder = inputPlaceHolder;
}

#pragma mark - <ZFInitViewProtocol>
- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.searchField];
    [self addSubview:self.cancelButton];
//    [self addSubview:self.lineView];
}

- (void)zfAutoLayoutView {
    [self.searchField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-5);
        make.trailing.mas_equalTo(self.cancelButton.mas_leading).offset(-6);
        make.height.mas_equalTo(36);
    }];
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.searchField);
        make.trailing.mas_equalTo(self.mas_trailing).offset(-10);
        if ([self.cancelButton.titleLabel.text length] > 8) {
            make.width.mas_equalTo(82);
        } else {
            make.width.mas_equalTo(65);
        }
    }];
    
//    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.leading.trailing.bottom.mas_equalTo(self);
//        make.height.mas_equalTo(0.5);
//    }];
}

#pragma mark - getter
- (UIImageView *)searchIconView {
    if (!_searchIconView) {
        _searchIconView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"search-min"]];
    }
    return _searchIconView;
}

- (UITextField *)searchField {
    if (!_searchField) {
        _searchField = [[UITextField alloc] initWithFrame:CGRectZero];
        _searchField.backgroundColor = ZFCOLOR(247, 247, 247, 1.f);
        _searchField.clearButtonMode = UITextFieldViewModeWhileEditing;
        _searchField.placeholder = ZFLocalizedString(@"Search_PlaceHolder_Search", nil);
        _searchField.delegate = self;
        _searchField.tintColor = ZFCOLOR(153, 153, 153, 1.f);
        _searchField.textColor = ZFC0x2D2D2D();
        _searchField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 32)];
        _searchField.font = [UIFont systemFontOfSize:14];
        _searchField.leftViewMode = UITextFieldViewModeAlways;
        _searchField.returnKeyType = UIReturnKeySearch;
        [_searchField addDoneOnKeyboardWithTarget:self action:@selector(searchDoneButtonAction:)];
        [_searchField convertTextAlignmentWithARLanguage];
        
        //3DTouch进来时, 如果Window上其他视图不能显示键盘
        [self performSelector:@selector(judgeShowKeyboardWhen3DTouchEnter) withObject:nil afterDelay:0.7];
    }
    return _searchField;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        [_cancelButton setTitleColor:ZFCOLOR(45, 45, 45, 1.f) forState:UIControlStateNormal];
        [_cancelButton setTitle:ZFLocalizedString(@"Cancel", nil) forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _cancelButton;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] initWithFrame:CGRectZero];
        _lineView.backgroundColor = [UIColor colorWithHex:0xdddddd];
    }
    return _lineView;
}
@end
