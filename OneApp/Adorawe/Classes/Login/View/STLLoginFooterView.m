//
//  STLLoginFooterView.m
// XStarlinkProject
//
//  Created by odd on 2020/7/31.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLLoginFooterView.h"
#import "YYText.h"
#import "STLButton.h"
#import "Adorawe-Swift.h"

@interface STLLoginFooterView()

@property (nonatomic, strong) UILabel       *tipLabel;

@property (nonatomic, strong) UIButton      *appleButton;
@property (nonatomic, strong) UIButton      *facebookButton;
@property (nonatomic, strong) UIButton      *googlePlusButton;
@property (nonatomic, strong) YYLabel       *infomationLabel;

@end

@implementation STLLoginFooterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self stlInitView];
        [self stlAutoLayoutView];
    }
    return self;
}

#pragma mark - STLInitViewProtocol
- (void)stlInitView {
    [self addSubview:self.tipLabel];
    [self addSubview:self.appleButton];
    [self addSubview:self.googlePlusButton];
    [self addSubview:self.facebookButton];
    [self addSubview:self.infomationLabel];
    [self addSubview:self.googlePlusButton];
    [self addSubview:self.facebookButton];
    
    self.infomationLabel.attributedText = [self fetchTipTitle:NO];

}

- (void)stlAutoLayoutView {
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.centerX.mas_equalTo(self.mas_centerX);
    }];
    
    __block BOOL isShowGoogle = NO;
    __block BOOL isShowFB = NO;
    NSArray *thirdArr = [OSSVAccountsManager sharedManager].loginThirdList;
    if (STLJudgeNSArray(thirdArr)) {
        [thirdArr enumerateObjectsUsingBlock:^(LoginThirdModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([@"Google" isEqualToString:STLToString(obj.thrid_app_name)]) {
                isShowGoogle = [STLToString(obj.state) isEqualToString:@"0"] ? YES : NO;
            } else if([@"Facebook" isEqualToString:STLToString(obj.thrid_app_name)]) {
                isShowFB = [STLToString(obj.state) isEqualToString:@"0"] ? YES : NO;
            }
        }];
    }

    self.googlePlusButton.hidden = !isShowGoogle;
    self.facebookButton.hidden = !isShowFB;
    
    
    if (@available(iOS 13.0, *)) {
        self.appleButton.hidden = NO;
        
        if (!isShowGoogle && !isShowFB) {
            [self.appleButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.centerX.mas_equalTo(self);
            }];
            
        } else if (isShowGoogle && isShowFB) {
            
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
            
            [self.appleButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.trailing.mas_equalTo(self.googlePlusButton.mas_leading).offset(-50);
            }];
            
        } else if(isShowGoogle) {
            
            [self.appleButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.trailing.mas_equalTo(self.mas_centerX).offset(-25);
            }];
            
            [self.googlePlusButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.leading.mas_equalTo(self.appleButton.mas_trailing).offset(50);
            }];
            
        } else if(isShowFB) {
            [self.appleButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.trailing.mas_equalTo(self.mas_centerX).offset(-25);
            }];
            
            [self.facebookButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.leading.mas_equalTo(self.appleButton.mas_trailing).offset(50);
            }];
        }
        
        
    } else {
        
        
        if (isShowGoogle && isShowFB) {
            
            [self.googlePlusButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.trailing.mas_equalTo(self.mas_centerX).offset(-25);
            }];
            
            [self.facebookButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.leading.mas_equalTo(self.googlePlusButton.mas_trailing).offset(50);
            }];
        } else if(isShowGoogle) {
            [self.googlePlusButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.centerX.mas_equalTo(self);
            }];
        } else if(isShowFB) {
            [self.facebookButton mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(12);
                make.size.mas_equalTo(CGSizeMake(44, 44));
                make.centerX.mas_equalTo(self);
            }];
        }
    }
    
    
    [self.infomationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(56+24);
        make.leading.mas_equalTo(self).offset(16);
        make.trailing.mas_equalTo(self).offset(-16);
        make.bottom.mas_equalTo(self.mas_bottom).mas_offset(-kIPHONEX_BOTTOM - 48);
    }];
    
    if (self.facebookButton.isHidden && self.googlePlusButton.isHidden && self.appleButton.isHidden) {
        self.infomationLabel.hidden = YES;
    }
}

#pragma mark - Action

- (void)appleButtonAction:(UIButton *)sender {
    //防止重复点击
    sender.enabled = NO;
    if (self.appleCompletionHandler) {
        self.appleCompletionHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    [GATools logSignInSignUpActionWithEventName:@"login_action" action:[NSString stringWithFormat:@"Entrance_%@",@"Apple"]];
}


- (void)facebookButtonAction:(UIButton *)sender {
    //防止重复点击
    sender.enabled = NO;
    if (self.facebookCompletionHandler) {
        self.facebookCompletionHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    [GATools logSignInSignUpActionWithEventName:@"login_action" action:[NSString stringWithFormat:@"Entrance_%@",@"Facebook"]];
}

- (void)googleplusButtonAction:(UIButton *)sender {
    //防止重复点击
    sender.enabled = NO;
    if (self.googleplusCompletionHandler) {
        self.googleplusCompletionHandler();
    }
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        sender.enabled = YES;
    });
    [GATools logSignInSignUpActionWithEventName:@"login_action" action:[NSString stringWithFormat:@"Entrance_%@",@"Google"]];
}

#pragma mark - Private method
- (NSAttributedString *)fetchTipTitle:(BOOL)isSignin {
    UIColor *normalColor = OSSVThemesColors.col_999999;
    UIColor *lineColor = OSSVThemesColors.col_999999;
    NSString *registerStr = [NSString stringWithFormat:@"%@ %@ %@",STLLocalizedString_(@"signInfoOfPrivacyPolicy", nil),STLLocalizedString_(@"signInfoOfAnd", nil),STLLocalizedString_(@"signInfoOftermsOfProtection", nil)];
    
    NSString *allString = registerStr;

//    NSString *signInStr = STLLocalizedString_(@"Information_security_LoginAdvice", nil);
//
//    NSString *allString = isSignin ? signInStr : registerStr;
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:allString];
    content.yy_font = FontWithSize(12.0);
    content.yy_color = normalColor;
    content.yy_alignment = NSTextAlignmentCenter;
//
//    if (isSignin) return content;
    

    //Terms Of Use
    @weakify(self)
    NSString *termsUseStr = STLLocalizedString_(@"signInfoOfPrivacyPolicy",nil);
    NSRange termsUseRange = [allString rangeOfString:termsUseStr];
    [content yy_setColor:lineColor range:termsUseRange];
    [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:termsUseRange];
    [content yy_setUnderlineColor:lineColor range:termsUseRange];
    [content yy_setTextHighlightRange:termsUseRange color:lineColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        STLLog(@"点击了 Terms Of Use");
        @strongify(self)
        if (self.privacyPolicyActionBlock) {
            self.privacyPolicyActionBlock(0);
        }
    }];
    
    //Privacy Policy
    NSString *privacyStr = STLLocalizedString_(@"signInfoOftermsOfProtection",nil);
    NSRange privacyRange = [allString rangeOfString:privacyStr];
    [content yy_setColor:lineColor range:privacyRange];
    [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:privacyRange];
    [content yy_setUnderlineColor:lineColor range:privacyRange];
    [content yy_setTextHighlightRange:privacyRange color:lineColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        STLLog(@"点击了 Privacy Policy");
        @strongify(self)
        if (self.privacyPolicyActionBlock) {
            self.privacyPolicyActionBlock(1);
        }
    }];
    return content;
}

#pragma mark - Getter
- (UILabel *)tipLabel {
    if (!_tipLabel) {
        _tipLabel = [[UILabel alloc] init];
        _tipLabel.font = FontWithSize(12);
        _tipLabel.text = [NSString stringWithFormat:@"- %@ -",STLLocalizedString_(@"sign_in_with", nil)];
        _tipLabel.textColor = OSSVThemesColors.col_666666;
    }
    return _tipLabel;
}


- (UIButton *)appleButton {
    if (!_appleButton) {
        _appleButton = [STLButton buttonWithType:UIButtonTypeCustom];
        [_appleButton setImage:[UIImage imageNamed:@"apple"] forState:UIControlStateNormal];
        [_appleButton addTarget:self action:@selector(appleButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _appleButton.hidden = YES;
    }
    return _appleButton;
}

- (UIButton *)facebookButton {
    if (!_facebookButton) {
        _facebookButton = [STLButton buttonWithType:UIButtonTypeCustom];
        [_facebookButton setImage:[UIImage imageNamed:@"register_fb"] forState:UIControlStateNormal];
        [_facebookButton addTarget:self action:@selector(facebookButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _facebookButton.hidden = YES;

    }
    return _facebookButton;
}

- (UIButton *)googlePlusButton {
    if (!_googlePlusButton) {
        _googlePlusButton = [STLButton buttonWithType:UIButtonTypeCustom];
        [_googlePlusButton setImage:[UIImage imageNamed:@"register_google"] forState:UIControlStateNormal];
        [_googlePlusButton addTarget:self action:@selector(googleplusButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _googlePlusButton.hidden = YES;
    }
    return _googlePlusButton;
}

- (YYLabel *)infomationLabel {
    if (!_infomationLabel) {
        _infomationLabel = [[YYLabel alloc] init];
        _infomationLabel.backgroundColor = [UIColor whiteColor];
        _infomationLabel.textColor = OSSVThemesColors.col_999999;
        _infomationLabel.numberOfLines = 0;
        _infomationLabel.font = FontWithSize(12.f);
        _infomationLabel.textAlignment = NSTextAlignmentCenter;
        _infomationLabel.attributedText = [self fetchTipTitle:NO];
        _infomationLabel.preferredMaxLayoutWidth = SCREEN_WIDTH - 32;
        _infomationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _infomationLabel;
}

-(void)setTextTitleTipText:(NSString *)textTitleTipText{
    _tipLabel.text = textTitleTipText;
}

@end
