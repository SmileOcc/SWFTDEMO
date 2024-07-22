//
//  YWLoginTypePasswordView.m
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginTypePasswordView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "IQKeyboardManager.h"
#import "NSStringUtils.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "ZFFrameDefiner.h"
#import "NSString+Extended.h"

static const CGFloat kLineHight = 1;

@interface YWLoginTypePasswordView ()<ZFInitViewProtocol,UITextFieldDelegate>

@property (nonatomic, strong) UIView             *lineView;
@property (nonatomic, strong) UILabel            *errorLabel;
@property (nonatomic, strong) UIButton           *eyeButton;
@property (nonatomic, assign) BOOL               isNeedUpdate;
@end

@implementation YWLoginTypePasswordView
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
    [self addSubview:self.passwordTextField];
    [self addSubview:self.eyeButton];
    [self addSubview:self.lineView];
    [self addSubview:self.errorLabel];
}

- (void)zfAutoLayoutView {
    [self.passwordTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(33);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.mas_equalTo(32);
    }];

    [self.eyeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.equalTo(self.passwordTextField.mas_trailing).offset(-0);
        make.centerY.equalTo(self.passwordTextField);
    }];
    
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.passwordTextField.mas_bottom);
        make.height.mas_equalTo(kLineHight);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
    }];
    
    [self.errorLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.lineView.mas_bottom).offset(2);
        make.leading.mas_equalTo(16);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self);
    }];
}

#pragma mark - <UITextFieldDelegate>
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self endEditing:YES];
    if(textField == self.passwordTextField) {
        [self doneAction];
    }
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField.isFirstResponder) {
        return NO;
    }
    if (!self.model.isFirstFocus) {
        if (self.passwordTextFieldEditingDidEndHandler) {
            self.passwordTextFieldEditingDidEndHandler(NO,self.model);
        }
    }
    
    [self showBegainEditAnimation];

    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSInteger strLength = textField.text.length - range.length + string.length;
    
    if (strLength > 32) {
        [self showErrorAnimation];
        return NO;
    }
    
    if (!self.errorLabel.hidden) {
        self.errorLabel.hidden = YES;
        self.model.isFirstFocus = NO;
        [self showLineAnimation:ZFCOLOR(45, 45, 45, 1) height:kLineHight*2];
        if (self.passwordTextFieldEditingDidEndHandler) {
            self.model.isValidPassword = NO;
            self.passwordTextFieldEditingDidEndHandler(NO,self.model);
        }
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    self.model.password = self.passwordTextField.text;
    if (ZFIsEmptyString(textField.text) && self.isNeedUpdate) {
        [self resetAnimation];
        return;
    }
    if (!ZFIsEmptyString(self.model.email)) {
        self.model.isValidEmail = YES;
    }
    [self checkValidPassword];
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    
    self.isNeedUpdate = model.isChangeType;
    
    if (self.isNeedUpdate) {
        if (!ZFIsEmptyString(self.passwordTextField.text)) {
            self.passwordTextField.text = nil;
            [self.passwordTextField resetAnimation];
        }
        
        if (!self.errorLabel.hidden) {
            [self resetAnimation];
        }
        
        self.isNeedUpdate = NO;
    }
}

#pragma mark - Action
- (void)showPassWord:(UIButton *)sender {
    self.passwordTextField.secureTextEntry = sender.selected;
    sender.selected = !sender.selected;
    
    // 解决明暗文切换出现空格问题
    self.passwordTextField.font = nil;
    self.passwordTextField.font = [UIFont systemFontOfSize:16.0f];
}

- (void)doneAction {
    [self.passwordTextField endEditing:YES];
    if ([self checkValidPassword]) {
        if (self.passwordTextFieldDoneHandler) {
            self.passwordTextFieldDoneHandler(self.model);
        }
    }
}

#pragma mark - Private method
- (BOOL)checkValidPassword {
    if (self.model.type == YWLoginEnterTypeRegister) {
        BOOL isValidPassword = [NSStringUtils checkPassWord:self.passwordTextField.text];
        if (!isValidPassword ||
            self.passwordTextField.text.length < 8 ||
            self.passwordTextField.text.length > 32)
        {
            [self showErrorAnimation];
            return NO;
        }else{
            [self showNormalStateAnimation];
            return YES;
        }
    }
    
    if (ZFIsEmptyString(self.passwordTextField.text) || self.passwordTextField.text.length > 32)
    {
        [self showErrorAnimation];
        return NO;
    }else{
        [self showNormalStateAnimation];
        return YES;
    }
}

- (void)showLineAnimation:(UIColor *)color height:(CGFloat)height {
//    void (^showBlock)(void) = ^{
//        [self layoutIfNeeded];
//        self.lineView.backgroundColor = color;
//    };
//
//    [self.errorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(self.errorLabel.hidden ? 0 : 14);
//    }];
//
//    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(height);
//    }];
//
//    [UIView animateWithDuration:0.3
//                          delay:0.0f
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:showBlock
//                     completion:nil];
    @weakify(self)
    void (^showBlock)(void) = ^{
        @strongify(self)
        [self layoutIfNeeded];
        self.lineView.backgroundColor = color;
    };
    
    CGFloat textheight = [self.errorLabel.text textSizeWithFont:self.errorLabel.font constrainedToSize:CGSizeMake(KScreenWidth - 32, MAXFLOAT) lineBreakMode:self.errorLabel.lineBreakMode].height;
    
    [self.passwordTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(32);
    }];
    
    [self.errorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.errorLabel.hidden ? 0 : textheight);
    }];
    
    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(65 + height + (self.errorLabel.hidden ? 0 : textheight));
    }];
    
    [UIView animateWithDuration:0.3
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:showBlock
                     completion:nil];
}

- (void)showBegainEditAnimation {
    self.errorLabel.hidden = YES;
    self.model.isFirstFocus = NO;
    [self showLineAnimation:ZFCOLOR(45, 45, 45, 1) height:kLineHight*2];
}

- (void)showErrorAnimation {
    self.errorLabel.hidden = NO;
    [self showLineAnimation:ZFC0xFE5269() height:kLineHight*2];
    self.model.isValidPassword = NO;
    if (self.passwordTextFieldEditingDidEndHandler) {
        self.passwordTextFieldEditingDidEndHandler(YES,self.model);
    }
}

- (void)showNormalStateAnimation {
    self.errorLabel.hidden = YES;
    [self showLineAnimation:ZFCOLOR(221, 221, 221, 1) height:kLineHight];
    if (self.passwordTextFieldEditingDidEndHandler) {
        self.model.isValidPassword = YES;
        self.passwordTextFieldEditingDidEndHandler(NO,self.model);
    }
}

- (void)resetAnimation {
    self.errorLabel.hidden = YES;
    [self showLineAnimation:ZFCOLOR(221, 221, 221, 1) height:kLineHight];
    if (self.passwordTextFieldEditingDidEndHandler) {
        self.model.isValidPassword = NO;
        self.passwordTextFieldEditingDidEndHandler(NO,self.model);
    }
}

#pragma mark - Getter
- (YWLoginTextField *)passwordTextField {
    if (!_passwordTextField) {
        _passwordTextField = [[YWLoginTextField alloc] init];
        _passwordTextField.backgroundColor = [UIColor whiteColor];
        _passwordTextField.keyboardType = UIKeyboardTypeEmailAddress;
        _passwordTextField.returnKeyType = UIReturnKeyDone;
        _passwordTextField.placeholder = ZFLocalizedString(@"SignIn_Password",nil);
        _passwordTextField.font = [UIFont systemFontOfSize:16.f];
        _passwordTextField.textColor = ZFCOLOR(45, 45, 45, 1);
        _passwordTextField.clearImage = [UIImage imageNamed:@"login_clearButton"];
        _passwordTextField.placeholderFont = ZFFontSystemSize(16);
        _passwordTextField.placeholderAnimationFont = ZFFontSystemSize(14);
        _passwordTextField.placeholderNormalColor = ZFCOLOR(153, 153, 153, 1);
        _passwordTextField.secureTextEntry = YES;
        if (self.isShowDone) {
            [_passwordTextField addDoneOnKeyboardWithTarget:self action:@selector(doneAction)];
        }
        _passwordTextField.delegate = self;
        _passwordTextField.rightButton = self.eyeButton;
    }
    return _passwordTextField;
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
        _errorLabel.text = ZFLocalizedString(@"Register_Confirm_Tip_Password",nil);
        _errorLabel.hidden = YES;
    }
    return _errorLabel;
}

- (UIButton *)eyeButton {
    if (!_eyeButton) {
        _eyeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_eyeButton setImage:[UIImage imageNamed:@"login_closeeye"] forState:UIControlStateNormal];
        [_eyeButton setImage:[UIImage imageNamed:@"login_openeye"] forState:UIControlStateSelected];
        [_eyeButton addTarget:self action:@selector(showPassWord:) forControlEvents:UIControlEventTouchUpInside];
        [_eyeButton setEnlargeEdge:10];
    }
    return _eyeButton;
}

@end
