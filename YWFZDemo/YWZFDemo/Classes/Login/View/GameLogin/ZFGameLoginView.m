//
//  ZFGameLoginView.m
//  ZZZZZ
//
//  Created by YW on 2018/9/28.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFGameLoginView.h"

#import "ZFGameSelectLoginView.h"
#import "ZFGameEmailLoginView.h"
#import "ZFGameLoginPasswordView.h"
#import "ZFGameLoingTitleView.h"

#import "LoginViewModel.h"

#import "ZFForgotPasswordViewController.h"
#import "YWLoginViewController.h"
#import "ZFNavigationController.h"

#import "YWLocalHostManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalyticsTimeManager.h"
#import "YWCFunctionTool.h"
#import "ZFFrameDefiner.h"
#import "ZFRequestModel.h"
#import "Constants.h"

#import "UIView+LayoutMethods.h"
#import "UIButton+ZFButtonCategorySet.h"

#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import <Masonry/Masonry.h>
#import <AppsFlyerLib/AppsFlyerTracker.h>
#import <IQKeyboardManager/IQKeyboardManager.h>
#import "ZFBranchAnalytics.h"

///页面状态
typedef NS_ENUM(NSInteger) {
    GameLoginPageStatus_Select,
    GameLoginPageStatus_Email,
    GameLoginPageStatus_Password
}GameLoginPageStatus;

@interface ZFGameLoginView ()
<
    ZFGameSelectLoginViewDelegate,
    ZFGameEmailLoginViewDelegate,
    ZFGameLoginPasswordViewDelegate
>
@property (nonatomic, strong) UIView *loginMaskView;                        ///登录背景图

@property (nonatomic, strong) ZFGameSelectLoginView *gameSelectView;        ///游客选择视图

@property (nonatomic, strong) ZFGameEmailLoginView *emailLoginView;         ///邮箱填写视图

@property (nonatomic, strong) ZFGameLoginPasswordView *passwordView;        ///密码填写视图

@property (nonatomic, strong) YWLoginModel *loginModel;                     ///登录数据模型存储
@property (nonatomic, copy) gameLoginCompletion completion;                 ///登录成功回调
@property (nonatomic, strong) LoginViewModel *loginViewModel;               ///登录网络请求

@property (nonatomic, assign) CGFloat keyboardHeight;

@property (nonatomic, assign) GameLoginPageStatus  pageStatus;

@end

@implementation ZFGameLoginView

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI
{
    self.backgroundColor = [UIColor whiteColor];
    
    self.pageStatus = GameLoginPageStatus_Password;
    
    [self addSubview:self.gameSelectView];
    
    [self addSubview:self.emailLoginView];
    
    [self addSubview:self.passwordView];
    
    self.frame = CGRectMake(0, KScreenHeight, KScreenWidth, self.gameSelectView.height);
    [self.gameSelectView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.leading.mas_equalTo(self);
        make.width.mas_equalTo(KScreenWidth);
    }];
    self.passwordView.frame = CGRectMake(self.right, 0, self.width, 318 + kiphoneXHomeBarHeight);
    self.emailLoginView.frame = CGRectMake(self.right, 0, KScreenWidth, 268 + kiphoneXHomeBarHeight);
}

#pragma mark - 键盘通知

- (void)addNotification {
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:NO];
    [[IQKeyboardManager sharedManager] setEnable:NO];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillhidden:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotification {
    [[IQKeyboardManager sharedManager] setEnableAutoToolbar:YES];
    [[IQKeyboardManager sharedManager] setEnable:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)note {
    //获取键盘的高度
    NSDictionary *userInfo = [note userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    [UIView animateWithDuration:0.3 animations:^{
        CGFloat height = self.superview.height - self.height  - keyboardRect.size.height;
        self.keyboardHeight = keyboardRect.size.height;
        self.y = height;
    }];
}

- (void)keyboardWillhidden:(NSNotification *)note {
    CGFloat height = self.height;
    height = self.subviews[self.pageStatus].height;
    if (self.pageStatus == GameLoginPageStatus_Email) {
        height = self.emailLoginView.height - 42;
    }
    [UIView animateWithDuration:0.3 animations:^{
        self.y = self.superview.height - height;
        self.keyboardHeight = 0;
    }];
}

#pragma mark - select view delegate

-(void)ZFGameSelectLoginViewDidClickCloseButton
{
    [self hiddenLoginView];
}

-(void)ZFGameSelectLoginViewUseEmailLogin
{
    [self jumpLoginButtonAction];
    [self hiddenLoginView];
}

-(void)ZFGameSelectLoginViewGuestLogin
{
    [self.emailLoginView emailBecomeFirstResponder];
    [self pushViewWithPageStatus:self.emailLoginView];
}

#pragma mark - email view delegate

-(void)ZFGameEmailLoginViewDidClickClose:(ZFGameEmailLoginView *)view
{
    [view endEditing:YES];
    [self popViewWithPageStatus:view];
}

-(void)ZFGameEmailLoginViewDidClickContinue:(ZFGameEmailLoginView *)view
{
    self.loginModel = view.loginModel;
    BOOL isvalid = [NSStringUtils isValidEmailString:[self.emailLoginView gainEmail]];
    if (!isvalid) {
        ShowToastToViewWithText(nil, ZFLocalizedString(@"Login_email_format_error", nil));
        return;
    }
    [self gameLoginRequest];
}

- (void)ZFGameEmailLoginViewDidClickJumpLogin:(ZFGameEmailLoginView *)view
{
    [self jumpLoginButtonAction];
}

#pragma mark - passwordview delegate

-(void)ZFGameLoginPasswordViewDidClickClose
{
    [self.emailLoginView emailBecomeFirstResponder];
    [self popViewWithPageStatus:self.passwordView];
}

- (void)ZFGameLoginPasswordViewDidClickForgetPassword
{
    [self forgetButtonAction];
}

- (void)ZFGameLoginPasswordViewDidClickJumpLogin
{
    [self jumpLoginButtonAction];
}

- (void)ZFGameLoginPasswordViewDidClickLogin
{
    [self signInAction];
}

#pragma mark - public method

- (void)showLoginView:(UIView *)parentView success:(nonnull gameLoginCompletion)completion
{
    if (![self superview]) {
        [WINDOW addSubview:self.loginMaskView];
        [WINDOW addSubview:self];
    }
    self.completion = completion;
    [UIView animateWithDuration:.35 animations:^{
        self.y = KScreenHeight - self.height;
        self.loginMaskView.alpha = 0.5;
    }];
    [self addNotification];
}

- (void)hiddenLoginView
{
    [self removeNotification];
    [self endEditing:YES];
    [UIView animateWithDuration:.35 animations:^{
        self.y = KScreenHeight;
        self.loginMaskView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
        [self.loginMaskView removeFromSuperview];
    }];
}

#pragma mark - target

///跳转到大登录页
- (void)jumpLoginButtonAction
{
    [self hiddenMaskView];
    YWLoginViewController *loginVC = [[YWLoginViewController alloc] init];
    loginVC.comefromType = YWLoginViewControllerEnterTypeCartPage;
    ZFNavigationController *nav = [[ZFNavigationController alloc] initWithRootViewController:loginVC];
    [WINDOW.rootViewController presentViewController:nav animated:YES completion:nil];
    @weakify(self)
    loginVC.cancelSignBlock = ^{
        @strongify(self)
        //用户没有登录，就重新显示游客登录页
        [self showMaskView];
    };
    loginVC.successBlock = ^{
        @strongify(self)
        AccountManager *manager = [AccountManager sharedManager];
        if (manager.isSignIn) {
            //如果在登录页面已经正常登录，就直接调用成功刷新购物车
            if (self.completion) {
                self.completion();
            }
            [self hiddenLoginView];
        }else{
            [self showMaskView];
        }
    };
}

- (void)closeLoginView
{
    [self hiddenLoginView];
}

///登录
- (void)signInAction
{
    self.loginModel.type = YWLoginEnterTypeLogin;
    BOOL isvalid = [self.passwordView.passwordView checkValidPassword];
    if (!isvalid) {
        return;
    }
    self.loginModel.password = self.passwordView.passwordView.passwordTextField.text;
    [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kStartLoadingSignIn];
    [self.loginViewModel requestLoginNetwork:self.loginModel completion:^(id obj) {
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignIn];
        if ([AccountManager sharedManager].isSignIn) {
            [ZFFireBaseAnalytics signInWithTypeName:@"general"];
            [AppsFlyerTracker sharedTracker].customerUserID = [NSStringUtils isEmptyString:USERID] ? @"0" : USERID;
            // Branch
            [[ZFBranchAnalytics sharedManager] branchLoginWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
            //注册大数据统计用户id
            [GGAppsflyerAnalytics registerBigDataWithUserId:[NSStringUtils isEmptyString:USERID] ? @"0" : USERID];
            [[NSNotificationCenter defaultCenter] postNotificationName:kLoginNotification object:nil];
            if (self.completion) {
                self.completion();
                self.completion = nil;
            }
            [self hiddenLoginView];
        }
    } failure:^(id obj) {
        [[ZFAnalyticsTimeManager sharedManager] logTimeWithEventName:kFinishLoadingSignIn];
    }];
}

///忘记密码
- (void)forgetButtonAction
{
    [self hiddenMaskView];
    ZFForgotPasswordViewController *forgetVC = [[ZFForgotPasswordViewController alloc] init];
    forgetVC.model = self.loginModel;
    UIViewController *topVC = [UIViewController currentTopViewController];
    [topVC.navigationController pushViewController:forgetVC animated:YES];
    @weakify(self)
    forgetVC.completion = ^(void){
        @strongify(self)
        [self showMaskView];
    };
}

#pragma mark - private method

- (void)pushViewWithPageStatus:(UIView *)view
{
    UIView *targetView = view;
    [UIView animateWithDuration:0.3 animations:^{
        targetView.x = 0;
        [self refreshSuperViewHeight:targetView];
    } completion:^(BOOL finished) {
        self.pageStatus = [self.subviews indexOfObject:view];
    }];
}

- (void)popViewWithPageStatus:(UIView *)view
{
    UIView *targetView = view;
    NSUInteger preIndex = [self.subviews indexOfObject:view] - 1;
    if (preIndex < 0) {
        preIndex = 0;
    }
    UIView *preView = self.subviews[preIndex];
    [UIView animateWithDuration:0.3 animations:^{
        targetView.x = KScreenWidth;
        [self refreshSuperViewHeight:preView];
    } completion:^(BOOL finished) {
        self.pageStatus = preIndex;
    }];
}

- (void)refreshSuperViewHeight:(UIView *)view
{
    self.height = view.height;
    self.y = KScreenHeight - self.height - self.keyboardHeight;
}

//隐藏maskView
- (void)hiddenMaskView
{
    [self removeNotification];
    [self endEditing:YES];
    [UIView animateWithDuration:.35 animations:^{
        self.y = KScreenHeight;
        self.loginMaskView.alpha = 0.0;
    }];
}

//显示maskView
- (void)showMaskView
{
    [UIView animateWithDuration:.35 animations:^{
        self.loginMaskView.alpha = 0.5;
    }];
    [self addNotification];
    [self.passwordView passwordBecomeFirstResponder];
}

#pragma mark - request

- (void)gameLoginRequest
{
    ShowLoadingToView(nil);
    ZFRequestModel *requestModel = [[ZFRequestModel alloc] init];
    requestModel.url = API(Port_GameLogin);
    requestModel.parmaters = @{
                               @"sess_id"     :   SESSIONID,
                               @"wj_linkid"   :   [NSStringUtils getLkid],
                               @"af_uid"      :   ZFToString([AppsFlyerTracker sharedTracker].getAppsFlyerUID),
                               @"ad_id"       :   [NSStringUtils getAdId],
                               @"email"       :   ZFToString([self.emailLoginView gainEmail])
                               };
    @weakify(self)
    [ZFNetworkHttpRequest sendRequestWithParmaters:requestModel success:^(id responseObject) {
        @strongify(self)
        HideLoadingFromView(nil);
        NSInteger statusCode = [responseObject[@"statusCode"] integerValue];
        if (statusCode == 200) {
            NSDictionary *resultDict = responseObject[ZFResultKey];
            if (!ZFJudgeNSDictionary(resultDict)) {
                ShowToastToViewWithText(nil, @"Params error");
                return;
            }
            NSInteger code = [resultDict[@"code"] integerValue];
            if (code == 1) {
                //表示用户邮箱已注册，进入到输入密码的页面
                [self.passwordView passwordBecomeFirstResponder];
                [self pushViewWithPageStatus:self.passwordView];
                return;
            }
 
            NSString *tipsMsg = resultDict[@"msg"];
            ShowToastToViewWithText(nil, tipsMsg);
            
            NSDictionary *userInfoDic = resultDict[@"user_info"];
            if (!ZFJudgeNSDictionary(userInfoDic)) {
                return;
            }
            AccountModel *userModel = [AccountModel yy_modelWithJSON:userInfoDic];
            [[AccountManager sharedManager] updateUserInfo:userModel];
            [[NSUserDefaults standardUserDefaults] setValue:userModel.email forKey:kUserEmail];
            [[NSUserDefaults standardUserDefaults] setValue:@([userInfoDic[@"cart_number"] integerValue]) forKey:kCollectionBadgeKey];
            [[NSUserDefaults standardUserDefaults] synchronize];
            // 保存LeandCloud数据
            [AccountManager saveLeandCloudData];
            if (self.completion) {
                self.completion();
                self.completion = nil;
            }
            [self hiddenLoginView];
        }else{
            NSString *message = responseObject[@"msg"];
            ShowToastToViewWithText(nil, message);
        }
    } failure:^(NSError *error) {
        HideLoadingFromView(nil);
        if ([error.userInfo[NSHelpAnchorErrorKey] integerValue] == 200) {
            ShowToastToViewWithText(nil, error.domain);
        }
    }];
}

#pragma mark - setter and getter

-(UIView *)loginMaskView
{
    if (!_loginMaskView) {
        _loginMaskView = ({
            UIView *view = [[UIView alloc] initWithFrame:WINDOW.bounds];
            view.backgroundColor = [UIColor blackColor];
            view.alpha = 0.0;
            view;
        });
    }
    return _loginMaskView;
}

-(ZFGameSelectLoginView *)gameSelectView
{
    if (!_gameSelectView) {
        _gameSelectView = [[ZFGameSelectLoginView alloc] init];
        _gameSelectView.delegate = self;
    }
    return _gameSelectView;
}

-(ZFGameEmailLoginView *)emailLoginView
{
    if (!_emailLoginView) {
        _emailLoginView = [[ZFGameEmailLoginView alloc] init];
        _emailLoginView.loginModel = self.loginModel;
        _emailLoginView.delegate = self;
    }
    return _emailLoginView;
}

-(ZFGameLoginPasswordView *)passwordView
{
    if (!_passwordView) {
        _passwordView = [[ZFGameLoginPasswordView alloc] init];
        _passwordView.delegate = self;
    }
    return _passwordView;
}

-(YWLoginModel *)loginModel
{
    if (!_loginModel) {
        _loginModel = [[YWLoginModel alloc] init];
        _loginModel.isFirstFocus = YES;
        _loginModel.type = YWLoginEnterTypeLogin;
    }
    return _loginModel;
}

-(LoginViewModel *)loginViewModel
{
    if (!_loginViewModel) {
        _loginViewModel = [[LoginViewModel alloc] init];
    }
    return _loginViewModel;
}

@end
