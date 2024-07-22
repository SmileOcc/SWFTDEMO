//
//  ZFKeychainDataManager.m
//  ZZZZZ
//
//  Created by YW on 2018/10/8.
//  Copyright © 2018年 ZZZZZ. All rights reserved.
//

#import "ZFKeychainDataManager.h"
#import "NSStringUtils.h"
#import "Constants.h"

static NSString * const KEY_IN_KEYCHAIN_UUID = @"KEY_IN_KEYCHAIN_UUID";
static NSString * const KEY_UUID = @"KEY_UUID";

@implementation ZFKeychainDataManager

/**
 * 读取设备的唯一标识
 */
+ (NSString *)readZZZZZUUID {
    NSMutableDictionary *keychainDataDict = (NSMutableDictionary *)[self load:KEY_IN_KEYCHAIN_UUID];
    
    if ([keychainDataDict isKindOfClass:[NSDictionary class]]) {
        NSString *saveUUID = [keychainDataDict objectForKey:KEY_UUID];
        if (saveUUID.length>0) {
            return saveUUID;
        }
    }
    NSString *uuid = [NSStringUtils uniqueUUID];
    [self saveZZZZZUUID:uuid];
    return uuid;
}

/**
 * 保存设备的唯一标识
 */
+ (void)saveZZZZZUUID:(NSString *)UUID {
    NSMutableDictionary *keychainDataDict = [NSMutableDictionary dictionary];
    [keychainDataDict setObject:UUID forKey:KEY_UUID];
    [self save:KEY_IN_KEYCHAIN_UUID data:keychainDataDict];
}

/**
 * 删除设备的唯一标识
 */
+ (void)deleteZZZZZUUID {
    [self delete:KEY_IN_KEYCHAIN_UUID];
}

#pragma mark -===========Keychain的增删改查===========

+ (NSMutableDictionary *)getKeychainQuery:(NSString *)service {
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
            (__bridge_transfer id)kSecClassGenericPassword,(__bridge_transfer id)kSecClass,
            service, (__bridge_transfer id)kSecAttrService,
            service, (__bridge_transfer id)kSecAttrAccount,
            (__bridge_transfer id)kSecAttrAccessibleAfterFirstUnlock,(__bridge_transfer id)kSecAttrAccessible,
            nil];
}

+ (void)save:(NSString *)service data:(id)data {
    //Get search dictionary
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Delete old item before add new item
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
    //Add new object to search dictionary(Attention:the data format)
    [keychainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge_transfer id)kSecValueData];
    //Add item to keychain with the search dictionary
    SecItemAdd((__bridge_retained CFDictionaryRef)keychainQuery, NULL);
}

+ (id)load:(NSString *)service {
    id ret = nil;
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    //Configure the search setting
    [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge_transfer id)kSecReturnData];
    [keychainQuery setObject:(__bridge_transfer id)kSecMatchLimitOne forKey:(__bridge_transfer id)kSecMatchLimit];
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge_retained CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge_transfer NSData *)keyData];
        } @catch (NSException *e) {
            YWLog(@"Unarchive of %@ failed: %@", service, e);
        } @finally {
        }
    }
    return ret;
}

+ (void)delete:(NSString *)service {
    NSMutableDictionary *keychainQuery = [self getKeychainQuery:service];
    SecItemDelete((__bridge_retained CFDictionaryRef)keychainQuery);
}


@end
