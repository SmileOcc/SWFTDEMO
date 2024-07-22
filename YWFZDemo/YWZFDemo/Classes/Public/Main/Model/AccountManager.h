//
//  AccountManager.h
//  Yoshop
//
//  Created by YW on 16/5/31.
//  Copyright © 2016年 yoshop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "AccountModel.h"
#import "ZFAddressCountryModel.h"
#import "ZFInitializeModel.h"
#import "ZFSkinModel.h"
#import "ZFGifTipsModel.h"

@interface AccountManager : NSObject

@property (nonatomic,strong) AccountModel *account;

/// 是否已经检查AppStore版本号
@property(nonatomic, assign) BOOL hasCheckAppStoreVersion;
/// 启动后是否有请求过强制更新接口
@property(nonatomic, assign) BOOL hasRequestUpgradeAppUrl;

/// 是否显示临时强制更新弹框 (临时强制更新是因为: 有时有紧急bug导致的App不能启动, 提示用户需要卸载此版本重新安装)
@property(nonatomic, assign) BOOL hasShowTempForceUpgrade;

/// 为记录是否是从桌面重按图标3DTouch进入App
@property(nonatomic, assign) BOOL isAppIcon3DTouchIntoApp;

/// 为记录是否已经显示了启动倒计时广告进入App
@property(nonatomic, assign) BOOL hasShowAdvertIntoApp;

/// 记录是否已经显示了首页未支付订单弹框 (在所有的弹框中的优先级最低)
@property(nonatomic, assign) BOOL hasRequestUnpaidOrderAlertUrl;

/// 记录当前用户是否已经选择切换了国家
@property(nonatomic, strong) ZFAddressCountryModel *accountCountryModel;

/// 读取 common/initialization 接口的数据
@property(nonatomic, strong, readonly) ZFInitializeModel *initializeModel;

/// 设备唯一标识, 防止每次获取很耗时,存在单例里面
@property (nonatomic, copy) NSString *device_id;
/// App系统推送DeviceToken :V5.0.0
@property (nonatomic, copy) NSString *appDeviceToken;

/// 谷歌登录获取的生日
@property (nonatomic, copy) NSString *googleLoginBirthday;
/// 谷歌登录获取的性别
@property (nonatomic, copy) NSString *googleLoginGender;

/// faceBook登录获取的生日
@property (nonatomic, copy) NSString *facebookLoginBirthday;
/// faceBook登录获取的性别
@property (nonatomic, copy) NSString *facebookLoginGender;

/// 用户主动选择的优惠券
@property (nonatomic, assign) BOOL  hasSelectedAppCoupon;
@property (nonatomic, assign) BOOL  no_login_select_coupon;
@property(nonatomic, copy) NSString *selectedAppCouponCode;

/// 首页换肤模型数据源
@property(nonatomic, strong) ZFSkinModel *currentHomeSkinModel;
@property(nonatomic, strong) NSArray<ZFSkinModel *> *appSkinModelArray;

/// 记录换肤操作
@property(nonatomic, assign) BOOL    needChangeAppSkin;
@property(nonatomic, strong) UIImage *appNavBgImage;
@property(nonatomic, strong) UIImage *appAccountHeadImage;
@property(nonatomic, strong) UIColor *appNavBgColor;
@property(nonatomic, strong) UIColor *appNavIconColor;
@property(nonatomic, strong) UIColor *appNavFontColor;
@property (nonatomic, strong) NSNumber *subNavStatusBarType;//(0:黑色, 1:白色)
@property (nonatomic, strong) NSNumber *homeNavStatusBarType;//(0:黑色, 1:白色)

/// 是否登录
@property(nonatomic, assign) BOOL isSignIn;

/// 是否同意流量播放
@property(nonatomic, assign) BOOL isNoWiFiPlay;

/// 默认值1, 1=新用户 0=老用户（新用户：未登录或未生成过已付款订单的用户),通过接口 user/get_new_user_status 获取
@property(nonatomic, copy) NSString *af_user_type;

/// 记录主页列表是否为CMS数据
@property(nonatomic, assign) BOOL   homeDateIsCMSType;

/// 启动时就获取服务端是否需要App请求走cdn的配置开关
@property(nonatomic, assign) BOOL appShouldRequestCdn;

/// 配置cms的超时时间
@property(nonatomic, strong) NSNumber *cmsTimeOutDuration;

/// 自定义 皮肤下载标识模型
@property (nonatomic, strong) NSMutableArray      *loadSinkModelArray;

/// common/location_info 接口返回的，是否显示分期付款的图标 1显示 0 不显示
/// 分类列表页， 虚拟分类列表页，搜索列表页，购物车页
@property (nonatomic, assign) BOOL br_is_show_icon;

/// ZZZZZ gif动画提示管理模型
@property (nonatomic, strong) ZFGifTipsModel *gifTipsModel;

/// 推送相关,是否为推送启动APP
@property (nonatomic, assign) BOOL isPushOpen;
/// 推送信息是否有deeplink(跳转首页以外的落地页)
@property (nonatomic, assign) BOOL isHadDeeplink;
///是否是第一次打开首页
@property (nonatomic, assign) BOOL isFirstOpenHomepage;
/// 是否过滤统计 （推送进入非首页落地页时，需要返回首页时才曝光首页数据）
@property (nonatomic, assign) BOOL isFilterAnalytics;
/// 首页待曝光banner数组
@property (nonatomic, strong) NSMutableArray *filterAnalyticsArray;
/// 首页待曝光channel_id
@property (nonatomic, copy) NSString *channelId;
/// 首页待曝光channel_name
@property (nonatomic, copy) NSString *channelName;


+ (AccountManager *)sharedManager;

- (void)updateUserInfo:(AccountModel *)account;

/**
 * 保存 common/initialization 接口的数据
 */
- (void)saveInitializeData:(NSDictionary *)InitializeDicInfo;

/**
 *  编辑个人资料时,更改部分item ,FirstName...
 */
- (void)editUserSomeItems:(AccountModel *)account;

/**
 *  刷新用户头像
 *
 *  @param url 返回的url链接
 */
- (void)updateUserAvatar:(NSString *)url;

/**
 *  刷新用户头像
 *
 *  @param url 返回的url链接
 */
- (void)updateUserDefaultAddressId:(NSString *)addressId;

/**
 * 保存LeandCloud数据
 */
+ (void)saveLeandCloudData;

/**
 * 上传FCM推送的信息
 */
+ (void)uploadFCMTokenToServerToken:(NSString *)fcmToken;

- (void)clearUserInfo;

- (void)clearWebCookie;

- (NSString *)userId;

- (NSString *)userNickname;

- (NSString *)token;

- (NSString *)defaultAddressId;

- (NSString *)sessionId;

- (NSString *)userSex;

- (NSDictionary *)userInfo;

/**
 * 首页切换环境登出
 */
- (void)logout;

// 清除购物车选择主动记住的全局优惠券
+ (void)clearUserSelectedCoupon;

@end
