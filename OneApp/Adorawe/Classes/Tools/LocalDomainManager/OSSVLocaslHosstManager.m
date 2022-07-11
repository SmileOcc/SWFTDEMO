//
//  OSSVLocaslHosstManager.m
// XStarlinkProject
//
//  Created by odd on 2020/7/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "OSSVLocaslHosstManager.h"
#import "NSString+Extended.h"
#import "UIViewController+STLCategory.h"
#import "OSSVConfigDomainsManager.h"
#import "STLConstants.h"

#if DEBUG
#import "FLEXManager.h"
#endif

typedef NS_OPTIONS(NSInteger, LocalHostEnvOptionType) {
    LocalHostEnvOptionTypeTrunk                     = 1 << 0,
    LocalHostEnvOptionTypePre                       = 1 << 1,
    LocalHostEnvOptionTypeDis                       = 1 << 2,
    LocalHostEnvOptionTypeInput                     = 1 << 3,
};

@implementation OSSVLocaslHosstManager


+(instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    static OSSVLocaslHosstManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [[OSSVLocaslHosstManager alloc] init];
    });
    return manager;
}


+ (void)initialize {
    DomainType domainType = [OSSVConfigDomainsManager domainEnvironment];

    if (!domainType) {
        //domainType = 1 << AppRequestType;
        [[NSUserDefaults standardUserDefaults] setInteger:domainType forKey:STLDevelopmentModel];
        [[NSUserDefaults standardUserDefaults] synchronize];
        // 保存到数据共享组
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[STLDeviceInfoManager sharedManager] appGroupSuitName]];
        [myDefaults setInteger:domainType forKey:@"EnvSettingTypeKey"];
    }
    
    if (AppRequestType == 2) {
        // 保存到数据共享组
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[STLDeviceInfoManager sharedManager] appGroupSuitName]];
        [myDefaults setInteger:DomainType_Release forKey:@"EnvSettingTypeKey"];
    } else {
        NSUserDefaults *myDefaults = [[NSUserDefaults alloc] initWithSuiteName:[[STLDeviceInfoManager sharedManager] appGroupSuitName]];
        [myDefaults setInteger:domainType forKey:@"EnvSettingTypeKey"];
    }
    
}

+ (NSString *)appName {
    return  STLToString([[STLDeviceInfoManager sharedManager] getAppName]);
}

+ (NSString *)appScheme {
    return  [STLToString([[STLDeviceInfoManager sharedManager] getAppName]) lowercaseString];
}

+ (NSString *)projectAppnameLowercaseString {
    return [NSString stringWithFormat:@"%@app",[[OSSVLocaslHosstManager appName] lowercaseString]];
}

+ (NSString *)appStoreId {
    
#if APP_TYPE == 1
    return @"1528273061";
#elif APP_TYPE == 2
    return @"1560262589";
#elif APP_TYPE == 3
    return @"1558803661";
#endif
    
    return @"";
}

+ (NSString *)appStoreReviewUrl {

    return [NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%@&pageNumber=0&sortOrdering=2&type=Purple+Software&mt=8",[self appStoreId]];
}

+ (NSString *)appStoreDownUrl {
    return [NSString stringWithFormat:@"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=%@",[self appStoreId]];
}

+ (NSString *)appHelpUrl:(HelpType)type {
    NSString *url = @"";
    
    switch (type) {
        case HelpTypeReturnPolicy:
            url = @"A";
            break;
        case HelpTypeLongReceiveOrider:
            url = @"B";
            break;
        case HelpTypeShipping:
            url = @"01";
            break;
        case HelpTypeOrders:
            url = @"02";
            break;
        case HelpTypeAfterSale:
            url = @"03";
            break;
        case HelpTypePromotion:
            url = @"04";
            break;
        case HelpTypeProducts:
            url = @"05";
            break;
        case HelpTypeContractUs:
            url = @"06";
            break;
        case HelpTypeAboutUs:
            url = @"AboutUs";
            break;
        case HelpTypePrivacyPolicy:
            url = @"PrivacyPolicy";
            break;
        case HelpTypeTermOfUsage:
            url = @"TermofUsega";
            break;
        default:
            break;
    }
    
    NSString *currentLang = [STLLocalizationString shareLocalizable].nomarLocalizable;
    NSString *appH5Url = [[OSSVConfigDomainsManager sharedInstance] appH5Url];
    NSString *helpPath = @"help";
    ///A站保持原先规则 其他站点help_APP名
    if (APP_TYPE != 1) {
        helpPath = [NSString stringWithFormat:@"help_%@",OSSVLocaslHosstManager.appName.lowercaseString];
    }
    
    url = [NSString stringWithFormat:@"%@static/html/%@/%@/%@.html",appH5Url,helpPath,currentLang,url];
    return url;
}


+ (NSString *)appDesEncrypt_iv {
    return @"ys160708";
#if APP_TYPE == 1
#elif APP_TYPE == 2
#elif APP_TYPE == 3
#endif
}

+ (NSString *)appDesEncrypt_key {
    return @"star71ik";
#if APP_TYPE == 1
#elif APP_TYPE == 2
#elif APP_TYPE == 3
#endif
}
#pragma mark ---评论系统域名

+ (NSString *)appLocalTestReviewHost {
    return @"http://review.cloudsdlk.com.release.fpm.testsdlk.com/api/";
}

+ (NSString *)appLocalOnleReviewHost {
    //评论系统线上
    if (APP_TYPE == 1) {
        return @"https://review.adorawe.net/api/";
    } else if(APP_TYPE == 2) {
        return @"https://review.soulmiacollection.com/api/";
    } else {
        return @"https://review.vivaiacollection.com/api/";
    }
    
}

+ (NSString *)appLocalPreOnleReviewHost {
    //预发布
    return @"https://beta-review.cloudsdlk.com/api/";
}

#pragma mark ---图片域名
+ (NSString *)appLocalTestReviewPictureDomain {
    // A, V, S 三端测试环境，图片域名一致
    return @"http://upload.cloudsdlk.com.release.fpm.testsdlk.com";
}

+ (NSString *)appLocalOnleReviewPictureDomain {
    
    if (APP_TYPE == 1) {
        return @"https://cdnimg.adorawe.net";
    } else if (APP_TYPE == 2) {
        return @"https://cdnimg.soulmiacollection.com";
    } else {
        return @"https://cdnimg.vivaiacollection.com";
    }
    
}

+ (NSString *)appLocalPreOnleReviewPictureDomain {
    //预发布
    if (APP_TYPE == 1) {
        return @"https://cdnimg.adorawe.net";
    } else if (APP_TYPE == 2) {
        return @"https://cdnimg.soulmiacollection.com";
    } else {
        return @"https://cdnimg.vivaiacollection.com";
    }
}

///评论系统key
+ (NSString *)reviewSystemKey {
    
#if APP_TYPE == 1
    //没有区分 正式与测试
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVConfigDomainsManager isPreRelease] || type == DomainType_Release) {
        return @"DS9h5BmGQAfTEDVTXWPdEfTVsjnRCEx6";
    }
    return @"DS9h5BmGQAfTEDVTXWPdEfTVsjnRCEx6";
#elif APP_TYPE == 2
    //没有区分 正式与测试
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVConfigDomainsManager isPreRelease] || type == DomainType_Release) {
        return @"dD87UXn23Vw09qp3DnPQ7VB8kda9f3b1";
    }
    return @"dD87UXn23Vw09qp3DnPQ7VB8kda9f3b1";
#elif APP_TYPE == 3
    //没有区分 正式与测试
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || [OSSVConfigDomainsManager isPreRelease] || type == DomainType_Release) {
        return @"dD87UXn23Vw09qp3DnPQ7VB8kda9f3b1";
    }
    return @"dD87UXn23Vw09qp3DnPQ7VB8kda9f3b1";
#endif
    return @"";
}

+ (NSString *)leancloudUrlMd5Key
{
    if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        return @"09FO08#1aAxT";
    } else {
        return @"09FO08#1aAxT";
    }
#if APP_TYPE == 1
#elif APP_TYPE == 2
#elif APP_TYPE == 3
#endif
    return @"";
}

#pragma mark ---推送系统
+ (NSString *)pushApiUrl
{
#if APP_TYPE == 1
    //push站点区分根据国家站区分
    DomainType domainType = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || domainType == DomainType_Release) {

        return @"https://push.adorawe.net/api/sync-fcmtoken";   //改回和安卓一致的旧的域名
    } else {
        // A, S，预发和测试是同一个域名
        return @"http://reach-center.test.shop.testsdlk.com/api/sync-fcmtoken";
    }
    
#elif APP_TYPE == 2
    //push站点区分根据国家站区分
    DomainType domainType = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || domainType == DomainType_Release) {
        return @"https://push.cloudsdlk.com/api/sync-fcmtoken";
    } else {
        // A, S ，预发和测试是同一个域名
        return @"http://reach-center.test.shop.testsdlk.com/api/sync-fcmtoken";
    }

#elif APP_TYPE == 3
    //push站点区分根据国家站区分
    DomainType domainType = [OSSVConfigDomainsManager domainEnvironment];
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || domainType == DomainType_Release) {
        return @"https://push.vivaiacollection.com/api/sync-fcmtoken";
    } else if(domainType == DomainType_Pre_Release) {
        return @"https://pre-push.vivaiacollection.com/api/sync-fcmtoken";
    } else {
        return @"https://reach-center.tools.fat.starlinke.tech/api/sync-fcmtoken";
    }
#endif
    return @"";
}

+ (NSString *)appSiteLaunchUrl {
    
    NSString *domainUrl = @"";

    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    ///occ测试数据
#if APP_TYPE == 1
    //正式、预发布、测试  A
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
        domainUrl = @"https://api.adorawe.net/";
    } else if([OSSVConfigDomainsManager isPreRelease]) {
        
        domainUrl = @"https://pre-api.adorawe.net/";
    } else {
        domainUrl = @"http://api.adorawe.net.shop.testsdlk.com/";
    }
#elif APP_TYPE == 2

    //正式、预发布、测试  S
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
        domainUrl = @"https://api.soulmiacollection.com/";
    } else if([OSSVConfigDomainsManager isPreRelease]) {
        domainUrl = @"https://pre-api.soulmiacollection.com/";
    } else {
        domainUrl = @"http://api.soulmiacollection.com.shop.testsdlk.com/";
    }
#elif APP_TYPE == 3

    //正式、预发布、测试  V
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
        domainUrl = @"https://api.vivaiacollection.com/";
    } else if([OSSVConfigDomainsManager isPreRelease]) {
        domainUrl = @"https://pre-api.vivaiacollection.com/";
    } else {
        //api.vivaiacollection-api.com.{分支名称}.fpm.testsdlk.com
//        domainUrl = @"http://api.vivaiacollection.com.shop.testsdlk.com/";
        NSString* branch = [OSSVConfigDomainsManager localBranch];
        if (branch.length == 0) {
            branch = @"release";
        }
        domainUrl = [NSString stringWithFormat:@"http://api.vivaiacollection-api.com.%@.fpm.testsdlk.com/",branch] ;
    }
#endif
    
    //occ测试数据
//    domainUrl = @"https://api.adorawe.net/";

    NSString *version = [[OSSVConfigDomainsManager gainDomainModule:masterDomain] domainVersion];
    if (version.length) {
        ///如果配置了版本号
        if (![OSSVConfigDomainsManager isDistributionOnlineRelease]) {
            
            NSString *localVersion = [[OSSVConfigDomainsManager sharedInstance] gainCustomerVersion];
            if (!STLIsEmptyString(localVersion)) {
                version = localVersion;
            }
        }
        if ([version rangeOfString:@"/"].location == NSNotFound) {
            domainUrl = [NSString stringWithFormat:@"%@%@/%@", domainUrl, version,kApi_WebsiteConfig];
        }else{
            domainUrl = [NSString stringWithFormat:@"%@%@%@", domainUrl, version,kApi_WebsiteConfig];
        }
    }
    
    return domainUrl;
}

+ (NSString *)appDotCloudUrl {
    
    //无正式与测试
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"http://dot.cloudsdlk.com/dot";
    } else {
        return @"http://dot.cloudsdlk.com/dot";
    }
    
#if APP_TYPE == 1
    
#elif APP_TYPE == 2

#elif APP_TYPE == 3

#endif
    
    return @"";
}




+ (NSString *)appABSnssdkUrl {
    
    ///APP站点区分使用 只A站使用
#if APP_TYPE == 1
    //无正式与测试
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"https://snssdk.cloudsdlk.com";
    } else {
        return @"https://snssdk.cloudsdlk.com";
    }
#elif APP_TYPE == 2

#elif APP_TYPE == 3

#endif
    
    return @"";
    
}

/// =========================== app三方配置信息  =========================== ///

+ (NSString *)googleLoginKey {
    
#if APP_TYPE == 1

    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"492937043190-jff4dle7ab9iv9uvo2et0i00k0e5aj8g.apps.googleusercontent.com";
    } else {
        return @"958842051255-d3paeu0mp41j0v4rtvpd3hf23n6d3osn.apps.googleusercontent.com";
    }
    
#elif APP_TYPE == 2

    // 直接跑线上
//    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"536854787512-bi0mshl8jn6dndce9upniof1ftkej558.apps.googleusercontent.com";
//    } else {
//        return @"530236309409-4kgimgfeusvj7ahig59fp273sv28gav6.apps.googleusercontent.com";
//    }
#elif APP_TYPE == 3
    //直接跑线上
    return @"91125413472-92tckqg7bc8jdkm32pdprfvkoh2l7mua.apps.googleusercontent.com";
#endif
    
    return @"";
}

+ (NSString *)googleSearchAddressApiKey {
#if APP_TYPE == 1
    return @"AIzaSyAKHhQF_3mbGWWquV2jURArjwGSSdH2Maw";
#elif APP_TYPE == 2
    return @"AIzaSyAKHhQF_3mbGWWquV2jURArjwGSSdH2Maw";
#elif APP_TYPE == 3
    return @"AIzaSyAKHhQF_3mbGWWquV2jURArjwGSSdH2Maw";
#endif
    return @"AIzaSyAKHhQF_3mbGWWquV2jURArjwGSSdH2Maw";
}


+ (NSString *)facebookID {
#if APP_TYPE == 1
    return @"610047386311859";
#elif APP_TYPE == 2
    return @"404656420623904";
#elif APP_TYPE == 3
    return @"637613247581555";
#endif
    return @"";
}

// 测试 fb294451711896088
+ (NSString *)facebookSchemeKey {
#if APP_TYPE == 1
    return @"fb610047386311859";
#elif APP_TYPE == 2
    return @"fb404656420623904";
#elif APP_TYPE == 3
    return @"fb637613247581555";
#endif
    return @"";
}

+ (NSString *)appsFlyerKey {
    // 其他项目都是一样的，😅
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"h2aKDhNSyjfE9HeC5kenjC";
    } else {//暂时没有区分测试，上报地方处理，线上环境上报
        return @"h2aKDhNSyjfE9HeC5kenjC";
    }
}

//AF上配置的：xxxx.onelink.me
+ (NSString *)appFlyerOnelink {
    
#if APP_TYPE == 1
    return [NSString stringWithFormat:@"%@.onelink.me",[[OSSVLocaslHosstManager appName] lowercaseString]];
#elif APP_TYPE == 2
    return [NSString stringWithFormat:@"%@.onelink.me",@"v76fw"];
#elif APP_TYPE == 3
    return [NSString stringWithFormat:@"%@.onelink.me",[[OSSVLocaslHosstManager appName] lowercaseString]];
#endif
    return @"";
}

//AF上配置的：xxxx-starlink.onelink.me
+ (NSString *)appFlyerOnelinkTwo {
#if APP_TYPE == 1
    return [NSString stringWithFormat:@"%@-starlink.onelink.me",[[OSSVLocaslHosstManager appName] lowercaseString]];
#elif APP_TYPE == 2
    return [NSString stringWithFormat:@"%@-starlink.onelink.me",@"v76fw"];
#elif APP_TYPE == 3
    return [NSString stringWithFormat:@"%@-starlink.onelink.me",[[OSSVLocaslHosstManager appName] lowercaseString]];
#endif
    return @"";

}

+ (NSString *)fireBaseAppKey {
    
#if APP_TYPE == 1
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"GoogleService-InfoAD";
    } else {
        return @"GoogleService-Info-DebugAD";
    }
    
#elif APP_TYPE == 2
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"GoogleService-InfoSM";
    } else {
        return @"GoogleService-Info-DebugSM";
    }
#elif APP_TYPE == 3
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"GoogleService-InfoVIV";
    } else {
        return @"GoogleService-Info-DebugVIV";
    }
#endif
    return @"";
}

+ (BOOL)isFirebaseConfigureRelease {
    if([[OSSVLocaslHosstManager fireBaseAppKey] containsString:@"Debug"]) {
        return NO;
    }
    return YES;
}

/// 神策url
//测试项目
//接收地址：https://sddatasink.data.starlinke.cn/sa?project=default
//scheme：sae3229b32
//
//正式项目
//接收地址：https://sddatasink.data.starlinke.cn/sa?project=production
//scheme：saeec02316
+ (NSString *)sensorsServerURL {
    
    //一模一样的地址，可能是站点区分吧
#if APP_TYPE == 1
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"https://sddatasink.data.starlinke.cn/sa?project=production";
    } else {
        return @"https://sddatasink.data.starlinke.cn/sa?project=default";
    }
    
#elif APP_TYPE == 2
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"https://sddatasink.data.starlinke.cn/sa?project=production";
    } else {
        return @"https://sddatasink.data.starlinke.cn/sa?project=default";
    }
    
#elif APP_TYPE == 3

    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"https://sddatasink.data.starlinke.cn/sa?project=production";
    } else {
        return @"https://sddatasink.data.starlinke.cn/sa?project=default";
    }
#endif
    
    return @"";
}

/// =========================== app deeplink配置信息  =========================== ///

+ (NSString *)appDeeplinkPrefix {
    //以项目名小写开头
    return [NSString stringWithFormat:@"%@://action",[[OSSVLocaslHosstManager appName] lowercaseString]];
}

/// =========================== app AB配置信息  =========================== ///

+ (NSString *)abTestAppName{
#if APP_TYPE == 1
    return @"adorawe";
    
#elif APP_TYPE == 2

#elif APP_TYPE == 3

#endif
    return @"";
}

+ (NSString *)abTestAppId{
#if APP_TYPE == 1
    return @"10000001";
    
#elif APP_TYPE == 2

#elif APP_TYPE == 3

#endif
    return @"";
}


+ (NSString *)appSearchBytem {

    /**
     通过后台搜索返回数据区分正式与测试
     search_engine:btm
     btm_index:
     */
    
    ///APP站点区分使用 只A站使用
#if APP_TYPE == 1
    if ([[OSSVConfigDomainsManager sharedInstance] thirdConfigureEnvironment]) {
        return @"http://adorawe.search.bytem.com/callback";

    } else {
        return @"http://adorawe.search.bytem.com/callback";

    }
    
#elif APP_TYPE == 2
#elif APP_TYPE == 3

#endif
    return @"";
    
    
}


/// =========================== app 本地分支切换  =========================== ///

/**
 * 当前环境字符串
 */
+ (NSString *)currentLocalHostTitle
{
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {//线上发布直接返回
        return @"线上";
    }
    NSString *branch = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranch];
    NSString *branchNum = [[OSSVConfigDomainsManager sharedInstance] gainCustomerBranchNum];
    NSString *version = [[OSSVConfigDomainsManager sharedInstance] gainCustomerVersion];
    NSString *branchText = @"分支";
    if (branchNum.integerValue > 0) {
        branchText = [NSString stringWithFormat:@"分支 - %@%@, 接口版本号 - %@", branch, branchNum, version];
    }else{
        branchText = [NSString stringWithFormat:@"分支 - %@, 接口版本号 - %@", branch, version];
    }
    return branchText;
}

/// 主弹框标题
+ (NSAttributedString *)fetchAlertTitle
{
    return [NSString getAttriStrByTextArray:@[@"💐当前环境: ", [self currentLocalHostTitle]]
                                    fontArr:@[[UIFont systemFontOfSize:12]]
                                   colorArr:@[[UIColor blackColor],[UIColor redColor]]
                                lineSpacing:0
                                  alignment:0];
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
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        STLLog(@"⚠️⚠️⚠️ 此状态是线上发布生产环境, 切记不能显示切换环境入口 ⚠️⚠️⚠️");
        return;
    }
    
    NSString *appUserId = [NSString stringWithFormat:@"用户UserId: %d", USERID];
    
    // 配置弹框所有按钮的标题-> (按Title添加顺序来显示)
    NSMutableArray *btnTitles = [NSMutableArray array];
    
    NSString *appSite = @"";
    if (APP_TYPE != 1) {///A站不需要切换国家站
        appSite = [self addTitle:@"切换App站点" toArray:btnTitles];
    }
    
    NSString *appHost   = [self addTitle:@"切换App环境" toArray:btnTitles];
    NSString *geshop    = [self addTitle:@"专题测试" toArray:btnTitles];
    NSString *catchLog  = [self addTitle:@"接口日志实时抓包" toArray:btnTitles];
    NSString *webURL    = [self addTitle:@"测试Web/link" toArray:btnTitles];
    
    #if DEBUG
    NSString *flexString = [NSString stringWithFormat:@"圈选坐标：%@",STLUserDefaultsGet(kAppShowFLEXManager)];
    NSString *showFLEXManager = [self addTitle:flexString toArray:btnTitles];
    #endif
    
    NSString *trackString = [NSString stringWithFormat:@"埋点日志开关：%@",STLUserDefaultsGet(kAppShowTrackingManager)];
    NSString *trackSwitchString  = [self addTitle:trackString toArray:btnTitles];

//    NSString *countryIP = [self addTitle:@"测试国家 IP 简码" toArray:btnTitles];
    if ([OSSVAccountsManager sharedManager].isSignIn) { [btnTitles addObject:appUserId]; }

    ShowAlertView([self fetchAlertTitle], nil, btnTitles, ^(NSInteger buttonIndex, id buttonTitle) {
        if ([buttonTitle isKindOfClass:[NSAttributedString class]]) {
            buttonTitle = ((NSAttributedString *)buttonTitle).string;
        }
        
        if ([buttonTitle isEqualToString:geshop]) { //新原生专题临时入口
            [STLAlertView inputAlertWithTitle:geshop
                                     message:nil
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                              textFieldCount:1
                              textFieldBlock:^(NSArray<UITextField *> *textFieldArr) {
                
                UITextField * textField = textFieldArr.firstObject;
                textField.clearButtonMode = UITextFieldViewModeAlways;
                textField.placeholder = @"请输入原生专题id";
                textField.text = STLUserDefaultsGet(@"kNewNativeThemeIdKey");
                
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                      [textField becomeFirstResponder];
                });
            } buttonBlock:^(NSArray<NSString *> *inputTextArr) {
                
                if (inputTextArr.firstObject.length > 0) {
                    STLUserDefaultsSet(@"kNewNativeThemeIdKey", inputTextArr.firstObject);
                    NSString *VCtitle = [NSString stringWithFormat:@"%@环境专题Id: %@",[self currentLocalHostTitle], inputTextArr.firstObject];
                    
                    UIViewController *homeVC = [UIViewController currentTopViewController];
                    [homeVC pushToViewController:@"STLCustomerThemeNewCtrl" propertyDic:@{
                        @"customId":inputTextArr.firstObject,
                        @"customName": VCtitle
                    }];
                }
            } cancelBlock:nil];
            
        }else if ([buttonTitle isEqualToString:appSite]){
            [self changeAppSite];
        }
        else if ([buttonTitle isEqualToString:appHost]) { //切换App请求环境
            [self changeAppRequestUrl];
            
        } else if ([buttonTitle isEqualToString:catchLog]) { //本地实时抓包
            [self dealwithCatchLog];
            
        } else if ([buttonTitle isEqualToString:webURL]) { //打开Web链接
            NSString *key = @"STLAlertViewLastInputText";
            NSString *lastUrl = STLIsEmptyString(STLUserDefaultsGet(key)) ? nil : STLUserDefaultsGet(key);
            
            [STLAlertView inputAlertWithTitle:@"测试加载Web链接/Deeplink"
                                     message:nil
                                        text:lastUrl
                                 placeholder:@"请输入Web链接/Deeplink"
                                 cancelTitle:@"取消"
                                  otherTitle:@"确认"
                                keyboardType:0
                                 buttonBlock:^(NSString *inputText) {
                
                    if (STLIsEmptyString(inputText)) return ;
                    STLUserDefaultsSet(key, inputText);
                
                    if ([inputText hasPrefix:@" "] || [inputText hasSuffix:@" "]) {
                        ShowToastToViewWithText(nil, @"您输入的内容头或尾含有空格");
                        return;
                    }
                    if ([inputText hasPrefix:@"http"]) {
                        UIViewController *homeVC = [UIViewController currentTopViewController];
                        [homeVC pushToViewController:@"STLActivityWWebCtrl" propertyDic:@{@"strUrl":STLToString(inputText)}];
                        
                    } else if ([inputText hasPrefix:[OSSVLocaslHosstManager appDeeplinkPrefix]]) {
                        NSMutableDictionary *paramDict = [OSSVAdvsEventsManager parseDeeplinkParamDicWithURL:[NSURL URLWithString:inputText]];
                        UIViewController *homeVC = [UIViewController currentTopViewController];
                        [OSSVAdvsEventsManager jumpDeeplinkTarget:homeVC deeplinkParam:paramDict];
                        
                    } else {
                        ShowToastToViewWithText(nil, @"您输入的内容既不是Web链接也不是Deeplink");
                    }
           } cancelBlock:nil];
            
        }
        else if ([buttonTitle isEqualToString:trackSwitchString]) {
            if ([STLUserDefaultsGet(kAppShowTrackingManager) boolValue]) {
                STLUserDefaultsSet(kAppShowTrackingManager, @(NO));
            } else {
                STLUserDefaultsSet(kAppShowTrackingManager, @(YES));
            }
        }
#if DEBUG
        else if ([buttonTitle isEqualToString:showFLEXManager]) {
            if ([STLUserDefaultsGet(kAppShowFLEXManager) boolValue]) {
                
                [[FLEXManager sharedManager] hideExplorer];
                STLUserDefaultsSet(kAppShowFLEXManager, @(NO));
            } else {
                [[FLEXManager sharedManager] showExplorer];
                STLUserDefaultsSet(kAppShowFLEXManager, @(YES));
            }
        }
#endif
        else if ([buttonTitle isEqualToString:appUserId]) { //复制UserId
            [UIPasteboard generalPasteboard].string = [NSString stringWithFormat:@"%d",USERID];
            ShowToastToViewWithText(nil, @"用户UserId已复制到剪切板");
        }
    }, @"取消", nil);
}

/**
 * 配置切换网络环境
 */
+ (void)changeAppRequestUrl {
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        STLLog(@"⚠️⚠️⚠️ 此状态是线上发布生产环境, 切记不能显示切换环境入口 ⚠️⚠️⚠️");
        return;
    }
    NSArray *otherBtnArray = @[@"主干", @"预发布", @"线上", @"切换测试分支"];
    ShowAlertView([self fetchAlertTitle], nil, otherBtnArray, ^(NSInteger buttonIndex, id buttonTitle) {
        
        if (buttonIndex == 3) { //切换后台测试分支
            [OSSVLocaslHosstManager showDevAlertCustomerView];
            
        } else if (buttonIndex == 4) { //切换社区测试分支
            
            
            
        } else { // 切换App环境: 主干, 预发布, 线上
            NSInteger envType = 1 << buttonIndex;
            [OSSVLocaslHosstManager showReleaseAlertCustomerView:envType];
        }
    }, @"取消", nil);
}

+(void)changeAppSite{
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease]) {
        STLLog(@"⚠️⚠️⚠️ 此状态是线上发布生产环境, 切记不能显示切换环境入口 ⚠️⚠️⚠️");
        return;
    }
    NSString *appName = OSSVLocaslHosstManager.appName.lowercaseString;
    NSString *message = [NSString stringWithFormat:@"输入国家站点code例如：%@、%@_de、%@_mx、%@_cl,%@_ar",appName,appName,appName,appName,appName];
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:@"输入站点code" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入接口版本号";
        NSString *siteCode = [[NSUserDefaults standardUserDefaults] objectForKey:STLSiteCode];
        NSString *currentSiteCode = STLWebsitesGroupManager.currentCountrySiteCode;
        textField.text = siteCode ? siteCode : currentSiteCode;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController.textFields enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                //允许设置空值清空
                [[NSUserDefaults standardUserDefaults] setObject:obj.text forKey:STLSiteCode];
            }
        }];
        [OSSVAccountsManager logout];
        [OSSVLocaslHosstManager logOutApplication];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [UIViewController.currentTopViewController presentViewController:alertController animated:YES completion:^{}];
}

+ (void)showReleaseAlertCustomerView:(DomainType)type
{
    NSString *message = @"第一个输入框输入的是版本号,因为正式环境和预发布环境都没有分支，所以只支持版本替换 例:vx_x";
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:@"输入分支" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入接口版本号";
        NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:STLVersion];
        NSString *currentVersion = [[OSSVConfigDomainsManager gainDomainModule:masterDomain] domainVersion];
        textField.text = version ? version : currentVersion;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [alertController.textFields enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                if (obj.text.length) {
                    if ([obj.text rangeOfString:@"/"].location == NSNotFound) {
                        obj.text = [NSString stringWithFormat:@"%@/", obj.text];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:obj.text forKey:STLVersion];
                }
            }
        }];
        [[NSUserDefaults standardUserDefaults] setObject:@"0" forKey:STLBranchNum];
        [[OSSVConfigDomainsManager sharedInstance] setCustomerDevelopmentModel:type];
        [OSSVAccountsManager logout];
        [OSSVLocaslHosstManager logOutApplication];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [UIViewController.currentTopViewController presentViewController:alertController animated:YES completion:^{}];
}

+ (void)showDevAlertCustomerView
{
//    NSString *message = @"第一个输入框输入的是分支名 例:a,b,c,d \n 第二个输入框输入的是分支名的版本号，默认为0 例:a01,a01,b01 \n 第三个是输入框是接口版本号";
    NSString *message = @"第一个输入框输入的是分支名 例:a,b,c,d \n 第二个输入框《暂时无效》 \n 第三个是输入框是接口版本号";
    STLAlertViewController *alertController = [STLAlertViewController alertControllerWithTitle:@"输入分支" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入分支";
        NSString *branch = [[NSUserDefaults standardUserDefaults] objectForKey:STLBranch];
        textField.text = branch ? branch : @"a";
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
//        textField.placeholder = @"请输入分支版本号";
//        NSString *num = [[NSUserDefaults standardUserDefaults] objectForKey:STLBranchNum];
//        textField.text = num ? num : @"0";
        textField.placeholder = @"此栏暂时无效";
        textField.enabled = NO;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入接口版本号";
        NSString *version = [[NSUserDefaults standardUserDefaults] objectForKey:STLVersion];
        NSString *currentVersion = [[OSSVConfigDomainsManager gainDomainModule:masterDomain] domainVersion];
        textField.text = version ? version : currentVersion;
    }];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        __block NSString *branch = [[NSString alloc] init];
        [alertController.textFields enumerateObjectsUsingBlock:^(UITextField * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (idx == 0) {
                [[NSUserDefaults standardUserDefaults] setObject:obj.text forKey:STLBranch];
                branch = [NSString stringWithFormat:@"%@%@", branch, obj.text];
            }
            if (idx == 1) {
                [[NSUserDefaults standardUserDefaults] setObject:obj.text forKey:STLBranchNum];
                if (obj.text.integerValue != 0) {
                    branch = [NSString stringWithFormat:@"%@%@", branch, obj.text];
                }
            }
            if (idx == 2) {
                if (obj.text.length) {
                    if ([obj.text rangeOfString:@"/"].location == NSNotFound) {
                        obj.text = [NSString stringWithFormat:@"%@/", obj.text];
                    }
                    [[NSUserDefaults standardUserDefaults] setObject:obj.text forKey:STLVersion];
                }
            }
        }];

        [[OSSVConfigDomainsManager sharedInstance] setCustomerDevelopmentModel:DomainType_DeveInput];
        [OSSVAccountsManager logout];
        [OSSVLocaslHosstManager logOutApplication];
    }]];
    
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }]];
    
    [UIViewController.currentTopViewController presentViewController:alertController animated:YES completion:^{}];
}


///本地实时抓包-> http://10.36.5.100:8090
+ (void)dealwithCatchLog {
    NSString *alertMsg = [NSString stringWithFormat:@"当前筛选日志标签: %@", [OSSVConfigDomainsManager localCatchLogTagKey]];
    alertMsg = [NSString stringWithFormat:@"%@\n筛选栏输入%@,关闭上传抓包",alertMsg,STLOpenLogSystemTag];
    
    NSMutableString *alertTitle = [NSMutableString stringWithString:@"请在电脑浏览器输入当前抓包IP地址: "];
    NSString *catchLogUrl = [OSSVConfigDomainsManager localCatchLogURLKey];
    if (STLIsEmptyString(catchLogUrl)) {
        NSURL *url = [NSURL URLWithString:[OSSVConfigDomainsManager localRequestLogToUrl]];
        [alertTitle appendFormat:@"%@:%@",url.host, url.port];
        
    } else if ([catchLogUrl containsString:@":"]) {
        [alertTitle appendString:catchLogUrl];
    } else {
        [alertTitle appendFormat:@"%@:8090",catchLogUrl];
    }
    [STLAlertView inputAlertWithTitle:alertTitle
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
                                  if (!STLIsEmptyString(inputText)){
                                      inputText = [inputText stringByReplacingOccurrencesOfString:@" " withString:@""];
                                      
                                      [OSSVConfigDomainsManager saveLocalCatchLogURLKey:inputText];
                                  }
                              } else {
                                  if ([STLToString(inputText) isEqualToString:STLOpenLogSystemTag]) {
                                      [OSSVConfigDomainsManager saveLocalCatchLogTagKey:STLOpenLogSystemTag];
                                      [OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem = NO;
                                      tipText = @"已关闭抓包IP地址";
                                  } else {
                                      [OSSVConfigDomainsManager saveLocalCatchLogTagKey:inputText];
                                      [OSSVRequestsConfigs sharedInstance].uploadResponseJsonToLogSystem = YES;
                                      tipText = [NSString stringWithFormat:@"保存抓包IP地址成功--%@",inputText];
                                  };
                              }
                          }
                          ShowToastToViewWithText(nil, tipText);
                          
                      } cancelBlock:nil];
    
}

+ (void)logOutApplication {
    [UIView animateWithDuration:0.5f animations:^{
        WINDOW.backgroundColor = OSSVThemesColors.col_FFFFFF;
        WINDOW.alpha = 0;
        CGFloat y = WINDOW.bounds.size.height;
        CGFloat x = WINDOW.bounds.size.width / 2;
        WINDOW.frame = CGRectMake(x, y, 0, 0);
    } completion:^(BOOL finished) {
        STLLog(@"退到后台, 输入的分支:%@",[OSSVConfigDomainsManager localBranch]);
        exit(0);
    }];
}

+ (NSString *)branchKey{
    
    NSDictionary *branchKeys = @{
        @"adorawe":@{
            @"debug":@"key_test_jn9a2uSzV01pOZrpS4P6LoddEuhSzGff",
            @"release":@"key_live_lb1m6ALDU26aS0yoK9FNWaggxtkVDw8Y",
        },
        @"vivaia":@{
            @"debug":@"key_test_ap3rmIIyOR4Eic9TA7JLvbimzqhz8ku4",
            @"release":@"key_live_de1EiTMxKKWubi4Pq0FV9bajsFdv5hBK",
        },
        @"soulmia":@{
            @"debug":@"key_live_gb2EhVPGS6eT7BWxc9tQMibfutkJsAjU",
            @"release":@"key_live_gb2EhVPGS6eT7BWxc9tQMibfutkJsAjU",
        },
    };
    
    NSDictionary *currentAppDic = branchKeys[self.appName.lowercaseString];
    
    DomainType type = [OSSVConfigDomainsManager domainEnvironment];
    //正式、预发布、测试  V
    if ([OSSVConfigDomainsManager isDistributionOnlineRelease] || type == DomainType_Release) {
        return currentAppDic[@"release"];
    } else if([OSSVConfigDomainsManager isPreRelease]) {
        return currentAppDic[@"release"];
    } else {
        return currentAppDic[@"debug"];
    }

}



@end
