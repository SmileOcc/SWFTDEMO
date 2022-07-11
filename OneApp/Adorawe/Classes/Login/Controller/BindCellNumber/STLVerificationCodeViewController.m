//
//  STLVerificationCodeViewController.m
// XStarlinkProject
//
//  Created by Starlinke on 2021/8/2.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLVerificationCodeViewController.h"
#import "JHVerificationCodeView.h"
#import "JKCountDownButton.h"
#import "STLVerifyCodeViewModel.h"
#import "OSSVCommonnRequestsManager.h"
#import "YYLabel.h"
#import "YYText.h"

@interface STLVerificationCodeViewController ()

@property (weak,nonatomic) UIButton *cancelButton;
@property (weak,nonatomic) UIButton *skipButton;
@property (weak,nonatomic) UILabel *boldTitleLable;
@property (strong,nonatomic) JHVerificationCodeView *codeView;
@property (strong,nonatomic) UILabel *errorLab;
@property (strong,nonatomic) JKCountDownButton *countBtn;
@property (strong,nonatomic) UIButton *sureBtn;
@property (strong,nonatomic) UIButton *bottomipLab;
@property (strong,nonatomic) JHVCConfig *config;
@property (strong,nonatomic) STLVerifyCodeViewModel *viewModel;

@property (assign,nonatomic) BOOL isInputFinish;

@property (assign,nonatomic) NSInteger currentSendCount;// 验证码发送次数
@property (copy,nonatomic) NSString *codeStr;
@end

@implementation STLVerificationCodeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

-(void)setupUI{

    self.view.backgroundColor = [UIColor whiteColor];
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    [cancelButton setImage:[UIImage imageNamed:@"reset_back"] forState:UIControlStateNormal];
    [cancelButton setBackgroundImage:[UIImage imageNamed:@"detail_close_black_zhijiao"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton = cancelButton;
    [self.view addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.width.height.mas_equalTo(18);
        make.leading.mas_equalTo(20);
    }];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        _cancelButton.transform = CGAffineTransformMakeScale(-1.0, 1.0);
    }
    
    UIButton *skipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    skipButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
    [skipButton setTitle:STLLocalizedString_(@"skip_bind_cellphone", nil) forState:UIControlStateNormal];
    [skipButton setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
    [self.view addSubview:skipButton];
    _skipButton = skipButton;
    [skipButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.cancelButton.mas_centerY);
        make.trailing.mas_equalTo(-24);
    }];
    [skipButton addTarget:self action:@selector(skipAction) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *titLab = [UILabel new];
    titLab.text = STLLocalizedString_(@"enterVerification", nil);
    titLab.font = [UIFont boldSystemFontOfSize:24];
    [self.view addSubview:titLab];
    [titLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(cancelButton.mas_bottom).offset(28);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-20);
    }];
    
    NSString *phoneStr = [NSString stringWithFormat:@"%@+%@ %@", STLLocalizedString_(@"sendedCode",nil), self.countryCode, self.phoneNum];
    
    UILabel *tipLab = [UILabel new];
    tipLab.text = phoneStr;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        tipLab.textAlignment = NSTextAlignmentRight;
    }
    tipLab.textColor = OSSVThemesColors.col_6C6C6C;
    tipLab.font = [UIFont systemFontOfSize:12];
    [self.view addSubview:tipLab];
    [tipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titLab.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-20);
    }];
    
    UILabel *tipDetailLab = [UILabel new];
    tipDetailLab.text = STLLocalizedString_(@"enterFourCode",nil);
    tipDetailLab.textColor = OSSVThemesColors.col_6C6C6C;
    tipDetailLab.font = [UIFont systemFontOfSize:10];
    [self.view addSubview:tipDetailLab];
    [tipDetailLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipLab.mas_bottom).offset(24);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-20);
    }];
    
    [self.view addSubview:self.codeView];
    [self.codeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(tipDetailLab.mas_bottom).offset(12);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-20);
        make.height.mas_equalTo(36);
    }];
    
    
    [self.view addSubview:self.errorLab];
    [self.errorLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.codeView.mas_bottom).offset(-6);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-20);
        make.height.mas_equalTo(0);
    }];
    
    [self.view addSubview:self.countBtn];
    [self.countBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.errorLab.mas_bottom).offset(10);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.height.mas_equalTo(14);
    }];
    
    [self.view addSubview:self.sureBtn];
    [self.sureBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.countBtn.mas_bottom).offset(24);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-20);
        make.height.mas_equalTo(44);
    }];
    
    [self.view addSubview:self.bottomipLab];
    [self.bottomipLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.sureBtn.mas_bottom).offset(20);
        make.leading.mas_equalTo(self.view.mas_leading).offset(20);
        make.trailing.mas_equalTo(self.view.mas_trailing).offset(-20);
        make.height.mas_equalTo(15);
    }];
    
    // 发送验证码
    [self judgeIsSendVerifiCode:^{
        [self sendCodeRequest];
    } notIs:^{
        
    }];
    
}

- (void)codeErrorAction{
    [self.codeView setAllUnderLineColor:OSSVThemesColors.col_B62B21];
    [self.errorLab mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(12);
    }];
    [self.countBtn mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.errorLab.mas_bottom).offset(16);
    }];
}

#pragma mark -- 进来时判断是否立即发送验证码
- (void)judgeIsSendVerifiCode:(void(^)())is notIs:(void(^)())notIs{
    BOOL isSend = NO;
    if (![OSSVAccountsManager sharedManager].msgDate) {
        isSend = YES;
    }else{
        NSInteger count = [OSSVAccountsManager sharedManager].count;
        NSDate *msgDate = [OSSVAccountsManager sharedManager].msgDate;
        NSString *verifiPhoneNumber = [OSSVAccountsManager sharedManager].verifiPhoneNumber;
        
        NSString *currentPhoneNumber = [NSString stringWithFormat:@"%@%@", self.countryCode, self.phoneNum];
        if (!verifiPhoneNumber || ![currentPhoneNumber isEqualToString:verifiPhoneNumber]) {
            isSend = YES;
        }else{
            
            NSDate *targetDate = [msgDate dateByAddingTimeInterval:count];
            
            NSTimeInterval result = [targetDate timeIntervalSinceNow];
            if (result < 0) {
                isSend = YES;
            }else{
                isSend = NO;
                NSInteger countNum = result;
                [self.countBtn startCountDownWithSecond:countNum];
            }
        }
    }
    
    if (isSend && is) {
        is();
    }
    if (!isSend && notIs) {
        notIs();
    }
}


#pragma mark -- 发送验证码
- (void)sendCodeRequest{
    @weakify(self)
    [self.viewModel requestCodeInfo:^{
        @strongify(self)
        NSUInteger count = (NSUInteger)[self.viewModel.countDown integerValue];
        [self.countBtn startCountDownWithSecond:count];
        self.currentSendCount ++;
//        if (self.currentSendCount == 2) {
//            self.bottomipLab.hidden = NO;
//        }
        
        [OSSVAccountsManager sharedManager].count = [self.viewModel.countDown integerValue];
        [OSSVAccountsManager sharedManager].msgDate = [NSDate date];
        [OSSVAccountsManager sharedManager].verifiPhoneNumber =  [NSString stringWithFormat:@"%@%@", self.countryCode, self.phoneNum];
        
    } failure:^{
        self.countBtn.enabled = YES;
    }];
}

- (void)verifiCodeRequestWithCode:(NSString *)code{
    NSDictionary *parm = @{@"code":code};
    @weakify(self)
    [self.viewModel requestVerifiCode:parm completion:^(NSDictionary *json) {
        @strongify(self)
        
        //GA埋点-----统计绑定成功
        [OSSVAnalyticsTool analyticsGAEventWithName:@"register_action" parameters:@{@"screen_group" : @"Login/Register",
                                                                               @"action"       : @"Bind_Number_Success"
        }];
        
        // 验证成功 刷新用户数据
        NSDictionary *result = [json objectForKey:kResult];
        NSString *coins = STLToString([result objectForKey:@"coin"]);
        YYLabel *label = [YYLabel new];
        UIImage *image = [UIImage imageNamed:@"sign_up_coin"];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
        NSMutableAttributedString *attatch = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(14, 14) alignToFont:[UIFont systemFontOfSize:13] alignment:YYTextVerticalAlignmentBottom];

        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
            NSString *formatedConis = [NSString stringWithFormat:@"+%@  ",coins];
            [attr yy_appendString:formatedConis];

            [attr appendAttributedString:attatch];
        }else{
            [attr appendAttributedString:attatch];
            NSString *formatedConis = [NSString stringWithFormat:@"  +%@",coins];
            [attr yy_appendString:formatedConis];
        }
        attr.yy_color = [UIColor whiteColor];
        label.attributedText = attr;
        [HUDManager showHUDWithMessage:STLLocalizedString_(@"bind_successfully", nil) customView:label];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_RefrshUserInfo object:nil];
        [self closeAction];
    } failure:^{
        // 验证失败
        [self codeErrorAction];
    }];
}

- (void)sureBtnAction{
    [self verifiCodeRequestWithCode:self.codeStr];
}

- (void)closeAction{
//    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
//        if (self.closeBlock) {
//            self.closeBlock();
//        }
//    }];
//    [self dismissViewControllerAnimated:YES completion:nil];
    
    UIViewController *controller = self;
    while(controller.presentingViewController){
       controller = controller.presentingViewController;
    }
    [controller dismissViewControllerAnimated:YES completion:^{
        if (self.closeBlock) {
            self.closeBlock();
        }
    }];
}


#pragma mark --- lazy
- (JHVerificationCodeView *)codeView{
    if (!_codeView) {
        _codeView = [[JHVerificationCodeView alloc] initWithFrame:CGRectMake(0, 0, (SCREEN_WIDTH - 40), 36) config:self.config];
        @weakify(self);
        _codeView.inputBlock = ^(NSString *code) {
            // 输入改变
            @strongify(self);
            [self.errorLab mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
            [self.countBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(self.errorLab.mas_bottom).offset(10);
            }];
            self.isInputFinish = NO;
            [self.sureBtn setEnabled:NO];
            self.codeStr = @"";
        };
        
        _codeView.finishBlock = ^(JHVerificationCodeView *codeView, NSString *code) {
            // 输入完成
            @strongify(self);
            self.isInputFinish = YES;
            [self.sureBtn setEnabled:YES];
            self.codeStr = code;
        };
        
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            _codeView.transform = CGAffineTransformMakeScale(-1.0, 1.0);
//            for (UIView *obj in _codeView.subviews) {
//                obj.transform = CGAffineTransformMakeScale(-1.0, 1.0);
//            }
//        }
    }
    return _codeView;
}

- (UILabel *)errorLab{
    if (!_errorLab) {
        _errorLab = [UILabel new];
        _errorLab.text = STLLocalizedString_(@"reEnterCode", nil);
        _errorLab.textColor = OSSVThemesColors.col_B62B21;
        _errorLab.font = [UIFont systemFontOfSize:10];
    }
    return _errorLab;
}

- (JHVCConfig *)config{
    if (!_config) {
        _config     = [[JHVCConfig alloc] init];
        _config.inputBoxNumber  = 4;
        _config.inputBoxSpacing = 4;
        _config.inputBoxWidth   = ((SCREEN_WIDTH - 40)-12)/4;
        _config.inputBoxHeight  = 25;
        _config.tintColor       = [UIColor blackColor];
        _config.underLineColor  = OSSVThemesColors.col_CCCCCC;
        _config.underLineHighlightedColor = OSSVThemesColors.col_0D0D0D;
        _config.secureTextEntry = NO;// 不显示密码状态
        _config.font            = [UIFont boldSystemFontOfSize:14];
        _config.textColor       = OSSVThemesColors.col_0D0D0D;
        _config.inputType       = JHVCConfigInputType_Number_Alphabet; // Default
        _config.showUnderLine   = YES;
        _config.autoShowKeyboard = YES;
        _config.inputBoxBorderWidth = 0;
        _config.keyboardType = UIKeyboardTypeNumberPad;
    }
    return _config;
}

- (JKCountDownButton *)countBtn{
    if (!_countBtn) {
        _countBtn = [JKCountDownButton buttonWithType:UIButtonTypeCustom];
        [_countBtn setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
        [_countBtn setTitleColor:OSSVThemesColors.col_B2B2B2 forState:UIControlStateDisabled];
        @weakify(self);
        [_countBtn countDownButtonHandler:^(JKCountDownButton*sender, NSInteger tag) {
            @strongify(self);
            [self.codeView becomeFirstResponder];
            [self.codeView clear];
            sender.enabled = NO;
            [self sendCodeRequest];
        }];
        [_countBtn countDownChanging:^NSString *(JKCountDownButton *countDownButton,NSUInteger second) {
            NSString *title = nil;
            if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
                title = [NSString stringWithFormat:@"（%zd%@）%@", second,@"S", STLLocalizedString_(@"didSent", nil)];
            }else{
                title = [NSString stringWithFormat:@"%@（%zd%@）",STLLocalizedString_(@"didSent", nil),second, @"S"];
            }
            countDownButton.enabled = NO;
            return title;
        }];
        
        [_countBtn countDownFinished:^NSString *(JKCountDownButton *countDownButton, NSUInteger second) {
            countDownButton.enabled = YES;
            return STLLocalizedString_(@"resendCode", nil);
        }];
        
        _countBtn.titleLabel.font = FontWithSize(12);
        [_countBtn setTitle:STLLocalizedString_(@"resendCode", nil) forState:UIControlStateNormal];
    }
    return _countBtn;
}

- (UIButton *)sureBtn{
    if (!_sureBtn) {
        _sureBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        if (APP_TYPE == 3) {
            [_sureBtn setTitle:STLLocalizedString_(@"confirm", nil) forState:UIControlStateNormal];
        } else {
            [_sureBtn setTitle:STLLocalizedString_(@"confirm", nil).uppercaseString forState:UIControlStateNormal];
        }
        [_sureBtn setBackgroundImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_0D0D0D] forState:UIControlStateNormal];
        [_sureBtn setBackgroundImage:[UIImage yy_imageWithColor:OSSVThemesColors.col_CCCCCC] forState:UIControlStateDisabled];
        _sureBtn.titleLabel.font = [UIFont stl_buttonFont:14];
        [_sureBtn setEnabled:NO];
        [_sureBtn addTarget:self action:@selector(sureBtnAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _sureBtn;
}

- (UIButton *)bottomipLab{
    if (!_bottomipLab) {
        _bottomipLab = [UIButton buttonWithType:UIButtonTypeCustom];
        _bottomipLab.titleLabel.font = FontWithSize(12);
        [_bottomipLab setTitleColor:OSSVThemesColors.col_6C6C6C forState:UIControlStateNormal];
        [_bottomipLab setTitle:STLLocalizedString_(@"noCodeSkip", nil) forState:UIControlStateNormal];
        [_bottomipLab addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
//        _bottomipLab.hidden = YES;
    }
    return _bottomipLab;
}

-(void)cancelAction:(UIButton *)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)skipAction{
    [self closeAction];
}

//-(void)closeAction{
//    [self dismissViewControllerAnimated:YES completion:^{
//        if (self.closeBlock) {
//            self.closeBlock();
//        }
//    }];
    
//    [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
//        if (self.closeBlock) {
//            self.closeBlock();
//        }
//    }];
//}

- (STLVerifyCodeViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[STLVerifyCodeViewModel alloc] init];
    }
    return _viewModel;
}

@end
