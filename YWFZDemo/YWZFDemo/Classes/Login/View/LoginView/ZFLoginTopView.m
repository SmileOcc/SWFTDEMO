//
//  YWLoginTopView.m
//  ZZZZZ
//
//  Created by YW on 25/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginTopView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"

@interface YWLoginTopView()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton   *closeButton;
@property (nonatomic, strong) UIButton   *loginButton;
@end

@implementation YWLoginTopView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.backgroundColor = ZFCOLOR_WHITE;
    [self addSubview:self.closeButton];
    [self addSubview:self.loginButton];
}

- (void)zfAutoLayoutView {
    [self.closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(13);
        make.bottom.mas_equalTo(-7);
        make.size.mas_equalTo(CGSizeMake(28, 28));
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(-16);
        make.bottom.mas_equalTo(-7);
        make.height.mas_equalTo(36);
    }];
}

#pragma mark - Action
- (void)closeLoginVC {
    if (self.loginCloseHandler) {
        self.loginCloseHandler();
    }
}

- (void)toggleMode:(UIButton *)sender {
    NSString *title = nil;
    if (self.model.type == YWLoginEnterTypeRegister) {
        title = ZFLocalizedString(@"Register_Button", nil);
        self.model.type = YWLoginEnterTypeLogin;
    } else {
        title = ZFLocalizedString(@"login_title", nil);
        self.model.type = YWLoginEnterTypeRegister;
    }
    [self.loginButton setTitle:title forState:UIControlStateNormal];

    self.model.isChangeType = YES;
    self.model.isFirstFocus = NO;
    if (self.toggleModeHandler) {
        self.toggleModeHandler(self.model);
    }
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    NSString *title = model.type == YWLoginEnterTypeLogin ? ZFLocalizedString(@"Register_Button",nil) : ZFLocalizedString(@"login_title",nil);
    [self.loginButton setTitle:title forState:UIControlStateNormal];
}

#pragma mark - Getter
- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_closeButton setImage:ZFImageWithName(@"login_dismiss") forState:UIControlStateNormal];
        _closeButton.backgroundColor = ZFCOLOR_WHITE;
        [_closeButton addTarget:self action:@selector(closeLoginVC) forControlEvents:UIControlEventTouchUpInside];
        [_closeButton setEnlargeEdge:20];
    }
    return _closeButton;
}

- (UIButton *)loginButton {
    if (!_loginButton) {
        _loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_loginButton setTitleColor:ZFCOLOR(0, 0, 0, 1) forState:UIControlStateNormal];
        [_loginButton setTitleColor:ZFCOLOR(0, 0, 0, 0.5) forState:UIControlStateHighlighted];
        _loginButton.backgroundColor = ZFCOLOR_WHITE;
        [_loginButton addTarget:self action:@selector(toggleMode:) forControlEvents:UIControlEventTouchUpInside];
        [_loginButton setEnlargeEdge:20];
    }
    return _loginButton;
}

@end

