//
//  ZFGameEmailLoginView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGameEmailLoginView.h"
#import "ZFGameLoingTitleView.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"
#import "Constants.h"

#import "UIView+LayoutMethods.h"
#import "UIButton+ZFButtonCategorySet.h"

#import <Masonry/Masonry.h>

@interface ZFGameEmailLoginView ()

@property (nonatomic, strong) YWLoginTypeEmailView *emailView;              ///输入邮箱控件
@property (nonatomic, strong) UILabel *emailTipsLabel;                      ///邮箱提示标签
@property (nonatomic, strong) UIView *tipsEmailView;                        ///邮箱提示控件
@property (nonatomic, strong) UIButton *continueButton;                     ///下一步按钮
@property (nonatomic, strong) UIButton *jumpLoginButton;                    ///跳转到大登录页面的按钮
@property (nonatomic, strong) ZFGameLoingTitleView *titleView;              ///顶部title
@property (nonatomic, strong) UIView *loginMaskView;                        ///登录背景图

@property (nonatomic, assign) CGFloat keyboardHeight;

@end

@implementation ZFGameEmailLoginView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.titleView];
        [self addSubview:self.emailView];
        [self addSubview:self.continueButton];
        [self addSubview:self.jumpLoginButton];
        [self addSubview:self.tipsEmailView];
        [self addSubview:self.emailTipsLabel];
        
        [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).mas_offset(0);
            make.trailing.mas_equalTo(self).mas_offset(0);
            make.top.mas_equalTo(self.mas_top).mas_offset(50);
            make.height.mas_offset(68);
        }];
        
        [self.emailTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.emailView).mas_offset(16);
            make.top.mas_equalTo(self.mas_top).mas_offset(64);
        }];
        
        [self.tipsEmailView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.height.mas_offset(42);
            make.bottom.mas_equalTo(self.mas_bottom);
        }];
        
        [self.continueButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self).mas_offset(16);
            make.trailing.mas_equalTo(self).mas_offset(-16);
            make.height.mas_offset(40);
            make.top.mas_equalTo(self.emailView.mas_bottom).mas_offset(24);
        }];
        
        [self.jumpLoginButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.mas_equalTo(self);
            make.top.mas_equalTo(self.continueButton.mas_bottom).mas_offset(16);
            make.height.mas_offset(19);
        }];
    }
    return self;
}

#pragma mark - private method

- (void)moveToBottom
{
    CGFloat tipsEmailHeight = self.tipsEmailView.height;
    if (self.keyboardHeight > 0) {
        tipsEmailHeight = 0;
    }
    [UIView animateWithDuration:.15 animations:^{
        if (self.jumpLoginButton.hidden) {
            self.height = 268;
        }else{
            self.height = 288;
        }
        self.y = self.superview.height - self.height  - self.keyboardHeight + tipsEmailHeight;
    }];
}

- (void)closeLoginView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameEmailLoginViewDidClickClose:)]) {
        [self.delegate ZFGameEmailLoginViewDidClickClose:self];
    }
}

- (void)pushNextVC
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameEmailLoginViewDidClickContinue:)]) {
        [self.delegate ZFGameEmailLoginViewDidClickContinue:self];
    }
}

- (void)jumpLoginButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameEmailLoginViewDidClickJumpLogin:)]) {
        [self.delegate ZFGameEmailLoginViewDidClickJumpLogin:self];
    }
}

- (void)tipsEmailClick:(UIGestureRecognizer *)sender
{
    id info = sender.view;
    if ([info isKindOfClass:[UILabel class]]) {
        UILabel *emailLabel = (UILabel *)info;
        if (![self.emailView.emailTextField.text containsString:@"@"]) {
            self.emailView.emailTextField.text = [self.emailView.emailTextField.text stringByAppendingString:emailLabel.text];
            self.emailView.emailTextFieldEditingChangeHandler(self.emailView.emailTextField);
            [self.emailView.emailTextField showPlaceholderAnimation];
        }
    }
}

#pragma mark - public method

- (void)emailBecomeFirstResponder
{
    [self.emailView.emailTextField becomeFirstResponder];
}

- (NSString *)gainEmail
{
    return self.loginModel.email;
}

#pragma mark - setter and getter

-(void)setLoginModel:(YWLoginModel *)loginModel
{
    _loginModel = loginModel;
    
    self.emailView.model = loginModel;
}

-(UIView *)loginMaskView
{
    if (!_loginMaskView) {
        _loginMaskView = ({
            UIView *view = [[UIView alloc] initWithFrame:WINDOW.bounds];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.0;
            view;
        });
    }
    return _loginMaskView;
}

-(ZFGameLoingTitleView *)titleView
{
    if (!_titleView) {
        _titleView = ({
            ZFGameLoingTitleView *view = [[ZFGameLoingTitleView alloc] init];
            view.title = ZFLocalizedString(@"GameLogin_EnterYourEmail", nil);
            view.image = [UIImage imageNamed:@"nav_arrow_left"];
            [view addtarget:self action:@selector(closeLoginView)];
            view;
        });
    }
    return _titleView;
}

-(YWLoginTypeEmailView *)emailView
{
    if (!_emailView) {
        _emailView = ({
            YWLoginTypeEmailView *emailView = [[YWLoginTypeEmailView alloc] init];
            emailView.isShowTipsEmail = NO;
            emailView.emailTextField.enablePlaceHoldAnimation = NO;
            emailView.emailTextField.placeholder = ZFLocalizedString(@"GameLogin_EmailPlaceHold", nil);
            @weakify(self)
            emailView.emailTextFieldEditingDidEndHandler = ^(BOOL isShowError, YWLoginModel *model) {
                @strongify(self);
                self.loginModel = model;
            };
            emailView.emailTextFieldEditingChangeHandler = ^(YWLoginTextField *textField) {
                @strongify(self)
                ///判断是否置灰
                if (textField.text.length) {
                    self.continueButton.enabled = YES;
                    [self.continueButton setBackgroundColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
                    [self.continueButton setBackgroundColor:ZFC0x2D2D2D_08() forState:UIControlStateHighlighted];
                }else{
                    self.continueButton.enabled = NO;
                    [self.continueButton setBackgroundColor:ZFCOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
                }
                self.loginModel.email = textField.text;
            };
            emailView;
        });
    }
    return _emailView;
}

-(UIButton *)continueButton
{
    if (!_continueButton) {
        _continueButton = ({
            UIButton *button = [[UIButton alloc] init];
            button.layer.cornerRadius = 3;
            button.layer.masksToBounds = YES;
            [button setTitle:ZFLocalizedString(@"ModifyAddress_Continue", nil) forState:UIControlStateNormal];
            button.titleLabel.font = ZFFontBoldSize(16);
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button addTarget:self action:@selector(pushNextVC) forControlEvents:UIControlEventTouchUpInside];
            [button setBackgroundColor:ZFCOLOR(153, 153, 153, 1) forState:UIControlStateNormal];
            button.enabled = NO;
            button;
        });
    }
    return _continueButton;
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
            button.hidden = YES;
            button;
        });
    }
    return _jumpLoginButton;
}

-(UIView *)tipsEmailView
{
    if (!_tipsEmailView) {
        _tipsEmailView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = [UIColor whiteColor];
            CGFloat width = KScreenWidth / 3;
            NSArray *titles = @[@"@gmail.com", @"@hotmail.com", @"@yahoo.com"];
            for (int i = 0; i < 3; i++) {
                UILabel *label = [[UILabel alloc] init];
                label.frame = CGRectMake(i * width, 0, width, 42);
                label.backgroundColor = ZFCOLOR(187, 194, 202, 1);
                label.textAlignment = NSTextAlignmentCenter;
                label.textColor = [UIColor whiteColor];
                label.font = [UIFont systemFontOfSize:18];
                label.text = titles[i];
                label.userInteractionEnabled = YES;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tipsEmailClick:)];
                [label addGestureRecognizer:tap];
                [view addSubview:label];
            }
            view;
        });
    }
    return _tipsEmailView;
}

-(UILabel *)emailTipsLabel
{
    if (!_emailTipsLabel) {
        _emailTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.text = ZFLocalizedString(@"SignIn_Email", nil);
            label.textAlignment = NSTextAlignmentLeft;
            label.textColor = ZFCOLOR(153, 153, 153, 1);
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _emailTipsLabel;
}



@end
