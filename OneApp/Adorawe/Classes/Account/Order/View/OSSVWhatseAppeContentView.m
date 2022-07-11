//
//  OSSVWhatseAppeContentView.m
// XStarlinkProject
//
//  Created by Kevin on 2021/9/9.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "OSSVWhatseAppeContentView.h"
#import "UIButton+STLCategory.h"
#import "OSSVWhatseAppSubscribeeAip.h"
#import "UIView+WhenTappedBlocks.h"
#import "OSSVCommonnRequestsManager.h"

@interface OSSVWhatseAppeContentView ()
@property (nonatomic, strong) UIView       *switchBgView; //上部分背景
@property (nonatomic, strong) UILabel      *notificationLabel; //订阅信息文案
@property (nonatomic, strong) UISwitch     *customSwitch; //开关

@property (nonatomic, strong) UIView       *phoneBgView;  //手机号信息的背景
@property (nonatomic, strong) UIImageView  *arrowImageView; //箭头图标
@property (nonatomic, strong) UIView       *lineView;
@property (nonatomic, strong) UITextField  *phoneTextField; //电话号码输入框
@property (nonatomic, strong) UIButton     *subscribeButton; //订阅按钮
@property (nonatomic, strong) UIButton     *deleteButton;
@end

@implementation OSSVWhatseAppeContentView
- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.switchBgView];
        [self addSubview:self.phoneBgView];

        [self.switchBgView addSubview:self.notificationLabel];
        [self.switchBgView addSubview:self.customSwitch];
        [self.phoneBgView addSubview:self.countryImageView];
        [self.phoneBgView addSubview:self.phoneCode];
        [self.phoneBgView addSubview:self.arrowImageView];
        [self.phoneBgView addSubview:self.lineView];
        [self.phoneBgView addSubview:self.phoneTextField];
        [self.phoneBgView addSubview:self.subscribeButton];
        [self.phoneBgView addSubview:self.deleteButton];
        
        NSString *phoneHead = STLToString([OSSVAccountsManager sharedManager].account.subscribeDic [@"phone_head"]);
        if ([phoneHead hasPrefix:@"+"]) {
            self.phoneCode.text = phoneHead;
        } else {
            self.phoneCode.text = [NSString stringWithFormat:@"+%@", phoneHead];
        }

//        self.phoneCode.text = [NSString stringWithFormat:@"+%@",STLToString([OSSVAccountsManager sharedManager].account.subscribeDic [@"phone_head"])] ;
        self.phoneTextField.text = STLToString([OSSVAccountsManager sharedManager].account.subscribeDic [@"phone"]);
        [self.countryImageView yy_setImageWithURL:[NSURL URLWithString:STLToString([OSSVAccountsManager sharedManager].account.subscribeDic[@"country_picture"])] placeholder:[UIImage imageNamed:@"region_place_polder"]];
        self.customSwitch.on = [STLToString([OSSVAccountsManager sharedManager].account.subscribeDic[@"status"]) isEqualToString:@"1"] ? YES : NO;



    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.switchBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(self);
        make.height.equalTo(42);
    }];
    
    [self.customSwitch mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.switchBgView.mas_trailing).offset(-2);
        make.centerY.mas_equalTo(self.switchBgView.mas_centerY);
        }];
    [self.notificationLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.switchBgView.mas_leading).offset(12);
        make.centerY.mas_equalTo(self.switchBgView.mas_centerY);
        make.trailing.mas_equalTo(self.customSwitch.mas_leading).offset(-2);
        make.height.equalTo(20);
    }];
    
    [self.phoneBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.mas_left).offset(12);
        make.right.mas_equalTo(self.mas_right).offset(-12);
        make.top.mas_equalTo(self.switchBgView.mas_bottom).offset(6);
        make.height.equalTo(36);
    }];

    [self.countryImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phoneBgView.mas_left).offset(9);
        make.centerY.mas_equalTo(self.phoneBgView.mas_centerY);
        make.size.equalTo(CGSizeMake(27, 16));
    }];

    [self.phoneCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.countryImageView.mas_right).offset(6);
        make.centerY.mas_equalTo(self.phoneBgView.mas_centerY);
        make.height.equalTo(17);
        make.width.equalTo(33);
    }];

    [self.arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.phoneCode.mas_right).offset(8);
        make.centerY.mas_equalTo(self.phoneBgView.mas_centerY);
        make.size.equalTo(CGSizeMake(12, 12));
    }];

    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.arrowImageView.mas_right).offset(8);
        make.width.equalTo(1);
        make.top.mas_equalTo(self.phoneBgView.mas_top).offset(9);
        make.bottom.mas_equalTo(self.phoneBgView.mas_bottom).offset(-9);
    }];

    [self.subscribeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.top.right.mas_equalTo(self.phoneBgView);
        make.width.equalTo(102);

    }];
    
    [self.deleteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.equalTo(CGSizeMake(18, 18));
        make.centerY.mas_equalTo(self.subscribeButton.mas_centerY);
        make.right.mas_equalTo(self.subscribeButton.mas_left).offset(-2);
    }];


    [self.phoneTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.lineView.mas_right).offset(8);
        make.right.mas_equalTo(self.deleteButton.mas_left);
        make.bottom.top.mas_equalTo(self.phoneBgView);
    }];
    
}
- (UIView *)switchBgView {
    if (!_switchBgView) {
        _switchBgView = [[UIView alloc] init];
        _switchBgView.backgroundColor = [OSSVThemesColors col_FFF3E4];
    }
    return _switchBgView;
}

- (UILabel *)notificationLabel {
    if (!_notificationLabel) {
        _notificationLabel = [[UILabel alloc] init];
        _notificationLabel.textColor = [OSSVThemesColors col_6C6C6C];
        _notificationLabel.font = [UIFont systemFontOfSize:12];
        _notificationLabel.text = STLLocalizedString_(@"whatsAppTitle", nil);
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _notificationLabel.textAlignment = NSTextAlignmentRight;
        } else {
            _notificationLabel.textAlignment = NSTextAlignmentLeft;

        }
    }
    return _notificationLabel;
}

- (UISwitch *)customSwitch {
    if (!_customSwitch) {
        _customSwitch = [[UISwitch alloc] init];
        _customSwitch.on = YES;
        _customSwitch.onTintColor = OSSVThemesColors.col_0D0D0D;
        _customSwitch.tintColor   = OSSVThemesColors.col_CCCCCC;
        _customSwitch.thumbTintColor = [UIColor whiteColor];
        _customSwitch.transform = CGAffineTransformMakeScale( 0.62, 0.62);//缩放
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            _customSwitch.transform = CGAffineTransformMakeScale(-0.62, 0.62);
        }
        [_customSwitch addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    }
    return _customSwitch;
}

- (UIView *)phoneBgView {
    if (!_phoneBgView) {
        _phoneBgView = [UIView new];
        _phoneBgView.backgroundColor = [OSSVThemesColors col_FAFAFA];
    }
    return _phoneBgView;
}

- (YYAnimatedImageView *)countryImageView {
    if (!_countryImageView) {
        _countryImageView = [[YYAnimatedImageView alloc] init];
        _countryImageView.backgroundColor = [UIColor clearColor];
        
    }
    return _countryImageView;
}

- (UILabel *)phoneCode {
    if (!_phoneCode) {
        _phoneCode = [[UILabel alloc] init];
        _phoneCode.textColor = OSSVThemesColors.col_0D0D0D;
        _phoneCode.font = [UIFont boldSystemFontOfSize:14];
        _phoneCode.userInteractionEnabled = YES;
        @weakify(self)
        [_phoneCode whenTapped:^{
            @strongify(self)
            [self selectCountrylist];
        }];
        
    }
    return _phoneCode;
}

- (UIImageView *)arrowImageView {
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"downArrow"]];
        _arrowImageView.userInteractionEnabled = YES;
        @weakify(self)
        [_arrowImageView whenTapped:^{
            @strongify(self)
            [self selectCountrylist];
        }];
    }
    return _arrowImageView;
}

- (UIView *)lineView {
    if (!_lineView) {
        _lineView = [UIView new];
        _lineView.backgroundColor =  OSSVThemesColors.col_EEEEEE;
        
    }
    return _lineView;
}

- (UITextField *)phoneTextField {
    if (!_phoneTextField) {
        _phoneTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _phoneTextField.textColor = OSSVThemesColors.col_0D0D0D;
        _phoneTextField.font = [UIFont boldSystemFontOfSize:14];
        _phoneTextField.backgroundColor = [UIColor clearColor];
        _phoneTextField.keyboardType = UIKeyboardTypePhonePad;
        _phoneTextField.textAlignment = NSTextAlignmentLeft;
         NSMutableDictionary *attrs = [NSMutableDictionary dictionary]; // 创建属性字典
          attrs[NSFontAttributeName] = [UIFont systemFontOfSize:12]; // 设置font
          attrs[NSForegroundColorAttributeName] = [OSSVThemesColors col_B2B2B2]; // 设置颜色
          NSAttributedString *attStr = [[NSAttributedString alloc] initWithString:STLLocalizedString_(@"WhatsAppNumber", nil) attributes:attrs];
          _phoneTextField.attributedPlaceholder = attStr;
        
        [_phoneTextField addTarget:self action:@selector(changeAction) forControlEvents:UIControlEventEditingChanged];

    }
    return _phoneTextField;
}

- (UIButton *)subscribeButton {
    if (!_subscribeButton) {
        _subscribeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _subscribeButton.backgroundColor = OSSVThemesColors.col_7AD06D;
        [_subscribeButton setImage:[UIImage imageNamed:@"whatsapp"] withTitle:STLLocalizedString_(@"SubscribeButtonTitle", nil) forState:UIControlStateNormal];
        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            [_subscribeButton setImagePosition:STLButtonImagePositionLeft spacing:-8];

        } else {
            [_subscribeButton setImagePosition:STLButtonImagePositionLeft spacing:5];

        }
        [_subscribeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _subscribeButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_subscribeButton addTarget:self action:@selector(subscribeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _subscribeButton;
}

- (UIButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.hidden = YES;
        [_deleteButton setImage:[UIImage imageNamed:@"text_field_close"] forState:UIControlStateNormal];
        [_deleteButton addTarget:self action:@selector(deleteTextfield:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _deleteButton;
}


#pragma mark ----action
- (void)changeAction {
    self.deleteButton.hidden = NO;
}
- (void)deleteTextfield:(UIButton *)sender {
    self.phoneTextField.text = @"";
    sender.hidden = YES;
}
- (void)selectCountrylist {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didtapedSelectCountryButton:)]) {
        [self.delegate didtapedSelectCountryButton:nil];
    }
}
- (void)switchAction:(UISwitch *) sw {
    if (sw.on == YES) {
        [self requestDataWithStatus:@"1"];
    }else{
        [self requestDataWithStatus:@"0"];
    }
}

- (void)subscribeAction {
    if (STLIsEmptyString(self.phoneTextField.text)) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"phoneNumEmpty",nil)];
        return;
    }
    NSString *status = self.customSwitch.isOn ? @"1" : @"0";
    [self sendChangePhoneNumberWithStatus:status phone:self.phoneTextField.text phoneHead:self.phoneCode.text];
}

#pragma mark ---发送订阅
- (void)requestDataWithStatus:(NSString *)status {
    OSSVWhatseAppSubscribeeAip *api  = [[OSSVWhatseAppSubscribeeAip alloc] initWithStatus:status phoneHead:@"" phone:@""];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        NSString *message = requestJSON[@"message"];
        
        if ([requestJSON[kStatusCode] integerValue] == 200) {
            if ([status isEqualToString:@"1"]) {
                [HUDManager showHUDWithMessage:STLLocalizedString_(@"subscribe_toast",nil)];

            } else {
                [HUDManager showHUDWithMessage:STLLocalizedString_(@"Unsubscribe_toast",nil)];
            }
        } else {
            self.customSwitch.on = [status isEqualToString:@"1"] ? NO : YES;
            [HUDManager showHUDWithMessage:message];
        }
        [OSSVCommonnRequestsManager checkUpdateUserInfo:nil];

    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        @strongify(self)
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkNotAvailable", nil)];        self.customSwitch.on = [status isEqualToString:@"1"] ? NO : YES;

    }];
}

- (void)sendChangePhoneNumberWithStatus:(NSString *)status phone:(NSString *)phone phoneHead:(NSString *)phoneHead {
    OSSVWhatseAppSubscribeeAip *api  = [[OSSVWhatseAppSubscribeeAip alloc] initWithStatus:status phoneHead:phoneHead  phone:phone];
    @weakify(self)
    [api startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        @strongify(self)
        self.deleteButton.hidden = YES;
        [self.phoneTextField resignFirstResponder];
        
        id requestJSON = [OSSVNSStringTool desEncrypt:request];
        NSString *message = requestJSON[@"message"];

        if ([requestJSON[kStatusCode] integerValue] == 200) {
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"changePhoneNumberSuccess",nil)];
            [OSSVCommonnRequestsManager checkUpdateUserInfo:nil];
        } else {
            [HUDManager showHUDWithMessage:message];
        }
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkNotAvailable", nil)];    }];
}
@end
