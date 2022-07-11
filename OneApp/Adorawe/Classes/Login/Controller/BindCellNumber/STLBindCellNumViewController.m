//
//  STLBindCellNumViewController.m
// XStarlinkProject
//
//  Created by fan wang on 2021/5/18.
//  Copyright © 2021 starlink. All rights reserved.
//

#import "STLBindCellNumViewController.h"
#import "CellTextfield.h"
#import "OSSVCountrySelectVC.h"
#import "OSSVNSStringTool.h"
#import "STLBindPhoneNumViewModel.h"
#import "STLBindCountrySelectViewController.h"
#import "SignViewController.h"
#import "YYText.h"
#import "OSSVCommonnRequestsManager.h"
#import "STLVerificationCodeViewController.h"
#import "Adorawe-Swift.h"


@interface STLBindCellNumViewController () <CellTextFieldDelegate>
@property (weak,nonatomic) UIButton *cancelButton;
@property (weak,nonatomic) UIButton *skipButton;
@property (weak,nonatomic) UILabel *boldTitleLable;
@property (weak,nonatomic) UIView *adView;
@property (weak,nonatomic) CellTextfield *phoneNumber;
@property (weak,nonatomic) UIButton *confirmButton;

@property (weak,nonatomic) UIView *coinView;
@property (weak,nonatomic) UILabel *coinLabel;
@property (strong,nonatomic) STLBindCountryModel *countryModel;
@property (strong,nonatomic) STLBindPhoneNumViewModel *viewModel;
@property (nonatomic, strong) UILabel *contentLabel;
@end

@implementation STLBindCellNumViewController

-(void)afterInfoGot:(STLBindCountryResultModel *)obj{
    for (STLBindCountryModel* country in obj.countries) {
        if ([country.countryId isEqualToString:obj.default_country_id]) {
            [[NSUserDefaults standardUserDefaults] setValue:STLToString(country.country_code) forKey:kDefaultCountryCode];
            [[NSUserDefaults standardUserDefaults] synchronize];
            self.countryModel = country;
        }
        NSDictionary *messages = obj.messages;
        self.coinView.hidden = ![[messages objectForKey:@"switch"] boolValue];
        if ([[messages objectForKey:@"switch"] boolValue]) {
            self.coinLabel.text = [NSString stringWithFormat:@"%@  ",[messages objectForKey:@"content"]];
        }
    }
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupUI];
    ///初始化数据
    @weakify(self)
    [self.viewModel requestInfo:^(STLBindCountryResultModel *  _Nonnull obj, NSString * _Nonnull msg) {
        @strongify(self)
        [self afterInfoGot:obj];
    } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
        
    }];
    
    NSDictionary *tipDic = [OSSVAccountsManager sharedManager].account.tipDic;
    NSString *bindPhoneReason = STLToString(tipDic[@"bind_phone_reason"]);
    self.contentLabel.hidden = !bindPhoneReason.length;
    self.contentLabel.text = bindPhoneReason;
    self.coinView.hidden = YES;
    //延时弹出注册成功的文案
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self)
        if (self.couponContent.length) {
            [HUDManager showHUDWithMessage:self.couponContent];
                
        }
    });
    

}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
}

-(void)cancelAction:(UIButton *)sender{
    [self closeAction];
}

-(void)skipAction{
    [GATools logSignInSignUpActionWithEventName:@"register_action" action:@"Bind_Number_Skip"];
    [self closeAction];
    if (self.tapSkipBlock) {
        self.tapSkipBlock();
    }
}

-(void)closeAction{
//    [self dismissViewControllerAnimated:YES completion:^{
//        if (self.closeBlock) {
//            self.closeBlock();
//        }
//    }];
//
//    if (self.presentingViewController.presentationController) {
//        [self.presentingViewController.presentingViewController dismissViewControllerAnimated:YES completion:^{
//            if (self.closeBlock) {
//                self.closeBlock();
//            }
//        }];
//    }
    
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

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.phoneNumber becomeFirstResponder];
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
}

-(void)setupUI{
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton* cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setImage:[UIImage imageNamed:@"detail_close_black_zhijiao"] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    _cancelButton = cancelButton;
    [self.view addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(15);
        make.width.height.mas_equalTo(18);
        make.leading.mas_equalTo(20);
    }];
    
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
    
    UILabel *titleLbl = [[UILabel alloc] init];
    _boldTitleLable = titleLbl;
    titleLbl.font = [UIFont boldSystemFontOfSize:24];
    titleLbl.text = STLLocalizedString_(@"sign_success", nil);
    if (APP_TYPE == 3) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:titleLbl.text];
        [attString addAttribute:NSFontAttributeName value:[UIFont vivaiaSemiBoldFont:24] range:NSMakeRange(0, titleLbl.text.length - 6)];
        [attString addAttribute:NSFontAttributeName value:[UIFont vivaiaBoldItalicFont:24] range:NSMakeRange(titleLbl.text.length - 6, 6)];
        titleLbl.attributedText = attString;
    }

    titleLbl.textColor = OSSVThemesColors.col_0D0D0D;
    [self.view addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(cancelButton.mas_bottom).offset(24);
    }];
    
    UILabel *contentLabel = [UILabel new];
    contentLabel.font = [UIFont systemFontOfSize:13];
    contentLabel.textColor = OSSVThemesColors.col_666666;
    _contentLabel = contentLabel;
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        _contentLabel.textAlignment = NSTextAlignmentRight;
    }
    [self.view addSubview:contentLabel];
    [contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(4);
        make.trailing.leading.mas_equalTo(titleLbl);
        
    }];
    
    UIView *coinView = [[UIView alloc] init];
    _coinView = coinView;
    [self.view addSubview:coinView];
    [coinView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(contentLabel.mas_bottom).offset(8);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.height.mas_equalTo(20);
    }];
    UIView *coinBg = [UIView new];
    [coinView addSubview:coinBg];
//    coinBg.backgroundColor = OSSVThemesColors.col_FFF5DF;
    coinBg.backgroundColor = [OSSVThemesColors col_FFF3E4];
    [coinBg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.height.mas_equalTo(20);
        make.width.mas_equalTo(24);
        make.top.mas_equalTo(0);
    }];

    YYAnimatedImageView *imgView = [[YYAnimatedImageView alloc] init];
    [imgView setImage:[UIImage imageNamed:@"sign_up_coin"]];
    [coinView addSubview:imgView];
    [imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(6);
        make.top.mas_equalTo(3);
        make.width.height.mas_equalTo(14);
    }];

    UILabel *coinLabel = [UILabel new];
    _coinLabel = coinLabel;
    coinLabel.font = [UIFont systemFontOfSize:11];
    [coinView addSubview:coinLabel];
    coinLabel.backgroundColor = [OSSVThemesColors col_FFF3E4];
    coinLabel.textColor = OSSVThemesColors.col_B56B23;
    ///动态数据
    coinLabel.text = @"Get 5 coins, after bind successful   ";
    [coinLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(imgView.mas_trailing).offset(4);
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.trailing.mas_lessThanOrEqualTo(0);
    }];
    
    UILabel *phoneNumText = [UILabel new];
    [self.view addSubview:phoneNumText];
    phoneNumText.textColor = OSSVThemesColors.col_999999;
    phoneNumText.font = [UIFont systemFontOfSize:11];
    phoneNumText.text = STLLocalizedString_(@"bind_phone_num", nil);
    [phoneNumText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.top.mas_equalTo(coinView.mas_bottom).offset(24);
    }];
    
    CellTextfield *phoneInput = [[CellTextfield alloc] init];
    _phoneNumber = phoneInput;
    phoneInput.placeholder = STLLocalizedString_(@"bind_phone_num", nil);
    phoneInput.deviderColor = OSSVThemesColors.col_CCCCCC;
    phoneInput.floatPlaceholderColor = OSSVThemesColors.col_999999;
    phoneInput.delegate = self;
    phoneInput.tintColor = [UIColor blackColor];
    [self.view addSubview:phoneInput];
    [phoneInput mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(phoneNumText.mas_bottom).offset(12);
    }];
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
//    actionButton.layer.cornerRadius = 2;
    actionButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [actionButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    if (APP_TYPE == 3) {
        [actionButton setTitle:STLLocalizedString_(@"bind_confirm", nil) forState:UIControlStateNormal];
    } else {
        [actionButton setTitle:STLLocalizedString_(@"bind_confirm", nil).uppercaseString forState:UIControlStateNormal];
    }
    
    [self.view addSubview:actionButton];
    [actionButton addTarget:self action:@selector(confirmAction) forControlEvents:UIControlEventTouchUpInside];
    _confirmButton = actionButton;
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(phoneInput.mas_bottom).offset(36);
    }];
}


-(void)confirmAction{
    [GATools logSignInSignUpActionWithEventName:@"register_action" action:@"Bind_Number_Confirm"];
    if(!self.phoneNumber.countryModel){
        [self.phoneNumber setError:STLLocalizedString_(@"RegionNumMsg", nil) color:OSSVThemesColors.col_B62B21];
        return;
    }
    if(self.phoneNumber.text.isAllSameNumber){
        [self.phoneNumber setError:STLLocalizedString_(@"id_num_format_err", nil) color:OSSVThemesColors.col_B62B21];
        return;
    }
    ///提交手机号码
    [self.phoneNumber endEditing:YES];
    if (STLIsEmptyString(self.phoneNumber.text)) {
        [self.phoneNumber setError:STLLocalizedString_(@"PhoneNumMsg", nil) color:OSSVThemesColors.col_B62B21];
        return;
    }
    if (![OSSVNSStringTool isAllNumberCharacterString:self.phoneNumber.text]) {
        [self.phoneNumber setError:STLLocalizedString_(@"Address_Phone_Number_Tip", nil) color:OSSVThemesColors.col_B62B21];
        return;
    }
    
    if (self.tapConfimBlock) {
        self.tapConfimBlock();
    }
    NSString *countryID = self.phoneNumber.countryModel.countryId.length > 0 ? self.phoneNumber.countryModel.countryId : @"";
    NSString *countryCode = self.phoneNumber.countryModel.country_code.length > 0 ? self.phoneNumber.countryModel.country_code : @"";
    NSString *phone = self.phoneNumber.text;
    
    ///服务端校验手机号
    @weakify(self)
    [self.viewModel checkPhoneNum:@{@"mobile":phone,@"country_id":countryID,@"country_code":countryCode} completion:^(id  _Nonnull obj, NSString * _Nonnull msg) {
        if ([obj[kStatusCode] integerValue] != 200) {
            NSString *message = obj[kMessagKey];
            [self.phoneNumber setError:message color:OSSVThemesColors.col_B62B21];
        }else{
            ///提交到server
            @strongify(self)
            [self bindPhone:phone countryId:countryID];
        }
    } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
        [HUDManager showHUDWithMessage:msg];
    }];
    
}

-(void)bindPhone:(NSString *)phone countryId:(NSString *)countryID{
    @weakify(self)
    [self.viewModel sendPhoneNum:@{@"phone":phone,@"country_id":countryID} completion:^(id  _Nonnull obj, NSString * _Nonnull msg) {
        [HUDManager showHUDWithMessage:msg];
        @strongify(self)
        [self bindPhoneAnalytic:phone areaCode:self.phoneNumber.countryModel.code];
//        [self closeAction];
        
//        YYLabel *label = [YYLabel new];
//        UIImage *image = [UIImage imageNamed:@"sign_up_coin"];
//        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] init];
//        NSMutableAttributedString *attatch = [NSMutableAttributedString yy_attachmentStringWithContent:image contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(14, 14) alignToFont:[UIFont systemFontOfSize:13] alignment:YYTextVerticalAlignmentBottom];
//
//        NSString *coins = [self.viewModel.countryModel.messages objectForKey:@"coins"];
//
//        if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
//            NSString *formatedConis = [NSString stringWithFormat:@"+%@  ",coins];
//            [attr yy_appendString:formatedConis];
//
//            [attr appendAttributedString:attatch];
//        }else{
//            [attr appendAttributedString:attatch];
//            NSString *formatedConis = [NSString stringWithFormat:@"  +%@",coins];
//            [attr yy_appendString:formatedConis];
//        }
//        attr.yy_color = [UIColor whiteColor];
//        label.attributedText = attr;
//        [HUDManager showHUDWithMessage:STLLocalizedString_(@"bind_successfully", nil) customView:label];
        ///刷新用户数据
        [OSSVCommonnRequestsManager checkUpdateUserInfo:nil];
        
        NSString *code = self.phoneNumber.countryModel.country_code.length > 0 ? self.phoneNumber.countryModel.code : @"";
        NSString *phone = self.phoneNumber.text;

        
        STLVerificationCodeViewController *vCodeVC = [[STLVerificationCodeViewController alloc] init];
        vCodeVC.countryCode = code;
        vCodeVC.phoneNum = phone;
        vCodeVC.closeBlock = ^{
            if (self.closeBlock) {
                self.closeBlock();
            }
        };
        vCodeVC.isModalPresent = YES;
        [self presentViewController:vCodeVC animated:YES completion:nil];
    } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
        [HUDManager showHUDWithMessage:msg];
    }];
}


///选择国家
-(void)didtapedSelectCountryButton:(id)currentCountry{
//    NSLog(@"-----------did taped country");
    STLBindCountrySelectViewController *vc = [[STLBindCountrySelectViewController alloc]init];
    UIImage *image = [UIImage imageNamed:@"icon1_back"];
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    backBtn.imageEdgeInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    [backBtn setImage:image forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(dismissSelect) forControlEvents:UIControlEventTouchUpInside];
    if ([OSSVSystemsConfigsUtils isRightToLeftShow]) {
        backBtn.transform = CGAffineTransformMakeScale(-1.0,1.0);
    }
    UIView *view = [UIView new];
    UIBarButtonItem *item1 = [[UIBarButtonItem alloc] initWithCustomView:view];
    UIBarButtonItem *item2 = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    vc.navigationItem.leftBarButtonItems = @[item1, item2];
    vc.isModalPresent = YES;
    
    @weakify(self)
    vc.countryBlock = ^(STLBindCountryModel * _Nonnull model) {
        @strongify(self)
        self.countryModel = model;
        [self dismissSelect];
    };
    if (self.viewModel.keyArr.count > 0) {
        vc.keyArr = self.viewModel.keyArr;
        OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:vc];
        nav.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:nav animated:YES completion:nil];
    }else{
        [self.viewModel requestInfo:^(id  _Nonnull obj, NSString * _Nonnull msg) {
            [self afterInfoGot:obj];
            vc.keyArr = self.viewModel.keyArr;
            OSSVNavigationVC *nav = [[OSSVNavigationVC alloc] initWithRootViewController:vc];
            nav.modalPresentationStyle = UIModalPresentationFullScreen;
            [self presentViewController:nav animated:YES completion:nil];
        } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
            [HUDManager showHUDWithMessage:msg];
        }];
    }
}

-(void)dismissSelect{
    [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
}

-(void)setCountryModel:(STLBindCountryModel *)countryModel{
    _countryModel = countryModel;
    self.phoneNumber.countryModel = countryModel;
    [self.phoneNumber clearError];
}

-(BOOL)textFieldShouldReturn:(DetailTextField *)detailField filed:(UITextField *)field{
    [self confirmAction];
    return YES;
}
-(void)textFieldDidBeginEditing:(DetailTextField *)detailField filed:(UITextField *)field{
    [detailField clearError];
    [self performSelector:@selector(changeCursorLocation) withObject:nil afterDelay:0.01];
}

-(BOOL)textField:(UITextField *)textField detailText:(DetailTextField *)detailField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (string.isContainArabic) {
        return NO;
    }
    return YES;
}

-(STLBindPhoneNumViewModel *)viewModel{
    if (!_viewModel) {
        _viewModel = [[STLBindPhoneNumViewModel alloc] init];
    }
    return _viewModel;
}

///绑定手机成功埋点
- (void)bindPhoneAnalytic:(NSString *)phone areaCode:(NSString *)areaCode{
    AccountModel *account = [OSSVAccountsManager sharedManager].account;
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"FillInNumber"
                                     parameters:@{
                                        @"register_id":STLToString(account.userid),
                                        @"register_name":STLToString(account.nickName),
                                        @"number":STLToString(phone),
                                        @"area_code":STLToString(areaCode)
    }];
}

- (void)changeCursorLocation{
    
    NSRange range =NSMakeRange(self.phoneNumber.inputField.text.length,0);
    UITextPosition *start = [self.phoneNumber.inputField positionFromPosition:[self.phoneNumber.inputField beginningOfDocument]offset:range.location];

    UITextPosition *end = [self.phoneNumber.inputField positionFromPosition:start offset:range.length];
    
    [self.phoneNumber.inputField setSelectedTextRange:[self.phoneNumber.inputField textRangeFromPosition:start toPosition:end]];
}

@end
