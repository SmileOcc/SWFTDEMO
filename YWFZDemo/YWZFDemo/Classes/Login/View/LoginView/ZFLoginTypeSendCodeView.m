//
//  YWLoginTypeSendCodeView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "YWLoginTypeSendCodeView.h"
#import "ZFInitViewProtocol.h"
#import "LoginViewModel.h"
#import "YWLoginEmailCell.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "UIView+ZFViewCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Constants.h"
#import "NSString+Extended.h"
#import <Masonry/Masonry.h>

static const CGFloat kLineHight = 1;

@interface YWLoginTypeSendCodeView ()
<
    ZFInitViewProtocol,
    UITextFieldDelegate,
    UIGestureRecognizerDelegate
>
@property (nonatomic, strong) UIView             *lineView;
@property (nonatomic, strong) UILabel            *errorLabel;
@property (nonatomic, strong) LoginViewModel     *viewModel;
@property (nonatomic, assign) BOOL               isNeedUpdate;
@property (nonatomic, copy)   NSString           *inputString;
@property (nonatomic, strong) ZFCountDownButton  *countDownButton;
@end

@implementation YWLoginTypeSendCodeView

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
        self.backgroundColor = ZFCOLOR_WHITE;
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.emailTextField];
    [self addSubview:self.lineView];
    [self addSubview:self.errorLabel];
    [self addSubview:self.countDownButton];
}

- (void)zfAutoLayoutView {
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(33);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(self.countDownButton.mas_leading).mas_offset(-12);
        make.height.mas_equalTo(32).priorityHigh();
    }];
    
    [self.countDownButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.emailTextField);
        make.leading.mas_equalTo(self.emailTextField.mas_trailing).mas_offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
        make.height.mas_equalTo(24).priorityHigh();
        make.width.priorityLow();
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailTextField.mas_bottom);
        make.height.mas_equalTo(kLineHight);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
    }];
    
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(2);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self);
    }];
}

#pragma mark - Action
- (void)emailTextFieldEditingDidChanged:(NSNotification *)notif {
    NSString *inputString = self.emailTextField.text;
    /** 禁止输入空格 */
    if ([inputString containsString:@" "]) {
        self.emailTextField.text = [inputString stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if (self.emailTextField.text.length > 6) {//设置最大长度
        self.emailTextField.text = [self.emailTextField.text substringToIndex:6];
    }
    if (self.emailTextFieldEditingChangeHandler) {
        self.emailTextFieldEditingChangeHandler(self.emailTextField);
    }
}

- (void)countDownButtonAction
{
    if (self.sendCodeHandler) {
        self.sendCodeHandler(self.countDownButton);
    }
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    self.emailTextField.text = @"";
}

#pragma mark - Getter
- (YWLoginTextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[YWLoginTextField alloc] init];
        _emailTextField.backgroundColor = [UIColor whiteColor];
        _emailTextField.keyboardType = UIKeyboardTypePhonePad;
        _emailTextField.returnKeyType = UIReturnKeyNext;
        _emailTextField.placeholder = ZFLocalizedString(@"Login_VerCode",nil);
        _emailTextField.font = [UIFont systemFontOfSize:16.f];
        _emailTextField.textColor = ZFCOLOR(45, 45, 45, 1);
        _emailTextField.clearImage = [UIImage imageNamed:@"login_clearButton"];
        _emailTextField.placeholderFont = ZFFontSystemSize(16);
        _emailTextField.placeholderAnimationFont = ZFFontSystemSize(14);
        _emailTextField.placeholderNormalColor = ZFCOLOR(153, 153, 153, 1);
        [_emailTextField addTarget:self action:@selector(emailTextFieldEditingDidChanged:) forControlEvents:UIControlEventEditingChanged];
        _emailTextField.delegate = self;
    }
    return _emailTextField;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = ZFCOLOR(221, 221, 221, 1);
    }
    return _lineView;
}

- (UILabel *)errorLabel {
    if (!_errorLabel) {
        _errorLabel = [[UILabel alloc] init];
        _errorLabel.backgroundColor = ZFCOLOR_WHITE;
        _errorLabel.font = ZFFontSystemSize(12);
        _errorLabel.textColor = ZFC0xFE5269();
        _errorLabel.numberOfLines = 0;
        _errorLabel.preferredMaxLayoutWidth = KScreenWidth - 32;
        _errorLabel.hidden = NO;
    }
    return _errorLabel;
}

- (LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
    }
    return _viewModel;
}

-(ZFCountDownButton *)countDownButton
{
    if (!_countDownButton) {
        _countDownButton = [[ZFCountDownButton alloc] init];
        _countDownButton.countDownInterval = 60;
        _countDownButton.normalTitle = ZFLocalizedString(@"InputTextView_Send", nil);
        _countDownButton.countDownTitle = ZFLocalizedString(@"Login_COuntDown", nil);
        _countDownButton.contentEdgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
        [_countDownButton setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
        _countDownButton.layer.borderColor = ZFC0x2D2D2D().CGColor;
        _countDownButton.layer.borderWidth = 1;
        _countDownButton.layer.cornerRadius = 2;
        _countDownButton.layer.masksToBounds = YES;
        [_countDownButton addTarget:self action:@selector(countDownButtonAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _countDownButton;
}

@end
