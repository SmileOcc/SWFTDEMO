//
//  ZFGameLoginPasswordView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/27.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGameLoginPasswordView.h"
#import "ZFGameLoingTitleView.h"
#import "ZFThemeManager.h"
#import "UIView+LayoutMethods.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFFrameDefiner.h"

@interface ZFGameLoginPasswordView ()

@property (nonatomic, strong) UIButton *jumpLoginButton;                    ///跳转到大登录页面的按钮
@property (nonatomic, strong) UIButton *loginButton;                        ///用户点击登录的按钮
@property (nonatomic, strong) UIButton *forgetButton;
@property (nonatomic, strong) UILabel *tipsLabel;
@property (nonatomic, strong) ZFGameLoingTitleView *titleView;
@end

@implementation ZFGameLoginPasswordView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleView];
        [self addSubview:self.passwordView];
        [self addSubview:self.tipsLabel];
        [self addSubview:self.loginButton];
        [self addSubview:self.jumpLoginButton];
        [self addSubview:self.forgetButton];
        
        [self.tipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleView.mas_bottom).mas_offset(16);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
        }];
        
        [self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.tipsLabel.mas_bottom);
            make.leading.trailing.equalTo(self);
            make.height.mas_equalTo(68);
        }];
        
        [self.forgetButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.loginButton.mas_top).mas_offset(-10);
            make.leading.mas_equalTo(self.tipsLabel);
        }];
        
        [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).mas_offset(16);
            make.trailing.mas_equalTo(self).mas_offset(-16);
            make.height.mas_offset(40);
            make.bottom.mas_equalTo(self.jumpLoginButton.mas_top).mas_offset(-16);
        }];
        
        [self.jumpLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-(24 + kiphoneXHomeBarHeight));
            make.height.mas_offset(19);
        }];
    }
    return self;
}

#pragma mark - target

///返回上一页
- (void)popView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameLoginPasswordViewDidClickClose)]) {
        [self.delegate ZFGameLoginPasswordViewDidClickClose];
    }
}

- (void)loginButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameLoginPasswordViewDidClickLogin)]) {
        [self.delegate ZFGameLoginPasswordViewDidClickLogin];
    }
}

- (void)jumpLoginButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameLoginPasswordViewDidClickJumpLogin)]) {
        [self.delegate ZFGameLoginPasswordViewDidClickJumpLogin];
    }
}

- (void)forgetButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameLoginPasswordViewDidClickForgetPassword)]) {
        [self.delegate ZFGameLoginPasswordViewDidClickForgetPassword];
    }
}

#pragma mark - public method

-(void)passwordBecomeFirstResponder
{
    [self.passwordView.passwordTextField becomeFirstResponder];
}

#pragma mark - setter and getter

-(ZFGameLoingTitleView *)titleView
{
    if (!_titleView) {
        _titleView = ({
            ZFGameLoingTitleView *view = [[ZFGameLoingTitleView alloc] init];
            view.title = ZFLocalizedString(@"GameLogin_InputPassword", nil);
            view.image = [UIImage imageNamed:@"nav_arrow_left"];
            [view addtarget:self action:@selector(popView)];
            view;
        });
    }
    return _titleView;
}

-(YWLoginTypePasswordView *)passwordView
{
    if (!_passwordView) {
        _passwordView = [[YWLoginTypePasswordView alloc] init];
        _passwordView.isShowDone = NO;
        _passwordView.passwordTextField.placeholder = ZFLocalizedString(@"GameLogin_InputPassword", nil);
    }
    return _passwordView;
}

-(UIButton *)loginButton
{
    if (!_loginButton) {
        _loginButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.layer.cornerRadius = 3;
            button.layer.masksToBounds = YES;
            [button setTitle:ZFLocalizedString(@"SignIn_Button", nil) forState:UIControlStateNormal];
            button.titleLabel.font = ZFFontBoldSize(16);
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
            [button setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
            [button addTarget:self action:@selector(loginButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _loginButton;
}

-(UIButton *)jumpLoginButton
{
    if (!_jumpLoginButton) {
        _jumpLoginButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:ZFLocalizedString(@"GameLogin_OtherLoginMethod", nil) forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(jumpLoginButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _jumpLoginButton;
}

-(UIButton *)forgetButton
{
    if (!_forgetButton) {
        _forgetButton = ({
            UIButton *button = [[UIButton alloc] init];
            [button setTitle:ZFLocalizedString(@"SignIn_ForgotPassword", nil) forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:16];
            [button setTitleColor:ZFCOLOR(45, 45, 45, 1) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(forgetButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _forgetButton;
}

-(UILabel *)tipsLabel
{
    if (!_tipsLabel) {
        _tipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"GameLogin_AlreadyRegisterTips", nil);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = [UIColor blackColor];
            label.font = [UIFont systemFontOfSize:14];
            label.numberOfLines = 0;
            label;
        });
    }
    return _tipsLabel;
}

@end
