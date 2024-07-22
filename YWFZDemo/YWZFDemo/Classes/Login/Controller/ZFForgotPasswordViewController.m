//
//  ZFForgotPasswordViewController.m
//  ZZZZZ
//
//  Created by Tsang_Fa on 2018/6/28.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFForgotPasswordViewController.h"
#import "ZFInitViewProtocol.h"
#import "YWLoginModel.h"
#import "YWLoginTypeEmailView.h"
#import "LoginViewModel.h"
#import "UINavigationController+FDFullscreenPopGesture.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "NSStringUtils.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"
#import "YSAlertView.h"

@interface ZFForgotPasswordViewController ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIScrollView                              *scrollView;
@property (nonatomic, strong) UIView                                    *conternView;
@property (nonatomic, strong) UILabel                                   *titleLabel;
@property (nonatomic, strong) YYLabel                                   *messageLabel;
@property (nonatomic, strong) YWLoginTypeEmailView                      *emailView;
@property (nonatomic, strong) UIButton                                  *confirmButton;
@property (nonatomic, strong) YYLabel                                   *resendLabel;
@property (nonatomic, strong) LoginViewModel                            *viewModel;
@property (nonatomic, assign) BOOL                                      isBack;
@property (nonatomic, assign) BOOL                                      isNotRegister;
@property (nonatomic, assign) BOOL                                      isVaildEmail;

@end

@implementation ZFForgotPasswordViewController
#pragma mark - Life cycle
-(void)dealloc
{
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_interactivePopDisabled = YES;
    self.title = ZFLocalizedString(@"SignIn_ForgotPassword", nil);
    [self zfInitView];
    [self zfAutoLayoutView];
    if (self.model.email.length) {
        [self.emailView.emailTextField showPlaceholderAnimation];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.conternView];
    [self.conternView addSubview:self.titleLabel];
    [self.conternView addSubview:self.messageLabel];
    [self.conternView addSubview:self.confirmButton];
    [self.conternView addSubview:self.resendLabel];
    [self.conternView addSubview:self.emailView];
}

- (void)zfAutoLayoutView {
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsZero);
    }];
    
    [self.conternView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(25);
        make.centerX.equalTo(self.conternView);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 75);
    }];
    
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom);
        make.leading.trailing.equalTo(self.conternView);
        make.height.mas_equalTo(69);
    }];
    
    [self.confirmButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.top.equalTo(self.emailView.mas_bottom).offset(36);
        make.height.mas_equalTo(44);
    }];
    
    [self.messageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.titleLabel.mas_bottom).offset(12);
        make.centerX.equalTo(self.conternView);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 40);
    }];
    
    [self.resendLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmButton.mas_bottom).offset(12);
        make.centerX.equalTo(self.conternView);
        make.width.mas_lessThanOrEqualTo(KScreenWidth - 40);
        make.height.mas_equalTo(36);
        make.bottom.equalTo(self.conternView);
    }];
}

#pragma mark - Animation
- (void)showErrorTipAnimation:(BOOL)isShow{
//    void (^showBlock)(void) = ^{
//        [self.view layoutIfNeeded];
//    };
//
//    [self.emailView mas_updateConstraints:^(MASConstraintMaker *make) {
//        make.height.mas_equalTo(isShow ? self.isNotRegister ? 104 : 83 : 69);
//    }];
//    
//    [UIView animateWithDuration:0.3
//                          delay:0.0f
//                        options: UIViewAnimationOptionCurveEaseOut
//                     animations:showBlock
//                     completion:nil];
}

#pragma mark - Request
- (void)forgotPasswordRequestWithEmail:(NSString *)email completion:(void (^)(id params))completion{
    NSDictionary *dict = @{
                           @"email"             : email,
                           kLoadingView         : self.view
                           };
    [self.viewModel requestForgotNetwork:dict completion:^(id obj) {
        if (completion) {
            completion(obj);
        }
    } failure:nil];
}

#pragma mark - Action
- (void)submitHandler {
    [self.view endEditing:YES];
    
    if (self.isBack) {
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if (![NSStringUtils isValidEmailString:self.model.email] || ZFIsEmptyString(self.model.email)) {
        self.isVaildEmail = NO;
        [self.emailView setupErrorTip:NO];
        [self.emailView showErrorAnimation];
        return;
    }
    
    self.isVaildEmail = YES;
    
    @weakify(self)
    [self forgotPasswordRequestWithEmail:self.model.email completion:^(id params) {
        @strongify(self)
        NSInteger errorCode = [params[@"errorCode"] integerValue];
        NSString *msg = params[@"msg"];
        BOOL isRegister = NO;
        
        if (errorCode == 0) {
            isRegister = YES;
            //发送邮件成功
            NSString *tips = [NSString stringWithFormat:@"%@ %@ %@", ZFLocalizedString(@"LoginForgotView_SuccessView_Descripe",nil), self.model.email, ZFLocalizedString(@"LoginForgotView_SuccessView_Descripe2",nil)];
            NSString *cancelTitle = ZFLocalizedString(@"LoginForgotView_OK",nil);
            ShowAlertView(nil, tips, nil, nil, cancelTitle, nil);
        }
        
        if (!isRegister) {
            self.isNotRegister = YES;
            [self.emailView setupErrorMessage:msg];
            [self.emailView showErrorAnimation];
            return;
        }
        
        self.isBack = YES;
        [self.emailView setupErrorTip:NO];
        self.isNotRegister = NO;
        [self.confirmButton mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.messageLabel.mas_bottom).offset(56).priorityLow();
        }];
        
        self.messageLabel.attributedText = [self fetchText:NO];
        self.resendLabel.attributedText = [self fetchText:YES];
        
        self.titleLabel.text = ZFLocalizedString(@"Forgot_success", nil);
        [self.confirmButton setTitle:ZFLocalizedString(@"return_signin", nil) forState:UIControlStateNormal];
        
        @weakify(self)
        void (^showBlock)(void) = ^{
            @strongify(self)
            self.emailView.hidden = YES;
            self.messageLabel.hidden = NO;
            self.resendLabel.hidden = NO;
            [self.view layoutIfNeeded];
        };
        [UIView animateWithDuration:0.3
                              delay:0.0f
                            options: UIViewAnimationOptionCurveEaseOut
                         animations:showBlock
                         completion:nil];
    }];
}

-(void)goBackAction
{
    [super goBackAction];
    if (self.completion) {
        self.completion();
    }
}

#pragma mark - Private method
- (NSAttributedString *)fetchText:(BOOL)isResend {
    UIColor *normalColor = ZFCOLOR(135, 135, 135, 1.0);
    UIColor *hightColor = ZFCOLOR(0, 0, 0, 1);
    NSString *allTitle = nil;
    NSMutableAttributedString *content = nil;
    NSRange normolTouchRange = NSMakeRange(0, 0);
    
    if (!isResend) {
        allTitle = [NSString stringWithFormat:ZFLocalizedString(@"Forgot_message", nil),self.model.email];
        content = [[NSMutableAttributedString alloc] initWithString:allTitle];
        content.yy_font = ZFFontSystemSize(16.0);
        content.yy_color = normalColor;
        
        NSString *email = self.model.email;
        NSRange emailRange = [allTitle rangeOfString:email];
        [content yy_setColor:hightColor range:emailRange];
        [content yy_setFont:ZFFontSystemSize(16.0) range:emailRange];
        
    } else {
        allTitle = ZFLocalizedString(@"resend_password",nil);
        content = [[NSMutableAttributedString alloc] initWithString:allTitle];
        content.yy_font = ZFFontSystemSize(16.0);
        content.yy_color = normalColor;
        
        NSString *resend = ZFLocalizedString(@"resend", nil);
        NSRange resendRange = [allTitle rangeOfString:resend];
        normolTouchRange = NSMakeRange(0, resendRange.location-1);
        [content yy_setColor:hightColor range:resendRange];
        [content yy_setFont:ZFFontSystemSize(16.0) range:resendRange];
        
        @weakify(self)
        [content yy_setTextHighlightRange:resendRange color:hightColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            @strongify(self)
            [self forgotPasswordRequestWithEmail:self.model.email completion:nil];
        }];
    }
    return content;
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    self.emailView.model = _model;
}

#pragma mark - Getter
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _scrollView;
}

- (UIView *)conternView {
    if (!_conternView) {
        _conternView = [[UIView alloc] init];
        _conternView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _conternView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = ZFFontSystemSize(16);
        _titleLabel.textColor = ZFCOLOR(45, 45, 45, 1);
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.text = ZFLocalizedString(@"forgot_title", nil);
    }
    return _titleLabel;
}

- (YWLoginTypeEmailView *)emailView {
    if (!_emailView) {
        _emailView = [[YWLoginTypeEmailView alloc] init];
        @weakify(self)
        _emailView.emailTextFieldEditingDidEndHandler = ^(BOOL isShowError, YWLoginModel *model) {
            @strongify(self);
            self.model = model;
            if (!self.isVaildEmail || ZFIsEmptyString(model.email)) {
                [self.emailView setupErrorTip:NO];
                self.isNotRegister = NO;
            }
            // 刷新高度
            [self showErrorTipAnimation:isShowError];
        };
    }
    return _emailView;
}

- (UIButton *)confirmButton {
    if (!_confirmButton) {
        _confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _confirmButton.layer.cornerRadius = 3;
        _confirmButton.layer.masksToBounds = YES;
        _confirmButton.backgroundColor = ZFC0x2D2D2D();
        [_confirmButton setTitle:ZFLocalizedString(@"submit", nil) forState:UIControlStateNormal];
        [_confirmButton setTitleColor:ZFCOLOR_WHITE forState:UIControlStateNormal];
        _confirmButton.titleLabel.font = ZFFontBoldSize(16);
        [_confirmButton addTarget:self action:@selector(submitHandler) forControlEvents:UIControlEventTouchUpInside];
    }
    return _confirmButton;
}

- (YYLabel *)messageLabel {
    if (!_messageLabel) {
        _messageLabel = [[YYLabel alloc] init];
        _messageLabel.backgroundColor = [UIColor whiteColor];
        _messageLabel.textColor = [UIColor blackColor];
        _messageLabel.numberOfLines = 0;
        _messageLabel.font = ZFFontSystemSize(16.f);
        _messageLabel.textAlignment = NSTextAlignmentCenter;
        _messageLabel.preferredMaxLayoutWidth = KScreenWidth -40;
        _messageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _messageLabel.hidden = YES;
    }
    return _messageLabel;
}

- (YYLabel *)resendLabel {
    if (!_resendLabel) {
        _resendLabel = [[YYLabel alloc] init];
        _resendLabel.backgroundColor = [UIColor whiteColor];
        _resendLabel.textColor = [UIColor blackColor];
        _resendLabel.numberOfLines = 0;
        _resendLabel.font = ZFFontSystemSize(12.f);
        _resendLabel.textAlignment = NSTextAlignmentCenter;
        _resendLabel.textVerticalAlignment = YYTextVerticalAlignmentTop;
        _resendLabel.preferredMaxLayoutWidth = KScreenWidth -40;
        _resendLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _resendLabel.hidden = YES;
    }
    return _resendLabel;
}

- (LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
    }
    return _viewModel;
}

@end
