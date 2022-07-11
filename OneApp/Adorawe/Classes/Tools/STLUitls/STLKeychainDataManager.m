//
//  STLKeychainDataManager.m
// XStarlinkProject
//
//  Created by odd on 2020/8/31.
//  Copyright © 2020 starlink. All rights reserved.
//

#import "STLKeychainDataManager.h"

static NSString * const KEY_IN_KEYCHAIN_UUID = @"KEY_IN_KEYCHAIN_UUID_ADORAWE";
static NSString * const KEY_UUID = @"KEY_UUID_ADORAWE";

static NSString * const KEY_IN_KEYCHAIN_USER_TOKEN = @"KEY_IN_KEYCHAIN_USER_TOKEN_ADORAWE";
static NSString * const KEY_USER_TOKEN = @"KEY_USER_TOKEN_ADORAWE";

@implementation STLKeychainDataManager


/**
 * 读取设备的唯一标识
 */
+ (NSString *)readAppUUID {
    NSMutableDictionary *keychainDataDict = (NSMutableDictionary *)[self load:KEY_IN_KEYCHAIN_UUID];
    
    if ([keychainDataDict isKindOfClass:[NSDictionary class]]) {
        NSString *saveUUID = [keychainDataDict objectForKey:KEY_UUID];
        if (saveUUID.length>0) {
            return saveUUID;
        }
    }
    NSString *uuid = [OSSVNSStringTool uniqueUUID];
    [self saveAppUUID:uuid];
    return uuid;
}

/**
 * 保存设备的唯一标识
 */
+ (void)saveAppUUID:(NSString *)UUID {
    NSMutableDictionary *keychainDataDict = [NSMutableDictionary dictionary];
    [keychainDataDict setObject:UUID forKey:KEY_UUID];
    [self save:KEY_IN_KEYCHAIN_UUID data:keychainDataDict];
}

/**
 * 删除设备的唯一标识
 */
+ (void)deleteAppUUID {
    [self delete:KEY_IN_KEYCHAIN_UUID];
}


/**
 * 读取用户TOKEN标识
 */
+ (NSString *)readUserToken {
    NSMutableDictionary *keychainDataDict = (NSMutableDictionary *)[self load:KEY_IN_KEYCHAIN_USER_TOKEN];
    
    if ([keychainDataDict isKindOfClass:[NSDictionary class]]) {
        NSString *email = OSSVAccountsManager.sharedManager.account.email;
        if (email.length > 0){
            NSString *key = [NSString stringWithFormat:@"%@ %@",KEY_USER_TOKEN, STLToString(OSSVAccountsManager.sharedManager.account.email)];;
            NSString *saveUUID = [keychainDataDict objectForKey:key];//使用用户email 作为key 防止串账号
            if (saveUUID.length>0) {
                return saveUUID;
            }
        }
    }
    return @"";
}

/**
 * 保存用户TOKEN标识
 */
+ (void)saveUserToken:(NSString *)token {
    NSMutableDictionary *keychainDataDict = [NSMutableDictionary dictionary];
    NSString *email = [NSString stringWithFormat:@"%@ %@",KEY_USER_TOKEN, STLToString(OSSVAccountsManager.sharedManager.account.email)];
    if (email.length > 0) {
        [keychainDataDict setObject:STLToString(token) forKey:email];//使用用户email 作为key 防止串账号
        [self save:KEY_IN_KEYCHAIN_USER_TOKEN data:keychainDataDict];
    }
   
}

/**
 * 删除用户TOKEN标识
 */
+ (void)deleteUserToken {
    [self delete:KEY_IN_KEYCHAIN_USER_TOKEN];
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
            STLLog(@"Unarchive of %@ failed: %@", service, e);
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
