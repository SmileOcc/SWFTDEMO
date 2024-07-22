//
//  YWLoginViewController.m
//  ZZZZZ
//
//  Created by YW on 25/6/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLoginViewController.h"
#import "ZFInitViewProtocol.h"

#import "YWLoginModel.h"
#import "LoginViewModel.h"
#import "ZFAccountViewModel.h"

#import "YWLoginTopView.h"
#import "YWLoginFooterView.h"
#import "YWLoginTypeModeView.h"
#import "YWLoginTypeEmailView.h"
#import "YWLoginTypePasswordView.h"
#import "YWLoginTypeConfirmView.h"
#import "YWLoginTypeSubscribeView.h"
#import "ZFSelectGenderView.h"
#import "DLPickerView.h"
#import "YWLoginSelectCountryView.h"
#import "YWLoginTypeMobileView.h"
#import "YWLoginTypeSendCodeView.h"

#import "ZFPushAllowView.h"
#import "ZFWebViewViewController.h"

#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <GoogleSignIn/GoogleSignIn.h>

#import <VK-ios-sdk/VKSdk.h>
#import <VK-ios-sdk/VKApi.h>

#import "ZFRegisterModel.h"
#import "ZFOtherRegisterViewController.h"
#import "UINavigationController+FDFullscreenPopGesture.h"   
#import <GoogleAPIClientForREST/GTLRPeopleService.h>
#import <Firebase/Firebase.h>
#import "YWLocalHostManager.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "YSAlertView.h"
#import "ZFCommonRequestManager.h"
#import "Masonry.h"
#import "Constants.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import "ZFBranchAnalytics.h"
#import "UIButton+ZFButtonCategorySet.h"

//登录类型
typedef NS_ENUM(NSInteger) {
    YWLoginStatus_EmailLogin, //邮箱登录
    YWLoginStatus_MobileLogin //电话号码登录
}YWLoginStatus;

static NSArray *SCOPE = nil;


@interface YWLoginViewController ()<ZFInitViewProtocol, GIDSignInDelegate,VKSdkDelegate,VKSdkUIDelegate>
@property (nonatomic, strong) UIScrollView                              *scrollView;
@property (nonatomic, strong) UIView                                    *conternView;
@property (nonatomic, strong) YWLoginTopView                            *loginTopView;
@property (nonatomic, strong) YWLoginFooterView                         *footerView;
@property (nonatomic, strong) YWLoginTypeModeView                       *modeView;
@property (nonatomic, strong) YWLoginTypeEmailView                      *emailView;
@property (nonatomic, strong) YWLoginTypePasswordView                   *passwordView;
@property (nonatomic, strong) ZFSelectGenderView                        *selectGenderView;
@property (nonatomic, strong) YWLoginTypeConfirmView                    *confirmView;
@property (nonatomic, strong) YWLoginTypeSubscribeView                  *subscribeView;
@property (nonatomic, strong) YWLoginModel                              *loginModel;
@property (nonatomic, strong) LoginViewModel                            *viewModel;
@property (nonatomic, copy)   NSString                                  *fbAccessToken;

//新兴市场
@property (nonatomic, strong) YWLoginSelectCountryView                  *selectCountryView;
@property (nonatomic, strong) YWLoginTypeMobileView                     *mobileView;
@property (nonatomic, strong) YWLoginTypeSendCodeView                   *sendCodeView;
@property (nonatomic, strong) UIView                                    *mobileLoginTipsView;   //电话号码登录提示语
///使用哪种方式登录的状态，默认为email登录
@property (nonatomic, assign) YWLoginStatus                             loginStatus;

@property (nonatomic, strong) UIButton                                  *forgotButton;
///新兴市场国家列表
@property (nonatomic, strong) NSMutableArray <YWLoginNewCountryModel *> *ZFNewCountryList;

///viewDidAppear 第一次进来是否已处理
@property (nonatomic, assign) BOOL                                      hadHandleDidAppear;

@property(nonatomic, strong) VKRequest                 *callingRequest;
@property (nonatomic, strong) VKAuthorizationResult    *vkAutorizationResult;

@end

@implementation YWLoginViewController

#pragma mark -  life cycle

-(void)dealloc {
    if ([GIDSignIn sharedInstance].delegate) {
        [GIDSignIn sharedInstance].delegate = nil;
    }
//    if ([GIDSignIn sharedInstance].uiDelegate) {
//        [GIDSignIn sharedInstance].uiDelegate = nil;
//    }
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.type = YWLoginEnterTypeNoromal;
        if ([AccountManager sharedManager].accountCountryModel.is_emerging_country) {
            self.loginStatus = YWLoginStatus_MobileLogin;
            self.type = YWLoginEnterTypeLogin;
        } else {
            self.loginStatus = YWLoginStatus_EmailLogin;
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.fd_prefersNavigationBarHidden = YES;
    
    if (self.loginStatus == YWLoginStatus_MobileLogin) {
        [self gainNewCountryList];
    } else {
        [self zfInitView];
        [self zfAutoLayoutView];
    }
    
    [self configGoogleplusLoginParams];
    
    BOOL isRus =  [[AccountManager sharedManager].accountCountryModel isRussiaCountry];
    [self.footerView configurationRus:isRus];

    
    self.emailView.region_id = ZFToString([AccountManager sharedManager].accountCountryModel.region_id);
        
    if (self.type == YWLoginEnterTypeGoogle) {
        // 放这里，弹窗授权界面空白
    } else if (self.type == YWLoginEnterTypeFacebook) {
        [self facebookLogin];
    } else if (self.type == YWLoginEnterTypeVKontakte) {
        // 放这里，弹窗授权界面空白
    }
    
    // 页面统计
    [ZFAnalytics appsFlyerTrackEvent:@"af_view_login_registration_page" withValues:@{AFEventParamContentType : @"view_login_registration_page",
                                                                                     @"af_page_name" : [self mediasourceFromType]
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // google 登录,需要界面已显示
    if (self.type == YWLoginEnterTypeGoogle && !self.hadHandleDidAppear) {
        [self googleLogin];
    } else if(self.type == YWLoginEnterTypeVKontakte && !self.hadHandleDidAppear) {
        [self vkAuthorize];
    }
    self.hadHandleDidAppear = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    HideLoadingFromView(nil);
}

#pragma mark - ZFInitViewProtocol
- (void)zfInitView {
    self.view.backgroundColor = ZFCOLOR_WHITE;
    if (self.loginStatus == YWLoginStatus_MobileLogin) {
        [self.view addSubview:self.mobileLoginTipsView];
    }
    [self.view addSubview:self.scrollView];
    [self.view addSubview:self.loginTopView];
    [self.view addSubview:self.footerView];
    
    [self.scrollView addSubview:self.conternView];
    [self.conternView addSubview:self.modeView];
    [self.conternView addSubview:self.passwordView];
    [self.conternView addSubview:self.confirmView];
    [self.conternView addSubview:self.subscribeView];
    [self.conternView addSubview:self.selectGenderView];
    [self.conternView addSubview:self.emailView];
    [self.confirmView addSubview:self.forgotButton];
    //新兴市场
    [self.conternView addSubview:self.selectCountryView];
    [self.conternView addSubview:self.mobileView];
    [self.conternView addSubview:self.sendCodeView];
}

- (void)zfAutoLayoutView {
    [self.loginTopView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.mas_equalTo(self.view);
        make.height.mas_equalTo((STATUSHEIGHT + 44));
    }];
    
    UIView *mastopView = self.loginTopView;
    if (self.loginStatus == YWLoginStatus_MobileLogin) {
        [self.mobileLoginTipsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.loginTopView.mas_bottom);
            make.leading.trailing.mas_equalTo(self.view);
        }];
        mastopView = self.mobileLoginTipsView;
    }
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(mastopView.mas_bottom);
        make.leading.trailing.equalTo(self.view);
        make.bottom.equalTo(self.footerView.mas_top);
    }];
    
    [self.conternView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.width.equalTo(self.scrollView);
    }];
    
    [self.modeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.top.equalTo(self.conternView);
    }];
    
    [self initEmailLoginView];
    
    [self initMobileLoginView];

    UIView *topView = self.passwordView;
    if (self.loginStatus == YWLoginStatus_MobileLogin && self.type != YWLoginEnterTypeRegister) {
        topView = self.sendCodeView;
        [self exchangeEmailViewStatus:YES];
        [self exchangeMobileViewStatus:NO];
    }

    // 首次进入为注册时需要显示选择性别view
    CGFloat height = [self gainSelectGenderViewHeight];

    [self.selectGenderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordView.mas_bottom).mas_offset(20);
        make.leading.mas_equalTo(self.passwordView);
        make.width.mas_equalTo(self.passwordView.mas_width);
        make.height.offset(height);
    }];
    //修改视图层级
    [self.view sendSubviewToBack:self.selectGenderView];
    
    [self exchangeConfirmViewLayoutTopView];
    
    [self.subscribeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.confirmView.mas_bottom);
        make.leading.trailing.equalTo(self.conternView);
        make.height.mas_equalTo(170);
        make.bottom.equalTo(self.conternView.mas_bottom);
    }];
    
    CGFloat bottomHeight = IPHONE_X_5_15 ? 34 : 16;
    [self.footerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
        make.bottom.mas_equalTo(-bottomHeight);
    }];
}

-(void)addOrUpdateGenderView:(YWLoginModel *)model
{
    CGFloat height = 0;
    /** 根据IP地址判断，如为后台设置的支持COD业务的国家，即货到付款城市设置中存在的国家, 注册时增加性别选择，必填，不默认，用户需手动选择
     * is_cod_sex 1: 显示, 0:不显示
     */
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    if (model.type == YWLoginEnterTypeRegister && [initializeModel.is_cod_sex integerValue] == 1) {
        //显示性别选择框
        height = 64;
        self.selectGenderView.alpha = 0;
    }
    
    [self.selectGenderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordView.mas_bottom).mas_offset(20);
        make.leading.mas_equalTo(self.passwordView);
        make.width.mas_equalTo(self.passwordView.mas_width);
        make.height.mas_offset(height);
    }];
    
    [self exchangeConfirmViewLayoutTopView];

    [UIView animateWithDuration:.3 animations:^{
        self.selectGenderView.alpha = height > 1 ? 1 : 0;
        [self.view layoutIfNeeded];
    }];
}

- (CGFloat)gainSelectGenderViewHeight
{
    CGFloat height = 0.0;
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    if (self.type == YWLoginEnterTypeRegister && [initializeModel.is_cod_sex integerValue] == 1) {
        height = 64;
        self.selectGenderView.alpha = 1;
    }
    if (self.type == YWLoginEnterTypeLogin) {
        height = 0;
        self.selectGenderView.alpha = 0;
    }
    return height;
}

- (void)initEmailLoginView
{
    [self.emailView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.modeView.mas_bottom);
        make.leading.trailing.equalTo(self.conternView);
        make.height.mas_equalTo(68);
    }];
    
    [self.passwordView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.emailView.mas_bottom);
        make.leading.trailing.equalTo(self.conternView);
        make.height.mas_equalTo(68);
    }];
    
    [self.forgotButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.passwordView.mas_bottom).mas_offset(12);
        make.trailing.mas_equalTo(self.passwordView.mas_trailing).mas_offset(-16);
        make.height.mas_equalTo(20);
    }];
}

- (void)initMobileLoginView
{
    [self.selectCountryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.modeView.mas_bottom).mas_offset(25);
        make.leading.mas_equalTo(self.view.mas_leading).mas_offset(16);
        make.trailing.mas_equalTo(self.view.mas_trailing).mas_offset(-16);
        make.height.mas_offset(36);
    }];
    
    [self.mobileView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.selectCountryView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.conternView);
        make.height.mas_equalTo(68);
    }];
    
    [self.sendCodeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mobileView.mas_bottom);
        make.leading.trailing.mas_equalTo(self.conternView);
        make.height.mas_equalTo(68);
    }];
    
    [self exchangeMobileViewStatus:YES];
}

- (void)exchangeEmailViewStatus:(BOOL)status
{
    CGFloat alpha = status ? 0.0 : 1.0;
    [UIView animateWithDuration:.2 animations:^{
        self.emailView.alpha = alpha;
        self.passwordView.alpha = alpha;
    }];
    self.emailView.hidden = status;
    self.passwordView.hidden = status;
}

- (void)exchangeMobileViewStatus:(BOOL)status
{
    CGFloat alpha = status ? 0.0 : 1.0;
    [UIView animateWithDuration:.2 animations:^{
        self.selectCountryView.alpha = alpha;
        self.mobileView.alpha = alpha;
        self.sendCodeView.alpha = alpha;
    }];
    self.selectCountryView.hidden = status;
    self.mobileView.hidden = status;
    self.sendCodeView.hidden = status;
}

///修改确认视图的顶部布局视图
- (void)exchangeConfirmViewLayoutTopView
{
    UIView *topView = self.passwordView;
    BOOL forgotButtonStatus = NO;
    CGFloat forgotButtonHeight = 0;
    if (self.loginModel.type == YWLoginEnterTypeRegister) {
        forgotButtonStatus = YES;
        forgotButtonHeight = 0;
    } else if (self.loginModel.type == YWLoginEnterTypeLogin && self.loginStatus == YWLoginStatus_EmailLogin) {
        forgotButtonStatus = NO;
        forgotButtonHeight = 20;
    } else if (self.loginModel.type == YWLoginEnterTypeLogin && self.loginStatus == YWLoginStatus_MobileLogin) {
        forgotButtonStatus = YES;
        topView = self.sendCodeView;
    } else if ((self.loginModel.type == YWLoginEnterTypeFacebook || self.loginModel.type == YWLoginEnterTypeGoogle || self.loginModel.type == YWLoginEnterTypeVKontakte)  && self.loginStatus == YWLoginStatus_MobileLogin) {
           forgotButtonStatus = YES;
           topView = self.sendCodeView;
    }
    
    self.forgotButton.hidden = forgotButtonStatus;
    
    CGFloat height = [self gainSelectGenderViewHeight];
    [self.confirmView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.equalTo(self.conternView);
        make.top.equalTo(topView.mas_bottom).mas_offset(height + forgotButtonHeight);
        make.height.mas_offset(80);
    }];
}

#pragma mark - Request
// 注册
- (void)registerWithModel:(YWLoginModel *)model {
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kStartLoadingSignUp];
    @weakify(self)
    [self.viewModel requestRegisterNetwork:model completion:^(id obj) {
        @strongify(self)
        [ZFAnalytics appsFlyerTrackEvent:@"af_sign_up" withValues:@{AFEventParamContentType : @"Email"}];
        // Branch
        [[ZFBranchAnalytics sharedManager] branchCompleteRegistrationType:@"email"];
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignUp];
        YWLog(@"注册成功🇨🇳");
        if ([AccountManager sharedManager].isSignIn) {
            //登录成功回调
            [self loginSuccess:YWLoginEnterTypeRegister];
        }
        [ZFFireBaseAnalytics signUpWithType:@"email"];
    } failure:^(id obj) {
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignUp];
    }];
}

// 登陆
- (void)signInWithModel:(YWLoginModel *) model{
    @weakify(self)
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kStartLoadingSignIn];
    [self.viewModel requestLoginNetwork:model completion:^(id obj) {
        @strongify(self)
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignIn];
        // Branch
        [[ZFBranchAnalytics sharedManager] branchLoginType:@"email"];
        [ZFAnalytics appsFlyerTrackEvent:@"af_sign_in" withValues:@{AFEventParamContentType : @"Email"}];
        
        if ([AccountManager sharedManager].isSignIn) {
            [ZFFireBaseAnalytics signInWithTypeName:@"email"];
            [self loginSuccess:YWLoginEnterTypeLogin];
        }
    } failure:^(id obj) {
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignIn];
    }];
}

//phone登录
- (void)registerPhoneWithModel:(YWLoginModel *)model
{
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kStartLoadingSignUp];
    @weakify(self)
    [self.viewModel requestNewCountryRegister:model completion:^(NSError *error) {
        if (error) {
            [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignUp];
            return ;
        }
        @strongify(self)
        NSString *eventName = @"af_sign_in";
        if ([AccountManager sharedManager].account.is_register) {
            eventName = @"af_sign_up";
        }
        [ZFAnalytics appsFlyerTrackEvent:eventName withValues:@{AFEventParamContentType : @"phone"}];
        // Branch
        [[ZFBranchAnalytics sharedManager] branchCompleteRegistrationType:@"phone"];
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignUp];
        if ([AccountManager sharedManager].isSignIn) {
            //登录成功回调
            [self loginSuccess:YWLoginEnterTypeRegister];
        }
        [ZFFireBaseAnalytics signUpWithType:@"email"];
    }];
}

#pragma mark - Private method
- (void)configGoogleplusLoginParams {
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    signIn.clientID = [FIRApp defaultApp].options.clientID;
    NSArray *scopes = @[@"https://www.googleapis.com/auth/user.birthday.read",
                        @"profile"];
    [signIn setScopes:scopes];
    signIn.shouldFetchBasicProfile = YES;
    signIn.delegate = self;
//    signIn.uiDelegate = self;
}

///获取新兴市场国家列表
- (void)gainNewCountryList
{
    //新兴市场获取国家列表
    @weakify(self)
    [self.viewModel requestNewCountryList:^(NSArray<YWLoginNewCountryModel *> *list, NSError *error) {
        @strongify(self)
        if (!error) {
            [self.ZFNewCountryList addObjectsFromArray:list];
            self.selectCountryView.countryList = self.ZFNewCountryList;
            self.loginStatus = YWLoginStatus_MobileLogin;
        } else {
            self.loginStatus = YWLoginStatus_EmailLogin;
        }
        [self zfInitView];
        [self zfAutoLayoutView];
    }];
}

- (void)dealWithTreatyLinkAction:(ZFTreatyLinkAction)actionType {
    NSString *title = nil;
    NSString *url = nil;
    NSString *appH5BaseURL = [YWLocalHostManager appH5BaseURL];
    switch (actionType) {
        case TreatyLinkAction_ProvacyPolicy:
        {
            title = ZFLocalizedString(@"Register_PrivacyPolicy",nil);
            url = [NSString stringWithFormat:@"%@privacy-policy/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
        }
            break;
        case TreatyLinkAction_TermsUse:
        {
            title = ZFLocalizedString(@"Login_Terms_Web_Title",nil);
            url = [NSString stringWithFormat:@"%@terms-of-use/?app=1&lang=%@",appH5BaseURL, [ZFLocalizationString shareLocalizable].nomarLocalizable];
        }
            break;
        default:
            break;
    }
    
    if (title && url) {
        [self jumpToWebVCWithTitle:title url:url];
    }
}

- (void)jumpToWebVCWithTitle:(NSString *)title url:(NSString *)url{
    ZFWebViewViewController *web = [[ZFWebViewViewController alloc] init];
    web.title = title;
    web.link_url = url;
    [self.navigationController pushViewController:web animated:YES];
    self.navigationController.navigationBar.hidden = NO;
}

- (void)loginSuccess:(YWLoginEnterType)successType
{
    if (![AccountManager sharedManager].isSignIn) return;
    
    // 请求是否新用户
    [ZFCommonRequestManager requestIsNewUser];
    
    [ZFCommonRequestManager requestLocationInfo];
    
    [AppsFlyerTracker sharedTracker].customerUserID = [NSStringUtils isEmptyString:USERID] ? @"0" : USERID;
    // Branch
    [[ZFBranchAnalytics sharedManager] branchLoginWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
    //注册大数据统计用户id
    [GGAppsflyerAnalytics registerBigDataWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
    
    // 清除购物车主动选择记住的全局优惠券
    [AccountManager clearUserSelectedCoupon];
  
    [self dismissViewControllerAnimated:YES completion:^{
        
        //注册成功时,判断显示注册远程推送View
        [[NSNotificationCenter defaultCenter] postNotificationName:kLoginNotification object:nil];
        
        [self showRegisterRemotePushView];
        
        if (self.successBlock) {
            self.successBlock();
        }
    }];
}

// 注册成功时,判断显示注册远程推送View
- (void)showRegisterRemotePushView {
    if (![NSStringFromClass(WINDOW.rootViewController.class) isEqualToString:@"ZFNewVersionGuideVC"]) {
        ///从导航进入登录页面的时候，不用弹出推送视图，因为在首页进入的时候，有弹窗逻辑，避免冲突
        [ZFPushManager canShowAlertView:^(BOOL canShow) {
            if (canShow) {
                // 引导打开推送通知
                [ZFPushAllowView AppLoginRegisterShowPushAllowView:nil];
            }
        }];
    }
}

//google facebook 获取的性别转化
- (NSString *)exChangeZZZZZGenderForOther:(NSString *)gender
{
    //* `male`
    //* `female`
    //* `other`
    //* `unknown`
    //  ZZZZZ: sex: 0 保密  1男 2女
    NSString *genderValue = @"";
    gender = ZFToString(gender);
    if ([gender isEqualToString:@"male"]) {
        genderValue = @"1";
    } else if ([gender isEqualToString:@"female"]) {
        genderValue = @"2";
    }  else {
        genderValue = @"0";
    }
    return genderValue;
}

- (NSString *)gainFacebookBirthday:(NSString *)birthday
{
    //facebook获取的日期格式 MM/dd/yyyy,后台需要的日期yyyy/MM/dd
    //可能获取的日期只有MM,dd,yyyy单个的, FB后台可编辑的特性，年月日同时存在，或者月日，或者单独存在年
    if (birthday.length) {
        NSArray *birthdayList = [birthday componentsSeparatedByString:@"/"];
        if (ZFJudgeNSArray(birthdayList)) {
            NSInteger count = [birthdayList count];
            if (count > 2) {
                //年月日都有
                birthday = [NSString stringWithFormat:@"%@/%@/%@", birthdayList[2], birthdayList[0], birthdayList[1]];
            }else if (count > 1){
                //只有月日
                birthday = [NSString stringWithFormat:@"%@/%@", birthdayList[1], birthdayList[0]];
            }else{
                //只有年,不用处理
            }
        }
        return birthday;
    }
    return @"";
}

- (void)popinputEmailAlertView:(NSDictionary *)dic thirdType:(YWLoginEnterType)thirdType
{
    NSString *title = ZFLocalizedString(@"Login_bind_email_get15_discount", nil);
    NSString *placehold = ZFLocalizedString(@"Email", nil);
    NSString *cancel = ZFLocalizedString(@"Login_cancel", nil);
    NSString *submit = ZFLocalizedString(@"Login_commit", nil);
    NSString *errorText = ZFLocalizedString(@"Login_email_format_error", nil);
    @weakify(self)
    [YSAlertView showBindEmailAlertViewTitle:title
                                     message:nil
                                 placeHolder:placehold
                                 cancelTitle:cancel
                                  otherTitle:submit
                                   errorText:errorText
                                  completion:^(NSString *inputText) {
                                      @strongify(self)
                                      NSMutableDictionary *requestParams = [dic mutableCopy];
                                      [requestParams setValue:inputText forKey:@"email"];
                                        if (thirdType == YWLoginEnterTypeFacebook) {
                                            [self fbLogin:requestParams isOu:NO];
                                        } else if(thirdType == YWLoginEnterTypeVKontakte) {
                                            [self vkLogin:requestParams isOu:NO];
                                        } else if(thirdType == YWLoginEnterTypeGoogle) {
                                            [self googleLogin:requestParams signIn:[GIDSignIn sharedInstance] isOu:NO];
                                        }
                                  }];
}

- (void)popTipsUserResetPasswordAlertView
{
    NSString *message = ZFLocalizedString(@"Login_email_already_inused", nil);
    NSString *OK = ZFLocalizedString(@"OK", nil);
    ShowAlertView(nil, message, @[OK], nil, nil, nil);
}

- (void)handlerConternViewOffsetY
{
    UIView *topView = nil;
    if (self.loginModel.type == YWLoginEnterTypeLogin) {
        if (self.loginStatus == YWLoginStatus_MobileLogin) {
            topView = self.mobileLoginTipsView;
        } else {
            topView = self.loginTopView;
        }
    } else {
        topView = self.loginTopView;
    }
    
    [UIView animateWithDuration:.3 animations:^{
        [self.scrollView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(topView.mas_bottom);
            make.leading.trailing.equalTo(self.view);
            make.bottom.equalTo(self.footerView.mas_top);
        }];
        [self.view setNeedsLayout];
        [self.view layoutIfNeeded];
    }];
}

- (NSString *)mediasourceFromType {
    NSString *mediasource = @"other";
    switch (self.comefromType) {
        case YWLoginViewControllerEnterTypeGoodsDetailPage:
            mediasource = @"goods_page";
            break;
        case YWLoginViewControllerEnterTypeCartPage:
            mediasource = @"cart_page";
            break;
        case YWLoginViewControllerEnterTypeAccountPage:
            mediasource = @"account_page";
            break;
        case YWLoginViewControllerEnterTypeCommunityHomePage:
            mediasource = @"community_homepage";
            break;
        case YWLoginViewControllerEnterTypeGuidePage:
            mediasource = @"guide_page";
            break;
        default:
            mediasource = @"other";
            break;
    }
    return mediasource;
}

#pragma mark - Facebook
- (void)facebookLogin {
    // 统计
    NSString *pageName = @"login_registration_page";
    if (self.comefromType == YWLoginViewControllerEnterTypeCartPage) {
        pageName = @"cart_page";
    } else if (self.comefromType == YWLoginViewControllerEnterTypeGuidePage) {
        pageName = @"guide_page";
    }
    [ZFAnalytics appsFlyerTrackEvent:@"af_sign_up_click"
    withValues:@{AFEventParamContentType : @"Facebook_sign_up_btn",
                 @"af_page_name" : pageName}];
    /**
     我们程序在自动登录的时候, 如果发现facebook不能自动登录(token过期, 概率很小)也会触发弹出弹窗,
     但这之前用户如果也点击了facebook登录, 并且点击弹窗的继续,
     并且来到SFAuthenticationViewController页面才触发自动登录失败的弹窗, 这时候再次点击弹窗就崩溃了.
     */
    UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while ([topController presentedViewController])    topController = [topController presentedViewController];
    
    if ([topController isKindOfClass:NSClassFromString(@"SFSafariViewController")]) {
        YWLog(@"---------- FB登录弹窗已显示 ----------");
        return;
    }
    
//    if ([FBSDKAccessToken currentAccessToken]) {
//        [self gainFaceBookUserInfo];
//    } else {
        FBSDKLoginManager *fbLogin = [[FBSDKLoginManager alloc] init];
        // 登录前先退出之前的token，防止报304
        [fbLogin logOut];
        fbLogin.authType = FBSDKLoginAuthTypeRerequest;
        NSArray *permissions = @[@"public_profile", @"email", @"user_likes", @"user_birthday", @"user_gender", @"user_age_range"];
        @weakify(self)
        [fbLogin logInWithPermissions:permissions fromViewController:self handler:^(FBSDKLoginManagerLoginResult * _Nullable result, NSError * _Nullable error) {
            @strongify(self)
            if (error) { YWLog(@"FB登录错误❌❌❌"); return; }
            if (result.isCancelled) { YWLog(@"取消FB登录"); return; }
            [self gainFaceBookUserInfo];
        }];
//    }
}

///获取FB用户数据
- (void)gainFaceBookUserInfo
{
    FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, first_name, last_name, gender, email, birthday, picture, age_range"} tokenString:[FBSDKAccessToken currentAccessToken].tokenString version:[FBSDKSettings graphAPIVersion] HTTPMethod:@"POST"];
    self.fbAccessToken = [FBSDKAccessToken currentAccessToken].tokenString;
    ShowLoadingToView(self.view);
    @weakify(self)
    [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
        @strongify(self)
        HideLoadingFromView(self.view);
        if (error) { YWLog(@"FB登录请求错误❌❌"); return; }
        NSString *fbid = [result valueForKey:@"id"];
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        //从facebook 获取的信息
        NSString *sex = ZFToString([result valueForKey:@"gender"]);
        NSString *email = [result valueForKey:@"email"];
        NSString *nickName = ZFToString([result valueForKey:@"name"]);
        NSString *birthday = ZFToString([result valueForKey:@"birthday"]);
        
        birthday = [self gainFacebookBirthday:birthday];
        sex = [self exChangeZZZZZGenderForOther:sex];
        [AccountManager sharedManager].facebookLoginGender = sex;
        [AccountManager sharedManager].facebookLoginBirthday = birthday;
        
        
        [dict setObject:ZFToString(fbid) forKey:@"fb_id"];
        [dict setObject:NullFilter(self.fbAccessToken) forKey:@"access_token"];
        [dict setObject:self.view forKey:kLoadingView];
        [dict setObject:@"Facebook" forKey:@"type"];
        [dict setObject:ZFToString(nickName) forKey:@"nickname"];
        [dict setObject:ZFToString(sex) forKey:@"sex"];
        [dict setObject:birthday forKey:@"birthday"];
        [dict setObject:ZFToString(email) forKey:@"email"];
        
        //facebook登录完以后，调用ZZZZZ facebook login接口
        [self fbLogin:dict isOu:NO];
    }];
}

- (void)fbLogin:(NSDictionary *)dict isOu:(BOOL)isOu{
    @weakify(self)
    [self.viewModel requestFBLoginNetwork:dict completion:^(NSInteger error, NSString *errorMsg) {
        @strongify(self)

        if (error == 0) {
            ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
            NSString *country_eu = ZFToString(initializeModel.country_eu);
                
            if ([AccountManager sharedManager].account.is_register && [country_eu boolValue] && !isOu) { // 第一次注册
                   [self showCountry_EUParams:dict
                                        email:[dict objectForKey:@"email"]
                                         name:[dict objectForKey:@"nickname"]
                                    thirdType:YWLoginEnterTypeFacebook];
            } else {
                [self loginSuccess:YWLoginEnterTypeFacebook];
            }
            
            [ZFFireBaseAnalytics signInWithTypeName:@"facebook"];
            //使用Facebook登录事件统计
            NSString *eventName = @"af_sign_in";
            if ([AccountManager sharedManager].account.is_register) {
                eventName = @"af_sign_up";
            }
            [ZFAnalytics appsFlyerTrackEvent:eventName withValues:@{AFEventParamContentType : @"Facebook"}];
            // Branch
            [[ZFBranchAnalytics sharedManager] branchCompleteRegistrationType:@"facebook"];
            [ZFFireBaseAnalytics signUpWithType:@"facebook"];
            
        } else {
            [self showInputEmailError:error
                               params:dict
                                email:[dict objectForKey:@"email"]
                                 name:[dict objectForKey:@"nickname"]
                            thirdType:YWLoginEnterTypeFacebook];
        }
       
    } failure:^(id obj) {
        
    }];
}

#pragma mark - VK

- (void)vkAuthorize {
    
    [[VKSdk instance] registerDelegate:self];
    [[VKSdk instance] setUiDelegate:self];
    
    SCOPE = @[VK_PER_WALL, VK_PER_PHOTOS, VK_PER_EMAIL];
    
    if ([VKSdk isLoggedIn]) {
        [VKSdk forceLogout];
    }
    [VKSdk authorize:SCOPE];

    // 统计
    NSString *pageName = @"login_registration_page";
    if (self.comefromType == YWLoginViewControllerEnterTypeCartPage) {
        pageName = @"cart_page";
    } else if (self.comefromType == YWLoginViewControllerEnterTypeGuidePage) {
        pageName = @"guide_page";
    }
    [ZFAnalytics appsFlyerTrackEvent:@"af_sign_up_click"
    withValues:@{AFEventParamContentType : @"Vkontakte_sign_up_btn",
                 @"af_page_name" : pageName}];
}
- (void)vkLogin:(NSDictionary *)dict isOu:(BOOL)isOu{
      
    [self.viewModel requestVKontakteLoginNetwork:dict completion:^(NSInteger error, NSString *errorMsg) {
        
        if (error == 0) {
            
            ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
            NSString *country_eu = ZFToString(initializeModel.country_eu);
                
            if ([AccountManager sharedManager].account.is_register && [country_eu boolValue] && !isOu)  { // 第一次注册
                   [self showCountry_EUParams:dict
                                        email:[dict objectForKey:@"email"]
                                         name:@""
                                    thirdType:YWLoginEnterTypeFacebook];
            } else {
                [self loginSuccess:YWLoginEnterTypeVKontakte];
            }
            
            [ZFFireBaseAnalytics signUpWithType:@"Vkontakte"];
            [ZFFireBaseAnalytics signInWithTypeName:@"Vkontakte"];
            //使用google登录事件统计
            NSString *eventName = @"af_sign_in";
            if ([AccountManager sharedManager].account.is_register) {
                eventName = @"af_sign_up";
            }
            [ZFAnalytics appsFlyerTrackEvent:eventName withValues:@{AFEventParamContentType : @"Vkontakte"}];
            // Branch
            [[ZFBranchAnalytics sharedManager] branchCompleteRegistrationType:@"Vkontakte"];
            
            
        } else {
            [self showInputEmailError:error params:dict email:[dict objectForKey:@"email"] name:@"" thirdType:YWLoginEnterTypeVKontakte];
        }
        
    } failure:^(id obj) {
        
    }];
}

- (void)vkSdkTokenHasExpired:(VKAccessToken *)expiredToken {
    [VKSdk authorize:SCOPE];
}

- (void)vkSdkAccessAuthorizationFinishedWithResult:(VKAuthorizationResult *)result {
    
    if (result.token) {
        YWLog(@"----- 授权成功toke_VK: %@ -- name: %@",result.token,result.user.first_name);
        self.vkAutorizationResult = result;
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        //从facebook 获取的信息
        NSString *email = ZFToString(self.vkAutorizationResult.token.email);
        NSString *vk_userId = ZFToString(self.vkAutorizationResult.token.userId);
        NSString *access_token = ZFToString(self.vkAutorizationResult.token.accessToken);

        [dict setObject:email forKey:@"email"];
        [dict setObject:vk_userId forKey:@"vk_userId"];
        [dict setObject:access_token forKey:@"access_token"];
        [dict setObject:self.view forKey:kLoadingView];
        [dict setObject:@"VKontakte" forKey:@"type"];
        
        [self vkLogin:dict isOu:NO];
        
    } else if (result.error) {
        
//        NSString *message = [NSString stringWithFormat:@"Access denied\n%@", result.error];
//        NSString *message = @"Access denied";
//        NSString *OK = ZFLocalizedString(@"OK", nil);
//        
//        ShowAlertView(nil, message, @[OK], nil, nil, nil);
    }
}

- (void)vkSdkUserAuthorizationFailed {
//    NSString *message = @"Access denied";
//    NSString *OK = ZFLocalizedString(@"OK", nil);
//    ShowAlertView(nil, message, @[OK], nil, nil, nil);
}

- (void)vkSdkNeedCaptchaEnter:(VKError *)captchaError {
    
    #ifdef DEBUG
        VKCaptchaViewController *vc = [VKCaptchaViewController captchaControllerWithError:captchaError];
        [vc presentIn:self];
    #endif
}

- (void)vkSdkShouldPresentViewController:(UIViewController *)controller {
    [self presentViewController:controller animated:YES completion:nil];
}

#pragma mark -

- (void)bindEmailWith:(NSMutableDictionary *)dict {
    UIAlertController *alertController =  [UIAlertController
                                           alertControllerWithTitle: ZFLocalizedString(@"confirmEmail", nil)
                                           message:ZFLocalizedString(@"inputEmail", nil)
                                           preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = ZFLocalizedString(@"signPlaceholderEmail", nil);
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:ZFLocalizedString(@"Login_cancel",nil) style:UIAlertActionStyleCancel handler:nil];
    UIAlertAction *confirmAction = [UIAlertAction actionWithTitle:ZFLocalizedString(@"confirm",nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        NSString *email = alertController.textFields.firstObject.text;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        [dict setObject:email forKey:@"email"];
        
        @weakify(self)
        [self.viewModel requestFBLoginNetwork:dict completion:^(NSInteger error, NSString *errorMsg) {
            @strongify(self)
            [self loginSuccess:YWLoginEnterTypeRegister];
        } failure:nil];
    }];
    confirmAction.enabled = NO;
    [alertController addAction:cancelAction];
    [alertController addAction:confirmAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)alertTextFieldDidChange:(NSNotification *)notification{
    UIAlertController *alertController = (UIAlertController *)self.presentedViewController;
    if (alertController) {
        NSString *email = alertController.textFields.firstObject.text;
        UIAlertAction *confirmAction = alertController.actions.lastObject;
        confirmAction.enabled = [NSStringUtils isValidEmailString:email];
    }
}

#pragma mark - Google

- (void)googleLogin {
    
    GIDSignIn *signIn = [GIDSignIn sharedInstance];
    //需要设置，不然gg
    signIn.presentingViewController = self;
    [signIn signIn];
    
    // 统计
    NSString *pageName = @"login_registration_page";
    if (self.comefromType == YWLoginViewControllerEnterTypeCartPage) {
        pageName = @"cart_page";
    } else if (self.comefromType == YWLoginViewControllerEnterTypeGuidePage) {
        pageName = @"guide_page";
    }
    [ZFAnalytics appsFlyerTrackEvent:@"af_sign_up_click"
    withValues:@{AFEventParamContentType : @"Google_sign_up_btn",
                 @"af_page_name" : pageName}];
}

- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    if (user != nil) {
        @weakify(self)
        //获取谷歌用户信息，性别，生日, person 可能为 nil
        ShowLoadingToView(nil);
        [self googleGainUserInfo:user completion:^(NSString *gender, NSString *birthday) {
            @strongify(self)
            HideLoadingFromView(nil);
            __block NSDictionary *dict = @{@"email"        : user.profile.email,
                                           @"googleId"     : user.userID,
                                           @"sex"          : ZFToString(gender),
                                           @"access_token" : NullFilter(user.authentication.idToken),
                                           @"nickname"     : NullFilter(user.profile.name),
                                           @"birthday"     : ZFToString(birthday),
                                           kLoadingView    : self.view
                                           };
            [AccountManager sharedManager].googleLoginGender = ZFToString(gender);
            [AccountManager sharedManager].googleLoginBirthday = ZFToString(birthday);
            [self googleLogin:dict signIn:signIn isOu:NO];
        }];
    }else{
        YWLog(@"谷歌登录失败");
    }
    [[GIDSignIn sharedInstance] signOut];
}


- (void)showInputEmailError:(NSInteger)error
                     params:(NSDictionary *)dict
                      email:(NSString *)email
                       name:(NSString *)name
                  thirdType:(YWLoginEnterType)thirdType {
    
    if (!(error ==1 || error == 2 || error == 7)) {// 请求里已经提示了
        return;
    }
    
    // 邮箱：（1标识未绑定且邮箱未空，2邮箱格式错误时）需要重新绑定邮箱; 7 已存在邮箱注册账户
    if (error == 7) {
        //表示已存在邮箱注册账户,弹窗提示用户重置密码
        [self popTipsUserResetPasswordAlertView];
        return;
    }
    
    ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
    NSString *country_eu = ZFToString(initializeModel.country_eu);
    if ([country_eu boolValue]) {
        // 进入注册页
        [self showCountry_EUParams:dict email:email name:name thirdType:thirdType];
    } else {
        //表示用户需要自己填一个邮箱
        [self popinputEmailAlertView:dict thirdType:thirdType];
    }
}

- (void)showCountry_EUParams:(NSDictionary *)dict
                       email:(NSString *)email
                        name:(NSString *)name
                   thirdType:(YWLoginEnterType)thirdType {
    
    // 进入注册页
      ZFRegisterModel *model = [[ZFRegisterModel alloc] init];
      model.email = ZFToString(email);
      model.nickName = ZFToString(name);
      ZFOtherRegisterViewController *vc = [[ZFOtherRegisterViewController alloc] init];
      vc.model = model;
      vc.registerHandler = ^(ZFRegisterModel *model) {
          if(thirdType == YWLoginEnterTypeGoogle) {
              [dict setValue:ZFToString(model.email) forKey:@"email"];
              [dict setValue:ZFToString(model.gender) forKey:@"sex"];
              [dict setValue:ZFToString(model.nickName) forKey:@"nickname"];
    
              [self googleLogin:dict signIn:[GIDSignIn sharedInstance] isOu:YES];
          } else if(thirdType == YWLoginEnterTypeFacebook) {
              [dict setValue:ZFToString(model.email) forKey:@"email"];
              [dict setValue:ZFToString(model.gender) forKey:@"sex"];
              [dict setValue:ZFToString(model.nickName) forKey:@"nickname"];
              [self fbLogin:dict isOu:YES];
          } else if (thirdType == YWLoginEnterTypeVKontakte) {
              [dict setValue:ZFToString(model.email) forKey:@"email"];
              [dict setValue:ZFToString(model.gender) forKey:@"sex"];
              [dict setValue:ZFToString(model.nickName) forKey:@"nickname"];
              [self vkLogin:dict isOu:YES];
          }
      };
      [self.navigationController pushViewController:vc animated:YES];
      self.navigationController.navigationBar.hidden = NO;
}

- (void)signIn:(GIDSignIn *)signIn presentViewController:(UIViewController *)viewController {
    [self presentViewController:viewController animated:YES completion:nil];
}

- (void)signIn:(GIDSignIn *)signIn dismissViewController:(UIViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)googleGainUserInfo:(GIDGoogleUser *)googleUser completion:(void(^)(NSString *gender, NSString *birthday))completion
{
    ///获取google用户性别，生日
    GTLRPeopleServiceQuery_PeopleGet *query = [GTLRPeopleServiceQuery_PeopleGet queryWithResourceName:@"people/me"];
    query.personFields = @"birthdays,genders";
    GTLRPeopleServiceService *service = [[GTLRPeopleServiceService alloc] init];
    service.authorizer = [googleUser.authentication fetcherAuthorizer];
    
    [service executeQuery:query completionHandler:^(GTLRServiceTicket * _Nonnull callbackTicket, id  _Nullable object, NSError * _Nullable callbackError) {
        NSString *genderValue = @"";
        NSMutableString *birthdayValue = [[NSMutableString alloc] init];
        if ([object isKindOfClass:[GTLRPeopleService_Person class]]) {
            GTLRPeopleService_Person *person = (GTLRPeopleService_Person *)object;
            if (person.genders) {
                GTLRPeopleService_Gender *gender = [person.genders firstObject];
                genderValue = [self exChangeZZZZZGenderForOther:gender.value];
            }
            if (person.birthdays) {
                GTLRPeopleService_Birthday *birthday = [person.birthdays firstObject];
                if (birthday.date.year) {
                    [birthdayValue appendFormat:@"%@/", birthday.date.year];
                }
                if (birthday.date.month) {
                    [birthdayValue appendFormat:@"%@/", birthday.date.month];
                }
                if (birthday.date.day) {
                    [birthdayValue appendFormat:@"%@", birthday.date.day];
                }
            }
        }
        if (completion) {
            completion(genderValue, birthdayValue);
        }
    }];
}

- (void)googleLogin:(NSDictionary *)dict signIn:(GIDSignIn *)signIn isOu:(BOOL)isOu{
    @weakify(self)
    [self.viewModel requestGoogleLoginNetwork:dict completion:^(NSInteger error, NSString *errorMsg) {
        
        @strongify(self)
        if (error == 0) {
            
            ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
            NSString *country_eu = ZFToString(initializeModel.country_eu);
                
            if ([AccountManager sharedManager].account.is_register && [country_eu boolValue] && !isOu) { // 第一次注册
                
                   [self showCountry_EUParams:dict
                                        email:[dict objectForKey:@"email"]
                                         name:[dict objectForKey:@"nickname"]
                                    thirdType:YWLoginEnterTypeFacebook];
            } else {
                //登录成功回调
                [self loginSuccess:YWLoginEnterTypeRegister];
            }
            
            //取得用户信息，后台生成/取得用户信息后，可以直接退出
            //登录通知
            [ZFFireBaseAnalytics signUpWithType:@"google"];
            [ZFFireBaseAnalytics signInWithTypeName:@"google"];
            //使用google登录事件统计
            NSString *eventName = @"af_sign_in";
            if ([AccountManager sharedManager].account.is_register) {
                eventName = @"af_sign_up";
            }
            [ZFAnalytics appsFlyerTrackEvent:eventName withValues:@{AFEventParamContentType : @"Google"}];
            // Branch
            [[ZFBranchAnalytics sharedManager] branchCompleteRegistrationType:@"google"];
            
            
        } else {
            [self showInputEmailError:error params:dict email:[dict objectForKey:@"email"] name:@"" thirdType:YWLoginEnterTypeGoogle];
        }
        
        
        
    } failure:^(id obj) {
        @strongify(self)
        [self dismissViewControllerAnimated:YES completion:^{
        }];
    }];
}

#pragma mark - Animation
- (void)showErrorTipAnimation:(BOOL)isShow targetView:(UIView *)targetView{
    @weakify(self)
    void (^showBlock)(void) = ^{
        @strongify(self)
        [self.view layoutIfNeeded];
    };

    [targetView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(isShow ? 83 : 69);
    }];

    [UIView animateWithDuration:0.3
                          delay:0.0f
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:showBlock
                     completion:nil];
}

#pragma mark - Check
- (void)checkValid{
    [self.view endEditing:YES];
    // 检查有效性
    if (self.loginStatus == YWLoginStatus_EmailLogin) {
        //邮箱登录
        if (!self.loginModel.isValidEmail) {
            if (self.loginModel.isFirstFocus ||  ZFIsEmptyString(self.loginModel.email))  [self.emailView checkValidEmail];
            [self showErrorTipAnimation:YES targetView:self.emailView];
            return;
        }
        
        if (!self.loginModel.isValidPassword) {
            if (self.loginModel.isFirstFocus || ZFIsEmptyString(self.loginModel.password))  [self.passwordView checkValidPassword];
            [self showErrorTipAnimation:YES targetView:self.passwordView];
            return;
        }
    } else if (self.loginStatus == YWLoginStatus_MobileLogin && self.loginModel.type == YWLoginEnterTypeLogin) {
        //电话号码登录
        if (ZFIsEmptyString(self.loginModel.phoneNum)) {
            [self.mobileView checkValidMobile];
            [self showErrorTipAnimation:YES targetView:self.mobileView];
            return;
        }
        if (ZFIsEmptyString(self.loginModel.VerificationCodeNum)) {
            ShowToastToViewWithText(self.view, ZFLocalizedString(@"Login_VerCodeError", nil));
            return;
        }
    }
    
    // 发送注册,登录请求
    if (self.loginModel.type == YWLoginEnterTypeLogin) {
        if (self.loginStatus == YWLoginStatus_EmailLogin) {
            [self signInWithModel:self.loginModel];
        } else if (self.loginStatus == YWLoginStatus_MobileLogin) {
            [self registerPhoneWithModel:self.loginModel];
        }
    }else{
        if (self.loginModel.isCountryEU && !self.loginModel.isConfirmInformation) {
            [self.subscribeView shakeKitWithAnimation];
            return;
        }
        
        // COD国家需要选择性别才能注册
        ZFInitializeModel *initializeModel = [AccountManager sharedManager].initializeModel;
        if ([initializeModel.is_cod_sex integerValue] == 1 &&
            self.selectGenderView.alpha != 0 &&
            (!self.loginModel.sex || ZFIsEmptyString(self.loginModel.sex))) {
            ShowAlertSingleBtnView(nil, ZFLocalizedString(@"Register_ChooseGender", nil), ZFLocalizedString(@"Register_ChooseGender_Sure", nil));
            return;
        }
        [self registerWithModel:self.loginModel];
    }
}

#pragma mark - target

- (void)forgotButtonAction
{
    if (self.loginModel.type == YWLoginEnterTypeLogin) {
        self.loginModel.isChangeType = NO;
        [self pushToViewController:@"ZFForgotPasswordViewController"
                       propertyDic:@{@"model" : [self.loginModel copy]}];
    }
}

#pragma mark - Getter
- (YWLoginTopView *)loginTopView {
    if (!_loginTopView) {
        _loginTopView = [[YWLoginTopView alloc] init];
        _loginTopView.model = self.loginModel;
        @weakify(self)
        _loginTopView.loginCloseHandler = ^{
            @strongify(self);
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            if (self.cancelSignBlock) {
                self.cancelSignBlock();
            }
        };
        
        _loginTopView.toggleModeHandler = ^(YWLoginModel *model) {
            @strongify(self);
            [self.view endEditing:YES];
            if (model.type == YWLoginEnterTypeLogin) {
                if (self.loginStatus == YWLoginStatus_EmailLogin) {
                    [self exchangeEmailViewStatus:NO];
                    [self exchangeMobileViewStatus:YES];
                } else if (self.loginStatus == YWLoginStatus_MobileLogin) {
                    [self exchangeEmailViewStatus:YES];
                    [self exchangeMobileViewStatus:NO];
                }
            } else if (model.type == YWLoginEnterTypeRegister) {
                [self exchangeEmailViewStatus:NO];
                [self exchangeMobileViewStatus:YES];
            }
            self.type = model.type;
            [self addOrUpdateGenderView:model];
            self.loginModel = model;
            self.modeView.model = model;
            self.emailView.model = model;
            self.passwordView.model = model;
            self.confirmView.model = model;
            self.subscribeView.model = model;
            self.footerView.model = model;
            [self handlerConternViewOffsetY];
        };
    }
    return _loginTopView;
}

- (YWLoginFooterView *)footerView {
    if (!_footerView) {
        _footerView = [[YWLoginFooterView alloc] init];
        _footerView.model = self.loginModel;
        @weakify(self)
        _footerView.googleplusButtonCompletionHandler = ^{
            @strongify(self)
            [self googleLogin];
        };
        
        _footerView.facebookButtonCompletionHandler = ^{
            @strongify(self);
            [self facebookLogin];
        };
        
        _footerView.privacyPolicyActionBlock = ^(ZFTreatyLinkAction actionType) {
            @strongify(self);
            [self dealWithTreatyLinkAction:actionType];
        };
        
        _footerView.vkButtonCompletionHandler = ^{
            @strongify(self);
            [self vkAuthorize];
        };
    }
    return _footerView;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _scrollView;
}

- (UIView *)conternView {
    if (!_conternView) {
        _conternView = [[UIView alloc] init];
        _conternView.backgroundColor = ZFCOLOR_WHITE;
    }
    return _conternView;
}

- (YWLoginTypeModeView *)modeView {
    if (!_modeView) {
        _modeView = [[YWLoginTypeModeView alloc] init];
        _modeView.model = self.loginModel;
    }
    return _modeView;
}

- (YWLoginTypeEmailView *)emailView {
    if (!_emailView) {
        _emailView = [[YWLoginTypeEmailView alloc] init];
        _emailView.model = self.loginModel;
        @weakify(self)
        _emailView.emailTextFieldEditingDidEndHandler = ^(BOOL isShowError, YWLoginModel *model) {
            @strongify(self);
            self.loginModel = model;
            // 刷新高度
//            [self showErrorTipAnimation:isShowError targetView:self.emailView];
        };
    }
    return _emailView;
}

- (YWLoginTypePasswordView *)passwordView {
    if (!_passwordView) {
        _passwordView = [[YWLoginTypePasswordView alloc] init];
        _passwordView.model = self.loginModel;
        @weakify(self)
        _passwordView.passwordTextFieldEditingDidEndHandler = ^(BOOL isShowError, YWLoginModel *model) {
            @strongify(self);
            self.loginModel = model;
            // 刷新高度
//            [self showErrorTipAnimation:isShowError targetView:self.passwordView];
        };
        
        _passwordView.passwordTextFieldDoneHandler = ^(YWLoginModel *model) {
            @strongify(self);
            self.loginModel = model;
            [self checkValid];
        };
    }
    return _passwordView;
}

- (YWLoginTypeConfirmView *)confirmView{
    if (!_confirmView) {
        _confirmView = [[YWLoginTypeConfirmView alloc] init];
        _confirmView.model = self.loginModel;
         @weakify(self)
        _confirmView.confirmCellHandler = ^{
            @strongify(self);
            [self checkValid];
            
            // 统计
            NSString *pageName = @"login_registration_page";
            if (self.comefromType == YWLoginViewControllerEnterTypeCartPage) {
                pageName = @"cart_page";
            } else if (self.comefromType == YWLoginViewControllerEnterTypeGuidePage) {
                pageName = @"guide_page";
            }
            NSString *contentType = @"sign_in_btn";
            if (self.loginModel.type == YWLoginEnterTypeLogin) {
                contentType = @"sign_in_btn";
            } else if (self.loginModel.type == YWLoginEnterTypeRegister) {
                contentType = @"sign_up_btn";
            }
            [ZFAnalytics appsFlyerTrackEvent:@"af_sign_up_click"
                                  withValues:@{AFEventParamContentType : contentType,
                                               @"af_page_name" : pageName}];
        };
    }
    return _confirmView;
}

-(ZFSelectGenderView *)selectGenderView {
    if (!_selectGenderView) {
        _selectGenderView = [[ZFSelectGenderView alloc] init];
        _selectGenderView.alpha = 0;
        @weakify(self)
        _selectGenderView.handleClick = ^(ZFSelectGenderView *genderView){
            @strongify(self)
            [self.view endEditing:YES];
            
            //sex: 0 保密  1男 2女 (V4.3.0去除保密 ZFLocalizedString(@"Profile_Privacy", nil))
            NSArray *array = @[ZFLocalizedString(@"Profile_Female", nil),
                               ZFLocalizedString(@"Profile_Male", nil)];
            @weakify(self)
            DLPickerView *pickerView = [[DLPickerView alloc] initWithDataSource:array
                                                               withSelectedItem:nil
                                                              withSelectedBlock:^(id selectedItem) {
                                                                  genderView.gender = selectedItem;
                                                                  @strongify(self)
                                                                  if ([array containsObject:selectedItem]){
                                                                      if ([selectedItem isEqualToString:ZFLocalizedString(@"Profile_Male", nil)]) {
                                                                          self.loginModel.sex = @"1";
                                                                      } else if ([selectedItem isEqualToString:ZFLocalizedString(@"Profile_Female", nil)]) {
                                                                          self.loginModel.sex = @"2";
                                                                      } else {
                                                                          self.loginModel.sex = @"0";
                                                                      }
                                                                  }
                                                              }
                                        ];
            pickerView.shouldDismissWhenClickShadow = YES;
            [pickerView show];
        };
    }
    return _selectGenderView;
}

- (YWLoginTypeSubscribeView *)subscribeView {
    if (!_subscribeView) {
        _subscribeView = [[YWLoginTypeSubscribeView alloc] init];
        _subscribeView.userInteractionEnabled = YES;
        _subscribeView.model = self.loginModel;
        [_subscribeView handlerExChangeButtonTitle:self.loginStatus];
        @weakify(self)
        _subscribeView.subscribeCellHandler = ^(YWLoginModel *model) {
            @strongify(self);
            [self.view endEditing:YES];
            self.loginModel = model;
        };
        
        _subscribeView.exchangeButtonHandler = ^(YWLoginModel *model) {
            @strongify(self);
            [self.view endEditing:YES];
            self.loginModel = model;
            switch (self.loginStatus) {
                case YWLoginStatus_MobileLogin:
                    self.loginStatus = YWLoginStatus_EmailLogin;
                    break;
                case YWLoginStatus_EmailLogin:
                    self.loginStatus = YWLoginStatus_MobileLogin;
                    break;
                default:
                    break;
            }
            [self addOrUpdateGenderView:model];
            if (self.loginStatus == YWLoginStatus_EmailLogin) {
                [self exchangeEmailViewStatus:NO];
                [self exchangeMobileViewStatus:YES];
            } else if (self.loginStatus == YWLoginStatus_MobileLogin) {
                [self exchangeEmailViewStatus:YES];
                [self exchangeMobileViewStatus:NO];
            }
            [self.subscribeView handlerExChangeButtonTitle:self.loginStatus];
            [self handlerConternViewOffsetY];
        };
        
        _subscribeView.loginPrivacyPolicyActionBlock = ^{
            @strongify(self);
            [self dealWithTreatyLinkAction:TreatyLinkAction_ProvacyPolicy];
        };
    }
    return _subscribeView;
}

- (YWLoginModel *)loginModel {
    if (!_loginModel) {
        _loginModel = [[YWLoginModel alloc] init];
        NSString *email = [[NSUserDefaults standardUserDefaults] valueForKey:kUserEmail];
        if (self.type == YWLoginEnterTypeNoromal) {
            _loginModel.type = ZFIsEmptyString(email) ? YWLoginEnterTypeRegister : YWLoginEnterTypeLogin;
            self.type = _loginModel.type;
        }else{
            _loginModel.type = self.type;
        }
        _loginModel.isValidEmail = ZFIsEmptyString(email) ? NO : YES;
        _loginModel.email = email;
        _loginModel.isFirstFocus = YES;
        _loginModel.isSubscribe = _loginModel.isCountryEU ? NO : YES;
    }
    return _loginModel;
}

- (LoginViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[LoginViewModel alloc] init];
        _viewModel.deepLinkSource = self.deepLinkSource;
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (YWLoginSelectCountryView *)selectCountryView
{
    if (!_selectCountryView) {
        _selectCountryView = [[YWLoginSelectCountryView alloc] init];
        
        NSString *currentCountryId = [AccountManager sharedManager].accountCountryModel.region_id;
        
        for (int i = 0; i < [self.ZFNewCountryList count]; i++) {
            YWLoginNewCountryModel *model = self.ZFNewCountryList[i];
            if ([currentCountryId isEqualToString:model.region_id]) {
                _selectCountryView.defaultCountryModel = model;
                self.loginModel.region_id = model.region_id;
                
                [self.footerView configurationRus:[ZFAddressCountryModel isRussiaCountryID:model.region_id]];

                break;
            }
        }
        
        @weakify(self)
        _selectCountryView.selectCountryHandler = ^(YWLoginNewCountryModel * _Nonnull model) {
            @strongify(self)
            self.loginModel.region_id = model.region_id;
            self.emailView.region_id = ZFToString(model.region_id);
            
            [self.footerView configurationRus:[ZFAddressCountryModel isRussiaCountryID:model.region_id]];
        };
    }
    return _selectCountryView;
}

-(YWLoginTypeMobileView *)mobileView
{
    if (!_mobileView) {
        _mobileView = [[YWLoginTypeMobileView alloc] init];
        _mobileView.model = self.loginModel;
        _mobileView.emailTextFieldEditingDidEndHandler = ^(BOOL isShowError, YWLoginModel *model) {
            YWLog(@"%@", model.phoneNum);
        };
        @weakify(self)
        _mobileView.emailTextFieldEditingChangeHandler = ^(YWLoginTextField *textField) {
            @strongify(self)
            self.loginModel.phoneNum = textField.text;
        };
    }
    return _mobileView;
}

-(YWLoginTypeSendCodeView *)sendCodeView
{
    if (!_sendCodeView) {
        _sendCodeView = [[YWLoginTypeSendCodeView alloc] init];
        _sendCodeView.model = self.loginModel;
        @weakify(self)
        _sendCodeView.emailTextFieldEditingChangeHandler = ^(YWLoginTextField *textField) {
            @strongify(self)
            self.loginModel.VerificationCodeNum = textField.text;
        };
        _sendCodeView.sendCodeHandler = ^(ZFCountDownButton *sendCodeButton) {
            @strongify(self)
            BOOL checkMobile = [self.mobileView checkValidMobile];
            if (!checkMobile) {
                return;
            }
            [sendCodeButton startCountDownAnimation];
            [self.viewModel requestsSendVerifyCode:self.loginModel.region_id phone:self.loginModel.phoneNum completion:^(NSError *error) {
                if (!error) {
                    //开始倒计时了
                    [sendCodeButton startCountDown];
                } else {
                    [sendCodeButton stopConutDown];
                }
            }];
        };
    }
    return _sendCodeView;
}

-(UIView *)mobileLoginTipsView
{
    if (!_mobileLoginTipsView) {
        _mobileLoginTipsView = ({
            UIView *view = [[UIView alloc] init];
            view.backgroundColor = ZFC0xF2F2F2();
            UILabel *label = [[UILabel alloc] init];
            label.numberOfLines = 0;
            label.text = ZFLocalizedString(@"Customer_no_register_login_phone", nil);
            label.textColor = ZFC0x999999();
            label.font = [UIFont systemFontOfSize:13];
            [view addSubview:label];
            
            [label mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(view).mas_offset(16);
                make.trailing.mas_equalTo(view.mas_trailing).mas_offset(-16);
                make.top.mas_equalTo(view).mas_offset(8);
                make.bottom.mas_equalTo(view).mas_offset(-8);
            }];
            
            view;
        });
    }
    return _mobileLoginTipsView;
}

- (UIButton *)forgotButton {
    if (!_forgotButton) {
        _forgotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_forgotButton setTitle:ZFLocalizedString(@"SignIn_ForgotPassword",nil) forState:UIControlStateNormal];
        [_forgotButton setTitleColor:ZFC0x999999() forState:UIControlStateNormal];
        _forgotButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_forgotButton addTarget:self action:@selector(forgotButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [_forgotButton setEnlargeEdge:20];
    }
    return _forgotButton;
}

-(NSMutableArray<YWLoginNewCountryModel *> *)ZFNewCountryList
{
    if (!_ZFNewCountryList) {
        _ZFNewCountryList = [[NSMutableArray alloc] init];
    }
    return _ZFNewCountryList;
}

@end
