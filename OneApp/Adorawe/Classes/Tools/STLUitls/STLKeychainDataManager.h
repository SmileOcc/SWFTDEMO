//
//  STLKeychainDataManager.h
// XStarlinkProject
//
//  Created by odd on 2020/8/31.
//  Copyright © 2020 starlink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface STLKeychainDataManager : NSObject

/**
 * 读取设备的唯一标识
 */
+ (NSString *)readAppUUID;

/**
 * 保存设备的唯一标识
 */
+ (void)saveAppUUID:(NSString *)UUID;

/**
 * 删除设备的唯一标识
 */
+ (void)deleteAppUUID;


/**
 * 读取用户TOKEN标识
 */
+ (NSString *)readUserToken;

/**
 * 保存用户TOKEN标识
 */
+ (void)saveUserToken:(NSString *)token;

/**
 * 删除用户TOKEN标识
 */
+ (void)deleteUserToken;

@end

NS_ASSUME_NONNULL_END
