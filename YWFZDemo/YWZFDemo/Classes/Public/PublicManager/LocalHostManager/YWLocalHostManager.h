//
//  YWLocalHostManager.h
//  ZZZZZ
//
//  Created by YW on 11/4/18.
//  Copyright © 2018年 YW. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YWLocalHostManager : NSObject

+ (NSString *)appBaseUR;

/// cms接口基地址
+ (NSString *)cmsAppBaseURL;

/**
 * 根据频道请求CMS备份在S3服务器上的缓存数据接口
 @param channelID 频道id
 */
+ (NSString *)cmsHomePageJsonS3URL:(NSString *)channelID;

/** 社区baseUrl */
+ (NSString *)communityAppBaseURL;

+ (NSString *)communityNewBaseURL:(NSString *)portName;

/** 社区直播相关*/
+ (NSString *)communityNewLiveBaseURL:(NSString *)portName;


+ (NSString *)appH5BaseURL;

/// AZZZZZ内部以图搜图
+ (NSString *)zfSearchImageURL;

//+ (NSString *)appH5ELFBaseURL;

+ (NSString *)appCardIntroURL;

/// V5.6.0: 原生专题详情URL
+ (NSString *)geshopDetailURL;

/// V5.6.0: 原生专题根据组件id请求组件数据URL
+ (NSString *)geshopAsyncInfoURL;

+ (NSString *)appCommunityIntroURL;

+ (NSString *)appCommunityShareURL;

+ (NSString *)appAuthQuickPayURL;

+ (NSString *)appPrivateKey;

+ (NSString *)appCommunityPrivateKey;

/**社区直播请求key*/
+ (NSString *)appCommunityLivePrivateKey;

+ (NSString *)appCommunityPostApiPrivateKey;

+ (NSString *)appAppsFlyerKey;

+ (NSString *)fireBaseAppKey;

+ (NSString *)appBuglyAppId;

+ (NSString *)appLeanCloudApplicationID;

+ (NSString *)appLeanCloudClientKey;

+ (NSString *)searchMapURL;

+ (NSString *)contactUsURL;

+ (NSString *)syncPushClickDataUrl;

+ (NSString *)fCMTokenUserInfoUrl;

+ (NSString *)leancloudUrlMd5Key;

/**
 * 内部地址经纬度定位
 */
+ (NSString *)addressLocationApiURL;

/**
 * app内bts请求地址
 */
+ (NSString *)appBtsSingleUrl;

/**
 * 多个BTS实验接口(数组方式)
 */
+ (NSString *)appBtsListUrl;


#pragma mark -===========判断当前环境===========
/**
 * 当前环境是否为线上布生产模式 (打包发布审核环境)
 */
+ (BOOL)isDistributionOnlineRelease;

/**
 * 当前环境是否为线上环境
 */
+ (BOOL)isOnlineRelease;

/**
 * 当前环境是否为预发布
 */
+ (BOOL)isPreRelease;

/**
 * 当前环境是否为开发环境
 */
+ (BOOL)isDevelopStatus;

/**
 * 显示当前环境弹框标题
 */
+ (NSString *)currentLocalHostTitle;

/**
 * 切换当前环境配置
 */
+ (void)changeLocalHost;

/**
 * 清除App所有网络接口缓存
 */
+ (void)clearZFNetworkCache;

/**
 * 退到桌面, 强制退出APp
 */
+ (void)logOutApplication;

/**
 * 推送通知打开app处理
 */
+ (void)launchOptionsRemoteOpenAppOptions:(NSDictionary *)launchOptions;


+ (BOOL)stateLaunchOptionsRemoteOpenApp;

/**
 * 推送通知点击打开跳转下一级时,接口添加标识
 */
+ (void)tipRemoteNotificatAlertEvent;

/**
* 推送通知打开 所以请求标记处理userAgent: RequestFlag/Push
* 当请求峰值太高是，若配置RequestFlag/Push，接口会直接请求失败
*/
+ (NSString *)requestFlagePushUserAgent;

@end
