//
//  YWLoginFooterView.m
//  ZZZZZ
//
//  Created by YW on 26/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "SystemConfigUtils.h"
#import "ZFButton.h"
#import "ZFFrameDefiner.h"
#import "Masonry.h"
#import "Constants.h"

@interface YWLoginFooterView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UILabel       *tipLabel;

@property (nonatomic, strong) UIButton      *vkButton;
@property (nonatomic, strong) UIButton      *facebookButton;
@property (nonatomic, strong) UIButton      *googlePlusButton;
@property (nonatomic, strong) YYLabel       *infomationLabel;
@end

@implementation YWLoginFooterView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    [self addSubview:self.tipLabel];
    [self addSubview:self.vkButton];
    [self addSubview:self.googlePlusButton];
    [self addSubview:self.facebookButton];
    [self addSubview:self.infomationLabel];
    [self addSubview:self.googlePlusButton];
    [self addSubview:self.facebookButton];
}

- (void)zfAutoLayoutView {
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    
    [self.googlePlusButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    [self.facebookButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.leading.mas_equalTo(self.googlePlusButton.mas_trailing).offset(50);
    }];
    
    [self.vkButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
        make.size.mas_equalTo(CGSizeMake(44, 44));
        make.trailing.mas_equalTo(self.googlePlusButton.mas_leading).offset(-50);
    }];
    
    [self.infomationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.facebookButton.mas_bottom).offset(14);
        make.leading.mas_equalTo(self).offset(16);
        make.trailing.mas_equalTo(self).offset(-16);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-kiphoneXHomeBarHeight);
    }];
    
    
}

- (void)configurationRus:(BOOL)isRus {
    if (isRus) {
        self.vkButton.hidden = NO;
        
        [self.googlePlusButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.centerX.mas_equalTo(self.mas_centerX);
        }];
        
        [self.facebookButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.leading.mas_equalTo(self.googlePlusButton.mas_trailing).offset(50);
        }];
        
    } else {
        self.vkButton.hidden = YES;
        
        [self.googlePlusButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.trailing.mas_equalTo(self.mas_centerX).offset(-44);
        }];
        
        [self.facebookButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
            make.size.mas_equalTo(CGSizeMake(44, 44));
            make.leading.mas_equalTo(self.mas_centerX).offset(44);
        }];
    }
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    self.infomationLabel.attributedText = [self fetchTipTitle:model.type == YWLoginEnterTypeLogin];
}

#pragma mark - Action

- (void)vkButtonAction:(UIButton *)sender {
    //防止重复点击
    sender.enabled = NO;
    if (self.vkButtonCompletionHandler) {
        self.vkButtonCompletionHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}


- (void)facebookButtonAction:(UIButton *)sender {
    //防止重复点击
    sender.enabled = NO;
    if (self.facebookButtonCompletionHandler) {
        self.facebookButtonCompletionHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

- (void)googleplusButtonAction:(UIButton *)sender {
    //防止重复点击
    sender.enabled = NO;
    if (self.googleplusButtonCompletionHandler) {
        self.googleplusButtonCompletionHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
}

#pragma mark - Private method
- (NSAttributedString *)fetchTipTitle:(BOOL)isSignin {
    UIColor *normalColor = ZFCOLOR(135, 135, 135, 1.0);
    UIColor *lineColor = ZFCOLOR(45, 45, 45, 1.0);
    NSString *registerStr = [NSString stringWithFormat:@"%@ %@",ZFLocalizedString(@"Information_security_SigningUp", nil),ZFLocalizedString(@"Information_security_publicAdvice", nil)];
    
    NSString *signInStr = ZFLocalizedString(@"Information_security_LoginAdvice", nil);
    
    NSString *allString = isSignin ? signInStr : registerStr;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:allString];
    content.yy_font = ZFFontSystemSize(12.0);
    content.yy_color = normalColor;
    content.yy_alignment = NSTextAlignmentCenter;
    
    if (isSignin) return content;
    
    //Terms Of Use
    @weakify(self)
    NSString *termsUseStr = ZFLocalizedString(@"Information_Register_TermsOfUser",nil);
    NSRange termsUseRange = [allString rangeOfString:termsUseStr];
    [content yy_setColor:lineColor range:termsUseRange];
    [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:termsUseRange];
    [content yy_setUnderlineColor:lineColor range:termsUseRange];
    [content yy_setTextHighlightRange:termsUseRange color:lineColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 Terms Of Use");
        @strongify(self)
        if (self.privacyPolicyActionBlock) {
            self.privacyPolicyActionBlock(1);
        }
    }];
    
    //Privacy Policy
    NSString *privacyStr = ZFLocalizedString(@"Information_Register_PrivacyPolicy",nil);
    NSRange privacyRange = [allString rangeOfString:privacyStr];
    [content yy_setColor:lineColor range:privacyRange];
    [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:privacyRange];
    [content yy_setUnderlineColor:lineColor range:privacyRange];
    [content yy_setTextHighlightRange:privacyRange color:lineColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 Privacy Policy");
        @strongify(self)
        if (self.privacyPolicyActionBlock) {
            self.privacyPolicyActionBlock(0);
        }
    }];
    return content;
}

#pragma mark - Getter
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = ZFFontSystemSize(12);
        _tipLabel.text = [NSString stringWithFormat:@"- %@ -",ZFLocalizedString(@"sign_in_with", nil)];
        _tipLabel.textColor = ZFCOLOR(153, 153, 153, 1);
    }
    return _tipLabel;
}


- (UIButton *)vkButton {
    if (!_vkButton) {
        _vkButton = [ZFButton buttonWithType:UIButtonTypeCustom];
        [_vkButton setImage:[UIImage imageNamed:@"VKontakte"] forState:UIControlStateNormal];
        [_vkButton addTarget:self action:@selector(vkButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _vkButton;
}

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [ZFButton buttonWithType:UIButtonTypeCustom];
        [_facebookButton setImage:[UIImage imageNamed:@"register_fb"] forState:UIControlStateNormal];
        [_facebookButton addTarget:self action:@selector(facebookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _facebookButton;
}

- (UIButton *)googlePlusButton {
    if (!_googlePlusButton) {
        _googlePlusButton = [ZFButton buttonWithType:UIButtonTypeCustom];
        [_googlePlusButton setImage:[UIImage imageNamed:@"register_google"] forState:UIControlStateNormal];
        [_googlePlusButton addTarget:self action:@selector(googleplusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _googlePlusButton;
}

- (YYLabel *)infomationLabel {
    if (!_infomationLabel) {
        _infomationLabel = [[YYLabel alloc] init];
        _infomationLabel.backgroundColor = [UIColor whiteColor];
        _infomationLabel.textColor = ZFCOLOR(135, 135, 135, 1);
        _infomationLabel.numberOfLines = 0;
        _infomationLabel.font = ZFFontSystemSize(12.f);
        _infomationLabel.textAlignment = NSTextAlignmentCenter;
        _infomationLabel.attributedText = [self fetchTipTitle:NO];
        _infomationLabel.preferredMaxLayoutWidth = KScreenWidth - 32;
        _infomationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _infomationLabel;
}

@end
