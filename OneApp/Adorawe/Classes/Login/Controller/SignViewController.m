//
//  SignViewController.m
// XStarlinkProject
//
//  Created by 10010 on 20/7/30.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import "SignViewController.h"
#import "SignViewModel.h"
#import "STLTextField.h"
#import "STLBottomLineButton.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <AuthenticationServices/AuthenticationServices.h>
#import "STLRegisterProtocolView.h"
#import "STLAlertViewController.h"

#import "STLLoginFooterView.h"
#import "STLRegisterAdvView.h"

#import "OSSVCountrysCheckAip.h"
#import "SSKeychain.h"
#import "AppDelegate+STLThirdLibrary.h"
#import "DetailTextField.h"
#import "STLResetpasswordViewController.h"
#import "STLBindCellNumViewController.h"
#import "STLPreference.h"
#import "Adorawe-Swift.h"
#import "STLBindPhoneNumViewModel.h"


typedef NS_ENUM(NSInteger, SignTypes) {
    SignTypesSystem     = 0,
    SignTypesFaceBook   ,
    SignTypesGoogle,
    SignTypesApple
};

static const NSInteger kInputTextFieldMaxLength = 30; // 允许输入最大的数

@interface SignViewController ()<
DetailTextFieldDelegate,
STLRegisterProtocolViewDelegate,
ASAuthorizationControllerDelegate,
ASAuthorizationControllerPresentationContextProviding,
GIDSignInDelegate
>

// backScrollerView
@property (nonatomic, strong) YYAnimatedImageView   *userAdvertising;
@property (nonatomic, strong) UIButton              *cancelButton;

@property (nonatomic, strong) UIButton              *maleButton;
@property (nonatomic, strong) UIButton              *femaleButton;

@property (nonatomic, strong) UIButton              *signUpButton;

@property (nonatomic, strong) UIView                *infoBackView;

///
@property (weak,nonatomic) UIButton *switchSignUpLoginBtn;
@property (weak,nonatomic) UILabel *boldTitleLable;  //注册/登录 文案
@property (weak,nonatomic) STLRegisterAdvSmallView *adView;

@property (weak,nonatomic) DetailTextField *emailTextField;
@property (weak,nonatomic) DetailTextField *passwordTextField;
@property (weak,nonatomic) UIButton *signUpOrSignInButtion;
@property (weak,nonatomic) UIButton *forgotPwdButton;

/** 欧盟协议*/
@property (nonatomic, strong) STLRegisterProtocolView     *registerProtocolView;
@property (nonatomic, assign) SignTypes                   currentSignTypes;

@property (nonatomic, strong) UITextField               *tempGetUIAlertTextField;
@property (nonatomic, strong) NSString                  *sexString;
@property (nonatomic, strong) SignViewModel             *viewModel;

@property (nonatomic, strong) UIButton                  *appleButton;

@property (nonatomic, strong) STLLoginFooterView        *loginFooterView;
@property (nonatomic, strong) STLRegisterAdvView        *registerAdvView;  //注册按钮下的文案

@property (nonatomic, strong) UIView *checkOutAsGuest;

@property (assign,nonatomic) BOOL isLoginAction;

@property (strong,nonatomic) STLBindCountryModel      *countryModel;
@property (strong,nonatomic) STLBindPhoneNumViewModel *bindPhoneViewModel;

///注册时可勾选的选项
@property (strong,nonatomic) UIStackView *signUpOptions;

@property (weak,nonatomic) CheckItemsView *subscribeCheck;

@end


@implementation SignViewController

#pragma mark - viewDidLoad
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    //需求调整，注册页面优先
    self.state = 2;
    [self initSubViews];

    if (![OSSVAdvsViewsManager sharedManager].isEURequrestSuccess) {
        [self requestCountryCheck:NO];
    }
    [self observeAppleSignInState];
    
    if (@available(iOS 13.0, *)) {
        self.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    self.isModalPresent = YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.firstEnter = YES;
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 150;
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [IQKeyboardManager sharedManager].keyboardDistanceFromTextField = 10;

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //进来默认弹窗苹果登录
    //[self perfomExistingAccountSetupFlows];
    [UIApplication sharedApplication].keyWindow.backgroundColor = [UIColor blackColor];
}

#pragma mark - 取消登录
- (void)cancelAction:(id)sender {
    
    if (self.closeBlock) {
        self.closeBlock();
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 欧盟判断
- (void)requestCountryCheck:(BOOL)showLoading {
    
           
    OSSVCountrysCheckAip *countryCheckAip = [[OSSVCountrysCheckAip alloc] init];
    
    //国家信息
    [countryCheckAip startWithBlockSuccess:^(__kindof OSSVBasesRequests *request) {
        
        NSDictionary *countryCheckDic = [OSSVNSStringTool desEncrypt:request];
        
        if ([countryCheckDic[kStatusCode] integerValue] == kStatusCode_200) {
            NSDictionary *resultDic = countryCheckDic[kResult];
            
            if (![OSSVAdvsViewsManager sharedManager].isEURequrestSuccess) {
                [OSSVAdvsViewsManager sharedManager].isEURequrestSuccess = YES;
                
                
                if ([resultDic[@"alert"] integerValue] == 1) {
                    [OSSVAdvsViewsManager sharedManager].isEU = YES;
                    
                    if (showLoading) {
                        if (self.currentSignTypes == SignTypesFaceBook) {
                            [self faceBookLogin];
                        } else if (self.currentSignTypes == SignTypesGoogle) {
                            [self googleLogin];
                        } else if (self.currentSignTypes == SignTypesApple) {
                            [self appleLogin];
                        }
                        else {
                            [self signUpAction];
                        }
                    }
                }
            }
        }
        
    } failure:^(__kindof OSSVBasesRequests *request, NSError *error) {
        if (showLoading) {
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"load_failed", nil)];
        }
    }];

}

- (void)makeAlertOfSendEmailSuccessMessage {
}

- (void)checkNetworkState:(void (^)(BOOL flag))stateBlock {
    
}

#pragma mark 登录操作
- (void)loginAction:(UIButton *)sender {
    
    switch (sender.tag) {
        case SignTypesSystem:{
            [self systemLogin];
        }
            break;
        case SignTypesFaceBook:{
            [self faceBookLogin];

        }
            break;
        case SignTypesGoogle: {
            [self googleLogin];

        }
        default:
            break;
    }
}


#pragma mark 登录

- (void)systemLogin {
    
        
    [[[UIApplication sharedApplication]keyWindow]endEditing:YES];
    // 判断有效性
    if (![self checkInputTextAndSexIsValid]) {
        return;
    }
    
    NSDictionary * dic = @{
                           SignKeyOfEmail : self.emailTextField.text,
                           SignKeyOfPassword : self.passwordTextField.text
                           };
    
    //数据GA埋点曝光 提交登录事件 ok
    //GA
//    NSDictionary *itemsDic = @{@"screen_group":@"Login/Register",
//                               @"action":@"Login_Confirm",
//    };
//    [OSSVAnalyticsTool analyticsGAEventWithName:@"login_action" parameters:itemsDic];

    @weakify(self)
    [self.viewModel requestLoginNetwork:dic completion:^(id obj, NSString *msg){
        @strongify(self)
        if ([OSSVAccountsManager sharedManager].isSignIn) {
            //归集数据
            @weakify(self)
            [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:nil showView:self.view Completion:^(id obj) {
                ///会导致重复请求
//                [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Login object:nil];
            } failure:^(id obj) {
                NSLog(@"faild");
            }];
            
            [self loginState:@"Email" flag:YES message:msg];
            
            @strongify(self)
            
            [self dismissViewControllerAnimated:YES completion:^{
                ///登录成功
//                [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"AdoraweFirstInited"];
//                STLPreference.lastLoginEmail = self.emailTextField.text;
                if (self.modalBlock) {
                    self.modalBlock();
                }
            }];
        } else if(obj && STLJudgeNSDictionary(obj)) {
            [self loginState:@"Email" flag:NO message:msg];
            NSDictionary *dic = (NSDictionary *)obj;
            if ([dic[kStatusCode] integerValue] == kStatusCode_203) {
                NSArray *titleUpper = @[STLLocalizedString_(@"cancel",nil).uppercaseString,STLLocalizedString_(@"confirm",nil).uppercaseString];
                NSArray *titleLower = @[STLLocalizedString_(@"cancel",nil),STLLocalizedString_(@"confirm",nil)];
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:STLLocalizedString_(@"Login_No_Register_Tip", nil) buttonTitles:APP_TYPE == 3 ? titleLower : titleUpper buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    if (index == 1) {
                        ///先注册 注册不成功再切到注册
                        //                        [self selectLoginOrSignUpAction:self.selectSignUpButton];
                        [self signUpAction];
                    }
                }];
                
            }else{/// 从注册快捷登录的
                if (!self.isLoginAction) {
                    self.isLoginAction = true;
                    [self setupStatus:self.isLoginAction];
                }
                [self.passwordTextField setError:msg color:OSSVThemesColors.col_B62B21];
            }
        }
        
    } failure:^(id obj, NSString *msg){
        @strongify(self)
        [self loginState:@"Email" flag:NO message:msg];
        if (!self.isLoginAction) {
            self.isLoginAction = true;
            [self setupStatus:self.isLoginAction];
        }
//        [self.passwordTextField setError:msg color:OSSVThemesColors.col_B62B21];
    }];
}

#pragma mark - Facebook

- (void)faceBookLogin {
    
    //判断欧盟处理
    if ([OSSVAdvsViewsManager sharedManager].isEURequrestSuccess) {
        if ([OSSVAdvsViewsManager sharedManager].isEU && !self.registerProtocolView.isAllSelected) {
            self.currentSignTypes = SignTypesFaceBook;
            [self.registerProtocolView show:self.view];
            return;
        }
    } else {
        self.currentSignTypes = SignTypesFaceBook;
        [self requestCountryCheck:YES];
        return;
    }


    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
//#warning Don't change FBLoginBeHavior,Fixed selection FBSDKLoginBehaviorWeb!!!
    //login.loginBehavior = FBSDKLoginBehaviorNative;

    [login logOut];
    login.authType = FBSDKLoginAuthTypeRerequest;

    @weakify(self)
    [login
     logInWithPermissions: @[@"public_profile", @"email"]
     fromViewController:self
     handler:^(FBSDKLoginManagerLoginResult *result, NSError *error) {
         @strongify(self)
         if (error) {
             NSLog(@"Process error");
         } else if (result.isCancelled) {
             NSLog(@"Cancelled");
         } else {
             
             NSString *tokenString = [FBSDKAccessToken currentAccessToken].tokenString;
             NSLog(@"Logged in");
             FBSDKGraphRequest *request = [[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:@{@"fields": @"id, name, first_name, last_name, picture, gender, email"} tokenString:[FBSDKAccessToken currentAccessToken].tokenString version:@"v2.5" HTTPMethod:FBSDKHTTPMethodGET];
             @weakify(self)
             [request startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                 @strongify(self)
                 if (error != nil) {
                     //                             [self loginFaileWithError:error];
                 } else {
                     NSString *fbid = [result valueForKey:@"id"];
                     [self.viewModel requestCheckFbidNetwork:fbid token:tokenString completion:^(id obj) {
                         
                         
                         NSString *sex= STLToString([result valueForKey:@"gender"]);
                         if ([sex isEqualToString:@"male"]) {
                             sex = @"0";
                         } else {
                             sex = @"1";
                         }

                         NSMutableDictionary *dict = [NSMutableDictionary dictionary];
                         [dict setObject:@"Facebook" forKey:@"type"];
                         [dict setObject:fbid forKey:@"fb_id"];
                         [dict setObject:[OSSVNSStringTool isEmptyString:sex] ? @"" : sex forKey:@"sex"];
                         [dict setObject:STLToString(tokenString) forKey:@"thirdtoken"];
                         [dict setObject:STLToString([result valueForKey:@"name"]) forKey:@"nickname"];
                         
                         NSDictionary *picDic = result[@"picture"];
                         if (STLJudgeNSDictionary(picDic)) {
                             if (STLJudgeNSDictionary(picDic[@"data"])) {
                                 NSString *imgUrl = picDic[@"data"][@"url"];
                                 [dict setObject:STLToString(imgUrl) forKey:@"avatar"];
                             }
                         }
                         
                         NSString *email = [result valueForKey:@"email"];
                         
                         // 后台返回邮箱为空，如授权返回邮箱也为空，弹窗输入
                         if (STLIsEmptyString(obj) && STLIsEmptyString(email)) {
                             
                             STLAlertViewController *alertController =  [STLAlertViewController
                                                                    alertControllerWithTitle: STLLocalizedString_(@"confirmEmail", nil)
                                                                    message:STLLocalizedString_(@"inputEmail", nil)
                                                                    preferredStyle:UIAlertControllerStyleAlert];
                             [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField){
                                 textField.placeholder = STLLocalizedString_(@"signPlaceholderEmail", nil);
                                 [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange:) name:UITextFieldTextDidChangeNotification object:textField];

                             }];
                             UIAlertAction * cancelAction = [UIAlertAction actionWithTitle: APP_TYPE == 3 ? STLLocalizedString_(@"cancel",nil) : STLLocalizedString_(@"cancel",nil).uppercaseString style:UIAlertActionStyleCancel handler:^(UIAlertAction * action) {

                             }];
                             UIAlertAction * confirmAction = [UIAlertAction actionWithTitle: APP_TYPE == 3 ? STLLocalizedString_(@"confirm",nil) : STLLocalizedString_(@"confirm",nil).uppercaseString style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
                                 
                                 NSString *email = alertController.textFields.firstObject.text;
                                 [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
                                 [dict setObject:email forKey:@"email"];
                                 [self apiloginInfo:dict fbManager:login google:NO failureDismiss:NO isAppleSignIn:NO];

                             }];
                             confirmAction.enabled = NO;
                             [alertController addAction:cancelAction];
                             [alertController addAction:confirmAction];
                             [self presentViewController:alertController animated:YES completion:nil];
                         } else {
                             
                             //后台返回邮箱不为空，用后台返回邮箱
                             if (!STLIsEmptyString(obj)) {
                                 email = obj;
                             }
                             
                             [dict setObject:STLToString(email) forKey:@"email"];
                             [self apiloginInfo:dict fbManager:login google:NO failureDismiss:YES isAppleSignIn:NO];
                             
                         }
                     } failure:^(id obj) {

                     }];
                     [FBSDKAccessToken setCurrentAccessToken:nil];
                     [FBSDKProfile setCurrentProfile:nil];
                 }
             }];

         }
     }];
}


#pragma mark - Google

- (void)googleLogin {
    
    //判断欧盟处理
    if ([OSSVAdvsViewsManager sharedManager].isEURequrestSuccess) {
        if ([OSSVAdvsViewsManager sharedManager].isEU && !self.registerProtocolView.isAllSelected) {
            self.currentSignTypes = SignTypesGoogle;
            [self.registerProtocolView show:self.view];
            return;
        }
    } else {
        self.currentSignTypes = SignTypesGoogle;
        [self requestCountryCheck:YES];
        return;
    }
    
    
    [GIDSignIn sharedInstance].delegate = self;
    [GIDSignIn sharedInstance].presentingViewController = self;
    [GIDSignIn sharedInstance].shouldFetchBasicProfile = YES;
    [[GIDSignIn sharedInstance] signOut];
    
    // Automatically sign in the user.
//    [[GIDSignIn sharedInstance] restorePreviousSignIn];
    [[GIDSignIn sharedInstance] signIn];
    
    [[NSNotificationCenter defaultCenter]
    addObserver:self
       selector:@selector(receiveToggleAuthUINotification:)
           name:@"ToggleAuthUINotification"
         object:nil];

}

// 实现代理方法
- (void)signIn:(GIDSignIn *)signIn didSignInForUser:(GIDGoogleUser *)user withError:(NSError *)error {
    
    if (!error) {
        STLLog(@"用户ID：%@", user.userID);
        
        GIDAuthentication *authentication = user.authentication;
        GIDProfileData *profileData = user.profile;
        NSString *sex;// = [result valueForKey:@"gender"];
        ///始终为女性
        sex = @"1";
        
        

        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:@"Google" forKey:@"type"];
        [dict setObject:STLToString(profileData.email) forKey:@"email"];
        [dict setObject:STLToString(sex) forKey:@"sex"];
        [dict setObject:STLToString(profileData.name) forKey:@"nickname"];
        [dict setObject:STLToString(authentication.idToken) forKey:@"thirdtoken"];

        if (profileData.hasImage) {
            NSURL *url = [profileData imageURLWithDimension:80];
            [dict setObject:STLToString(url.absoluteString) forKey:@"avatar"];
        }
        
        [self apiloginInfo:dict fbManager:nil google:YES failureDismiss:YES isAppleSignIn:NO];
        
    } else {
        STLLog(@"%@", error.debugDescription);
    }
}

#pragma mark - Apple
- (void)appleLogin {
    
    //判断欧盟处理
    if ([OSSVAdvsViewsManager sharedManager].isEURequrestSuccess) {
        if ([OSSVAdvsViewsManager sharedManager].isEU && !self.registerProtocolView.isAllSelected) {
            self.currentSignTypes = SignTypesApple;
            [self.registerProtocolView show:self.view];
            return;
        }
    } else {
        self.currentSignTypes = SignTypesApple;
        [self requestCountryCheck:YES];
        return;
    }
    
    [self handleAuthrization:nil];
}


#pragma mark - 注册请求信息------第三方登录

- (void)apiloginInfo:(NSDictionary *)dic fbManager:(FBSDKLoginManager *)fbLoginManager google:(BOOL)google  failureDismiss:(BOOL)failureDismiss isAppleSignIn:(BOOL)isAppleSignIn{
    
    @weakify(self)
    [self.viewModel requestApiloginNetwork:dic completion:^(id obj, NSString * isNew, NSString *msg) {

        if ([obj boolValue]) {
            @strongify(self)
            
            if ([OSSVAccountsManager sharedManager].isSignIn) {
                
                NSDictionary *tipDic = [OSSVAccountsManager sharedManager].account.tipDic;
                NSString *couponContent = STLToString(tipDic[@"register_coupon_recevied"]);
                //开启手机绑定
                NSNumber *bindPhone = [NSNumber numberWithInteger:[OSSVAccountsManager sharedManager].account.bindPhoneAvailable];
                BOOL needBindCellPhone = [bindPhone boolValue] && !isAppleSignIn && false;

                //是否为新用户 1：是
                if (!STLIsEmptyString(isNew) && [isNew isEqualToString:@"1"]) {
                    //是否需要绑定手机号，  老用户不会去绑定手机号
                    if (needBindCellPhone) {
                        ///传递到绑定手机号码
                        STLBindCellNumViewController *bindViewController = [[STLBindCellNumViewController alloc] init];
                        bindViewController.couponContent = couponContent;
                        bindViewController.closeBlock = ^{
                            ///注册成功
                            if (self.modalBlock) {
                                self.modalBlock();
                            }
                        };
                        bindViewController.isModalPresent = YES;
//                        bindViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                        
                        [self dismissViewControllerAnimated:NO completion:^{
                            if (couponContent.length) {
                                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [HUDManager showHUDWithMessage:couponContent];
                                });

                            }
                            [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:bindViewController animated:YES completion:nil];
                        }];
                        
                    } else {
                        if (couponContent.length) {
                            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                    [HUDManager showHUDWithMessage:couponContent];
                            });

                        }
                    }

                    //数据GA埋点曝光 提交注册事件
                    //GA
//                    NSDictionary *itemsDic = @{@"screen_group":@"Login/Register",
//                                               @"action":@"Register_Confirm",
//                    };
//
//                    [OSSVAnalyticsTool analyticsGAEventWithName:@"register_action" parameters:itemsDic];
                    
                    //谷歌统计
                    [self analyticsRegister:STLToString(dic[@"type"]) flag:YES message:msg];
                    
                } else {
                    
                    //数据GA埋点曝光 提交登录事件 ok
                    //GA
//                    NSDictionary *itemsDic = @{@"screen_group":@"Login/Register",
//                                               @"action":@"Login_Confirm",
//                    };
//                    [OSSVAnalyticsTool analyticsGAEventWithName:@"login_action" parameters:itemsDic];
                }
                
                [OSSVAccountsManager sharedManager].shareSourceUid = @"";

                //归集数据
                @weakify(self)
                [[OSSVCartsOperateManager sharedManager] cartSyncServiceDataGoods:nil showView:self.view Completion:^(id obj) {
                    if (fbLoginManager) {
                        [fbLoginManager logOut];
                    } else if(google) {
                        [[GIDSignIn sharedInstance] signOut];
                    }
                    [self loginState:STLToString(dic[@"type"]) flag:YES message:msg];

                    @strongify(self)
                    [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Login object:nil];
                    //老用户，或者 不需要绑定手机号
                    if ((!STLIsEmptyString(isNew) && ![isNew isEqualToString:@"1"]) || !needBindCellPhone) {
                        [self dismissViewControllerAnimated:YES completion:^{
                            ///登录成功
    //                        STLPreference.lastLoginEmail = self.emailTextField.text;
    //                        [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"AdoraweFirstInited"];
                            if (self.modalBlock) {
                                self.modalBlock();
                            }
                        }];
                    }

                } failure:^(id obj) {

                    if (failureDismiss) {
                        if (fbLoginManager) {
                            [fbLoginManager logOut];
                        } else if(google) {
                            [[GIDSignIn sharedInstance] signOut];
                        }
                        [self loginState:STLToString(dic[@"type"]) flag:YES message:msg];

                        @strongify(self)
                        if ((!STLIsEmptyString(isNew) && ![isNew isEqualToString:@"1"]) || !needBindCellPhone) {
                            [self dismissViewControllerAnimated:YES completion:^{
                                if (self.modalBlock) {
                                    self.modalBlock();
                                }
                            }];
                        }
                    }
                }];
            }
        }
    } failure:^(id obj, NSString *msg) {
        
        //数据GA埋点曝光 提交注册事件
        //GA
//        NSDictionary *itemsDic = @{@"screen_group":@"Login/Register",
//                                   @"action":@"Register_Confirm",
//        };
//
//        [OSSVAnalyticsTool analyticsGAEventWithName:@"register_action" parameters:itemsDic];
        
        [self loginState:STLToString(dic[@"type"]) flag:NO message:msg];

    }];
}

- (void) receiveToggleAuthUINotification:(NSNotification *) notification {
  if ([notification.name isEqualToString:@"ToggleAuthUINotification"]) {

  }
}

- (void)alertTextFieldDidChange:(NSNotification *)notification{
    STLAlertViewController *alertController = (STLAlertViewController *)self.presentedViewController;
    if (alertController) {
        NSString *email = alertController.textFields.firstObject.text;
        UIAlertAction *confirmAction = alertController.actions.lastObject;
        confirmAction.enabled = [OSSVNSStringTool isValidEmailString:email];
    }
}


#pragma mark 注册操作
- (void)signUpAction {
        
    [[[UIApplication sharedApplication]keyWindow]endEditing:YES];
    // 判断有效性
    if (![self checkInputTextAndSexIsValid]) {
        return;
    }
    
    
    //判断欧盟处理
    self.currentSignTypes = SignTypesSystem;
    if ([OSSVAdvsViewsManager sharedManager].isEURequrestSuccess) {
        if ([OSSVAdvsViewsManager sharedManager].isEU && !self.registerProtocolView.isAllSelected) {
            [self.registerProtocolView show:self.view];
            return;
        }
    } else {
        
        [[STLNetworkStateManager sharedManager] networkState:^{
            [self requestCountryCheck:YES];
        } exception:^{
            [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
        }];
        return;
    }
    
    
    
    ///<self.sexString = 1 默认设置为女性，后台只做女性分支
    NSDictionary * dic = nil;
    NSString *shareUserId = [[NSUserDefaults standardUserDefaults] objectForKey:ONELINK_SHAREUSERID];
    if (![OSSVNSStringTool isEmptyString:shareUserId]) {
        NSInteger time = [[NSUserDefaults standardUserDefaults] integerForKey:SAVE_ONELINK_PARMATERS_TIME];
        NSString *shareTime = [NSString stringWithFormat:@"%li",(long)time];
        dic = @{
                               SignKeyOfEmail        :self.emailTextField.text,
                               SignKeyOfPassword     :self.passwordTextField.text,
                               SignKeyOfSex          :@"",
                               SignKeyOfShareUserId  :shareUserId,
                               SignKeyOfShareTime    :shareTime,
                               SignKeyOfSubscribe : self.subscribeCheck.isSelected ? @"1" : @"0"
                               };
    }else{
        dic = @{
                               SignKeyOfEmail        :self.emailTextField.text,
                               SignKeyOfPassword     :self.passwordTextField.text,
                               SignKeyOfSex          :@"",
                               SignKeyOfSubscribe : self.subscribeCheck.isSelected ? @"1" : @"0"
                               };
    }
    
    //数据GA埋点曝光 提交注册事件 ok
    //GA
//    NSDictionary *itemsDic = @{@"screen_group":@"Login/Register",
//                               @"action":@"Register_Confirm",
//    };
//    [OSSVAnalyticsTool analyticsGAEventWithName:@"register_action" parameters:itemsDic];
    
     @weakify(self)
    [self.viewModel requestRegisterNetwork:dic completion:^(id obj, NSString *msg){
         @strongify(self)
        
        if ([OSSVAccountsManager sharedManager].isSignIn) {
            
            [self loginState:@"Email" flag:YES message:msg];
            [self analyticsRegister:@"Email" flag:YES message:msg];
            
            [OSSVAccountsManager sharedManager].shareSourceUid = @"";
            NSDictionary *tipDic = [OSSVAccountsManager sharedManager].account.tipDic;
            
            NSString *couponContent = STLToString(tipDic[@"register_coupon_recevied"]);
            NSNumber *bindPhone = [NSNumber numberWithInteger:[OSSVAccountsManager sharedManager].account.bindPhoneAvailable];
            ///1.3.6 添加开关
            BOOL needBindCellPhone = [bindPhone boolValue] && false;

            if (needBindCellPhone && !self.isCheckOutIn) {
                ///传递到绑定手机号码
                STLBindCellNumViewController *bindViewController = [[STLBindCellNumViewController alloc] init];
                bindViewController.couponContent = couponContent;
                bindViewController.closeBlock = ^{
                    ///注册成功 重复了
//                    if (self.modalBlock) {
//                        self.modalBlock();
//                    }
//                    if (self.signUpBlock) {
//                        self.signUpBlock();
//                    }

                };
                bindViewController.isModalPresent = YES;
//                bindViewController.modalPresentationStyle = UIModalPresentationFullScreen;
                
                [self dismissViewControllerAnimated:NO completion:^{
                    if (self.modalBlock) {
                        self.modalBlock();
                    }
                    if (self.signUpBlock) {
                        self.signUpBlock();
                    }
                    
                    if (couponContent.length) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [HUDManager showHUDWithMessage:couponContent];
                        });
                    }
                    
                    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:bindViewController animated:YES completion:nil];
                }];
                

            }else{
                [self dismissViewControllerAnimated:YES completion:^{
                    if (self.modalBlock) {
                        self.modalBlock();
                    }
                    if (self.signUpBlock) {
                        self.signUpBlock();
                    }
                    
                    if (couponContent.length) {
                        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        [HUDManager showHUDWithMessage:couponContent];
                        });
                    }
                }];
            }
           
        } else if(obj && STLJudgeNSDictionary(obj)) {
            [self analyticsRegister:@"Email" flag:NO message:msg];
            NSDictionary *dic = (NSDictionary *)obj;
            if ([dic[kStatusCode] integerValue] == kStatusCode_204) {
                
                NSArray *titlesUpper = @[STLLocalizedString_(@"Login_cancel",nil).uppercaseString,STLLocalizedString_(@"Login_In_Now",nil).uppercaseString];
                NSArray *titlesLower = @[STLLocalizedString_(@"Login_cancel",nil),STLLocalizedString_(@"Login_In_Now",nil)];
                [OSSVAlertsViewNew showAlertWithAlertType:STLAlertTypeButton isVertical:YES messageAlignment:NSTextAlignmentCenter isAr:NO showHeightIndex:1 title:@"" message:STLLocalizedString_(@"Registered_To_Login_Tip", nil) buttonTitles:APP_TYPE == 3 ? titlesLower : titlesUpper buttonBlock:^(NSInteger index, NSString * _Nonnull title) {
                    if (index == 1) {
                        ///先登录 不成功再 切换到注册
                        [self systemLogin];
                        //                        [self selectLoginOrSignUpAction:self.selectLoginButton];
                    }
                }];
            }else{
                if (self.isLoginAction) {
                    self.isLoginAction = false;
                    [self setupStatus:self.isLoginAction];
                }
            }
        }
       
    } failure:^(id obj, NSString *msg){
        @strongify(self)
        [self analyticsRegister:@"Email" flag:NO message:msg];

    }];
    
}

- (void)analyticsRegister:(NSString *)method flag:(BOOL)flag message:(NSString *)message {
    
    NSDictionary *sensorData = @{@"email":STLToString([OSSVAccountsManager sharedManager].account.email),
                                 @"register_method":[STLToString(method) lowercaseString],
                                    @"upper_id":flag ? STLToString([OSSVAccountsManager sharedManager].shareSourceUid) : @"",
                                 @"is_success":@(flag)};
    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"RegisterResult" parameters:sensorData];
    
    [GATools logSignInSignUpWithEventName:flag ? @"register" : @"register_failed"];
    
    if (flag) {
        [OSSVAnalyticsTool appsFlyerRegister:@{@"af_param_user_id":STLToString(USERID_STRING)}];
        
        [OSSVAnalyticsTool analyticsGAEventWithName:@"sign_up" parameters:@{@"method":STLToString(method)}];
        
        [OSSVBrancshToolss logCompleteRegistration:sensorData];
        
        [DotApi signUp];
    }
}

- (void)analyticsLogin:(NSString *)method flag:(BOOL)flag message:(NSString *)message {
    
    if (flag) {
        [OSSVAnalyticsTool appsFlyerLogin:nil];
        [OSSVAnalyticsTool analyticsGAEventWithName:@"login" parameters:@{@"method":STLToString(method)}];
    }

    [OSSVAnalyticsTool analyticsSensorsEventWithName:@"LoginResult" parameters:@{@"email":STLToString([OSSVAccountsManager sharedManager].account.email),
                                                                            @"login_method":[STLToString(method) lowercaseString],
                                                                            @"is_success":@(flag)}
     ];
    
    [DotApi signIn];
    
    //数据GA埋点曝光 登录事件
    //GA
//    NSDictionary *itemsDic = @{@"screen_group":@"Login/Register",
//                               @"status":flag ? @"Success" : @"Fail",
//    };
//
//    [OSSVAnalyticsTool analyticsGAEventWithName:@"login" parameters:itemsDic];
    
    [GATools logSignInSignUpWithEventName:flag ? @"login" : @"login_failed"];
}


#pragma mark 进入条约
- (void)dealWithTreatyLinkAction:(STLTreatyLinkAction)actionType {
    if (actionType == TreatyLinkAction_ProvacyPolicy) {
        [self goToPrivacyPolicyAction];
    } else if(actionType == TreatyLinkAction_TermsUse) {
        [self goToTermsOfProtectionAction];
    }
}

- (void)goToPrivacyPolicyAction {
    
    STLWKWebCtrl *webVc = [[STLWKWebCtrl alloc]init];
    webVc.urlType = SystemURLTypePrivacyPolicy;
    webVc.isPresentVC = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVc];
    [self presentViewController:nav animated:YES completion:nil];
}

- (void)goToTermsOfProtectionAction {
    
    STLWKWebCtrl *webVc = [[STLWKWebCtrl alloc]init];
    webVc.urlType = SystemURLTypeTermsOfUs;
    webVc.isPresentVC = YES;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:webVc];
    [self presentViewController:nav animated:YES completion:nil];
}

#pragma mark 登录成功
- (void)loginState:(NSString *)method flag:(BOOL)flag message:(NSString *)message{
    
    [OSSVAnalyticsTool sensorsDynamicConfigure];
    [self analyticsLogin:method flag:flag message:message];

    if (flag) {
        
        if ([OSSVAccountsManager sharedManager].isSignIn) {
            
            [AppDelegate appsFlyerTracekerCustomerUserID];
        }
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kNotif_Login object:nil];
        
        if (self.signBlock) {
            self.signBlock();
        }
        
        [[SensorsAnalyticsSDK sharedInstance] login:USERID_STRING];
        [OSSVAnalyticsTool analyticsGASetUserID:USERID_STRING];

        [self getCountryList];
    }
}

//获取国家列表，目的是用于地址页面中，地址关联搜索的默认国家code
- (void)getCountryList {
    @weakify(self)
    [self.bindPhoneViewModel requestInfo:^(STLBindCountryResultModel *  _Nonnull obj, NSString * _Nonnull msg) {
        @strongify(self)
        [self afterInfoGot:obj];
    } failure:^(id  _Nonnull obj, NSString * _Nonnull msg) {
        
    }];

}
- (void)afterInfoGot:(STLBindCountryResultModel *)obj{
    for (STLBindCountryModel* country in obj.countries) {
        if ([country.countryId isEqualToString:obj.default_country_id]) {
            [[NSUserDefaults standardUserDefaults] setValue:STLToString(country.country_code) forKey:kDefaultCountryCode];
            [[NSUserDefaults standardUserDefaults] setValue:STLToString(country.code) forKey:kDefaultCountryPhoneCode];
            [[NSUserDefaults standardUserDefaults] setValue:STLToString(country.picture) forKey:kDefaultCountryPicUrl];

            [[NSUserDefaults standardUserDefaults] synchronize];
            self.countryModel = country;
        }
    }
}

#pragma mark - input text delegate
-(void)textFieldDidEndEditing:(DetailTextField *)detailField filed:(UITextField *)field{
//    [detailField clearError];
    if (detailField == self.emailTextField) {
        [self checkEmail];
    }
    if (detailField == self.passwordTextField) {
        [self checkpassword];
    }
}


-(BOOL)textFieldShouldReturn:(DetailTextField *)detailField filed:(UITextField *)field{
    [field resignFirstResponder];
    // 仅仅登录的时候添加
    if(detailField == self.passwordTextField) {
        if (self.isLoginAction) {
            [self loginAction:nil];
        }else{
            [self signUpAction];
        }
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(DetailTextField *)detailField filed:(UITextField *)field{
    [detailField clearError];
}


-(BOOL)textField:(UITextField *)textField detailText:(DetailTextField *)detailField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    // MAX Length = 30 为了解决联想带来的问题，此处已经通过 UITextField 的分类解决啦
    if (textField.text.length + string.length > kInputTextFieldMaxLength) {
        return NO;
    }
    return YES;
}


#pragma mark - STLRegisterProtocolViewDelegate

- (void)registerProtocol:(STLRegisterProtocolView *)protocolView event:(RegisterProtocolEvent)event {
    
    if (event == RegisterProtocolEventTerm) {
        [self goToTermsOfProtectionAction];
        
    } else if(event == RegisterProtocolEventPolicy) {
        [self goToPrivacyPolicyAction];
        
    } else if(event == RegisterProtocolEventSure) {
        if (self.currentSignTypes == SignTypesFaceBook) {
            [self faceBookLogin];
        } else if (self.currentSignTypes == SignTypesGoogle) {
            [self googleLogin];
        } else if (self.currentSignTypes == SignTypesApple) {
            [self appleLogin];
        }
        else {
            [self signUpAction];
        }
    }
}


#pragma mark - 点击授权按钮

- (void)handleAuthrization:(UIButton *)sender {
    if (@available(iOS 13.0, *)) {
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        // 创建新的AppleID 授权请求
        ASAuthorizationAppleIDRequest *request = appleIDProvider.createRequest;
        // 在用户授权期间请求的联系信息
        request.requestedScopes = @[ASAuthorizationScopeFullName, ASAuthorizationScopeEmail];
        // 由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *controller = [[ASAuthorizationController alloc] initWithAuthorizationRequests:@[request]];
        // 设置授权控制器通知授权请求的成功与失败的代理
        controller.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        controller.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [controller performRequests];
    }
}

#pragma mark - 授权成功地回调

//user: 001963.27e48e27b0e5853a7c5d744d9a1c5432.0701
// familyName: XX
//givenName: XX
//email: 你的邮箱

//🌶🌶🌶🌶🌶🌶
//授权信息里的用户信息（email、NSPersonNameComponents对象所有属性）当且仅当第一次授权时才会返回,之后就算 停止使用 Apple ID 再重新授权都不会返回用户信息
//🌶🌶🌶🌶🌶🌶

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithAuthorization:(ASAuthorization *)authorization  API_AVAILABLE(ios(13.0)) {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"%@", controller);
    NSLog(@"%@", authorization);
    NSLog(@"authorization.credential：%@", authorization.credential);
    NSMutableString *mutableString = [NSMutableString string];
    
    NSString *sex = @"1";
    NSString *type = @"Apple";
    NSString *appleId = @"";
    NSString *nickname = @"";
    NSString *email = @"";
    NSString *identityToken = @"";


    BOOL isFlage = YES;
    if ([authorization.credential isKindOfClass:[ASAuthorizationAppleIDCredential class]]) {
        // 用户登录使用ASAuthorizationAppleIDCredential
        ASAuthorizationAppleIDCredential *appleIDCredential = authorization.credential;
        
        // 苹果用户唯一标识符，该值在同一个开发者账号下的所有 App 下是一样的，开发者可以用该唯一标识符与自己后台系统的账号体系绑定起来。
        NSString *user = appleIDCredential.user;
        appleId = [NSString stringWithFormat:@"%@",user];
        nickname = appleIDCredential.fullName.familyName;
        email = appleIDCredential.email;
        
        // 服务器验证需要使用的参数
        NSString * authorizationCode = [[NSString alloc] initWithData:appleIDCredential.authorizationCode encoding:NSUTF8StringEncoding];
        identityToken = [[NSString alloc] initWithData:appleIDCredential.identityToken encoding:NSUTF8StringEncoding];
        
        
        
        // 使用钥匙串的方式保存用户的唯一信息
        NSString *bundleId = [NSBundle mainBundle].bundleIdentifier;
        [SSKeychain setPassword:user forService:bundleId account:kSTLCurrentAppIdentifier];
        [mutableString appendString:user?:@""];
        NSString *familyName = appleIDCredential.fullName.familyName;
        [mutableString appendString:familyName?:@""];
        NSString *givenName = appleIDCredential.fullName.givenName;
        [mutableString appendString:givenName?:@""];
        NSString *email = appleIDCredential.email;
        [mutableString appendString:email?:@""];
        STLLog(@"mStr：%@   \n%@\n%@", mutableString,authorizationCode,identityToken);
        [mutableString appendString:@"\n"];
        
    } else if ([authorization.credential isKindOfClass:[ASPasswordCredential class]]) {
        
        // 用户登录使用现有的密码凭证
        ASPasswordCredential *passwordCredential = authorization.credential;
        // 密码凭证对象的用户标识 用户的唯一标识
        NSString *user = passwordCredential.user;
        appleId = [NSString stringWithFormat:@"%@",user];
        
        // 密码凭证对象的密码
        NSString *password = passwordCredential.password;
        [mutableString appendString:user?:@""];
        [mutableString appendString:password?:@""];
        [mutableString appendString:@"\n"];
        STLLog(@"mStr：%@", mutableString);

    } else {
        STLLog(@"授权信息均不符");
        ShowToastToViewWithText(self.view, @"The authorization information does not match");
        
        isFlage = NO;
    }
    
    if (isFlage) {
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setObject:type forKey:@"type"];
        [dict setObject:appleId forKey:@"ios_id"];
        [dict setObject:STLToString(sex) forKey:@"sex"];
        [dict setObject:STLToString(nickname) forKey:@"nickname"];
        [dict setObject:STLToString(email) forKey:@"email"];
        [dict setObject:STLToString(identityToken) forKey:@"thirdtoken"];

        [self apiloginInfo:dict fbManager:nil google:NO failureDismiss:YES isAppleSignIn:YES];
    }
}

#pragma mark  授权失败的回调

- (void)authorizationController:(ASAuthorizationController *)controller didCompleteWithError:(NSError *)error  API_AVAILABLE(ios(13.0)) {
    NSLog(@"%s", __FUNCTION__);
    NSLog(@"错误信息：%@", error);
    NSString *errorMsg = nil;
    switch (error.code) {
        case ASAuthorizationErrorCanceled:
            errorMsg = @"User canceled authorization request";
            break;
        case ASAuthorizationErrorFailed:
            errorMsg = @"Authorization request failed";
            break;
        case ASAuthorizationErrorInvalidResponse:
            errorMsg = @"Authorization request response is invalid";
            break;
        case ASAuthorizationErrorNotHandled:
            errorMsg = @"Failed to process authorization request";
            break;
        case ASAuthorizationErrorUnknown:
            errorMsg = @"Unknown reason for authorization request failure";
            break;
    }
    NSMutableString *mStr = [[NSMutableString alloc] init];
    [mStr appendString:errorMsg];
    [mStr appendString:@"\n"];
    
    
    if (error.localizedDescription) {
        [mStr appendString:error.localizedDescription];
        [mStr appendString:@"\n"];
    }
    if (!STLIsEmptyString(errorMsg)) {
        ShowToastToViewWithText(self.view, errorMsg);
    }
    STLLog(@"controller requests：%@", controller.authorizationRequests);
}
//
//#pragma mark - 告诉代理应该在哪个window 展示内容给用户
//
- (ASPresentationAnchor)presentationAnchorForAuthorizationController:(ASAuthorizationController *)controller  API_AVAILABLE(ios(13.0)){
    NSLog(@"调用展示window方法：%s", __FUNCTION__);
    // 返回window
    return self.view.window;
}

#pragma mark - 如果存在iCloud Keychain 凭证或者AppleID 凭证提示用户

- (void)perfomExistingAccountSetupFlows {
    if (@available(iOS 13.0, *)) {
        // 基于用户的Apple ID授权用户，生成用户授权请求的一种机制
        ASAuthorizationAppleIDProvider *appleIDProvider = [ASAuthorizationAppleIDProvider new];
        // 授权请求依赖于用于的AppleID
        ASAuthorizationAppleIDRequest *authAppleIDRequest = [appleIDProvider createRequest];
        // 为了执行钥匙串凭证分享生成请求的一种机制
        ASAuthorizationPasswordRequest *passwordRequest = [[ASAuthorizationPasswordProvider new] createRequest];

        NSMutableArray <ASAuthorizationRequest *>* mArr = [NSMutableArray arrayWithCapacity:2];
        if (authAppleIDRequest) {
            [mArr addObject:authAppleIDRequest];
        }
        if (passwordRequest) {
            [mArr addObject:passwordRequest];
        }
        // ASAuthorizationRequest：对于不同种类授权请求的基类
        NSArray <ASAuthorizationRequest *>* requests = [mArr copy];
        // ASAuthorizationController是由ASAuthorizationAppleIDProvider创建的授权请求 管理授权请求的控制器
        ASAuthorizationController *authorizationController = [[ASAuthorizationController alloc] initWithAuthorizationRequests:requests];
        // 设置授权控制器通知授权请求的成功与失败的代理
        authorizationController.delegate = self;
        // 设置提供 展示上下文的代理，在这个上下文中 系统可以展示授权界面给用户
        authorizationController.presentationContextProvider = self;
        // 在控制器初始化期间启动授权流
        [authorizationController performRequests];
    }
}

#pragma mark- Private Method
#pragma mark 验证弹出框
- (void)showHUDWithErrorText:(NSString *)text {
    [HUDManager showHUDWithMessage:STLLocalizedString_(text, nil) customView:[[YYAnimatedImageView alloc] initWithImage:[UIImage imageNamed:@"prompt"]]];
    
}


- (BOOL)checkInputTextAndSexIsValid {
    if (![self checkEmail]) {
        return NO;
    }
    if (![self checkpassword]) {
        return NO;
    }
    return YES;
}

-(BOOL)checkEmail{
    [self.emailTextField clearError];
    
    if ([OSSVNSStringTool isEmptyString:self.emailTextField.text])  {
        [self.emailTextField setError:STLLocalizedString_(@"emailEmptyMsg", nil) color:OSSVThemesColors.col_B62B21];
        return NO;
    }else{
        [self.emailTextField clearError];
    }
    if (![OSSVNSStringTool isValidEmailString:self.emailTextField.text]) {
        [self.emailTextField setError:STLLocalizedString_(@"emailFormatMsg", nil) color:OSSVThemesColors.col_B62B21];
        return NO;
    }else{
        [self.emailTextField clearError];
    }
    return YES;
}

-(BOOL)checkpassword{
    [self.passwordTextField clearError];
    /**
     *  注意此处的提示语已经是国际化啦
     */
   
    if ([OSSVNSStringTool isEmptyString:self.passwordTextField.text]) {
        [self.passwordTextField setError:STLLocalizedString_(@"passwordEmptyMsg", nil) color:OSSVThemesColors.col_B62B21];
        return NO;
    }else{
        [self.passwordTextField clearError];
    }

    // 截取 收尾空格
    self.passwordTextField.text = [OSSVNSStringTool cutLeadAndTrialBlankCharacter:self.passwordTextField.text];

    if (!(self.passwordTextField.text.length > 5)) {
        [self.passwordTextField setError:STLLocalizedString_(@"passwordMinLengthMsg", nil) color:OSSVThemesColors.col_B62B21];
        return NO;
    }else{
        [self.passwordTextField clearError];
    }
    if ((self.passwordTextField.text.length > kInputTextFieldMaxLength)) {
        [self.passwordTextField setError:STLLocalizedString_(@"passwordMaxLengthMsg", nil) color:OSSVThemesColors.col_B62B21];
        return NO;
    }else{
        [self.passwordTextField clearError];
    }
    return YES;
}

-(void)switchLoginSingUp{
    self.isLoginAction = !self.isLoginAction;
//    NSUserDefaults
    NSString *lastEmail = [[NSUserDefaults standardUserDefaults] valueForKey:kUserEmail];
    self.emailTextField.text = self.isLoginAction ? STLToString(lastEmail) : @"";
    [self setupStatus:self.isLoginAction];
    [self.emailTextField clearError];
    [self.passwordTextField clearError];
    [GATools logSignInSignUpActionWithEventName:@"register_login_action" action:[NSString stringWithFormat:@"Select_%@",self.isLoginAction ? @"SIGN IN" : @"SIGN UP"]];
}

///展示login / sign up
-(void)setupStatus:(BOOL)islogin{
    NSString *switchBtnTitle = !islogin ? @"sws_login" : @"sws_signup";
    [_switchSignUpLoginBtn setTitle:STLLocalizedString_(switchBtnTitle, nil).uppercaseString forState:UIControlStateNormal];
    NSString *titleText = islogin ? @"login_welcom" : @"sign_up_create";
    _boldTitleLable.text = STLLocalizedString_(titleText, nil);
    if (APP_TYPE == 3) {
        NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString:_boldTitleLable.text];
        [attString addAttribute:NSFontAttributeName value:[UIFont vivaiaSemiBoldFont:24] range:NSMakeRange(0, _boldTitleLable.text.length - 7)];
        [attString addAttribute:NSFontAttributeName value:[UIFont vivaiaBoldItalicFont:24] range:NSMakeRange(_boldTitleLable.text.length - 7, 7)];
        _boldTitleLable.attributedText = attString;
    }
    
    NSString *userTip =  [STLPushManager sharedInstance].tip_user_page_text;
    if (!STLIsEmptyString(userTip) && !islogin) {
        _adView.titleLabel.text = userTip;
        _adView.hidden = NO;
    }else{
        _adView.hidden = YES;
    }
    
    _forgotPwdButton.hidden = !islogin;
    [_forgotPwdButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(islogin ? 16 : 0);
        make.top.mas_equalTo(self.signUpOptions.mas_bottom).offset(islogin ? 6 : -6);
    }];
    
    for (UIView *view in self.signUpOptions.subviews) {
        view.hidden = islogin;
    }
    NSString *actionButtonTitle = islogin ? @"sws_login" : @"sws_signup";
    if (APP_TYPE == 3) {
        [_signUpOrSignInButtion setTitle:STLLocalizedString_(actionButtonTitle, nil) forState:UIControlStateNormal];

    } else {
        [_signUpOrSignInButtion setTitle:STLLocalizedString_(actionButtonTitle, nil).uppercaseString forState:UIControlStateNormal];
    }
//    NSString *thirdLogInText = islogin ? @"sign_in_with" : @"sign_up_with";
    self.loginFooterView.textTitleTipText = [NSString stringWithFormat:@"- %@ -",STLLocalizedString_(@"sign_in_with", nil)];
}

-(void)signUpOrLoginAction{
    if (self.isLoginAction) {
        [self loginAction:nil];
        [GATools logSignInSignUpActionWithEventName:@"login_action" action:@"Login_Confirm"];
    }else{
        [self signUpAction];
        [GATools logSignInSignUpActionWithEventName:@"register_action" action:@"Register_Confirm"];
    }
}

#pragma mark- MakeUI
#pragma mark Init backViewAndTopView
- (void)initSubViews {
    
    self.cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setImage:[UIImage imageNamed:@"close_sign"] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    switchButton.titleLabel.font = [UIFont boldSystemFontOfSize:15];
    [switchButton setTitleColor:OSSVThemesColors.col_0D0D0D forState:UIControlStateNormal];
    [self.view addSubview:switchButton];
    _switchSignUpLoginBtn = switchButton;
    [switchButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.trailing.mas_equalTo(-24);
    }];
    
    [switchButton addTarget:self action:@selector(switchLoginSingUp) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(60);
        make.width.height.mas_equalTo(30);
        make.leading.mas_equalTo(20);
    }];
    
    UIStackView *titleContainer = [[UIStackView alloc] init];
    titleContainer.axis = UILayoutConstraintAxisVertical;
    titleContainer.alignment = UIStackViewAlignmentLeading;
    [self.view addSubview:titleContainer];
    [titleContainer mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(self.cancelButton.mas_bottom).offset(24);
    }];
    
    UILabel *titleLbl = [[UILabel alloc] init];
    _boldTitleLable = titleLbl;
    titleLbl.font = [UIFont boldSystemFontOfSize:24];
    [titleContainer addSubview:titleLbl];
    [titleLbl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(30);
        make.top.mas_equalTo(titleContainer);
        make.leading.mas_equalTo(0);
    }];
    
    STLRegisterAdvSmallView *registerTipView = [[STLRegisterAdvSmallView alloc] initWithFrame:CGRectZero];
    registerTipView.hidden = YES;
    _adView = registerTipView;
    [titleContainer addSubview:registerTipView];
    [registerTipView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleLbl.mas_bottom).offset(4);
        make.width.mas_lessThanOrEqualTo((SCREEN_WIDTH - 48));
        make.bottom.mas_equalTo(titleContainer);
        make.leading.mas_equalTo(0);
    }];
    
    DetailTextField *emailInputFiled = [[DetailTextField alloc] init];
    _emailTextField = emailInputFiled;
    [self.view addSubview:emailInputFiled];
    [emailInputFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(titleContainer.mas_bottom).offset(37);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
    }];
    emailInputFiled.keyboardType = UIKeyboardTypeEmailAddress;
    emailInputFiled.placeholder = STLLocalizedString_(@"email_field", nil);
    emailInputFiled.deviderColor = OSSVThemesColors.col_CCCCCC;
    emailInputFiled.floatPlaceholderColor = OSSVThemesColors.col_999999;
    emailInputFiled.delegate = self;
    
    DetailTextField *passwordInputFiled = [[DetailTextField alloc] init];
    _passwordTextField = passwordInputFiled;
    [self.view addSubview:passwordInputFiled];
    [passwordInputFiled mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(emailInputFiled.mas_bottom).offset(25);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
    }];
    passwordInputFiled.isPassword = YES;
    passwordInputFiled.placeholder = STLLocalizedString_(@"password_field", nil);
    passwordInputFiled.deviderColor = OSSVThemesColors.col_CCCCCC;
    passwordInputFiled.floatPlaceholderColor = OSSVThemesColors.col_999999;
    passwordInputFiled.delegate = self;
    
    emailInputFiled.delegate = self;
    passwordInputFiled.delegate = self;
    
    
    [self.view addSubview:self.signUpOptions];
    [self.signUpOptions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(passwordInputFiled.mas_bottom).offset(6);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
    }];
    
    
    UIButton *forgotPwd = [UIButton buttonWithType:UIButtonTypeCustom];
    [forgotPwd setTitle:STLLocalizedString_(@"signForgotPasswordTitle", nil) forState:UIControlStateNormal];
    [self.view addSubview:forgotPwd];
    _forgotPwdButton = forgotPwd;
    [forgotPwd setTitleColor:OSSVThemesColors.col_666666 forState:UIControlStateNormal];
    forgotPwd.titleLabel.font = [UIFont systemFontOfSize:13];
    [forgotPwd mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.signUpOptions.mas_bottom).offset(6);
        make.trailing.mas_equalTo(-24);
    }];
    [forgotPwd addTarget:self action:@selector(forgotPassword:) forControlEvents:UIControlEventTouchUpInside];
    
    UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    actionButton.backgroundColor = OSSVThemesColors.col_0D0D0D;
    actionButton.layer.cornerRadius = 2;
    if (APP_TYPE == 3) {
        actionButton.titleLabel.font = [UIFont vivaiaRegularFont:18];
    } else {
        actionButton.titleLabel.font = [UIFont stl_buttonFont:15];
    }
    [actionButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.view addSubview:actionButton];
    [actionButton addTarget:self action:@selector(signUpOrLoginAction) forControlEvents:UIControlEventTouchUpInside];
    _signUpOrSignInButtion = actionButton;
    [actionButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(44);
        make.leading.mas_equalTo(24);
        make.trailing.mas_equalTo(-24);
        make.top.mas_equalTo(forgotPwd.mas_bottom).offset(APP_TYPE == 3 ? 20 : 36);
    }];
    
    ///是否新安装如果是首次安装展示signup 否则展示login
//    BOOL isFirstInit = [NSUserDefaults.standardUserDefaults boolForKey:@"AdoraweFirstInited"];
//    self.isLoginAction = isFirstInit;
    [self setupStatus:false];
    
    
    
    [self.view addSubview:self.loginFooterView];
    CGFloat bottomHeight = kIS_IPHONEX ? 34 : 16;
    [self.loginFooterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(self.view);
//        if (self.isCheckOutIn) {
//            make.top.equalTo(actionButton.mas_bottom).offset(30);
//        }else{
            make.bottom.mas_equalTo(-bottomHeight);
//        }
    }];
//
//    [self.view addSubview:self.checkOutAsGuest];
//    [self.checkOutAsGuest mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.trailing.equalTo(-20);
//        make.leading.equalTo(20);
//        make.bottom.equalTo(self.view.mas_bottomMargin).offset(-40);
//    }];
//    self.checkOutAsGuest.hidden = !self.isCheckOutIn;
}

-(void)forgotPassword:(UIButton *)sender{
    ///忘记密码之前去掉校验
//    if ([OSSVNSStringTool isEmptyString:_emailTextField.text])  {
//        [self.emailTextField setError:STLLocalizedString_(@"emailEmptyMsg", nil) color:OSSVThemesColors.col_B62B21];
//        return;
//    }
//    if (![OSSVNSStringTool isValidEmailString:_emailTextField.text]) {
//        [self.emailTextField setError:STLLocalizedString_(@"emailFormatMsg", nil) color:OSSVThemesColors.col_B62B21];
//        return;
//    }
    
    STLResetpasswordViewController *resetPwd = [[STLResetpasswordViewController alloc] init];
    resetPwd.modalPresentationStyle = UIModalPresentationFullScreen;
    resetPwd.emailStr = _emailTextField.text;
    [self presentViewController:resetPwd animated:YES completion:nil];
    [GATools logSignInSignUpActionWithEventName:@"login_action" action:@"Forgot_Password"];
}

#pragma mark - 添加苹果登录的状态通知

- (void)observeAppleSignInState {
//    if (@available(iOS 13.0, *)) {
//        NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
//        [center addObserver:self selector:@selector(handleSignInWithAppleStateChanged:) name:ASAuthorizationAppleIDProviderCredentialRevokedNotification object:nil];
//    }
}

#pragma mark - 观察SignInWithApple状态改变

- (void)handleSignInWithAppleStateChanged:(NSNotification *) noti {
    NSLog(@"%@", noti.name);
    NSLog(@"%@", noti.userInfo);
}

#pragma mark - Custom makeView
- (UIButton *)makeCustomSelectButtonWithTitle:(NSString *)title {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [button setTitleColor:OSSVThemesColors.col_333333 forState:UIControlStateSelected];
    [button setTitleColor:OSSVThemesColors.col_999999 forState:UIControlStateNormal];
    [button setAdjustsImageWhenHighlighted:NO];
    return button;
}

- (STLTextField *)makeCustomTextFieldWithPlaceholder:(NSString *)placeholder keyboardType:(UIKeyboardType)keyboardType leftIconImage:(UIImage *)iconImage {
    
    // textField LeftView
    YYAnimatedImageView *imageIconView = [[YYAnimatedImageView alloc] init];
    // 设置 左边图标 大小 此处给的图片也是 = CGSize(20,20);
    CGRect rect =  imageIconView.frame;
    rect.size = CGSizeMake(20, 20);
    imageIconView.frame = rect;
    // 设置 左边图标 图片
    imageIconView.image = iconImage;
    
    STLTextField *textField = [[STLTextField alloc] init];
    textField.leftView = imageIconView;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.delegate = self;
    textField.clearButtonMode = UITextFieldViewModeAlways;
    textField.keyboardType = keyboardType;
    textField.returnKeyType = UIReturnKeyDone;
    textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    [textField setAutocorrectionType:UITextAutocorrectionTypeNo];
    // 改变PlaceHolder颜色 和字体
    textField.attributedPlaceholder =
    [[NSAttributedString alloc] initWithString:placeholder
                                    attributes:@{
                                                 NSForegroundColorAttributeName: OSSVThemesColors.col_D1D1D1
//                                                 ,NSFontAttributeName : [UIFont systemFontOfSize:13]
                                                 }
     
     ];
    textField.textAlignment = [OSSVSystemsConfigsUtils isRightToLeftShow] ? NSTextAlignmentRight : NSTextAlignmentLeft;
    textField.textColor = [OSSVThemesColors stlBlackColor];
    
    textField.font = [UIFont systemFontOfSize:13];
    // 增加边框颜色和圆角
    textField.layer.borderColor   = [OSSVThemesColors.col_E1E1E1 CGColor];
    textField.layer.borderWidth   = 1.0;
    textField.layer.cornerRadius  = 4.0;
    textField.layer.masksToBounds = YES;

    return textField;
}

#pragma mark - Lazy
- (SignViewModel *)viewModel {
    
    if(!_viewModel) {
        _viewModel = [[SignViewModel alloc] init];
        _viewModel.controller = self;
    }
    return _viewModel;
}

- (STLRegisterAdvView *)registerAdvView {
    if (!_registerAdvView) {
        _registerAdvView  = [[STLRegisterAdvView alloc] initWithFrame:CGRectZero];
        _registerAdvView.hidden = YES;
    }
    return _registerAdvView;
}


- (UIView *)infoBackView {
    if (!_infoBackView) {
        _infoBackView = [[UIView alloc] init];
        _infoBackView.backgroundColor = [UIColor clearColor];
    }
    return _infoBackView;
}

- (UITextField *)tempGetUIAlertTextField {
    
    if(!_tempGetUIAlertTextField) {
        _tempGetUIAlertTextField = [[UITextField alloc] init];
    }
    return _tempGetUIAlertTextField;
}


- (STLRegisterProtocolView *)registerProtocolView {
    if (!_registerProtocolView) {
        _registerProtocolView = [[STLRegisterProtocolView alloc] initWithFrame:CGRectZero];
        _registerProtocolView.delegate = self;
    }
    return _registerProtocolView;
}

- (STLLoginFooterView *)loginFooterView {
    if (!_loginFooterView) {
        _loginFooterView = [[STLLoginFooterView alloc] init];

        @weakify(self)
        _loginFooterView.googleplusCompletionHandler = ^{
            @strongify(self)
            
            [[STLNetworkStateManager sharedManager] networkState:^{
                [self googleLogin];
            } exception:^{
                [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
            }];
        };
        
        _loginFooterView.facebookCompletionHandler = ^{
            @strongify(self);
            [[STLNetworkStateManager sharedManager] networkState:^{
                [self faceBookLogin];
            } exception:^{
                [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
            }];
        };
        
        _loginFooterView.privacyPolicyActionBlock = ^(STLTreatyLinkAction actionType) {
            @strongify(self);
            [self dealWithTreatyLinkAction:actionType];
        };
        
        _loginFooterView.appleCompletionHandler = ^{
            @strongify(self);
            [[STLNetworkStateManager sharedManager] networkState:^{
                [self appleLogin];
            } exception:^{
                [HUDManager showHUDWithMessage:STLLocalizedString_(@"networkErrorMsg", nil)];
            }];
        };
    }
    return _loginFooterView;
}


-(STLBindPhoneNumViewModel *)bindPhoneViewModel{
    if (!_bindPhoneViewModel) {
        _bindPhoneViewModel = [[STLBindPhoneNumViewModel alloc] init];
    }
    return _bindPhoneViewModel;
}

-(UIStackView *)signUpOptions{
    if (!_signUpOptions) {
        _signUpOptions = [[UIStackView alloc] init];
        _signUpOptions.axis = UILayoutConstraintAxisVertical;
        CheckItemsView *receieveEmail = [[CheckItemsView alloc] initWithFrame:CGRectZero];
        [receieveEmail addTarget:self action:@selector(signUpOptionChecked:) forControlEvents:UIControlEventTouchUpInside];
        receieveEmail.text = STLLocalizedString_(@"receive_adv_emails", nil);
//        CheckItemsView *signUpEmail = [[CheckItemsView alloc] initWithFrame:CGRectZero];
//        [signUpEmail addTarget:self action:@selector(signUpOptionChecked:) forControlEvents:UIControlEventTouchUpInside];
//        signUpEmail.text =  STLLocalizedString_(@"sign_up_for_email_get_exclusive", nil);
        [_signUpOptions addArrangedSubview:receieveEmail];
//        [_signUpOptions addArrangedSubview:signUpEmail];
        
        self.subscribeCheck = receieveEmail;
    }
    return _signUpOptions;
}

-(void)signUpOptionChecked:(CheckItemsView *)chekItem{
    chekItem.selected = !chekItem.selected;
}

- (UIView *)checkOutAsGuest{
    if (!_checkOutAsGuest) {
        _checkOutAsGuest = [[UIView alloc] init];
        _checkOutAsGuest.hidden = true;
        UILabel *lbl = [[UILabel alloc] init];
        lbl.font = FontWithSize(12);
        lbl.text = [NSString stringWithFormat:@"- %@? -",STLLocalizedString_(@"No account", nil)];
        lbl.textColor = OSSVThemesColors.col_666666;
        [_checkOutAsGuest addSubview:lbl];
        [lbl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(_checkOutAsGuest.mas_centerX);
            make.top.equalTo(0);
        }];
        
        UIButton *checkOutBtn = [[UIButton alloc] init];
        [checkOutBtn setTitle:STLLocalizedString_(@"Checkout as a Guest", nil) forState:UIControlStateNormal];
        checkOutBtn.titleLabel.font = [UIFont stl_buttonFont:18];
        [checkOutBtn setTitleColor:OSSVThemesColors.stlBlackColor forState:UIControlStateNormal];
        [_checkOutAsGuest addSubview:checkOutBtn];
        [checkOutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.leading.trailing.equalTo(0);
            make.height.equalTo(48);
            make.top.equalTo(lbl.mas_bottom).offset(10);
            make.bottom.equalTo(_checkOutAsGuest.mas_bottom);
        }];
        checkOutBtn.layer.borderWidth = 2;
        checkOutBtn.layer.borderColor = [OSSVThemesColors col_000000:1].CGColor;
        [checkOutBtn addTarget:self action:@selector(guestCheckOut:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _checkOutAsGuest;
}

-(void)guestCheckOut:(UIButton *)sender{
    [self dismissViewControllerAnimated:true completion:^{
        if (self.guestCheckOutAction) {
            self.guestCheckOutAction();
        }
    }];
}

@end
