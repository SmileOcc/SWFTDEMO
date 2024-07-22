//
//  Constants.h
//  ZZZZZ
//
//  Created by YW on 18/9/13.
//  Copyright © 2018年 YW. All rights reserved.
//®
#ifndef Constants_h
#define Constants_h

#import "AppDelegate.h"
#import "AccountManager.h"
#import "Configuration.h"
#import "ZFPubilcKeyDefiner.h"
#import "ZFNotificationDefiner.h"

#pragma mark -===========================系统版本号=============================
//系统版本号
#define kiOSSystemVersion               [[[UIDevice currentDevice] systemVersion] floatValue]
#define IOS67UP                         (kiOSSystemVersion >= 6.0)     // 大于等于IOS7的系统
#define IOS7UP                          (kiOSSystemVersion >= 7.0)     // 大于等于IOS7的系统
#define IOS8UP                          (kiOSSystemVersion >= 8.0)     // 大于等于IOS8的系统
#define IOS9UP                          (kiOSSystemVersion >= 9.0)     // 大于等于IOS9的系统
#define IOS103UP                        (kiOSSystemVersion >= 10.3)    // 大于等于IOS10.3的系统
#define IOS11UP                         (kiOSSystemVersion >= 11.0)    // 大于等于IOS11的系统
#define IOS13UP                         (kiOSSystemVersion >= 13.0)    // 大于等于IOS13的系统

///弧度转角度
#define RADIANS_TO_DEGREES(radians)     ((radians) * (180.0 / M_PI))
///角度转弧度
#define DEGREES_TO_RADIANS(angle)       ((angle) / 180.0 * M_PI)


#pragma mark -==================================常用目录====================================
// Directory 目录
#define ZFPATH_DIRECTORY                [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0]
// Cache 目录
#define ZFPATH_CACHE                    [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
// 数据库 目录
#define ZFPATH_DATABASE_CACHE           [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0]


#pragma mark -==================================用户相关key====================================
#define ISLOGIN                         [AccountManager sharedManager].isSignIn
#define USERID                          [[AccountManager sharedManager] userId]
#define TOKEN                           [[AccountManager sharedManager] token]
#define SESSIONID                       [[NSUserDefaults standardUserDefaults] objectForKey:kSessionId] == nil ? @"" :[[NSUserDefaults standardUserDefaults] objectForKey:kSessionId]


#pragma mark -==================================自定义Log====================================
#ifdef DEBUG
    // 判断是真机还是模拟器
    #if TARGET_OS_IPHONE
    //iPhone Device
        //#define YWLog(fmt, ...) fprintf(stderr,"%s: %s [Line %d]\t%s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String],__PRETTY_FUNCTION__, __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);
    #define YWLog(fmt, ...) fprintf(stderr,"%s: [Line %d] %s\n",[[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, [[NSString stringWithFormat:fmt, ##__VA_ARGS__] UTF8String]);
    #elif TARGET_IPHONE_SIMULATOR
    //iPhone Simulator
        #define YWLog(arg,...) //NSLog(@"%s " arg ,__PRETTY_FUNCTION__, ##__VA_ARGS__)
    #endif
#else
    #define YWLog(...)
    #define NSLog(format,...)
#endif


#pragma mark -==================================弱引用宏====================================
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

#pragma mark -==================================忽略警告====================================
//-忽略警告的宏-
#define ZFPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

//-忽略警告的宏- eg: [obj respondsToSelector:@(xxx)]
#define ZFUndeclaredSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wundeclared-selector\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)

//方法废弃注解
#define ZF_DEPRECATED_MSG_ATTRIBUTE(msg) __attribute__((deprecated(msg)))

#pragma mark -========================设置App字体====================================
//字体加粗名称
#define FONT_BOLD                                   @"Helvetica-Bold"
#define FONT_HIGHT                                  @"STHeitiTC-Light"
//设置自定义细体字
#define ZFFontCustomThinSize(fontSize)              [UIFont fontWithName:@"Heiti SC" size:fontSize]
//设置系统默认字体的大小
#define ZFFontSystemSize(fontSize)                  [UIFont systemFontOfSize:fontSize]
//设置系统粗体字体
#define ZFFontBoldSize(fontSize)                    [UIFont boldSystemFontOfSize:fontSize]
//品牌升级第一期数字字体
#define ZFNumberFontSize(fontSize)                  [UIFont fontWithName:@"DINAlternate-Bold" size:fontSize];
//自定义字体大小
#define ZFFontCustomSize(fontName,fontSize)         ([UIFont fontWithName:fontName size:fontSize])



#pragma mark -=========================== 偏好设置快捷操作宏 =============================
//判空对象
#define isNull(obj)                                 (((NSNull *)obj == [NSNull null])?YES:NO)

/** 保存数据到偏好设置 */
#define SaveUserDefault(key,Obj) \
({  if (!isNull(key) && !isNull(Obj) && key != nil  && Obj != nil) { \
[[NSUserDefaults standardUserDefaults] setObject:Obj forKey:key]; \
[[NSUserDefaults standardUserDefaults] synchronize]; } \
})

/** 获取偏好设置数据 */
#define GetUserDefault(key)  key!=nil ? [[NSUserDefaults standardUserDefaults] objectForKey:key] : nil



#pragma mark -===========================其他相关宏=============================
// 版本号
#define ZFSYSTEM_VERSION                            [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]

#define mas_equalTo(...)                            equalTo(MASBoxValue((__VA_ARGS__)))

#define RegularExpression                           @"#([^\\s]+)\\s"
#define SHAREDAPP                                   [UIApplication sharedApplication]
#define APPDELEGATE                                 ((AppDelegate*)[SHAREDAPP delegate])
#define WINDOW                                      [[UIApplication sharedApplication].delegate window]
// 时间
#define sec_per_min                                 60
#define sec_per_hour                                3600
#define sec_per_day                                 86400
#define sec_per_month                               2592000
#define sec_per_year                                31104000

//显示在window上的注册通知视图tag
#define kRegisterNotificationViewTag                (520)
//显示在window上的首页浮窗广告视图tag
#define kHomeFloatingViewTag                        (620)
//显示在window上的321倒计时广告视图tag
#define kZFLaunchAdvertViewTag                      (720)
//显示在window上的App升级视图tag
#define kZFAppUpgradeViewTag                        (820)
//显示在window上的未支付订单提示弹框tag
#define kZFUnpaidOrderViewTag                       (920)
//显示在window上的启动动画视图tag
#define kZFLaunchAnimationViewTag                   (1024)

//请求路径
#define ENCPATH                                     [NSStringUtils buildRequestPath:@""]
#define NullFilter(s)                               [NSStringUtils emptyStringReplaceNSNull:s]

#define YW_GA_DEFAULT YW_GA_CONFIG[@"en"][([YWLocalHostManager isOnlineRelease]) ? kCfgGATrackingId : kCfgDevGATrackingId]
#define YW_GA_CURRENT YW_GA_CONFIG[[ZFLocalizationString shareLocalizable].nomarLocalizable][([YWLocalHostManager isOnlineRelease]) ? kCfgGATrackingId : kCfgDevGATrackingId]


#endif /* Constants_h */
