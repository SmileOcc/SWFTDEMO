//
//  OSSVSMSVerifysView.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/8.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "OSSVSMSVerifysView.h"
#import "STLTextField.h"
#import "OSSVSMSVerifysAip.h"
#import "UITextField+STLCategory.h"

@interface OSSVSMSVerifysView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView      *container;
@property (nonatomic, strong) UIView      *topBgView;
@property (nonatomic, strong) UIButton    *closeBtn;
@property (nonatomic, strong) UILabel     *title;
@property (nonatomic, strong) UILabel     *subtitle;
@property (nonatomic, strong) STLTextField *phoneNum;
@property (nonatomic, strong) UIButton    *sendSMSBtn;
@property (nonatomic, strong) STLTextField *verifyCode;
@property (nonatomic, strong) UILabel     *errorPrompt;
@property (nonatomic, strong) UIButton    *verifyBtn;
@property (nonatomic, strong) UIView      *tipBgView;
@property (nonatomic, strong) UILabel     *verifyTip;
@property (nonatomic, assign) NSInteger    count;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic, weak) NSTimer *timer;
@end

@implementation OSSVSMSVerifysView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initViewWithFrame:frame];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSMSSuccess:) name:SEND_SMS_SUCCESS object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sendSMSFail:) name:SEND_SMS_FAIL object:nil];
    }
    return self;
}

- (void)initViewWithFrame:(CGRect)frame {
    self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
    self.isShow = YES;
    
    _container = [[UIView alloc] init];
    _container.backgroundColor = [UIColor whiteColor];
    _container.layer.cornerRadius = 5;
    _container.clipsToBounds = YES;
    [self addSubview:_container];
    
    [_container mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(self.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(self.mas_trailing).mas_offset(-12);
        make.centerX.mas_equalTo(self.mas_centerX);
        make.centerY.mas_equalTo(self.mas_centerY);
    }];
    
    
    _topBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _topBgView.backgroundColor = [STLThemeColor col_F5F5F5];
    [_container addSubview:_topBgView];

    _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_closeBtn addTarget:self action:@selector(dismiss) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setImage:[UIImage imageNamed:@"detail_close"] forState:UIControlStateNormal];
    [_container addSubview:_closeBtn];
    
    [_closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_top).mas_offset(15);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-15);
        make.width.height.mas_equalTo(20);
    }];
    
    _title = [[UILabel alloc] init];
    _title.textColor = [STLThemeColor col_FF6734];
    _title.font = [UIFont systemFontOfSize:14];
    [_container addSubview:_title];
    
    [_title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_container.mas_top).mas_offset(30);
        make.centerX.mas_equalTo(_container.mas_centerX);
    }];
        
    [_topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.top.trailing.mas_equalTo(_container);
        make.bottom.mas_equalTo(_title.mas_bottom).offset(12);
    }];
    
    _subtitle = [[UILabel alloc] init];
    _subtitle.numberOfLines = 0;
    _subtitle.textColor = [STLThemeColor col_333333];
    _subtitle.font = [UIFont systemFontOfSize:12];
    _subtitle.text = STLLocalizedString_(@"VerificationCodePrompt", @"验证码提示语");
    [_container addSubview:_subtitle];
    
    [_subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_topBgView.mas_bottom).mas_offset(20);
        make.centerX.mas_equalTo(_container.mas_centerX);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-12);
    }];
    
    
    
    _phoneNum = [[STLTextField alloc] init];
    _phoneNum.userInteractionEnabled = NO;
    _phoneNum.keyboardType = UIKeyboardTypeDefault;
    _phoneNum.returnKeyType = UIReturnKeyDone;
//    [_phoneNum stlPlaceholderColor:[STLThemeColor col_808080]];
    _phoneNum.textColor = [STLThemeColor col_808080];

    _phoneNum.font = [UIFont systemFontOfSize:12];
    _phoneNum.layer.cornerRadius = 4.0;
    _phoneNum.layer.masksToBounds = YES;
    _phoneNum.backgroundColor = [STLThemeColor col_F5F5F5];
    [_container addSubview:_phoneNum];
    
    [_phoneNum mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_subtitle.mas_bottom).mas_offset(12);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-12);
        make.height.mas_equalTo(45);
    }];
    
    _sendSMSBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _sendSMSBtn.layer.cornerRadius = 4.0;
    _sendSMSBtn.layer.masksToBounds = YES;
    [_sendSMSBtn setTitle:STLLocalizedString_(@"SendSMS", @"发送验证码") forState:UIControlStateNormal];
    [_sendSMSBtn addTarget:self action:@selector(sendSMS) forControlEvents:UIControlEventTouchUpInside];
    [_sendSMSBtn.titleLabel setFont:[UIFont systemFontOfSize:14]];
    [_sendSMSBtn setTitleColor:[STLThemeColor stlWhiteColor] forState:UIControlStateNormal];
    _sendSMSBtn.backgroundColor = [STLThemeColor stlBlackColor];
    [_container addSubview:_sendSMSBtn];
    
    [_sendSMSBtn mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.mas_equalTo(_phoneNum.mas_bottom).mas_offset(12);
        make.height.mas_equalTo(45);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-12);
        make.width.mas_equalTo(112);
    }];
    
    _verifyCode = [[STLTextField alloc] init];
    _verifyCode.delegate = self;
    _verifyCode.keyboardType = UIKeyboardTypeASCIICapableNumberPad;
    _verifyCode.returnKeyType = UIReturnKeyDone;
    _verifyCode.clearButtonMode = UITextFieldViewModeWhileEditing;
    _verifyCode.placeholder = STLLocalizedString_(@"InputValidationCode", @"输入验证码");
    [_verifyCode stlPlaceholderColor:[STLThemeColor col_999999]];
    _verifyCode.textColor = [STLThemeColor col_262626];
    _verifyCode.font = [UIFont systemFontOfSize:12];
    _verifyCode.layer.borderColor = [[STLThemeColor col_E6E6E6] CGColor];
    _verifyCode.layer.cornerRadius = 4.0;
    _verifyCode.layer.masksToBounds = YES;
    _verifyCode.layer.borderWidth = 1.0;
    _verifyCode.backgroundColor = [STLThemeColor stlWhiteColor];
    [_container addSubview:_verifyCode];
    
    [_verifyCode mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_phoneNum.mas_bottom).mas_offset(12);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(_sendSMSBtn.mas_leading).offset(-12);
        make.height.mas_equalTo(45);
    }];
    

    _errorPrompt = [[UILabel alloc] init];
    _errorPrompt.textColor = [STLThemeColor col_FF6734];
    _errorPrompt.font = [UIFont systemFontOfSize:12];
    [_container addSubview:_errorPrompt];
    
    [_errorPrompt mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_verifyCode.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(_verifyCode.mas_leading);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-25);
    }];
    
    _verifyBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _verifyBtn.layer.cornerRadius = 4.0;
    _verifyBtn.layer.masksToBounds = YES;
    _verifyBtn.enabled = NO;
    
    [_verifyBtn setTitle:STLLocalizedString_(@"verify", @"验证码") forState:UIControlStateNormal];
    [_verifyBtn addTarget:self action:@selector(verifySMS) forControlEvents:UIControlEventTouchUpInside];
    [_verifyBtn.titleLabel setFont:[UIFont systemFontOfSize:18]];
    [_verifyBtn setTitleColor:[STLThemeColor stlWhiteColor] forState:UIControlStateNormal];
    _verifyBtn.backgroundColor = [STLThemeColor col_CCCCCC];
    [_container addSubview:_verifyBtn];
    
    [_verifyBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_errorPrompt.mas_bottom).mas_offset(8);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-12);
        make.height.mas_equalTo(45);
    }];
    
    _tipBgView = [[UIView alloc] initWithFrame:CGRectZero];
    _tipBgView.backgroundColor = [STLThemeColor col_F5F5F5];
    [_container addSubview:_tipBgView];
    [_tipBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.bottom.mas_equalTo(_container);
        make.top.mas_equalTo(_verifyBtn.mas_bottom).offset(20);
    }];
    
    _subtitle = [[UILabel alloc] init];
    _subtitle.numberOfLines = 0;
    _subtitle.textColor = [STLThemeColor col_999999];
    _subtitle.font = [UIFont systemFontOfSize:11];
    _subtitle.text = STLLocalizedString_(@"ValidationMessagePrompt", @"验证信息提示");
    [_container addSubview:_subtitle];
    
    [_subtitle mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(_tipBgView.mas_top).mas_offset(12);
        make.leading.mas_equalTo(_container.mas_leading).mas_offset(12);
        make.trailing.mas_equalTo(_container.mas_trailing).mas_offset(-12);
        make.bottom.mas_equalTo(_tipBgView.mas_bottom).mas_offset(-20);
    }];
    
    [_sendSMSBtn addSubview:self.activityView];
    [self.activityView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(_sendSMSBtn);
        make.width.height.mas_offset(30);
    }];
}

- (void)dismiss {
    [self coolse];
    
    if (self.closeSMSBlock) {
        self.closeSMSBlock();
    }
}

- (void)sendSMS {
    if (self.sendSMSRequestBlock) {
        self.sendSMSRequestBlock();
    }
    ///增加一个菊花
    [self.sendSMSBtn setTitle:@"" forState:UIControlStateNormal];
    [self.activityView startAnimating];
    self.sendSMSBtn.userInteractionEnabled = NO;
}

- (void)sendSMSSuccess:(NSNotification *)noti {
    
    id object = noti.object;
    NSInteger timeCount = 0;
    [self.activityView stopAnimating];
    _sendSMSBtn.enabled =NO;
    _sendSMSBtn.backgroundColor = [STLThemeColor col_262626];
    
    if ([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *resultDic = (NSDictionary *)object;
        timeCount = [STLToString(resultDic[@"countdown"]) integerValue];
    }
    
    if (timeCount <= 0) {
        timeCount = 300;
    }
    _count = timeCount;
    
    [_sendSMSBtn setTitle:[NSString stringWithFormat:@"%lds %@",(long)_count, STLLocalizedString_(@"resend", nil)] forState:UIControlStateDisabled];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerFired:) userInfo:nil repeats:YES];
}

- (void)timerFired:(NSTimer *)timer {
    if (_count != 1) {
        _count -= 1;
        [_sendSMSBtn setTitle:[NSString stringWithFormat:@"%lds %@",(long)_count,STLLocalizedString_(@"resend", nil)] forState:UIControlStateDisabled];
    } else {
        [self resetSendButtonStatus];
    }
}

-(void)sendSMSFail:(NSNotification *)sender
{
    [self.activityView stopAnimating];
    [self resetSendButtonStatus];
}

-(void)resetSendButtonStatus
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    _sendSMSBtn.enabled = YES;
    self.sendSMSBtn.userInteractionEnabled = YES;
    [_sendSMSBtn setTitle:STLLocalizedString_(@"SendSMS", @"发送验证码") forState:UIControlStateNormal];
}

- (void)verifySMS {
    
    if ([_verifyCode.text isEqualToString:@""]||(_verifyCode.text==NULL)) {
        _errorPrompt.text = STLLocalizedString_(@"VerificationCodeEmpty", @"验证码为空提示语");
        if (self.verifyCodeAnalyticBlock) {
            self.verifyCodeAnalyticBlock(NO);
        }
    } else {
        if (self.verifyCodeAnalyticBlock) {
            self.verifyCodeAnalyticBlock(YES);
        }
        /* 请求接口验证Code是否正确. */
        if (self.verifyCodeRequestBlock) {
            self.verifyCodeRequestBlock(_verifyCode.text);
        }
    }
}

- (void)setPrompt:(NSString *)prompt {
    _errorPrompt.text = prompt;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSMutableString *code = [textField.text mutableCopy];
    [code replaceCharactersInRange:range withString:string];
    
    if (code.length > 0) {
        self.verifyBtn.enabled = YES;
        self.verifyBtn.backgroundColor = [STLThemeColor col_262626];
    } else {
        self.verifyBtn.enabled = NO;
        self.verifyBtn.backgroundColor = [STLThemeColor col_CCCCCC];
    }
    if (textField == _verifyCode) {
        if (code.length <= 0) {
            _errorPrompt.text = nil;
        }
        if (code.length > 6) return NO;
    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    self.verifyBtn.enabled = NO;
    self.verifyBtn.backgroundColor = [STLThemeColor col_CCCCCC];
    return YES;
}

- (void)setUserPhoneNum:(NSString *)userPhoneNum paymentAmount:(NSString *)paymentAmount {
    _phoneNum.text = userPhoneNum;
    NSString *str;
    if ([SystemConfigUtils isRightToLeftShow]) {
        str = [NSString stringWithFormat:@"%@ :%@",paymentAmount,STLLocalizedString_(@"PaymentAmount", nil)];
    } else {
        str = [NSString stringWithFormat:@"%@: %@",STLLocalizedString_(@"PaymentAmount", nil),paymentAmount];
    }
    NSMutableAttributedString *followingAttrStr = [[NSMutableAttributedString alloc] initWithString:str];
    NSRange followingRange = [str rangeOfString:[NSString stringWithFormat:@"%@:",STLLocalizedString_(@"PaymentAmount", nil)]];
    [followingAttrStr addAttributes:@{ NSFontAttributeName:[UIFont systemFontOfSize: 14],
                                                     NSForegroundColorAttributeName: [STLThemeColor col_333333] }
                                                     range:followingRange];
    _title.attributedText = followingAttrStr;
    
    [[STLAnalyticsPageManager sharedManager] pageStartTime:NSStringFromClass(OSSVSMSVerifysView.class)];
}

- (void)coolse {
    
    NSString *startTime = [[STLAnalyticsPageManager sharedManager] startPageTime:NSStringFromClass(OSSVSMSVerifysView.class)];
    NSString *endTime = [[STLAnalyticsPageManager sharedManager] endPageTime:NSStringFromClass(OSSVSMSVerifysView.class)];

    NSString *timeLeng = [[STLAnalyticsPageManager sharedManager] pageEndTimeLength:NSStringFromClass(OSSVSMSVerifysView.class)];
    [STLAnalytics analyticsSensorsEventWithName:@"key_page_load" parameters:@{@"$screen_name":[UIViewController currentTopViewControllerPageName],
                                                                              @"$referrer":[UIViewController lastViewControllerPageName],
                                                                              @"$title":STLToString(self.viewController.title),
                                                                                @"$url":STLToString(@""),
                                                                                @"load_begin":startTime,
                                                                                @"load_end":endTime,
                                                                              @"load_time":timeLeng}];
    [self resetSendButtonStatus];
    self.isShow = NO;
    [self removeFromSuperview];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - setter and getter

-(UIActivityIndicatorView *)activityView
{
    if (!_activityView) {
        _activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        _activityView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    }
    return _activityView;
}

@end
