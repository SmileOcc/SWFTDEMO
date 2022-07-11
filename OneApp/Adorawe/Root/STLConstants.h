//
//  STLConstants.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/25.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#ifndef STLConstants_h
#define STLConstants_h

/**
 * 一键切换网络环境, (0️⃣:主干   1️⃣:预发布   2️⃣:线上)
* ⚠️警告⚠️:开发期间不要提交类型为2️⃣的环境到git主仓库,
 * 线上发版时直接改成2️⃣的Type, 切换到Release模式打包发布即可
*/
#define AppRequestType         0

#pragma mark - 常用变量

//App版本号
#define APPVIERSION             @"APPVIERSION"

#pragma mark -==================================用户相关key====================================

#define USERID                  [[OSSVAccountsManager sharedManager] userId]
#define USERID_STRING           [[OSSVAccountsManager sharedManager] userIdString]
#define USER_TOKEN              [OSSVAccountsManager sharedManager].userToken

#pragma mark - 系统相关
// 系统版本
#define DSYSTEM_VERSION [[[UIDevice currentDevice] systemVersion] floatValue]

// 系统判断
#define ISIOS11 ([[[UIDevice currentDevice] systemVersion] floatValue] >= 11.0) // IOS11的系统

#pragma mark - 屏幕大小
#define SCREEN_WIDTH                    ([[UIScreen mainScreen]bounds].size.width)
#define SCREEN_HEIGHT                   ([[UIScreen mainScreen]bounds].size.height)
#define SCREEN_WITHOUT_STATUS_HEIGHT    (SCREEN_HEIGHT - [[UIApplication sharedApplication] statusBarFrame].size.height)

#define kNAVBARHEIGHT                    self.navigationController.navigationBar.frame.size.height
#define kSTATUSHEIGHT                    [UIApplication sharedApplication].statusBarFrame.size.height
#define kTabBarHeight                    self.tabBarController.tabBar.bounds.size.height


#define kScale_375                      SCREEN_WIDTH / 375.0
#define kSCREEN_BAR_HEIGHT               (kIS_IPHONEX ? 44 : 20)
#define SCREENSCALE                     [UIScreen mainScreen].scale
#define MIN_PIXEL                       1/SCREENSCALE
#define DSCREEN_HEIGHT_SCALE            SCREEN_HEIGHT / 568.0
#define DSCREEN_WIDTH_SCALE             SCREEN_WIDTH / 320.0
#define DSCREEN_WIDTH_375_SCALE         SCREEN_WIDTH / 375.0
//iPhoneX状态栏增加尺寸
#define kIPHONEX_TOP_SPACE                   ((SCREEN_HEIGHT > 736.0)?24:0)
#define kIPHONEX_BOTTOM                  ((SCREEN_HEIGHT > 736.0)?34:0)
#define kNavHeight                       (64+kIPHONEX_TOP_SPACE)
#define kTabHeight                       (49+kIPHONEX_BOTTOM)
//获取键盘高度
#define KEYBOARD_SIZE_HIGHT             216.0
//判断机型
#define IPHONE_4X_3_5 (SCREEN_HEIGHT==480.0f)
#define IPHONE_5X_4_0 (SCREEN_HEIGHT==568.0f)
#define IPHONE_6X_4_7 (SCREEN_HEIGHT==667.0f)
#define IPHONE_6P_5_5 (SCREEN_HEIGHT==736.0f || SCREEN_WIDTH==414.0f)
#define kIS_IPHONEX    (SCREEN_HEIGHT >= 812.0f)

#define NavBarButtonSize                (24.0)
#define NavBarSearchHeight                (32.0)

//分类展示屏幕大小
#define CATEGORY_SCREEN_SCALE (SCREEN_WIDTH - 100) / (320.0 - 100)
#define STL_COLLECTION_MOVECONTENT_HEIGHT SCREEN_HEIGHT  //滑动多少后，显示那个滑动到顶部的button
#define STL_TEXTFIELD_INPUT_MAX_LENGTH       35 //TextField 最多输入的字符数目
#define STL_NAVBAR_HEIGHT                    64.0 // NavBar的高度
#define STL_TABBAR_HEIGHT                    49.0 // TabBar的高度
#define STL_TABBAR_IPHONEX_H                 34.0 // iphoneX的高度

#define kGoodsWidth (SCREEN_WIDTH - kPadding * 3.0) / 2.0
#define kPadding                12
#define kBottomPadding          12
#define KColumnIndex2           2
#define KColumnIndex3           3
#define kHomeCellBottomViewHeight   49.0f // 底部高度

#define kPaddingGoodsDetailSpace   8

///商品详情满减字体
#define kGoodsDetailFullReducFontSize 13


// 时间
#define sec_per_min     60
#define sec_per_hour    3600
#define sec_per_day     86400
#define sec_per_month   2592000
#define sec_per_year    31104000

#define SHAREDAPP       [UIApplication sharedApplication]
#define APPDELEGATE     ((AppDelegate*)[SHAREDAPP delegate])
#define WINDOW          [[UIApplication sharedApplication].delegate window]

#define SHOW_SYSTEM_ACTIVITY(value)  [SHAREDAPP setNetworkActivityIndicatorVisible:value]

// 字体号
#define FontWithSize(x) [UIFont systemFontOfSize:x]

#pragma mark - 常用方法
// URL编码/解码
#define URLENCODING(s)  [s stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]

#define REMOVE_URLENCODING(s)  [s stringByRemovingPercentEncoding]

// Directory / Cache 数据库
#define STL_PATH_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define STL_PATH_CACHE [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]

#define STL_PATH_DATABASE_CACHE [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0]

// UserDefaults
#define STLUserDefaultsGet(key) [[NSUserDefaults standardUserDefaults] objectForKey:key]
#define STLUserDefaultsSet(key,value) [[NSUserDefaults standardUserDefaults] setObject:value ?:@"" forKey:key]

// 自定义Log
#ifdef DEBUG
#define STLLog(...) NSLog(__VA_ARGS__)
#define NSLog(...) NSLog(__VA_ARGS__)
#define DLog(fmt, ...) fprintf(stderr,"%s: %s [Line %d]\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);
#else
#define STLLog(...)
#define NSLog(...)
#define DLog(...)
#endif

// 弱应用
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
            #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
            #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
            #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
            #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif


// Appflyer数据
#define APPFLYER_ALL_PARAMS                 @"APPFLYER_ALL_PARAMS"
#define ADID                                @"ad_id"
#define MEDIA_SOURCE                        @"media_source"
#define CAMPAIGN                            @"campaign"
#define LKID                                @"lkid"
#define FIRST_LOAD                          @"firstLoad"
#define AFADGroup                           @"adgroup"

#define NOTIFICATIONS_PAYMENT_PARMATERS   @"notificationPaymentParmaters"
#define SAVE_NOTIFICATIONS_PARMATERS_TIME @"saveNotificationsParmatersTime"

#define ONELINK_PARMATERS   @"ONELINK_PARMATERS"
#define SAVE_ONELINK_PARMATERS_TIME @"SAVE_ONELINK_PARMATERS_TIME"
#define ONELINK_SHAREUSERID   @"ONELINK_SHAREUSERID"

// 加载更多
#define STLLoadMore                          @"0"
// 刷新
#define STLRefresh                           @"1"
// 无法刷新更多了
#define STLNoMoreToLoad                      @"NoMoreToLoad"

#define kLoadingView                         @"kloadingView"

//返回状态码
#define kStatusCode                          @"statusCode"
//直接返回的result 结果
#define kResult                              @"result"
#define kErrorKey                            @"error"
#define kMsgKey                              @"msg"
#define kMessagKey                           @"message"

//正确的返回码
#define kStatusCode_200                      200

//错误码
#define kStatusCode_201                      201
//登录未注册
#define kStatusCode_203                      203
//已注册
#define kStatusCode_204                      204
//重新登录
#define kStatusCode_302                      302

//弹窗提示
#define kStatusCode_205                      205
//下单时候需要弹身份证弹窗
#define kStatusCode_208                      208

//下单支付方式折扣信息改变的时候
#define kStatusCode_209                      209

//身份证提示信息
#define kStatusCode_210                      210

#define PageSize                            @"15"

#define kLastLanag                           @"lastLang"

// 1为加密   0不加密
#define ISENC @"1"
#define kAppVersion  [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define kPlatform    STLToString([STLDeviceInfoManager sharedManager].platomDeviceType)
#define kUserEmail              @"kUserEmail"
#define kExchangeKey            @"kExchangeKey"
#define kCurExchangeKey         @"kCurExchangeKey"

/**汇率-文件名称*/
#define kCurRateName            @"kCurRateName"
/**当前汇率-文件名称*/
#define kRateName               @"kRateName"
/**当前货币*/
#define kNowCurrencyKey         @"kNowCurrencyKey"
/**当前货币模型*/
#define kNowCurrencyRateKey     @"kNowCurrencyRateKey"
/**当前货币*/
#define kIsSettingCurrentKey    @"kIsSettingCurrentKey"
/**国别*/
#define kCountryKey             @"kCountryKey"
/**国别-文件名称*/
#define kCountryName            @"kCountryName"
/**主要用于记录用户性别本地存储*/
#define kGenderKey              @"kGenderKey"
/**主要用于记录信息来源*/
#define kSourceKey              @"kSourceKey"
/**商品当天详情页进入的时间*/
#define kGoodsDetailTime        @"kGoodsDetailTime"
/**分享是否展示过强烈感知模块*/
#define kShareStrongFell        @"kShareStrongFell"
/**首页是否展示过banner*/
#define kHomeDisplayBanner        @"kHomeDisplayBanner"
/**首页是否展示过banner*/
#define kHomeDisplayBannerID        @"kHomeDisplayBannerID"
/**商品详情页是否展示过banner*/
#define kGoodsDetailDisplayBanner        @"kGoodsDetailDisplayBanner"
/**商品详情页是否展示过banner*/
#define kGoodsDetailDisplayBannerID        @"kGoodsDetailDisplayBannerID"


#define kCFgOnlineAppsOnleDomain      @"OnlineAppsOnleDomain"

#define kHadShowSystemNotificationAlert         @"kHadShowSystemNotificationAlert"
#define kHadRegisterRemotePush                  @"kHadRegisterRemotePush"

#define kDefaultCountryCode       @"kDefaultCountryCode"
#define kDefaultCountryPhoneCode  @"kDefaultCountryPhoneCode"
#define kDefaultCountryPicUrl       @"kDefaultCountryPicUrl"

#endif /* STLConstants_h */
