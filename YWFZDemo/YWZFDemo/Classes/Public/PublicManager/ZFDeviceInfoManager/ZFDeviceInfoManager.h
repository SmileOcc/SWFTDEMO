//
//  ZFDeviceInfoManager.h
//  ZZZZZ
//
//  Created by mac on 2018/12/29.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ZFDeviceInfoManager : NSObject

/** 获取城市 */
@property (nonatomic, strong) NSString *ipAddress;
/** 获取外网ip */
@property (nonatomic, strong) NSString *extranetIp;
/** 设备唯一标识 */
@property (nonatomic, strong) NSString *device_id;

+ (ZFDeviceInfoManager *)sharedManager;

/**
 获取设备UUID
 
 @return 返回UUID，设备唯一标识码(3DCF9688-6946-4C30-8B27-377A7910DCB0)
 */
- (NSString *)getDeviceUUIDString;

/**
 获取手机名称
 
 @return 返回手机名称(xxx的iphone)
 */
- (NSString *)getIphoneName;

/**
 获取设备名称
 
 @return 返回设备名称(iPhone OS)
 */
- (NSString *)getDeviceName;

/**
 获取国际化区域名称
 
 @return 返回国际化区域名称(iphone)
 */
- (NSString *)getLocalizedModel;

/**
 获取设备系统版本号
 
 @return 返回系统版本号（eg:11.2.2）
 */
- (NSString *)getDeviceVersion;

/**
 获取设备类型
 
 @return 返回设备类型(iphone X)
 */
- (NSString *)getDeviceType;

/**
 获取应用版本号
 
 @return 返回应用版本号(1.11.0)
 */
- (NSString *)getAppVersion;

/**
 获取应用名称
 
 @return 返回应用名称(及时云)
 */
- (NSString *)getAppName;

/**
 获取应用bundleId
 
 @return 返回应用bundleId
 */
- (NSString *)getBundleIdentifier;

/**
 获取应用的icon
 
 @return 返回应用icon
 */
- (UIImage *)getAppIcon;

/**
 获取设备物理尺寸
 
 @return 返回设备物理尺寸(375*667)
 */
- (CGSize)getDeviceSize;

/**
 获取设备分辨率
 
 @return 返回分辨率基数（基数*物理尺寸=分辨率）
 */
- (CGFloat)getDeviceScale;

/**
 获取设备运营商
 
 @return 返回设备运营商
 */
- (NSString *)getDeviceCarrierName;

/**
 获取设备电量
 
 @return 返回电量
 */
- (CGFloat)getDeviceElectricity;

/**
 获取设备当前使用语言
 
 @return 返回使用语言
 */
- (NSString *)getDeviceLanguage;

/**
 获取电池充电状态
 
 @return 返回充电状态(UnKnow：无法取得充电状态情况;Unplugged：不是充电状态;Charging：连接充电状态;Full：连接充满状态)
 */
- (NSString *)getBatteryState;

/**
 获取设备内存大小
 
 @return 返回内存大小
 */
- (long long)getTotalMemorySize;

/**
 获取当前设备可用内存
 
 @return 返回可用内存
 */
- (double)getAvailableMemory;

/**
 获取当前当前应用占用内存
 
 @return 返回占用内存
 */
- (double)getAppUsedMemory;

/**
 获取设备ip
 
 @param preferIPv4 是否是IPv4（YES:ipv4 NO:ipv6）
 @return 返回ip
 */
- (NSString *)getIPAddress:(BOOL)preferIPv4;

/**
 获取mac地址
 
 @return 返回mac地址
 */
- (NSString *)getMacAddress;

/**
 获取当前连接wifi名称
 
 @return 返回wifi名称
 */
- (NSString *)getWifiName;

/**
 调用系统短信提醒省
 */
-(void)playSystemSound;

/**
 *  获取当前时间的时间戳（例子：1464326536）
 *
 *  @return 时间戳字符串型
 */
- (NSString *)getCurrentTimestamp;

/**
 获取IDFA的方法
 */
- (NSString *)getIDFA;

/**
 获取IDFA是否限制广告追踪状态
 */
- (BOOL)getAdvertisingTrackingEnabled;

@end

