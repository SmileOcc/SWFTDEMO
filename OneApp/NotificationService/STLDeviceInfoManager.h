//
//  STLDeviceInfoManager.h
// XStarlinkProject
//
//  Created by odd on 2020/9/16.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface STLDeviceInfoManager : NSObject

@property (nonatomic, strong) NSString *platomDeviceType;

/** 设备唯一标识 */
@property (nonatomic, strong) NSString *device_id;

+ (STLDeviceInfoManager *)sharedManager;

- (NSString *)appGroupSuitName;

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
 获取国际化区域名称
 
 @return 返回国际化区域名称(iphone)
 */
- (NSString *)getLocalizedModel;

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



@end

NS_ASSUME_NONNULL_END
