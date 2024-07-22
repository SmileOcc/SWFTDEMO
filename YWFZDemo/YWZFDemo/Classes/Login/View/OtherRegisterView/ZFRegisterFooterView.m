//
//  ZFRegisterFooterView.m
//  ZZZZZ
//
//  Created by YW on 29/5/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "ZFRegisterFooterView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "ZFLocalizationString.h"
#import "YWCFunctionTool.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIImage+ZFExtended.h"

@interface ZFRegisterFooterView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton      *registerButton;
@property (nonatomic, strong) UIButton      *agreeButton;
@property (nonatomic, strong) YYLabel       *agreeTopLabel;
@property (nonatomic, strong) UIButton      *subscribeButton;
@property (nonatomic, strong) YYLabel       *subscribeTopLabel;
@property (nonatomic, assign) BOOL          isSubscribe;
@end

@implementation ZFRegisterFooterView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    return self;
}

- (void)zfInitView {
    self.contentView.backgroundColor = ZFCOLOR_WHITE;
    [self.contentView addSubview:self.registerButton];
    [self.contentView addSubview:self.agreeButton];
    [self.contentView addSubview:self.agreeTopLabel];
    [self.contentView addSubview:self.subscribeButton];
    [self.contentView addSubview:self.subscribeTopLabel];
}

- (void)zfAutoLayoutView {
    [self.agreeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(12);
    }];
    
    [self.agreeTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.agreeButton.mas_leading).offset(24);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-11);
        make.centerY.mas_equalTo(self.agreeButton);
    }];
    
    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.agreeTopLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(self.agreeButton.mas_leading);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-11);
    }];
    
    [self.subscribeTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([self hasChangeCountryLang]) {
            make.top.equalTo(self.subscribeButton).offset(-3);
        }else{
            make.centerY.mas_equalTo(self.subscribeButton);
        }
        
        make.leading.mas_equalTo(self.subscribeButton.mas_leading).offset(24);
        make.trailing.mas_equalTo(self.contentView.mas_trailing).offset(-11);
    }];
    
    [self.registerButton mas_makeConstraints:^(MASConstraintMaker *make) {
        if ([self hasChangeCountryLang]) {
            make.top.equalTo(self.subscribeTopLabel.mas_bottom).offset(24);
        }else{
            make.top.equalTo(self.subscribeButton.mas_bottom).offset(24);
        }
        make.leading.mas_equalTo(16);
        make.trailing.mas_equalTo(-16);
        make.height.mas_equalTo(40);
    }];
}

- (void)showTipAnimation {
    if (!self.agreeButton.selected) {
        [self shakeKitWithAnimation:self.agreeTopLabel];
        return;
    }
    
    //欧盟国家,一定要勾选下面的协议
    BOOL hasChangeCountry = [self hasChangeCountryLang];
    if (hasChangeCountry && !self.subscribeButton.selected) {
        [self shakeKitWithAnimation:self.subscribeTopLabel];
        return;
    }
}

#pragma mark - Private method
- (void)shakeKitWithAnimation:(UIView *)shakeKit {
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.fromValue = [NSNumber numberWithFloat:-5];
    shake.toValue = [NSNumber numberWithFloat:5];
    shake.duration = 0.1;//执行时间
    shake.autoreverses = YES; //是否重复
    shake.repeatCount = 2;//次数
    [shakeKit.layer addAnimation:shake forKey:@"shakeAnimation"];
    shakeKit.alpha = 1.0;
}

- (NSAttributedString *)fetchAgreeTermsUseTitle {
    NSString *allString = ZFLocalizedString(@"Register_AgreeTermsOfUser", nil);
    NSMutableAttributedString *content = [[NSMutableAttributedString alloc] initWithString:allString];
    content.yy_font = ZFFontSystemSize(12.0);
    content.yy_color = ZFCOLOR(34, 34, 34, 1.0);
    
    //Terms Of Use
    @weakify(self)
    NSString *componentStr = ZFLocalizedString(@"Information_Register_TermsOfUser",nil);
    NSRange termsUseRange = [allString rangeOfString:componentStr];
    [content yy_setColor:ZFCOLOR(34, 34, 34, 1.0) range:termsUseRange];
    [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:termsUseRange];
    [content yy_setUnderlineColor:ZFCOLOR(34, 34, 34, 1.0) range:termsUseRange];
    [content yy_setTextHighlightRange:termsUseRange color:ZFCOLOR(34, 34, 34, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 Terms Of Use");
        @strongify(self)
        if (self.privacyPolicyActionBlock) {
            self.privacyPolicyActionBlock(TreatyLinkAction_TermsUse);
        }
    }];
    
    //添加点击 "I agree to ZZZZZ "事件
    NSRange agreeRange = NSMakeRange(0, termsUseRange.location-1);
    [content yy_setTextHighlightRange:agreeRange color:ZFCOLOR(34, 34, 34, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 I agree to ZZZZZ ");
        @strongify(self)
        [self subscribeButtonAction:self.agreeButton];
    }];
    return content;
}

- (void)subscribeButtonAction:(UIButton *)sender {
    [self endEditing:YES];
    sender.selected = !sender.selected;
    self.isSubscribe = sender.selected;
}

/**
 *  I confirm all informatio。。。
 */
- (NSAttributedString *)fetchSubscribeTopLabelTitle {
    UIColor *normalColor = ZFCOLOR(34, 34, 34, 1.0);
    NSString *allTitle = nil;
    NSMutableAttributedString *content = nil;
    NSRange normolTouchRange = NSMakeRange(0, 0);
    
    if ([self hasChangeCountryLang]) {
        allTitle = ZFLocalizedString(@"Register_ConfirmInformation",nil);
        content = [[NSMutableAttributedString alloc] initWithString:allTitle];
        content.yy_font = ZFFontSystemSize(12.0);
        content.yy_color = normalColor;
        
        //Privacy Policy链接
        NSString *componentStr1 = ZFLocalizedString(@"Register_PrivacyPolicy", nil);
        NSRange policyRange = [allTitle rangeOfString:componentStr1];
        normolTouchRange = NSMakeRange(0, policyRange.location-1);;
        [content yy_setColor:ZFCOLOR(34, 34, 34, 1.0) range:policyRange];
        [content yy_setFont:ZFFontSystemSize(12.0) range:policyRange];
        [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:policyRange];
        [content yy_setUnderlineColor:ZFCOLOR(34, 34, 34,1.0) range:policyRange];
        
        @weakify(self)
        [content yy_setTextHighlightRange:policyRange color:ZFCOLOR(34, 34, 34, 1.0) backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            YWLog(@"点击了 Privacy Policy");
            @strongify(self)
            if (self.privacyPolicyActionBlock) {
                self.privacyPolicyActionBlock(TreatyLinkAction_ProvacyPolicy);
            }
        }];
    } else {
        allTitle = ZFLocalizedString(@"Register_subscribe",nil);
        content = [[NSMutableAttributedString alloc] initWithString:allTitle];
        content.yy_font = ZFFontSystemSize(12.0);
        content.yy_color = ZFCOLOR(34, 34, 34, 1.0);;
        normolTouchRange = [allTitle rangeOfString:allTitle];
    }
    
    //相当于点击按钮
    @weakify(self)
    [content yy_setTextHighlightRange:normolTouchRange color:normalColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 I confirm all 。。。");
        @strongify(self)
        [self subscribeButtonAction:self.subscribeButton];
    }];
    return content;
}

/**
 * 是否已切换到欧盟国家
 */
- (BOOL)hasChangeCountryLang {
    //根据国家ip来判断,  country_eu : 0         1 欧盟字段标识
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    NSString *country_eu = ZFToString(initializeModel.country_eu);
    return [country_eu boolValue];
}

#pragma mark - Action
- (void)registerButtonAction:(UIButton *)sender {
    [self endEditing:YES];
    if (self.registerButtonCompletionHandler) {
        self.registerButtonCompletionHandler(self.agreeButton.selected, self.isSubscribe);
    }
}

#pragma mark - Getter
- (UIButton *)agreeButton {
    if (!_agreeButton) {
        _agreeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_agreeButton setImage:[UIImage imageNamed:@"login_unchoosed"] forState:UIControlStateNormal];
        [_agreeButton setImage:[[UIImage imageNamed:@"login_choosed"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        _agreeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_agreeButton addTarget:self action:@selector(subscribeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _agreeButton.adjustsImageWhenHighlighted = NO;
        _agreeButton.selected = YES;
    }
    return _agreeButton;
}

- (YYLabel *)agreeTopLabel {
    if (!_agreeTopLabel) {
        _agreeTopLabel = [[YYLabel alloc] init];
        _agreeTopLabel.backgroundColor = [UIColor whiteColor];
        _agreeTopLabel.textColor = [UIColor blackColor];
        _agreeTopLabel.numberOfLines = 0;
        _agreeTopLabel.font = ZFFontSystemSize(12.f);
        _agreeTopLabel.textAlignment = NSTextAlignmentCenter;
        _agreeTopLabel.attributedText = [self fetchAgreeTermsUseTitle];
        _agreeTopLabel.preferredMaxLayoutWidth = 290-15*2;
        _agreeTopLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _agreeTopLabel;
}

- (UIButton *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subscribeButton setImage:[UIImage imageNamed:@"login_unchoosed"] forState:UIControlStateNormal];
        [_subscribeButton setImage:[[UIImage imageNamed:@"login_choosed"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        _subscribeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _subscribeButton.adjustsImageWhenHighlighted = NO;
        [_subscribeButton addTarget:self action:@selector(subscribeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _subscribeButton.selected = [self hasChangeCountryLang] ? NO : YES;
        self.isSubscribe = [self hasChangeCountryLang] ? NO : YES;
    }
    return _subscribeButton;
}

- (YYLabel *)subscribeTopLabel {
    if (!_subscribeTopLabel) {
        _subscribeTopLabel = [[YYLabel alloc] init];
        _subscribeTopLabel.backgroundColor = [UIColor whiteColor];
        _subscribeTopLabel.textColor = [UIColor blackColor];
        _subscribeTopLabel.numberOfLines = 0;
        _subscribeTopLabel.font = ZFFontSystemSize(12.f);
        _subscribeTopLabel.textAlignment = NSTextAlignmentCenter;
        _subscribeTopLabel.attributedText = [self fetchSubscribeTopLabelTitle];
        _subscribeTopLabel.preferredMaxLayoutWidth = 290-15*2;
        _subscribeTopLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _subscribeTopLabel;
}

- (UIButton *)registerButton {
    if (!_registerButton) {
        _registerButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _registerButton.layer.cornerRadius = 3;
        _registerButton.layer.masksToBounds = YES;
        [_registerButton setTitle:ZFLocalizedString(@"Register_Button",nil) forState:UIControlStateNormal];
        _registerButton.backgroundColor = ZFC0x2D2D2D();
        [_registerButton setTitleColor:ZFC0xFFFFFF() forState:UIControlStateNormal];
        [_registerButton addTarget:self action:@selector(registerButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _registerButton.titleLabel.font = ZFFontBoldSize(16);
    }
    return _registerButton;
}

@end

