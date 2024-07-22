//
//  YWLoginTypeMobileView.m
//  ZZZZZ
//
//  Created by YW on 2019/5/21.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "YWLoginTypeMobileView.h"
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

@interface YWLoginTypeMobileView ()
<
    ZFInitViewProtocol,
    UITextFieldDelegate,
    UIGestureRecognizerDelegate
>

@property (nonatomic, strong) UIView             *lineView;
@property (nonatomic, strong) UILabel            *errorLabel;
@property (nonatomic, strong) LoginViewModel     *viewModel;
@property (nonatomic, assign) BOOL               isNeedUpdate;
@property (nonatomic, assign) BOOL               isNotRegister;
@property (nonatomic, copy)   NSString           *inputString;

@end

@implementation YWLoginTypeMobileView

#pragma mark - Life cycle
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    [self addSubview:self.emailTextField];
    [self addSubview:self.lineView];
    [self addSubview:self.errorLabel];
}

- (void)zfAutoLayoutView {
    [self.emailTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(33);
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.mas_equalTo(32).priorityHigh();
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
- (void)emailTextFieldEditingDidBegin {
    if (!self.model.isFirstFocus) {
        if (self.emailTextFieldEditingDidEndHandler) {
            self.emailTextFieldEditingDidEndHandler(NO,self.model);
        }
    }
    [self showBegainEditAnimation];
}

- (void)emailTextFieldEditingDidEnd {
    self.model.phoneNum = self.emailTextField.text;
    if (ZFIsEmptyString(self.emailTextField.text) && self.isNeedUpdate) {
        [self resetAnimation];
        return;
    }
    [self checkValidMobile];
}

- (void)emailTextFieldEditingDidChanged:(NSNotification *)notif {
    NSString *inputString = self.emailTextField.text;
    /** 禁止输入空格 */
    if ([inputString containsString:@" "]) {
        self.emailTextField.text = [inputString stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    if (self.emailTextFieldEditingChangeHandler) {
        self.emailTextFieldEditingChangeHandler(self.emailTextField);
    }
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    self.emailTextField.text = model.phoneNum;
    self.isNeedUpdate = model.isChangeType;
    if (self.isNeedUpdate) {
        if (ZFIsEmptyString(self.emailTextField.text) && !self.errorLabel.hidden) {
            [self resetAnimation];
            self.isNeedUpdate = NO;
            return;
        }
        
        if (!ZFIsEmptyString(model.phoneNum)) {
            [self checkValidMobile];
        }
        self.isNeedUpdate = NO;
    }
}

#pragma mark - Public method

- (void)setupErrorMessage:(NSString *)errorMessage
{
    if (ZFToString(errorMessage).length) {
        self.errorLabel.text = errorMessage;
    }
}

#pragma mark - Private method
- (BOOL)checkValidMobile {

    // 与地址编辑电话号码提示基本一致
    if(ZFIsEmptyString(self.emailTextField.text)){
        self.errorLabel.text = ZFLocalizedString(@"Login_InvalidPhoneTips", nil);
        [self showErrorAnimation];
        return NO;
    } else if (self.emailTextField.text.length > 20){       // 没有限制号码长度   电话号码长度最大不能超过 20位
        self.errorLabel.text =  [NSString stringWithFormat:ZFLocalizedString(@"ModifyAddress_include_Digits",nil),@"20"];
        [self showErrorAnimation];
        return NO;
        
    } else if (self.emailTextField.text.length < 6){       // 没有限制号码长度   电话号码长度最小不能小于
        self.errorLabel.text =  ZFLocalizedString(@"ModifyAddress_valid_phone_number",nil);
        [self showErrorAnimation];
        return NO;
    }
    
    [self showNormalStateAnimation];
    return YES;
}

- (void)showLineAnimation:(UIColor *)color height:(CGFloat)height hiddenErrorLabel:(BOOL)isHidden {
    @weakify(self)
    void (^showBlock)(void) = ^{
        @strongify(self)
        [self layoutIfNeeded];
        self.lineView.backgroundColor = color;
    };
    
    CGFloat textheight = [self.errorLabel.text textSizeWithFont:self.errorLabel.font constrainedToSize:CGSizeMake(KScreenWidth - 32, MAXFLOAT) lineBreakMode:self.errorLabel.lineBreakMode].height;
    
    [self.emailTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(32);
    }];
    
    [self.errorLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(isHidden ? 0 : textheight);
    }];
    
    [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    CGFloat selfHeight = 67 + height + (isHidden ? 0 : textheight);
    [self mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(selfHeight);
    }];
    
    [UIView animateWithDuration:0.3
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:showBlock
                     completion:nil];
}

- (void)showBegainEditAnimation {
//    self.errorLabel.hidden = YES;
    self.model.isFirstFocus = NO;
    [self showLineAnimation:ZFCOLOR(45, 45, 45, 1) height:kLineHight*2 hiddenErrorLabel:YES];
}

- (void)showErrorAnimation {
//    self.errorLabel.hidden = NO;
    [self showLineAnimation:ZFC0xFE5269() height:kLineHight*2 hiddenErrorLabel:NO];
    if (self.emailTextFieldEditingDidEndHandler) {
        self.model.isValidEmail = NO;
        self.emailTextFieldEditingDidEndHandler(YES,self.model);
    }
}

- (void)showNormalStateAnimation {
//    self.errorLabel.hidden = YES;
    [self showLineAnimation:ZFCOLOR(221, 221, 221, 1) height:kLineHight hiddenErrorLabel:YES];
    if (self.emailTextFieldEditingDidEndHandler) {
        self.model.isValidEmail = YES;
        self.emailTextFieldEditingDidEndHandler(NO,self.model);
    }
}

- (void)resetAnimation {
//    self.errorLabel.hidden = YES;
    [self showLineAnimation:ZFCOLOR(221, 221, 221, 1) height:kLineHight hiddenErrorLabel:YES];
    if (self.emailTextFieldEditingDidEndHandler) {
        self.model.isValidEmail = NO;
        self.emailTextFieldEditingDidEndHandler(NO,self.model);
    }
}

#pragma mark - Getter
- (YWLoginTextField *)emailTextField {
    if (!_emailTextField) {
        _emailTextField = [[YWLoginTextField alloc] init];
        _emailTextField.backgroundColor = [UIColor whiteColor];
        _emailTextField.keyboardType = UIKeyboardTypePhonePad;
        _emailTextField.returnKeyType = UIReturnKeyNext;
        _emailTextField.placeholder = ZFLocalizedString(@"Login_PhoneNumber",nil);
        _emailTextField.font = [UIFont systemFontOfSize:16.f];
        _emailTextField.textColor = ZFCOLOR(45, 45, 45, 1);
        _emailTextField.clearImage = [UIImage imageNamed:@"login_clearButton"];
        _emailTextField.placeholderFont = ZFFontSystemSize(16);
        _emailTextField.placeholderAnimationFont = ZFFontSystemSize(14);
        _emailTextField.placeholderNormalColor = ZFCOLOR(153, 153, 153, 1);
        _emailTextField.enablePlaceHoldAnimation = NO;
        [_emailTextField addTarget:self action:@selector(emailTextFieldEditingDidEnd) forControlEvents:(UIControlEventEditingDidEnd)];
        [_emailTextField addTarget:self action:@selector(emailTextFieldEditingDidBegin) forControlEvents:(UIControlEventEditingDidBegin)];
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
        _errorLabel.text = ZFLocalizedString(@"Login_InvalidPhoneTips",nil);
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

@end
