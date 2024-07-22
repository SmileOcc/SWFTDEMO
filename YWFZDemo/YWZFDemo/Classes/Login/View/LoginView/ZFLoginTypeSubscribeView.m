//
//  YWLoginTypeSubscribeView.m
//  ZZZZZ
//
//  Created by Tsang_Fa on 2018/6/27.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginTypeSubscribeView.h"
#import "ZFInitViewProtocol.h"
#import "ZFThemeManager.h"
#import "YYText.h"
#import "UIButton+ZFButtonCategorySet.h"
#import "ZFLocalizationString.h"
#import "Masonry.h"
#import "Constants.h"
#import "UIImage+ZFExtended.h"

@interface YWLoginTypeSubscribeView ()<ZFInitViewProtocol>
@property (nonatomic, strong) UIButton      *subscribeButton;
@property (nonatomic, strong) YYLabel       *subscribeTopLabel;
@property (nonatomic, strong) UIButton      *confirmInformationButton;
@property (nonatomic, strong) YYLabel       *confirmInformationLabel;
///修改 邮箱或者电话号码登录按钮
@property (nonatomic, strong) UIButton      *exchangeButton;
@end

@implementation YWLoginTypeSubscribeView
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
    [self addSubview:self.subscribeButton];
    [self addSubview:self.subscribeTopLabel];
    [self addSubview:self.exchangeButton];
    [self addSubview:self.confirmInformationButton];
    [self addSubview:self.confirmInformationLabel];
}

- (void)zfAutoLayoutView {
    [self mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_offset(170);
    }];
    
    CGFloat height = 0;
    if ([AccountManager sharedManager].accountCountryModel.is_emerging_country) {
        height = 20;
    }
    
    [self.exchangeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(13);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.height.mas_equalTo(height);
    }];

    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.exchangeButton.mas_bottom).mas_offset(5);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.subscribeTopLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.subscribeButton);
        make.leading.mas_equalTo(self.subscribeButton.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.mas_trailing).offset(0);
    }];
 
    [self.confirmInformationButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.subscribeButton.mas_bottom).offset(13);
        make.leading.mas_equalTo(self.mas_leading).offset(16);
        make.size.mas_equalTo(CGSizeMake(16, 16));
    }];
    
    [self.confirmInformationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmInformationButton);
        make.leading.mas_equalTo(self.confirmInformationButton.mas_trailing).offset(10);
        make.trailing.mas_equalTo(self.mas_trailing).offset(0);
    }];
}

#pragma mark - Public method
- (void)changeInfomation:(BOOL)isSignin {
    BOOL is_emerging_country = [AccountManager sharedManager].accountCountryModel.is_emerging_country;
    if (isSignin) {
        if (is_emerging_country) {
            self.exchangeButton.hidden = NO;
        }
        self.subscribeButton.hidden = YES;
        self.subscribeTopLabel.hidden = YES;
        self.confirmInformationButton.hidden = YES;
        self.confirmInformationLabel.hidden = YES;
    }else{
        self.exchangeButton.hidden = YES;
        if (self.model.isCountryEU) {
            self.subscribeButton.hidden = NO;
            self.subscribeTopLabel.hidden = NO;
            self.confirmInformationButton.hidden = NO;
            self.confirmInformationLabel.hidden = NO;
        } else {
            self.subscribeButton.hidden = YES;
            self.subscribeTopLabel.hidden = YES;
            self.confirmInformationButton.hidden = YES;
            self.confirmInformationLabel.hidden = YES;
            self.model.isSubscribe = YES;
        }
    }
}

#pragma mark - Setter
- (void)setModel:(YWLoginModel *)model {
    _model = model;
    self.subscribeTopLabel.attributedText = [self fetchTitleWithConfirmInformation:NO];
    self.confirmInformationLabel.attributedText = [self fetchTitleWithConfirmInformation:YES];
    self.subscribeTopLabel.textVerticalAlignment = model.isCountryEU ? YYTextVerticalAlignmentTop : YYTextVerticalAlignmentCenter;
    self.confirmInformationLabel.textVerticalAlignment = model.isCountryEU ? YYTextVerticalAlignmentTop : YYTextVerticalAlignmentCenter;
    [self changeInfomation:model.type == YWLoginEnterTypeLogin];
}

#pragma mark - Action
- (void)exchangeButtonAction:(UIButton *)sender {
    if (self.exchangeButtonHandler) {
        self.exchangeButtonHandler(self.model);
    }
}

- (void)subscribeButtonAction:(UIButton *)sender {
    if (self.subscribeCellHandler) {
        sender.selected = !sender.selected;
        self.model.isSubscribe = sender.selected;
        self.subscribeCellHandler(self.model);
    }
}

- (void)confirmInformationButtonAction:(UIButton *)sender {
    if (self.subscribeCellHandler) {
        sender.selected = !sender.selected;
        self.model.isConfirmInformation = sender.selected;
        self.subscribeCellHandler(self.model);
    }
}

#pragma mark - Private method
- (NSAttributedString *)fetchTitleWithConfirmInformation:(BOOL)ConfirmInformation {
    UIColor *normalColor = ZFCOLOR(34, 34, 34, 1.0);
    NSString *allTitle = @"";
    NSMutableAttributedString *content = nil;
    NSRange normolTouchRange = NSMakeRange(0, 0);
    
    if (ConfirmInformation) {
        allTitle = ZFLocalizedString(@"Register_ConfirmInformation",nil);
        content = [[NSMutableAttributedString alloc] initWithString:allTitle];
        content.yy_font = ZFFontSystemSize(12.0);
        content.yy_color = normalColor;
        
        //Privacy Policy链接
        NSString *componentStr1 = ZFLocalizedString(@"Register_PrivacyPolicy", nil);
        NSRange policyRange = [allTitle rangeOfString:componentStr1];
        normolTouchRange = NSMakeRange(0, policyRange.location-1);
        [content yy_setColor:normalColor range:policyRange];
        [content yy_setFont:ZFFontSystemSize(12.0) range:policyRange];
        [content yy_setUnderlineStyle:NSUnderlineStyleSingle range:policyRange];
        [content yy_setUnderlineColor:normalColor range:policyRange];
        
        @weakify(self)
        [content yy_setTextHighlightRange:policyRange color:normalColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
            YWLog(@"点击了 Privacy Policy");
            @strongify(self)
            if (self.loginPrivacyPolicyActionBlock) {
                self.loginPrivacyPolicyActionBlock();
            }
        }];
    } else {
        allTitle = ZFLocalizedString(@"Register_subscribe",nil);
        content = [[NSMutableAttributedString alloc] initWithString:allTitle];
        content.yy_font = ZFFontSystemSize(12.0);
        content.yy_color = normalColor;
        normolTouchRange = [allTitle rangeOfString:allTitle];
    }
    
    //相当于点击按钮
    @weakify(self)
    [content yy_setTextHighlightRange:normolTouchRange color:normalColor backgroundColor:nil tapAction:^(UIView * _Nonnull containerView, NSAttributedString * _Nonnull text, NSRange range, CGRect rect) {
        YWLog(@"点击了 I confirm all 。。。");
        @strongify(self)
        if (ConfirmInformation) {
            [self confirmInformationButtonAction:self.confirmInformationButton];
        } else {
            [self subscribeButtonAction:self.subscribeButton];
        }
    }];
    return content;
}

#pragma mark - Public method
- (void)shakeKitWithAnimation {
    CABasicAnimation *shake = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
    shake.fromValue = [NSNumber numberWithFloat:-5];
    shake.toValue = [NSNumber numberWithFloat:5];
    shake.duration = 0.1;//执行时间
    shake.autoreverses = YES; //是否重复
    shake.repeatCount = 2;//次数
    [self.confirmInformationLabel.layer addAnimation:shake forKey:@"shakeAnimation"];
    self.confirmInformationLabel.alpha = 1.0;
}

- (void)handlerExChangeButtonTitle:(NSInteger)type
{
    if (type == 0) {
        //email登录
        [self.exchangeButton setTitle:ZFLocalizedString(@"Login_ViaPhone", nil) forState:UIControlStateNormal];
    } else if (type == 1) {
        //mobile登录
        [self.exchangeButton setTitle:ZFLocalizedString(@"Login_Viamail", nil) forState:UIControlStateNormal];
    }
}


#pragma mark - Getter
- (UIButton *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_subscribeButton setImage:[UIImage imageNamed:@"login_unchoosed"]  forState:UIControlStateNormal];
        [_subscribeButton setImage:[[UIImage imageNamed:@"login_choosed"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        _subscribeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _subscribeButton.adjustsImageWhenHighlighted = NO;
        [_subscribeButton addTarget:self action:@selector(subscribeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_subscribeButton setEnlargeEdge:5];
    }
    return _subscribeButton;
}

- (YYLabel *)subscribeTopLabel {
    if (!_subscribeTopLabel) {
        _subscribeTopLabel = [[YYLabel alloc] init];
        _subscribeTopLabel.backgroundColor = [UIColor whiteColor];
        _subscribeTopLabel.textColor = [UIColor blackColor];
        _subscribeTopLabel.numberOfLines = 0;
        _subscribeTopLabel.font = ZFFontSystemSize(10.f);
        _subscribeTopLabel.textAlignment = NSTextAlignmentCenter;
        _subscribeTopLabel.preferredMaxLayoutWidth = 290-15*2;
        _subscribeTopLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _subscribeTopLabel;
}

- (UIButton *)exchangeButton {
    if (!_exchangeButton) {
        _exchangeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_exchangeButton setTitle:ZFLocalizedString(@"Login_ViaPhone", nil) forState:UIControlStateNormal];
        [_exchangeButton setTitleColor:ZFCOLOR(45, 45, 45, 1.0) forState:UIControlStateNormal];
        _exchangeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_exchangeButton addTarget:self action:@selector(exchangeButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        _exchangeButton.hidden = YES;
    }
    return _exchangeButton;
}

- (UIButton *)confirmInformationButton {
    if (!_confirmInformationButton) {
        _confirmInformationButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_confirmInformationButton setImage:[UIImage imageNamed:@"login_unchoosed"] forState:UIControlStateNormal];
        [_confirmInformationButton setImage:[[UIImage imageNamed:@"login_choosed"] imageWithColor:ZFC0xFE5269()] forState:UIControlStateSelected];
        _confirmInformationButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        _confirmInformationButton.adjustsImageWhenHighlighted = NO;
        [_confirmInformationButton addTarget:self action:@selector(confirmInformationButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        [_confirmInformationButton setEnlargeEdge:5];
    }
    return _confirmInformationButton;
}

- (YYLabel *)confirmInformationLabel {
    if (!_confirmInformationLabel) {
        _confirmInformationLabel = [[YYLabel alloc] init];
        _confirmInformationLabel.backgroundColor = [UIColor whiteColor];
        _confirmInformationLabel.textColor = [UIColor blackColor];
        _confirmInformationLabel.numberOfLines = 0;
        _confirmInformationLabel.font = ZFFontSystemSize(10.f);
        _confirmInformationLabel.textAlignment = NSTextAlignmentCenter;
        _confirmInformationLabel.preferredMaxLayoutWidth = 290-15*2;
        _confirmInformationLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return _confirmInformationLabel;
}

@end
