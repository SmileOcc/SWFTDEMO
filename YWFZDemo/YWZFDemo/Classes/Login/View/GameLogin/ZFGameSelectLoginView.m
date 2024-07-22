//
//  ZFGameSelectLoginView.m
//  ZZZZZ
//
//  Created by YW on 2019/6/11.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFGameSelectLoginView.h"
#import "ZFGameLoingTitleView.h"
#import "ZFLocalizationString.h"
#import "ZFFrameDefiner.h"
#import "ZFThemeManager.h"

#import <Masonry/Masonry.h>

@interface ZFGameSelectLoginView ()

@property (nonatomic, strong) ZFGameLoingTitleView *titleView;

@property (nonatomic, strong) UILabel *registerTipsLabel;
///注册按钮
@property (nonatomic, strong) UIButton *registerButton;

///游客登录按钮
@property (nonatomic, strong) UIButton *guestButton;
@property (nonatomic, strong) UILabel *guestTipsLabel;
@end

@implementation ZFGameSelectLoginView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self addSubview:self.titleView];
        [self addSubview:self.registerTipsLabel];
        [self addSubview:self.registerButton];
        
        [self addSubview:self.guestTipsLabel];
        [self addSubview:self.guestButton];
        
        [self.registerTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.titleView.mas_bottom).mas_offset(24);
            make.leading.mas_equalTo(self.mas_leading).mas_offset(16);
            make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-16);
        }];
        
        [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.mas_equalTo(self.registerTipsLabel);
            make.trailing.mas_equalTo(self.registerTipsLabel);
            make.height.mas_offset(40);
            make.top.mas_equalTo(self.registerTipsLabel.mas_bottom).mas_offset(12);
        }];
        
        [self.guestTipsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.registerButton.mas_bottom).mas_offset(36);
            make.leading.mas_equalTo(self.registerTipsLabel);
            make.trailing.mas_equalTo(self.registerTipsLabel);
        }];
        
        [self.guestButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.guestTipsLabel.mas_bottom).mas_offset(12);
            make.leading.mas_equalTo(self.registerTipsLabel);
            make.trailing.mas_equalTo(self.registerTipsLabel);
            make.height.mas_offset(40);
            make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-(24 + kiphoneXHomeBarHeight));
        }];
        
        [self mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_offset(KScreenWidth);
        }];
        
        [self setNeedsLayout];
        [self layoutIfNeeded];
    }
    return self;
}

#pragma mark - target

- (void)popView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameSelectLoginViewDidClickCloseButton)]) {
        [self.delegate ZFGameSelectLoginViewDidClickCloseButton];
    }
}

- (void)registerButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameSelectLoginViewUseEmailLogin)]) {
        [self.delegate ZFGameSelectLoginViewUseEmailLogin];
    }
}

- (void)guestButtonAction
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(ZFGameSelectLoginViewGuestLogin)]) {
        [self.delegate ZFGameSelectLoginViewGuestLogin];
    }
}

#pragma mark - setter and getter

-(ZFGameLoingTitleView *)titleView
{
    if (!_titleView) {
        _titleView = ({
            ZFGameLoingTitleView *view = [[ZFGameLoingTitleView alloc] init];
            view.title = ZFLocalizedString(@"Bag_CheckOut", nil);
            view.image = [UIImage imageNamed:@"size_close"];
            [view addtarget:self action:@selector(popView)];
            view;
        });
    }
    return _titleView;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.cornerRadius = 3;
            button.layer.masksToBounds = YES;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            button.backgroundColor = ZFC0x2D2D2D();
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"Customer_continue_checkout", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(registerButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _registerButton;
}

-(UILabel *)registerTipsLabel
{
    if (!_registerTipsLabel) {
        _registerTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"Customer_create_account_shopping", nil);
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _registerTipsLabel;
}

- (UIButton *)guestButton {
    if (!_guestButton) {
        _guestButton = ({
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.layer.cornerRadius = 3;
            button.layer.masksToBounds = YES;
            button.titleLabel.font = [UIFont boldSystemFontOfSize:16];
            button.layer.borderColor = ZFC0x2D2D2D().CGColor;
            button.layer.borderWidth = 1;
            button.backgroundColor = ZFC0xFFFFFF();
            [button setTitleColor:ZFC0x2D2D2D() forState:UIControlStateNormal];
            [button setTitle:ZFLocalizedString(@"Customer_checkout_as_guest", nil) forState:UIControlStateNormal];
            [button addTarget:self action:@selector(guestButtonAction) forControlEvents:UIControlEventTouchUpInside];
            button;
        });
    }
    return _guestButton;
}

-(UILabel *)guestTipsLabel
{
    if (!_guestTipsLabel) {
        _guestTipsLabel = ({
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"Customer_quickly_creating_account", nil);
            label.textColor = ZFC0x2D2D2D();
            label.font = [UIFont systemFontOfSize:14];
            label;
        });
    }
    return _guestTipsLabel;
}

@end
