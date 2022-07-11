//
//  YXShareHelper.h
//  uSmartOversea
//
//  Created by ellison on 2018/9/12.
//  Copyright © 2018年 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <ShareSDK/ShareSDK.h>

#pragma mark - 配置开启平台

#define IMPORT_SUB_WechatSession
#define IMPORT_SUB_WechatTimeline
#define IMPORT_Facebook
#define IMPORT_Twitter

#ifndef YX_UNIVERSAL_LINKS
    #if defined(PRD) || defined(PRD_HK) || defined(AD_HOC_SIT)
        #define YX_UNIVERSAL_LINKS @"https://m.usmartsecurities.com"
    #else
        #define YX_UNIVERSAL_LINKS @"https://m1-uat.yxzq.com"
    #endif
#endif

#ifndef YX_WECHAT_UNIVERSAL_LINKS
    #if defined(PRD) || defined(PRD_HK) || defined(AD_HOC_SIT)
        #define YX_WECHAT_UNIVERSAL_LINKS @"https://m.usmartsg.com/app_universal_links/"
    #else
        #define YX_WECHAT_UNIVERSAL_LINKS @"https://m-uat.yxzq.com/oversea_app_universal_links/"
    #endif
#endif

#pragma mark - 微信平台的配置信息
/*
 info.plist 中需要设置 白名单 LSApplicationQueriesSchemes
 <string>weixin</string>
 
 info.plist 中需要设置 URL Schemes
 规则 appID 例：wx4868b35061f87885
 
 Other Linker Flags 需设置 -ObjC
 
 授权：客户端SSO 未安装客户端则会使用应用内web
 
 分享：仅客户端 微信好友 文字 图片 链接 音乐链接 视频链接 应用消息 表情 文件[本地视频] 小程序
 微信朋友圈 文字 图片 链接 音乐链接 视频链接
 微信收藏 文字 图片 链接 音乐链接 视频链接 文件[本地视频]
 
 分享详例：MOBWechatcontactsViewController MOBWechatmomentsViewController MOBWechatfavoritesViewController
 
 开放平台地址： https://open.weixin.qq.com
 */
#if (defined IMPORT_SUB_WechatSession) || (defined IMPORT_SUB_WechatTimeline)
#if defined(PRD) || defined(PRD_HK) || defined(AD_HOC_SIT)
//AppID
#define MOBSSDKWeChatAppID @"wx6234a831c0395ff9"
//AppSecret
#define MOBSSDKWeChatAppSecret @"a991512a5e5b342199cf724695df5633"
#else
//AppID
#define MOBSSDKWeChatAppID @"wx49915c94082ce0bf"
//AppSecret
#define MOBSSDKWeChatAppSecret @"27c6706f73e976884d4de9ded07e3bbf"
#endif
//是否默认返回 UnionID v4.0.2增加
//#define MOBSSDKWeChatBackUnionID NO
// 如需测试小程序 需要修改 bundleID 为  com.tencent.wc.xin.SDKSample
// MOBSSDKWeChatAppID @"wxd930ea5d5a258f4f"
#endif

#pragma mark - Facebook平台配置信息
/*
 info.plist 中需要设置 白名单 LSApplicationQueriesSchemes
 <string>fbauth</string>
 <string>fbauth2</string>
 
 info.plist 中需要设置 URL Schemes
 规则 fb+APPID 例：fb107704292745179
 
 授权：应用内web 客户端SSO
 
 可以通过以下方法进行权限设置
 - (void)SSDKSetAuthSettings:(NSArray *)authSettings
 
 分享：应用内 文字 图片[文字] 视频 链接 应用邀请
 注：其中 文字 图片 视频 需要使用 publish_action权限 需要进行facebook审核
 链接 不需要publish_action权限 不需要审核
 应用邀请功能目前支持在web分享邀请：链接申请地址（https://developers.facebook.com/quickstarts/?platform=app-links-host）
 
 客户端 图片[可多张] 链接 相册视频
 注：分享链接 时 图片必须为网络图片
 
 分享详例：MOBFacebookViewController
 
 开放平台地址： https://developers.facebook.com
 */
#ifdef IMPORT_Facebook
#if defined(PRD) || defined(PRD_HK) || defined(AD_HOC_SIT)
//AppID
#define MOBSSDKFacebookAppID @"453157839856169"
//AppSecret
#define MOBSSDKFacebookAppSecret @"80be1664293105da465ccd3f68ad181c"
//displayName facebook客户端分享必须
#define MOBSSDKFacebookDisplayName @"uSMART SG"
//AuthType 授权优先类型 web sso both
//#define MOBSSDKFacebookAuthType SSDKAuthTypeBoth
#else
//AppID
#define MOBSSDKFacebookAppID @"495196128508885"
//AppSecret
#define MOBSSDKFacebookAppSecret @"4967b3fa67745a886cd8f673bc7d485c"
//displayName facebook客户端分享必须
#define MOBSSDKFacebookDisplayName @"uSMART SG- Test"
//AuthType 授权优先类型 web sso both
//#define MOBSSDKFacebookAuthType SSDKAuthTypeBoth
#endif
#endif

#pragma mark - Twitter平台配置信息
/*
 授权：应用内web
 
 分享：仅应用内 文字 文字+图片 文字+视频
 
 分享详例：MOBTwitterViewController
 
 开放平台地址： https://dev.twitter.com
 */
#ifdef IMPORT_Twitter
//ConsumerKey

#define MOBSSDKTwitterConsumerKey @"WHmdfiHthx6noGOJn3Dwqw2TF"
//ConsumerSecret
#define MOBSSDKTwitterConsumerSecret @"L0RNuiDsBHPuT3Kv5l6vmT0qrMTWryPkwymNqk1bo7enpax1xm"
//RedirectUri
#define MOBSSDKTwitterRedirectUri @"https://www.usmartsg.com"
#endif

#pragma mark - Instagram平台配置信息
/*
 授权：应用内web
 
 分享：仅应用内 文字 文字+图片 文字+视频
 
 分享详例：MOBInstagramViewController
 
 开放平台地址： http://instagram.com/developer
 */

#if defined(PRD) || defined(PRD_HK) || defined(AD_HOC_SIT)
//AppID
#define MOBSSDKInstagramAppID @"945032256401265"
//AppSecret
#define MOBSSDKInstagramAppSecret @"185b389020b0018b18dcc15ec8f63119"
//displayName facebook客户端分享必须
#define MOBSSDKInstagramRedirectUri @"https://www.usmartsg.com"
//AuthType 授权优先类型 web sso both
//#define MOBSSDKFacebookAuthType SSDKAuthTypeBoth
#else
//AppID
#define MOBSSDKInstagramAppID @"512014020520955"
//AppSecret
#define MOBSSDKInstagramAppSecret @"347fa83c8adecf145da19b234bcb0fe4"
//displayName facebook客户端分享必须
#define MOBSSDKInstagramRedirectUri @"https://www.usmartsg.com"
#endif




typedef void(^ShareCallback)(BOOL success, NSDictionary*userInfo, SSDKPlatformType platformType);

@interface YXShareSDKHelper : NSObject

@property (nonatomic, strong) NSArray *platforms;
@property (nonatomic, strong) NSArray *platformTypes;

+ (instancetype)shareInstance;

- (void)handleOpenURL:(NSURL *)url;

- (BOOL)handleOpenUniversalLink:(NSUserActivity *)userActivity;

/**
 返回第三方平台对应标题

 @param platformType 第三方平台
 @return 标题
 */
+ (NSString *)titleForPlatforms:(SSDKPlatformType)platformType;


/**
 指定的平台是否已经安装了

 @param platformType 指定的平台类型
 @return 是否已安装；YES已安装，NO未安装
 */
+ (BOOL)isClientIntalled:(SSDKPlatformType)platformType;

/**
 授权

 @param platformType 第三方平台
 @param callback 回调
 */
- (void)authorize:(SSDKPlatformType)platformType withCallback:(ShareCallback)callback;

/**
 取消授权

 @param platformType 第三方平台
 @param callback 回调，此处默认返回true，具体判断取error
 */
- (void)cancelAuthorize:(SSDKPlatformType)platformType withCallback:(ShareCallback)callback;

/**
 获取用户信息

 @param platformType 第三方平台
 @param callback 回调
 */
- (void)getUserInfo:(SSDKPlatformType)platformType withCallback:(ShareCallback)callback;

/**
 通用分享

 @param platformType 分享平台
 @param text 文本
 @param images 图片集合,传入参数可以为单张图片信息，也可以为一个NSArray，数组元素可以为UIImage、NSString（图片路径）、NSURL（图片路径）、SSDKImage。如: @"http://www.mob.com/images/logo_black.png" 或 @[@"http://www.mob.com/images/logo_black.png"]
 @param url 网页路径/应用路径
 @param title 标题
 @param type 分享类型
 */
- (void)share:(SSDKPlatformType)platformType
         text:(NSString *)text
       images:(id)images
          url:(NSURL *)url
        title:(NSString *)title
         type:(SSDKContentType)type
 withCallback:(ShareCallback)callback;



/**
 v4.1.2 为微信小程序分享增加
 
 @param platformType 类型
 @param title 标题
 @param description 详细说明
 @param webpageUrl 网址（6.5.6以下版本微信会自动转化为分享链接 必填）
 @param path 跳转到页面路径
 @param thumbImage 缩略图 , 旧版微信客户端（6.5.8及以下版本）小程序类型消息卡片使用小图卡片样式 要求图片数据小于32k
 @param hdThumbImage 高清缩略图，建议长宽比是 5:4 ,6.5.9及以上版本微信客户端小程序类型分享使用 要求图片数据小于128k
 @param userName 小程序的userName （必填）
 @param withShareTicket 是否使用带 shareTicket 的转发
 @param type 分享小程序的版本（0-正式，1-开发，2-体验）
 @param platformSubType 分享自平台 微信小程序暂只支持 SSDKPlatformSubTypeWechatSession（微信好友分享)
 @param callback 分享的回调
 */
- (void)shareMiniProgramByPlatformType:(SSDKPlatformType)platformType
                                 title:(NSString *)title
                           description:(NSString *)description
                            webpageUrl:(NSURL *)webpageUrl
                                  path:(NSString *)path
                            thumbImage:(id)thumbImage
                          hdThumbImage:(id)hdThumbImage
                              userName:(NSString *)userName
                       withShareTicket:(BOOL)withShareTicket
                       miniProgramType:(NSUInteger)type
                    forPlatformSubType:(SSDKPlatformType)platformSubType
                              callback:(ShareCallback)callback;

/**
 自定义分享

 @param platformType 分享平台
 @param params 见“NSMutableDictionary+SSDKShare.h”
 @param callback 回调
 */
- (void)share:(SSDKPlatformType)platformType
   parameters:(NSMutableDictionary *)params
 withCallback:(ShareCallback)callback;

@end
