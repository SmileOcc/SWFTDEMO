//
//  ZFKeychainDataManager.h
//  ZZZZZ
//
//  Created by YW on 2018/10/8.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZFKeychainDataManager : NSObject

/**
 * 读取设备的唯一标识
 */
+ (NSString *)readZZZZZUUID;

/**
 * 保存设备的唯一标识
 */
+ (void)saveZZZZZUUID:(NSString *)UUID;

/**
 * 删除设备的唯一标识
 */
+ (void)deleteZZZZZUUID;

@end

NS_ASSUME_NONNULL_END
