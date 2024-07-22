//
//  AccountManager.m
//  Yoshop
//
//  Created by YW on 16/5/31.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import "AccountManager.h"
#import <AVOSCloud/AVOSCloud.h>
#import "FIRMessaging.h"
#import "ZFPushManager.h"
#import "ZFKeychainDataManager.h"
#import "ZFSkinViewModel.h"
#import "ZFThemeManager.h"
#import "ZFLocalizationString.h"
#import "ZFFireBaseAnalytics.h"
#import "ZFAnalytics.h"
#import "ZFGrowingIOAnalytics.h"
#import "ExchangeManager.h"
#import "YWCFunctionTool.h"
#import "ZFCommonRequestManager.h"
#import "Constants.h"
#import <GGAppsflyerAnalyticsSDK/GGAppsflyerAnalytics.h>
#import "ZFBranchAnalytics.h"
#import "NSStringUtils.h"
#import "ZFBTSDataSets.h"
#import <GGBrainKeeper/BrainKeeperManager.h>
#import "ZFZegoHelper.h"
#import "ZFAccountViewModel.h"
#import "ZFCMSCouponManager.h"

@interface AccountManager ()
{
    ZFInitializeModel *_initializeModel;
}
@end

@implementation AccountManager

- (instancetype)init {
    self = [super init];
    if (self) {
        self.af_user_type = @"1";
    }
    return self;
}

+ (AccountManager *)sharedManager {
    static AccountManager *sharedAccountManagerInstance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedAccountManagerInstance = [[self alloc] init];
        [sharedAccountManagerInstance readUserInfo];
        //学生卡开通成功刷新用户数据
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadAccountInfo) name:kUserJoinStudentVipSuccessKey object:nil];
    });
    return sharedAccountManagerInstance;
}

- (void)reloadAccountInfo
{
    //重新刷新用户本地保存信息
    ZFAccountViewModel *viewModel = [[ZFAccountViewModel alloc] init];
    [viewModel requestUserInfoData:^(AccountModel *model) {} failure:nil];
}

- (void)readUserInfo {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]]) {
        
        NSData *data = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        //解档出数据模型
        AccountModel *account = [unarchiver decodeObjectForKey:kDataKey];
        [unarchiver finishDecoding];//一定不要忘记finishDecoding，否则会报错
        self.account = account;
        if (self.account) {
            if (!self.isSignIn) {
                ///登录后统计growingIO
                [Growing setUserId:ZFgrowingToString(self.account.user_id)];
                //用户是否购买
                if (self.account.paid_order_number.integerValue) {
                    [Growing setPeopleVariableWithKey:@"IfUserBuy_ppl" andStringValue:@"YES"];
                }else{
                    [Growing setPeopleVariableWithKey:@"IfUserBuy_ppl" andStringValue:@"NO"];
                }
                //用户注册信息
                [Growing setPeopleVariableWithKey:@"register_ppl" andStringValue:@""];
                //社区用户类型(用户变量)
                [Growing setPeopleVariableWithKey:@"comUserId_ppl" andStringValue:@""];
                //上传国家站信息
                [Growing setPeopleVariableWithKey:@"national_code" andStringValue:ZFToString(GetUserDefault(kLocationInfoPipeline))];
                [Growing setVisitor:@{@"appLanguage" : ZFToString([ZFLocalizationString shareLocalizable].nomarLocalizable),
                                      @"national_code" : ZFToString(GetUserDefault(kLocationInfoPipeline))
                }];
            }
            self.isSignIn = YES;
//            v4.0.0后台没有提供字段，所以先不加
//            //用户注册信息
//            [Growing setPeopleVariableWithKey:@"register_ppl" andStringValue:@""];
//            //社区用户类型(用户变量)
//            [Growing setPeopleVariableWithKey:@"comUserId_ppl" andStringValue:@""];
            // Branch
            [[ZFBranchAnalytics sharedManager] branchLoginWithUserId:self.account.user_id];
        }
    }
    
    NSString *countryModeljson = GetUserDefault(kAccountCountryModelKey);
    if (countryModeljson) {
        self.accountCountryModel = [ZFAddressCountryModel yy_modelWithJSON:countryModeljson];
    }
}

- (void)updateUserAvatar:(NSString *)url {
    if (ZFIsEmptyString(url)) return;
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]]) {
        
        NSData *unData = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:unData];
        //解档出数据模型
        AccountModel *account = [unarchiver decodeObjectForKey:kDataKey];
        //一定不要忘记finishDecoding，否则会报错
        [unarchiver finishDecoding];
        
        account.avatar = url;
        
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:account forKey:kDataKey];
        [archiver finishEncoding];
        
        [data writeToFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName] atomically:YES];
        
        self.account = account;
        if (self.account) {
            self.isSignIn = YES;
        }
    }
}

- (void)updateUserDefaultAddressId:(NSString *)addressId {
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]]) {
        
        NSData *unData = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:unData];
        //解档出数据模型
        AccountModel *account = [unarchiver decodeObjectForKey:kDataKey];
        //一定不要忘记finishDecoding，否则会报错
        [unarchiver finishDecoding];
        
        account.addressId = addressId;
        
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:account forKey:kDataKey];
        [archiver finishEncoding];
        
        [data writeToFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName] atomically:YES];
        
        self.account = account;
        if (self.account) {
            self.isSignIn = YES;
        }
    }
}

- (void)setAccountCountryModel:(ZFAddressCountryModel *)accountCountryModel
{
    _accountCountryModel = accountCountryModel;
    NSString *countryModeljson = [accountCountryModel yy_modelToJSONString];
    if (countryModeljson) {
        SaveUserDefault(kAccountCountryModelKey, countryModeljson);
        
        BOOL hasChangeCurrency = [GetUserDefault(kHasChangeCurrencyKey) boolValue];
        if (!hasChangeCurrency) {
            NSString *sign = accountCountryModel.exchange.sign;
            NSString *name = accountCountryModel.exchange.name;
            NSString *exchangeString = [NSString stringWithFormat:@"%@ %@", sign, name];
            [ExchangeManager updateLocalCurrency:exchangeString];
        }
    }
}

-(void)saveUserInfo:(AccountModel *)account {
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:account forKey:kDataKey];
    [archiver finishEncoding];
    YWLog(@"%@",ZFPATH_DIRECTORY);
    [data writeToFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName] atomically:YES];
}

- (void)updateUserInfo:(AccountModel *)account {
    [self saveUserInfo:account];
    [self readUserInfo];
    //把用户登录的 facebook google登录的资料保存
    self.account.googleLoginGender = ZFToString([AccountManager sharedManager].googleLoginGender);
    self.account.googleLoginBirthday = ZFToString([AccountManager sharedManager].googleLoginBirthday);
    self.account.facebookLoginGender = ZFToString([AccountManager sharedManager].facebookLoginGender);
    self.account.facebookLoginBirthday = ZFToString([AccountManager sharedManager].facebookLoginBirthday);
    //注册大数据统计用户id
    [GGAppsflyerAnalytics registerBigDataWithUserId:account.user_id];
}

- (void)editUserSomeItems:(AccountModel *)account
{
    if ([[NSFileManager defaultManager] fileExistsAtPath:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]]) {
        
        NSData *unData = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]];
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:unData];
        AccountModel *unarchiverAccount = [unarchiver decodeObjectForKey:kDataKey];
        [unarchiver finishDecoding];
        
        unarchiverAccount.firstname = account.firstname;
        unarchiverAccount.lastname = account.lastname;
        unarchiverAccount.nickname = account.nickname;
        unarchiverAccount.sex = account.sex;
        unarchiverAccount.birthday = account.birthday;
        unarchiverAccount.phone = account.phone;
        unarchiverAccount.has_new_coupon = account.has_new_coupon;
        unarchiverAccount.is_update_birthday =account.is_update_birthday;
        
        NSMutableData *data = [[NSMutableData alloc] init];
        NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
        [archiver encodeObject:unarchiverAccount forKey:kDataKey];
        [archiver finishEncoding];
        
        [data writeToFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName] atomically:YES];
        
        NSData *unData1 = [[NSData alloc] initWithContentsOfFile:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]];
        NSKeyedUnarchiver *unarchiver1 = [[NSKeyedUnarchiver alloc] initForReadingWithData:unData1];
        AccountModel *unarchiverAccount1 = [unarchiver1 decodeObjectForKey:kDataKey];
        [unarchiver finishDecoding];
        
        self.account = unarchiverAccount1;
        
        if (self.account) {
            self.isSignIn = YES;
        }
    }
}

- (void)EditUserSomeItems:(AccountModel *)account {
    [self readUserInfo];
    [self saveUserInfo:account];
}

/// 清除所有登录信息
- (void)clearUserInfo {
    YWLog(@"%@",ZFPATH_DIRECTORY);
    
    if (self.account.is_emerging_country) {
        //新兴市场登录的需要清除保存的邮箱地址
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:kUserEmail];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName]]) {
        [[NSFileManager defaultManager] removeItemAtPath:[ZFPATH_DIRECTORY stringByAppendingPathComponent:kFileName] error:nil];
        self.account = nil;
        self.isSignIn = NO;
    }

    // 清除web Cookie
    [[AccountManager sharedManager] clearWebCookie];
    // 清除用户统计路径
    [[ZFBTSDataSets sharedInstance] clearBtsSets];
    // 清除保存的信息
    [AccountManager sharedManager].googleLoginGender = @"";
    [AccountManager sharedManager].googleLoginBirthday = @"";
    [AccountManager sharedManager].facebookLoginGender = @"";
    [AccountManager sharedManager].facebookLoginBirthday = @"";
    // 退出登录后重置新老客标识为新客: 1=新用户
    [AccountManager sharedManager].af_user_type = @"1";
    
    // 清除购物车选择主动记住的全局优惠券
    [AccountManager clearUserSelectedCoupon];
    
    [[NSUserDefaults standardUserDefaults] setValue:@(0) forKey:kCollectionBadgeKey];
    [[NSUserDefaults standardUserDefaults] setValue:@"" forKey:kSessionId];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 退出登录后选中首页
    ZFTabBarController *tabbar = (ZFTabBarController *)(APPDELEGATE.tabBarVC);
    [tabbar setZFTabBarIndex:TabBarIndexHome];
    
    // 保存LeandCloud数据
    [AccountManager saveLeandCloudData];
    
    //清楚已持有的首页cms个人优惠券数据
    [[ZFCMSCouponManager manager].localCouponList removeAllObjects];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kLogoutNotification object:nil];
    [AccountManager sharedManager].account.has_new_coupon = @"0";
    [tabbar isShowNewCouponDot];
    [ZFFireBaseAnalytics selectContentWithItemId:@"Sign Out" itemName:@"SIGN OUT" ContentType:@"Sign Out" itemCategory:@"Button"];
    [AppsFlyerTracker sharedTracker].customerUserID = @"0";
    // Branch
    [[ZFBranchAnalytics sharedManager] branchLogout];
    //注册大数据统计用户id
    [GGAppsflyerAnalytics registerBigDataWithUserId:@"0"];
    
    //清楚zego登录数据
    [ZFZegoHelper clearUserInfo];
    
    //退出登录清除userId
    [Growing clearUserId];
}

- (void)clearWebCookie {
    NSString *libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *cookiesFolderPath = [libraryPath stringByAppendingString:@"/Cookies"];
    NSError *errors;
    [[NSFileManager defaultManager] removeItemAtPath:cookiesFolderPath error:&errors];
}

- (NSString *)userId {
    return ZFToString(self.account.user_id);
}

- (NSString *)userNickname {
    return ZFToString(self.account.nickname);
}

- (NSString *)token {
    return ZFToString(self.account.token);
}

- (NSString *)defaultAddressId {
    return ZFToString(self.account.addressId);
}

- (NSString *)sessionId {
    return ZFToString(self.account.sess_id);
}

- (NSString *)device_id {
    if (!_device_id) {
        _device_id = [ZFKeychainDataManager readZZZZZUUID];
        // 保存到数据共享组
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
        [myDefaults setObject:ZFToString(_device_id) forKey:@"Device_Id"];
    }
    return _device_id;
}

- (NSString *)userSex {
    NSString *sex = GetUserDefault(ZFSexSelect);
    if (self.account.sex == UserEnumSexTypeMale) {
        sex = @"1";
    } else if (self.account.sex == UserEnumSexTypeFemale) {
        sex = @"2";
    }
    return sex;
}

- (NSDictionary *)userInfo {
    return @{
    @"sex"      : ZFToString([self userSex]),
    @"nickname" : ZFToString(self.account.nickname),
    @"email"    : ZFToString(self.account.email),
    @"firstname": ZFToString(self.account.firstname),
    @"lastname" : ZFToString(self.account.lastname),
    @"birthday" : ZFToString(self.account.birthday),
    @"user_id"  : ZFToString(self.account.user_id),
    @"phone"    : ZFToString(self.account.phone)
    };
}

- (void)logout {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void) {
#ifdef LeandCloudEnabled
        AVInstallation *currentInstallationLeandcloud = [AVInstallation defaultInstallation];
        [currentInstallationLeandcloud setObject:USERID forKey:@"userId"];
        [currentInstallationLeandcloud saveInBackground];
#endif
    });
    [[AccountManager sharedManager] clearUserInfo];
}



/**
 * 保存LeandCloud数据
 */
+ (void)saveLeandCloudData
{
    BOOL hasShowUserNotification = [GetUserDefault(kHasShowSystemNotificationAlert) boolValue];
    if (!hasShowUserNotification) return;  // 没注册推送前，不往服务器上传设备信息
    
#ifdef LeandCloudEnabled
    NSString *paid_order_number = @"0";
    if ([AccountManager sharedManager].isSignIn) {
        paid_order_number = ZFToString([AccountManager sharedManager].account.paid_order_number);
    }
    
    NSString *country = nil;
    ZFInitCountryInfoModel *countryInfoModel = [AccountManager sharedManager].initializeModel.countryInfo;
    if (ZFIsEmptyString(countryInfoModel.region_name)) {
        country = @"United States";
    }else{
        country = countryInfoModel.region_name;
    }
    
    YWLog(@"保存LeandCloud数据==%@", [AppsFlyerTracker sharedTracker].getAppsFlyerUID);
    NSInteger user = [[[AccountManager sharedManager] userId] integerValue];
    
    AVInstallation *currentInstallationLeandcloud = [AVInstallation defaultInstallation];
    [currentInstallationLeandcloud setObject:@(user) forKey:@"userId"];
    [currentInstallationLeandcloud setObject:@"YES"  forKey:@"promotions"];
    [currentInstallationLeandcloud setObject:@"YES"  forKey:@"orderMessages"];
    [currentInstallationLeandcloud setObject:ZFToString(country)  forKey:@"country"];
    [currentInstallationLeandcloud setObject:ZFToString(paid_order_number)  forKey:@"ordercount"];
    [currentInstallationLeandcloud setObject:ZFToString([AppsFlyerTracker sharedTracker].getAppsFlyerUID) forKey:@"appsFlyerId"];
    [currentInstallationLeandcloud setObject:ZFToString([ZFLocalizationString shareLocalizable].nomarLocalizable) forKey:@"language"];
    [currentInstallationLeandcloud saveInBackground];
#endif
    
    //保存FCM推送的信息
    [self uploadFCMTokenToServerToken:ZFToString([FIRMessaging messaging].FCMToken)];
}

/**
 * 上传FCM推送的信息
 */
+ (void)uploadFCMTokenToServerToken:(NSString *)fcmToken {
    
    NSString *paid_order_number = @"0";
#ifdef LeandCloudEnabled
    if ([AccountManager sharedManager].isSignIn) {
        paid_order_number = ZFToString([AccountManager sharedManager].account.paid_order_number);
    }
#endif
    
    // pushPower: 是否开启系统推送权限, 1开启, 0关闭
    [ZFPushManager isRegisterRemoteNotification:^(BOOL isRegister) {
        // 保存FCM推送的信息到leancloud
        [ZFCommonRequestManager saveFCMUserInfo:paid_order_number
                                      pushPower:isRegister
                                       fcmToken:fcmToken];
    }];
}

- (UIColor *)appNavBgColor {
    if (!_appNavBgColor) {
        return ZFCOLOR_WHITE;
    }
    return _appNavBgColor;
}

-(UIColor *)appNavIconColor {
    if (!_appNavIconColor) {
        return ZFCOLOR(51, 51, 51, 1.0);
    }
    return _appNavIconColor;
}

-(UIColor *)appNavFontColor {
    if (!_appNavFontColor) {
        return ZFCOLOR(51, 51, 51, 1.0);
    }
    return _appNavFontColor;
}

- (NSArray *)appSkinModelArray {
    if (!_appSkinModelArray) {
        NSData *data = [[NSData alloc] initWithContentsOfFile:[ZFSkinViewModel skinModelPath]];
        if ([data length] > 0) {
            _appSkinModelArray = [NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return _appSkinModelArray;
}

- (NSNumber *)cmsTimeOutDuration {
    if (!_cmsTimeOutDuration) {
        _cmsTimeOutDuration = @(20);
    }
    if (_cmsTimeOutDuration.integerValue <= 0) {
        _cmsTimeOutDuration = @(20);
    }
    return _cmsTimeOutDuration;
}

/**
 * 保存 common/initialization 接口的数据
 */
- (void)saveInitializeData:(NSDictionary *)InitializeDicInfo {
    ZFInitializeModel *initializeModel = [ZFInitializeModel yy_modelWithJSON:InitializeDicInfo];
    initializeModel.countryInfo.support_lang = [NSArray yy_modelArrayWithClass:[ZFSupportLangModel class] json:InitializeDicInfo[@"support_lang"]];
    
    [ZFLocalizationString shareLocalizable].languageArray = initializeModel.countryInfo.support_lang;
    //设置语言
    ZFSupportLangModel *supportModel = [[ZFLocalizationString shareLocalizable] filterSupporlang:initializeModel.countryInfo.support_lang];
    [ZFLocalizationString shareLocalizable].nomarLocalizable = supportModel.code;
    
    if (initializeModel) {
        _initializeModel = initializeModel;
    }
}

- (ZFInitializeModel *)initializeModel {
    if (!_initializeModel) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSDictionary *result = [userDefault objectForKey:kInitialize];
        if (ZFJudgeNSDictionary(result)) {
            _initializeModel = [ZFInitializeModel yy_modelWithJSON:result];
        }
    }
    return _initializeModel;
}

// 清除购物车主动选择记住的全局优惠券
+ (void)clearUserSelectedCoupon {
    [AccountManager sharedManager].no_login_select_coupon = NO;
    [AccountManager sharedManager].hasSelectedAppCoupon = NO;
    [AccountManager sharedManager].selectedAppCouponCode = nil;
}

- (ZFGifTipsModel *)gifTipsModel
{
    if (!_gifTipsModel) {
        _gifTipsModel = [[ZFGifTipsModel alloc] init];
    }
    return _gifTipsModel;
}

- (NSMutableArray *)filterAnalyticsArray {
    if (!_filterAnalyticsArray) {
        _filterAnalyticsArray = [NSMutableArray array];
    }
    return _filterAnalyticsArray;
}

@end
