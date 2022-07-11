//
//  OSSVLocaslHosstManager.h
// XStarlinkProject
//
//  Created by odd on 2020/7/20.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSSVConfigDomainsManager.h"
NS_ASSUME_NONNULL_BEGIN

@interface OSSVLocaslHosstManager : NSObject

+(instancetype)sharedInstance;
@property (nonatomic, strong) UIView *bgConentView;


/// =========================== app配置信息  =========================== ///
+ (NSString *)appStoreId;

//跳转到评分页
+ (NSString *)appStoreReviewUrl;

+ (NSString *)appStoreDownUrl;

+ (NSString *)appName;
+ (NSString *)appScheme;
+ (NSString *)projectAppnameLowercaseString;

+ (NSString *)appHelpUrl:(HelpType)type;

/// =========================== app请求配置信息  =========================== ///
////正式预发布

+ (NSString *)appLocalTestReviewHost;
+ (NSString *)appLocalOnleReviewHost;
+ (NSString *)appLocalPreOnleReviewHost;

+ (NSString *)appLocalTestReviewPictureDomain;
+ (NSString *)appLocalOnleReviewPictureDomain;
+ (NSString *)appLocalPreOnleReviewPictureDomain;
// 新 one
+ (NSString *)appSiteLaunchUrl;

///// DES加密（key与偏移）
+ (NSString *)appDesEncrypt_iv;
+ (NSString *)appDesEncrypt_key;

/**
 * 切换当前环境配置
 */
+ (void)changeLocalHost;

///评论系统key
+ (NSString *)reviewSystemKey;


/// push key
+ (NSString *)leancloudUrlMd5Key;
+ (NSString *)pushApiUrl;


///后台新打点日志
+ (NSString *)appDotCloudUrl;

///后台ab实验
+ (NSString *)appABSnssdkUrl;

/// =========================== app三方配置信息  =========================== ///

+ (NSString *)googleLoginKey;
///谷歌地址搜索key
+ (NSString *)googleSearchAddressApiKey;
///
+ (NSString *)facebookID;
+ (NSString *)facebookSchemeKey;

///
+ (NSString *)appsFlyerKey;

//AF上配置的：adorawe-starlink.onelink.me
+ (NSString *)appFlyerOnelink;
+ (NSString *)appFlyerOnelinkTwo;

///
+ (NSString *)fireBaseAppKey;
+ (BOOL)isFirebaseConfigureRelease;
/// 神策url
+ (NSString *)sensorsServerURL;

/// =========================== app deeplink配置信息  =========================== ///

+ (NSString *)appDeeplinkPrefix;

///AB TEST 
+ (NSString *)abTestAppName;
+ (NSString *)abTestAppId;

///华为搜索
+ (NSString *)appSearchBytem;

+ (NSString *)branchKey;

@end

NS_ASSUME_NONNULL_END
