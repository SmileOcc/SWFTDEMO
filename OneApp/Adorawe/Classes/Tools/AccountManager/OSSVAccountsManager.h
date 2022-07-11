//
//  OSSVAccountsManager.h
// XStarlinkProject
//
//  Created by 10010 on 20/7/31.
//  Copyright © 2020年 XStarlinkProject. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AccountModel.h"
#import "STLSysInitModel.h"

@class CountryListModel;
@class CountryModel;
@class LoginThirdModel;

@interface OSSVAccountsManager : NSObject


@property (nonatomic,strong) AccountModel                               *account;

///本次启动 是否点击了关闭绑定按钮
@property (nonatomic, assign) BOOL                                      isCloseBindPhone;
@property (nonatomic,assign) BOOL                                       isRelogining;

@property (nonatomic, copy) NSString                                    *userToken;

//@property (nonatomic,strong) NSArray <CountryListModel *>               *countryList;
////第三方登录显示
@property (nonatomic,strong) NSArray <LoginThirdModel *>                *loginThirdList;

/** 是否显示定位设置信息，每次打开只主动显示一次 */
@property (nonatomic, assign) BOOL                                      hasShowedMapSetMsg;

@property (nonatomic, copy) NSString *appDeviceToken;

// 是否登录
@property(nonatomic,assign)BOOL                                         isSignIn;

// 是否显示会员中心相关的入口
//@property(nonatomic,assign)BOOL                                         needShowMember;

///自定义
@property (nonatomic, assign) NSInteger appUnreadMessageNum; //未读消息数

@property (nonatomic, copy) NSString                                    *iosplatform;

/// 设备唯一标识, 防止每次获取很耗时,存在单例里面
@property (nonatomic, copy) NSString *device_id;

///分享 拉新来源
@property (nonatomic, copy) NSString *shareChannelSource;
@property (nonatomic, copy) NSString *shareSourceUid;

@property (nonatomic, strong) NSDictionary                              *homeBanner;//1.4.0
@property (nonatomic, strong) NSDictionary                              *goodsDetailBanner;//1.4.0

@property (nonatomic, copy) NSString *testMessage;

/// 绑定倒计时 存入全局变量 （用于倒计时操作）
@property (nonatomic, strong) NSDate *msgDate;// 发送成功验证码的时间
@property (nonatomic, assign) NSInteger count;// 验证码总的倒计时
@property (nonatomic, copy) NSString *verifiPhoneNumber;// 发送验证码的电话号码
@property (nonatomic,strong) STLSysInitModel *sysIniModel;

@property (nonatomic, strong) NSArray *socialPlatforms;

+ (void)testLaunchMessage:(NSString *)msg;

+ (NSInteger)stlShareChannelSource;

+ (OSSVAccountsManager *)sharedManager;

- (void)updateUserInfo:(AccountModel *)account;

- (void)clearUserInfo;

- (int)userId;
- (NSString *)userIdString;

- (void)saveUserToken:(NSString *)token;

+ (void)logout;
+ (void)reLogin;


/**
 * 保存LeandCloud数据
 */
+ (void)saveLeandCloudData;

/**
 * 上传FCM推送的信息
 */
+ (void)uploadFCMTokenToServerToken:(NSString *)fcmToken;

@end


@interface LoginThirdModel : NSObject

@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *thrid_app_name;

@end
