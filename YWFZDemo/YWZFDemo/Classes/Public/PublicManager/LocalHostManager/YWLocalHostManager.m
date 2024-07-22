//
//  YWLocalHostManager.m
//  ZZZZZ
//
//  Created by YW on 11/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "YWLocalHostManager.h"
#import "ZFSkinViewModel.h"
#import "ZFThemeManager.h"
#import "NSStringUtils.h"
#import "ZFProgressHUD.h"
#import "NSString+Extended.h"
#import "UIViewController+ZFViewControllerCategorySet.h"
#import "YWCFunctionTool.h"
#import "YSAlertView.h"
#import "ZFRequestModel.h"
#import "Constants.h"
#import "ZFNetworkConfigPlugin.h"
#import "ZFLocalizationString.h"
#import "BannerManager.h"

#import <GGPaySDK/GGPaySDK.h>

typedef NS_OPTIONS(NSInteger, LocalHostEnvOptionType) {
    LocalHostEnvOptionTypeTrunk                     = 1 << 0,
    LocalHostEnvOptionTypePre                       = 1 << 1,
    LocalHostEnvOptionTypeDis                       = 1 << 2,
    LocalHostEnvOptionTypeInput                     = 1 << 3,
};

@interface YWLocalHostManager()

@end

@implementation YWLocalHostManager

+ (instancetype)manager {
    static dispatch_once_t onceToken;
    static YWLocalHostManager *once;
    dispatch_once(&onceToken, ^{
        once = [[YWLocalHostManager alloc] init];
    });
    return once;
}

+ (void)initialize {
    NSInteger envType = [GetUserDefault(kEnvSettingTypeKey) integerValue];
    if (!envType) {
        envType = 1 << AppRequestType;
        [[NSUserDefaults standardUserDefaults] setInteger:envType forKey:kEnvSettingTypeKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 保存到数据共享组
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
        [myDefaults setInteger:envType forKey:@"EnvSettingTypeKey"];
    }
}

+ (NSString *)appBaseUR {
    if ([YWLocalHostManager isDevelopStatus]) {
        NSString *inputAppBranch = GetUserDefault(kInputBranchKey);
        if (ZFIsEmptyString(inputAppBranch)) {
            inputAppBranch = @"master";
        }
        return [NSString stringWithFormat:@"http:////%@/", inputAppBranch, ZFSYSTEM_VERSION];
    } else {
        return [NSString stringWithFormat:@"https:///%@/",ZFSYSTEM_VERSION];
    }
}

+ (NSString *)cmsAppBaseURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        NSString *inputCMSBranch = GetUserDefault(kInputCMSBranchKey);
        if (ZFIsEmptyString(inputCMSBranch)) {
            inputCMSBranch = @"release";
        }
        return [NSString stringWithFormat:@"http://.com/", inputCMSBranch];
    } else {
        return @"https://.com/";
    }
}

/**
 * 根据频道请求CMS备份在S3服务器上的缓存数据接口
 @param channelID 频道id
 */
+ (NSString *)cmsHomePageJsonS3URL:(NSString *)channelID {
    //国家站标识
    NSString *ZZZZZ_pipeline = GetUserDefault(kLocationInfoPipeline);
    if (ZFIsEmptyString(ZZZZZ_pipeline)) {
        ZZZZZ_pipeline = @""; //第一次启动可能还没请求到,显示全球站数据
    } else {
        ZZZZZ_pipeline = [ZZZZZ_pipeline uppercaseString];
        if ([ZZZZZ_pipeline isEqualToString:@"ZF"]) { //全球站
            ZZZZZ_pipeline = @"";//cms约定:全球站则不传空标识
        }
    }
    if (ZFIsEmptyString(channelID)) {
        channelID = @"";
    }
    if ([YWLocalHostManager isDevelopStatus]) {
        return [NSString stringWithFormat:@"http://.com/cmsjsondata/%@%@APPHomePage.json", channelID, ZZZZZ_pipeline];
    } else {
        return [NSString stringWithFormat:@"https:///cmsjsondata/%@%@APPHomePage.json", channelID, ZZZZZ_pipeline];
    }
}

+ (NSString *)communityAppBaseURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        NSString *communityBranch = GetUserDefault(kInputCommunityBranchKey);
        if (ZFIsEmptyString(communityBranch)) {
            communityBranch = @"trunk";//master
        }
        return [NSString stringWithFormat:@"http://community/do?site=ZZZZZcommunity", communityBranch];
    } else {
        return @"http://dallas_community.gloapi.com/api-ZZZZZ-community/do?site=ZZZZZcommunity";
    }
}

+ (NSString *)communityNewBaseURL:(NSString *)portName {
    if ([YWLocalHostManager isDevelopStatus]) {
        NSString *branchName = GetUserDefault(kInputCommunityBranchKey);
        if (ZFIsEmptyString(branchName)) {
            branchName = @"trunk";//master
        }
        return [NSString stringWithFormat:@"http://community/%@?site=ZZZZZcommunity",branchName, portName];
    } else {
        return [NSString stringWithFormat:@"http://dallas_community.gloapi.com/api-ZZZZZ-community/%@?site=ZZZZZcommunity", portName];
    }
}

+ (NSString *)communityNewLiveBaseURL:(NSString *)portName {
    if ([YWLocalHostManager isDevelopStatus]) {
        NSString *branchName = GetUserDefault(kInputCommunityBranchKey);
        if (ZFIsEmptyString(branchName)) {
            branchName = @"trunk";//master
        }
        return [NSString stringWithFormat:@"http://.com/%@",portName];
    } else {
        return [NSString stringWithFormat:@"http://service.miyanws.com/%@",portName];
    }
}

+ (NSString *)appH5BaseURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://m.wap-ZZZZZ.com.master.php5.egomsl.com/";
    } else {
        return @"https://m.ZZZZZ.com/";
    }
}

/// AZZZZZ内部以图搜图
+ (NSString *)zfSearchImageURL {
//    if ([YWLocalHostManager isDevelopStatus]) {
//        return @"http:///gs/search/zfImg";
//    } else {
        return @"http://ytst.logsss.com/gs/search/zfImg";
//    }
}

//暂时没用
//+ (NSString *)appH5ELFBaseURL {
//    if ([YWLocalHostManager isDevelopStatus]) {
//        return @"https://elf.ZZZZZ.com/";
//    } else {
//        return @"https://elf.ZZZZZ.com/";
//    }
//}

+ (NSString *)appCardIntroURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://wap-ZZZZZ.com.c.s1.egomsl.com/index.php?m=app_h5&a=introduce_idcard&lang=%@";
    } else {
        return @"http://m.ZZZZZ.com/index.php?m=app_h5&a=introduce_idcard&lang=%@";
    }
}

/// V5.6.0: 原生专题详情URL
+ (NSString *)geshopDetailURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://test.geshop-api.com.release_sop.php7.egomsl.com/app/activity/page/detail";
    } else {
        return @"https://api.hqgeshop.com/app/activity/page/detail";
    }
}

/// V5.6.0: 原生专题根据组件id请求组件数据URL
+ (NSString *)geshopAsyncInfoURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://test.geshop-api.com.release_sop.php7.egomsl.com/app/activity/page/asyncInfo";
    } else {
        return @"https://api.hqgeshop.com/app/activity/page/asyncInfo";
    }
}

+ (NSString *)appCommunityIntroURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://www.ZZZZZ-m.com.a.s1.egomsl.com/m-app_h5-a-ios.htm";
    } else {
        return @"https://m.ZZZZZ.com/index.php?m=article&id=118&is_app=1";
    }
}

+ (NSString *)appCommunityShareURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://wap-ZZZZZ.com.b.s1.egomsl.com/m-app_h5-a-app_download.htm";
    } else {
        return @"https://m.ZZZZZ.com/m-app_h5-a-app_download.htm";
    }
}

+ (NSString *)appAuthQuickPayURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        NSString *inputAppBranch = GetUserDefault(kInputBranchKey);
        if (ZFIsEmptyString(inputAppBranch)) {
            inputAppBranch = @"release";
        }
        return [NSString stringWithFormat:@"http://app-ZZZZZ.com.%@.php5.egomsl.com/pay/quick?", inputAppBranch];
    } else {
        return @"https://app.ZZZZZ.com/pay/quick?";
    }
}

+ (NSString *)appPrivateKey {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"jeFQy4qnxgOMM+T+GU@3-xvH3@8TfCLF";
    } else {
        return @"VulSg[j8#7~CBAA#dk[)+sL38sFSk[!t";
    }
}

+ (NSString *)appCommunityPrivateKey {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"ios-api-key#222222";
    } else {
        return @"aa91e90c0fd7c333bbfcbfc6ccb7bca8";
    }
}

+ (NSString *)appCommunityLivePrivateKey {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"8acb7bcc6cfbcfbb333c7df0c09e19aa";
    } else {
        return @"aa91e90c0fd7c333bbfcbfc6ccb7bca8";
    }
}


+ (NSString *)appCommunityPostApiPrivateKey {
    return @"123456";
}

+ (NSString *)appAppsFlyerKey {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"PQmjs6dfikqatrWRQ4EEG";
    } else {
        return @"PQmjs6dfikqatrWRQ4EEG";
    }
}

+ (NSString *)fireBaseAppKey
{
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"GoogleService-Info-Debug";
    } else {
        return @"GoogleService-Info-Release";
    }
}

+ (NSString *)appBuglyAppId {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"4cc1809903";
    } else {
        return @"4c08b49354";
    }
}

+ (NSString *)appLeanCloudApplicationID {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"jj3cOE5IfCEElRmY5FbNxw7c-MdYXbMMI";
    } else {
        return @"ldXsItSBa4rrMwf9JLLiz74K-MdYXbMMI";
    }
}

+ (NSString *)appLeanCloudClientKey {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"CE0HuCA5ofkJVM5UdVfvqPXV";
    } else {
        return @"VPS0kjiDycHULHOQcPVzT6u1";
    }
}

+ (NSString *)searchMapURL {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://52.221.238.136:8001/image_recognize/img_rec";
    } else {
        return @"https://xai.1talking.net/image_recognize/img_rec";
    }
}

+ (NSString *)contactUsURL
{
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://m.wap-ZZZZZ.com.master.php5.egomsl.com/contact-us?app=1&lang=%@";
    } else {
        return @"https://m.ZZZZZ.com/contact-us?app=1&lang=%@";
    }
}

+ (NSString *)syncPushClickDataUrl
{
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://leancloud.gloapi.com.master.php5.egomsl.com/api/sync-clickdata";
    } else {
        return @"https://leancloud.gloapi.com/api/sync-clickdata";
    }
}

+ (NSString *)fCMTokenUserInfoUrl
{
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://leancloud.gloapi.com.master.php5.egomsl.com/api/sync-fcmtoken";
    }else{
        return @"https://leancloud.gloapi.com/api/sync-fcmtoken";
    }
}

+ (NSString *)leancloudUrlMd5Key
{
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"btxDmBwn#X6KBFVpbrOFKM3gTHBLpNaK";
    } else {
        return @"btxDmBwn#X6KBFVpbrOFKM3gTHBLpNaK";
    }
}

+ (NSString *)addressLocationApiURL {
//    if ([YWLocalHostManager isDevelopStatus]) {
//        return @"http://address-api.com.master.test.php5.egomsl.com";
//    } else {
        return @"http://address-api-public.gloapi.com";
//    }
}

/// 单个BTS实验接口
+ (NSString *)appBtsSingleUrl {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://test-bts.logsss.com/gateway/shunt";
        
    } else {
        return @"https://slapi-bts.logsss.com/gateway/shunt";
    }
}

/// 多个BTS实验接口(数组方式)
+ (NSString *)appBtsListUrl {
    if ([YWLocalHostManager isDevelopStatus]) {
        return @"http://test-bts.logsss.com/gateway/shuntList";
        
    } else {
        return @"https://slapi-bts.logsss.com/gateway/shuntList";
    }
}

#pragma mark -===========获取当前分支是否为开发环境分支===========

/**
 * 当前环境是否为线上布生产模式 (打包发布审核环境)
 */
+ (BOOL)isDistributionOnlineRelease {
    BOOL isDistributionOnlineRelease = NO;
#if DEBUG
#else
    if (AppRequestType == 2) { //线上发布生产环境
        isDistributionOnlineRelease = YES;
    }
#endif
    return isDistributionOnlineRelease;
}

/**
 * 当前环境是否为线上环境
 */
+ (BOOL)isOnlineRelease
{
    if ([self isDistributionOnlineRelease]) {//线上发布直接返回
        return YES;
    }
    NSInteger envType = [GetUserDefault(kEnvSettingTypeKey) integerValue];
    return envType & LocalHostEnvOptionTypeDis;
}

/**
 * 当前环境是否为预发布环境
 */
+ (BOOL)isPreRelease
{
    if ([self isDistributionOnlineRelease]) {//线上发布直接返回
        return NO;
    }
    NSInteger envType = [GetUserDefault(kEnvSettingTypeKey) integerValue];
    return envType & LocalHostEnvOptionTypePre;
}

/**
 * 当前环境是否为开发环境
 */
+ (BOOL)isDevelopStatus
{
    if ([self isDistributionOnlineRelease]) {//线上发布直接返回
        return NO;
    }
    NSInteger envType = [GetUserDefault(kEnvSettingTypeKey) integerValue];
    return envType & LocalHostEnvOptionTypeTrunk || envType & LocalHostEnvOptionTypeInput;
}

/**
 * 当前环境字符串
 */
+ (NSString *)currentLocalHostTitle
{
    if ([self isDistributionOnlineRelease]) {//线上发布直接返回
        return @"线上";
    }
    NSString *currentHost = nil;
    NSString *inputBranch = GetUserDefault(kInputBranchKey);
    NSInteger envType = [GetUserDefault(kEnvSettingTypeKey) integerValue];
    if (envType & LocalHostEnvOptionTypeTrunk) {
        currentHost = @"主干";
    } else if (envType & LocalHostEnvOptionTypePre) {
        currentHost = @"预发布";
    } else if (envType & LocalHostEnvOptionTypeDis) {
        currentHost = @"线上";
    } else {
        currentHost = [NSString stringWithFormat:@"测试 - %@",inputBranch];
    }
    return currentHost;
}

#pragma mark -===========App内部切换环境===========

/// 主弹框标题
+ (NSAttributedString *)fetchAlertTitle
{
    return [NSString getAttriStrByTextArray:@[@"💐当前环境: ", [self currentLocalHostTitle]]
                                    fontArr:@[ZFFontSystemSize(12)]
                                   colorArr:@[[UIColor blackColor],[UIColor redColor]]
                                lineSpacing:0
                                  alignment:0];
}

/// 弹框副标题: GGPay SDK版本号, IM SDK版本号
+ (NSAttributedString *)fetchAlertMessage
{
    NSString *ggPayVersion = [NSString stringWithFormat:@"\nGGPaySDK: v%@", [GGPayCashierViewController ggPaySDKVersion]];
    NSString *imSDKVersion = [NSString stringWithFormat:@"\nIMSDK: v%@", @"2.1.3"];
    return [NSString getAttriStrByTextArray:@[[self appBaseUR], ggPayVersion, imSDKVersion]
                                    fontArr:@[ZFFontSystemSize(12)]
                                   colorArr:@[[UIColor blackColor],[UIColor redColor]]
                                lineSpacing:0
                                  alignment:0];
}

/**
 * 配置切换网络环境
 */
+ (void)changeAppRequestUrl {
    if ([YWLocalHostManager isDistributionOnlineRelease]) {
        YWLog(@"⚠️⚠️⚠️ 此状态是线上发布生产环境, 切记不能显示切换环境入口 ⚠️⚠️⚠️");
        return;
    }
    NSArray *otherBtnArray = @[@"主干", @"预发布", @"线上", @"切换ZZZZZ测试分支", @"切换社区测试分支"];
    ShowAlertView([self fetchAlertTitle], [self fetchAlertMessage], otherBtnArray, ^(NSInteger buttonIndex, id buttonTitle) {
        
        if (buttonIndex == 3) { //切换后台测试分支
            NSString *alertMsg = [NSString stringWithFormat:@"%@\n当前后台分支%@",[self appBaseUR], [self currentLocalHostTitle]];
            [YSAlertView inputAlertWithTitle:@"👉切换ZZZZZ测试分支👈"
                                     message:alertMsg
                                        text:nil
                                 placeholder:@"请输入ZZZZZ后台测试分支"
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                                keyboardType:0
                                 buttonBlock:^(NSString *inputText) {
                                     
                                     if ([NSStringUtils isEmptyString:inputText]) return;
                                     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
                                     NSInteger envType = LocalHostEnvOptionTypeInput;
                                     [ud setInteger:envType forKey:kEnvSettingTypeKey];
                                     [ud setObject:ZFToString(inputText) forKey:kInputBranchKey];
                                     [ud synchronize];
                                     // 保存到数据共享组
                                     NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
                                     [myDefaults setInteger:envType forKey:@"EnvSettingTypeKey"];
                                     
                                     [[AccountManager sharedManager] logout];
                                     [self clearZFNetworkCache];
                                     SaveUserDefault(kInputCountryIPKey, @"");
                
                                    ShowToastToViewWithText(nil, @"切换成功,退出后请手动启动App");
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self logOutApplication];
                                    });
                                     
                                 } cancelBlock:nil];
            
        } else if (buttonIndex == 4) { //切换社区测试分支
            NSString *branch = ZFIsEmptyString(GetUserDefault(kInputCommunityBranchKey)) ? @"trunk" : GetUserDefault(kInputCommunityBranchKey);
            NSString *alertMsg = [NSString stringWithFormat:@"%@\n当前社区分支: %@",[self communityAppBaseURL], branch];
            
            [YSAlertView inputAlertWithTitle:@"👉切换社区测试分支👈"
                                     message:alertMsg
                                        text:nil
                                 placeholder:@"请输入社区测试分支"
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                                keyboardType:0
                                 buttonBlock:^(NSString *inputText) {
                                     if (ZFIsEmptyString(inputText)) return;
                                     
                                     [[AccountManager sharedManager] logout];
                                     [self clearZFNetworkCache];
                                     SaveUserDefault(kInputCommunityBranchKey, inputText);
                                     SaveUserDefault(kInputCountryIPKey, @"");
                                     
                                    ShowToastToViewWithText(nil, @"切换成功,退出后请手动启动App");
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self logOutApplication];
                                    });
                                     
                                 } cancelBlock:nil];
            
        } else { // 切换App环境: 主干, 预发布, 线上
            NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
            NSInteger envType = 1 << buttonIndex;
            [ud setInteger:envType forKey:kEnvSettingTypeKey];
            [ud removeObjectForKey:kInputBranchKey];
            [ud synchronize];
            // 保存到数据共享组
            NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
            [myDefaults setInteger:envType forKey:@"EnvSettingTypeKey"];
            
            [[AccountManager sharedManager] logout];
            [self clearZFNetworkCache];
            SaveUserDefault(@"kInputCountryIP", @"");
            
            ShowToastToViewWithText(nil, @"切换成功,退出后请手动启动App");
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self logOutApplication];
            });
        }
    }, @"取消", nil);
}

///本地实时抓包-> http://10.36.5.100:8090
+ (void)dealwithCatchLog {
    NSString *alertMsg = [NSString stringWithFormat:@"当前筛选日志标签: %@", ZFToString(GetUserDefault(kInputCatchLogTagKey))];
    
    NSMutableString *alertTitle = [NSMutableString stringWithString:@"请在电脑浏览器输入当前抓包IP地址: "];
    NSString *catchLogUrl = GetUserDefault(kInputCatchLogUrlKey);
    if (ZFIsEmptyString(catchLogUrl)) {
        NSURL *url = [NSURL URLWithString:[ZFRequestModel new].uploadRequestLogToUrl];
        [alertTitle appendFormat:@"%@:%@",url.host, url.port];
        
    } else if ([catchLogUrl containsString:@":"]) {
        [alertTitle appendString:catchLogUrl];
    } else {
        [alertTitle appendFormat:@"%@:8090",catchLogUrl];
    }
    [YSAlertView inputAlertWithTitle:alertTitle
                             message:alertMsg
                         cancelTitle:@"取消"
                          otherTitle:@"确认"
                      textFieldCount:2
                      textFieldBlock:^(NSArray<UITextField *> *textFieldArr) {
                          
                          // 多个弹框时需要自己在外部设置输入框的部分属性样式
                          for (NSInteger i=0; i<textFieldArr.count; i++) {
                              UITextField *textField = textFieldArr[i];
                              textField.superview.layer.cornerRadius = 3;
                              textField.superview.layer.masksToBounds = YES;
                              textField.clearButtonMode = UITextFieldViewModeAlways;
                              textField.keyboardType = (i==0) ? UIKeyboardTypeDecimalPad : UIKeyboardTypeDefault;
                              textField.placeholder = (i==0) ? @"可输入抓包地址, 不填则使用默认地址" : @"请输入需要筛选的日志标签";
                              if (i==1) {
                                  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                      [textField becomeFirstResponder];
                                  });
                              }
                              
                          }
                      }  buttonBlock:^(NSArray<NSString *> *inputTextArr) {
                          NSString *tipText = @"";
                          for (NSInteger i=0; i<inputTextArr.count; i++) {
                              NSString *inputText = inputTextArr[i];
                              if (i == 0) {
                                  if (!ZFIsEmptyString(inputText)){
                                      inputText = [inputText stringByReplacingOccurrencesOfString:@" " withString:@""];
                                      SaveUserDefault(kInputCatchLogUrlKey, inputText);
                                  }
                              } else {
                                  if (ZFIsEmptyString(inputText)) {
                                      SaveUserDefault(kInputCatchLogTagKey, @"");
                                      [ZFNetworkConfigPlugin sharedInstance].uploadResponseJsonToLogSystem = NO;
                                      tipText = @"已关闭抓包IP地址";
                                  } else {
                                      SaveUserDefault(kInputCatchLogTagKey, inputText);
                                      [ZFNetworkConfigPlugin sharedInstance].uploadResponseJsonToLogSystem = YES;
                                      tipText = [NSString stringWithFormat:@"保存抓包IP地址成功--%@",inputText];
                                  };
                              }
                          }
                          ShowToastToViewWithText(nil, tipText);
                          
                      } cancelBlock:nil];
    
}

+ (id)addTitle:(id)title toArray:(NSMutableArray *)array {
    if (([title isKindOfClass:[NSString class]] || [title isKindOfClass:[NSAttributedString class]])
        && [array isKindOfClass:[NSMutableArray class]]) {
        [array addObject:title];
        return title;
    }
    return nil;
}

/**
 * 警告: 非线上发布环境开发时才可以切换环境
 */
+ (void)changeLocalHost {
    if ([YWLocalHostManager isDistributionOnlineRelease]) {
        YWLog(@"⚠️⚠️⚠️ 此状态是线上发布生产环境, 切记不能显示切换环境入口 ⚠️⚠️⚠️");
        return;
    }
    // appsFlyerid
    NSUserDefaults *userDF = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
    NSString *appsFlyerid = [NSString stringWithFormat:@"AFId: %@", [userDF objectForKey:@"appsFlyerid"]];
    
    // App UserId
    NSString *appUserId = [NSString stringWithFormat:@"用户UserId: %@", USERID];
    
    //以高亮颜色提示 主页显示的是cms还是非cms数据
    NSAttributedString *cmsAttrTitle = nil;
    NSArray *CMSTitles = @[@"CMS条件筛选"];
    NSArray *CMSColors = @[ColorHex_Alpha(0x2D2D2D, 1.0), [UIColor redColor]];
    NSArray *CMSFonts = @[ZFFontSystemSize(14), ZFFontSystemSize(10)];
    if (![AccountManager sharedManager].homeDateIsCMSType) {
        CMSTitles = @[@"CMS条件筛选\n", @"(目前主页为CMS备份数据)"];
    }
    cmsAttrTitle = [NSString getAttriStrByTextArray:CMSTitles
                                            fontArr:CMSFonts
                                           colorArr:CMSColors
                                        lineSpacing:0
                                          alignment:1];
    
    // 配置弹框所有按钮的标题-> (按Title添加顺序来显示)
    NSMutableArray *btnTitles = [NSMutableArray array];
    NSString *appHost   = [self addTitle:@"切换App环境" toArray:btnTitles];
    cmsAttrTitle        = [self addTitle:cmsAttrTitle toArray:btnTitles];
    NSString *geshop    = [self addTitle:@"Geshop专题测试" toArray:btnTitles];
    NSString *catchLog  = [self addTitle:@"接口日志实时抓包" toArray:btnTitles];
    NSString *webURL    = [self addTitle:@"测试Web/Deeplink" toArray:btnTitles];
    NSString *countryIP = [self addTitle:@"测试国家 IP 简码" toArray:btnTitles];
    NSString *ipaLog    = [self addTitle:@"查看最近打包修改" toArray:btnTitles];
    if (ISLOGIN) { [btnTitles addObject:appUserId]; }
    NSString *afIdTitle = [self addTitle:appsFlyerid toArray:btnTitles];
    
    ShowAlertView([self fetchAlertTitle], [self fetchAlertMessage], btnTitles, ^(NSInteger buttonIndex, id buttonTitle) {
        if ([buttonTitle isKindOfClass:[NSAttributedString class]]) {
            buttonTitle = ((NSAttributedString *)buttonTitle).string;
        }
        
        if ([buttonTitle isEqualToString:geshop]) { //新原生专题临时入口
            [YSAlertView inputAlertWithTitle:geshop
                                     message:nil
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                              textFieldCount:1
                              textFieldBlock:^(NSArray<UITextField *> *textFieldArr) {
                
                UITextField * textField = textFieldArr.firstObject;
                textField.clearButtonMode = UITextFieldViewModeAlways;
                textField.placeholder = @"请输入Geshop原生专题id";
                textField.text = GetUserDefault(@"kNewNativeThemeIdKey");
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [textField becomeFirstResponder];
                });
            } buttonBlock:^(NSArray<NSString *> *inputTextArr) {
                
                if (inputTextArr.firstObject.length > 0) {
                    SaveUserDefault(@"kNewNativeThemeIdKey", inputTextArr.firstObject);
                    NSString *VCtitle = [NSString stringWithFormat:@"%@环境专题Id: %@",[self currentLocalHostTitle], inputTextArr.firstObject];
                    
                    UIViewController *homeVC = [UIViewController currentTopViewController];
                    [homeVC pushToViewController:@"ZFGeshopNativeThematicVC" propertyDic:@{
                        @"nativeThemeId":inputTextArr.firstObject,
                        @"title": VCtitle
                    }];
                }
            } cancelBlock:nil];
            
        } else if ([buttonTitle isEqualToString:appHost]) { //切换App请求环境
            [self changeAppRequestUrl];
            
        } else if ([buttonTitle isEqualToString:cmsAttrTitle.string]) { //CMS条件筛选
            if ([YWLocalHostManager isOnlineRelease]) {
                ShowAlertSingleBtnView(@"温馨提示", @"CMS条件筛选功能在线上环境中禁止操作", @"好的");
            } else {
                UIViewController *homeVC = [UIViewController currentTopViewController];
                [homeVC pushToViewController:@"ZFTestCMSViewController" propertyDic:@{@"title":@"CMS条件筛选"}];
            }
            
        } else if ([buttonTitle isEqualToString:catchLog]) { //本地实时抓包
            [self dealwithCatchLog];
            
        } else if ([buttonTitle isEqualToString:webURL]) { //打开Web链接
            NSString *key = @"YSAlertViewLastInputText";
            NSString *lastUrl = ZFIsEmptyString(GetUserDefault(key)) ? nil : GetUserDefault(key);
            
            [YSAlertView inputAlertWithTitle:@"测试加载Web链接/Deeplink"
                                     message:nil
                                        text:lastUrl
                                 placeholder:@"请输入Web链接/Deeplink"
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                                keyboardType:0
                                 buttonBlock:^(NSString *inputText) {
                
                    if (ZFIsEmptyString(inputText)) return ;
                    SaveUserDefault(key, inputText);
                
                    if ([inputText hasPrefix:@" "] || [inputText hasSuffix:@" "]) {
                        ShowToastToViewWithText(nil, @"您输入的内容头或尾含有空格");
                        return;
                    }
                    if ([inputText hasPrefix:@"http"]) {
                        UIViewController *homeVC = [UIViewController currentTopViewController];
                        [homeVC pushToViewController:@"ZFWebViewViewController" propertyDic:@{@"link_url":ZFToString(inputText)}];
                        
                    } else if ([inputText hasPrefix:@"ZZZZZ://"]) {
                        NSMutableDictionary *paramDict = [BannerManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:inputText]];
                        UIViewController *homeVC = [UIViewController currentTopViewController];
                        [BannerManager jumpDeeplinkTarget:homeVC deeplinkParam:paramDict];
                        
                    } else {
                        ShowToastToViewWithText(nil, @"您输入的内容既不是Web链接也不是Deeplink");
                    }                
           } cancelBlock:nil];
            
        } else if ([buttonTitle isEqualToString:countryIP]) { //测试国家IP
            NSString *inputCountryIP = [NSString stringWithFormat:@"当前ip简码:  %@",ZFToString(GetUserDefault(kInputCountryIPKey))];
            [YSAlertView inputAlertWithTitle:@"👉请输入国家IP简码👈"
                                     message:inputCountryIP
                                        text:nil
                                 placeholder:@"请输入IP简码"
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                                keyboardType:0
                                 buttonBlock:^(NSString *inputText) {
                                     
                                     if (ZFIsEmptyString(inputText)) {
                                         SaveUserDefault(kInputCountryIPKey, @"");
                                         ShowToastToViewWithText(nil, @"清除简码成功,退出后请手动启动App");
                                     } else {
                                         SaveUserDefault(kInputCountryIPKey, inputText);
                                         ShowToastToViewWithText(nil, [NSString stringWithFormat:@"保存简码成功--%@,退出后请手动启动App",inputText]);
                                     }
                                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                                        [self logOutApplication];
                                    });
                
                                 } cancelBlock:nil];
            
        } else if ([buttonTitle isEqualToString:afIdTitle]) {  //复制AppsFlyerId
            NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.ZZZZZ.ZZZZZ"];
            NSString *appsFlyerid = [myDefaults objectForKey:@"appsFlyerid"];
            [UIPasteboard generalPasteboard].string = appsFlyerid;
            ShowToastToViewWithText(nil, @"AppsFlyerId 已复制到剪切板");
            
        } else if ([buttonTitle isEqualToString:ipaLog]) {  //上次包提交记录
            NSString *commitFilePath = [[NSBundle mainBundle]pathForResource:@"Upgrade_desc" ofType:@"txt"];
            
            NSString *body = [NSString stringWithContentsOfFile:commitFilePath usedEncoding:nil error:nil];
            
            ///警告: 这里不能直接放外部的下载地址, 因为在AppStore审核时检测到外部下载的域名会直接被拒
            NSString *loadHtmlString = [NSString stringWithFormat:
                @"<HTML>" "<head>" "<title>代码提交记录</title>"
                "<meta name='viewport' content='width=device-width, initial-scale=1.0, maximum-scale=1.0, minimum-scale=1.0, user-scalable=no'>"
                "</head>" "<BODY>" "<pre>" "%@" "</pre>"
                "<a href=\"ZZZZZ://action?actiontype=7&url=http://10.36.5.84/ZZZZZ/d_ZZZZZ.html\">下载安装包 (已安装证书点这里)</a>" "<p>"
                "<a href=\"ZZZZZ://action?actiontype=7&url=http://10.36.5.84/ZZZZZ/d_ZZZZZ_qiye.html\">下载企业包 (没已安装证书点这里)</a>"
                                        "</BODY>" "</HTML>", body];
            
            UIViewController *homeVC = [UIViewController currentTopViewController];
            [homeVC pushToViewController:@"ZFWebViewViewController" propertyDic:@{@"loadHtmlString": ZFToString(loadHtmlString)}];
            
        } else if ([buttonTitle isEqualToString:appUserId]) { //复制UserId
            [UIPasteboard generalPasteboard].string = USERID;
            ShowToastToViewWithText(nil, @"用户UserId已复制到剪切板");
        }
    }, @"取消", nil);
}

+ (void)clearZFNetworkCache {
    [ZFSkinViewModel clearCacheFile];
    [ZFNetworkHttpRequest clearZFNetworkHttpRequestCache];
}

+ (void)logOutApplication {
    [UIView animateWithDuration:0.5f animations:^{
        WINDOW.backgroundColor = ZFCOLOR_WHITE;
        WINDOW.alpha = 0;
        CGFloat y = WINDOW.bounds.size.height;
        CGFloat x = WINDOW.bounds.size.width / 2;
        WINDOW.frame = CGRectMake(x, y, 0, 0);
    } completion:^(BOOL finished) {
        YWLog(@"退到后台, 输入的分支:%@",GetUserDefault(kInputBranchKey));
        exit(0);
    }];
}

/**
 * 推送通知打开app处理
 */

+ (void)launchOptionsRemoteOpenAppOptions:(NSDictionary *)launchOptions {
    
    NSDictionary *userInfo = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    if (userInfo && ![userInfo isKindOfClass:[NSNull class]]) {
        [AccountManager sharedManager].isPushOpen = YES;
        SaveUserDefault(kLaunchOptionsRemoteNotificationKey, @(YES));
        SaveUserDefault(ktipRemoteAlertEventIOSNotificationKey, @(YES));
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SaveUserDefault(kLaunchOptionsRemoteNotificationKey, @(NO));
        });
        [YWLocalHostManager tipRemoteNotificatAlertEvent];
    }
}

+ (BOOL)stateLaunchOptionsRemoteOpenApp {
    BOOL isLaunchRemoteNotif = [GetUserDefault(kLaunchOptionsRemoteNotificationKey) boolValue];
    return isLaunchRemoteNotif;
}

+ (void)tipRemoteNotificatAlertEvent {
    
    SaveUserDefault(ktipRemoteAlertEventIOSNotificationKey, @(YES));
    SaveUserDefault(ktipRemoteAlertEventNotificationKey, @(YES));
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(120 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SaveUserDefault(ktipRemoteAlertEventNotificationKey, @(NO));
    });
}

+ (NSString *)requestFlagePushUserAgent {
    
    //通知触发，追加iOS标识
    NSString *usageIOS = [self requestFlagePushUserAgentIOS];
    //通知点击事件
    BOOL isTipRemoteNotif = [GetUserDefault(ktipRemoteAlertEventNotificationKey) boolValue];
    //通知打开APP
    BOOL isLaunchRemoteNotif = [GetUserDefault(kLaunchOptionsRemoteNotificationKey) boolValue];

     // 推送通知打开 所以请求标记处理
    if (isTipRemoteNotif || isLaunchRemoteNotif || !ZFIsEmptyString(usageIOS)) {
        
        // 【AFHTTPRequestSerializer 里拷贝出来的】
        NSString *userAgent = [NSString stringWithFormat:@"%@/%@ (%@; iOS %@; Scale/%0.2f)", [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleExecutableKey] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleIdentifierKey], [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"] ?: [[NSBundle mainBundle] infoDictionary][(__bridge NSString *)kCFBundleVersionKey], [[UIDevice currentDevice] model], [[UIDevice currentDevice] systemVersion], [[UIScreen mainScreen] scale]];
        
        if (isTipRemoteNotif || isLaunchRemoteNotif) {
            userAgent = [NSString stringWithFormat:@"%@ %@",userAgent,@"RequestFlag/Push"];
        }

        if (!ZFIsEmptyString(usageIOS)) {
            userAgent = [NSString stringWithFormat:@"%@ %@",userAgent,usageIOS];
        }
        return userAgent;
    }

    return @"";
}

/**
 移动APP再新增一个UA（区别是在PUSH进来的才添加）：
 安卓：
 空格+ExtraParam/AndroidPush
 IOS:
 空格+ExtraParam/iOSPush
 备注：
 不需要做延时remove失效处理，该 UA用于后续定位PUSH问题及在运维工作中直接区分是安卓或IOS发起的请求
 */
+ (NSString *)requestFlagePushUserAgentIOS {
    BOOL isTipRemoteNotif = [GetUserDefault(ktipRemoteAlertEventIOSNotificationKey) boolValue];
    if (isTipRemoteNotif) {
        return @"ExtraParam/iOSPush";
    }
    return @"";
}
@end


