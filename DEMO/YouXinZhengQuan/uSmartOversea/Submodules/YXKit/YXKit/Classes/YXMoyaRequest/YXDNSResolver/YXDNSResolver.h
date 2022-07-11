//
//  YXDNSResolver.h
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2020/5/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, YXDNSResolverType) {
    YXDNSResolverTypeHZGlobalConfig     =   0,
    YXDNSResolverTypeHZBuildIn          =   1,
    YXDNSResolverTypeJYGlobalConfig     =   2,
    YXDNSResolverTypeJYBuildIn          =   3,
    YXDNSResolverTypeZXGlobalConfig     =   4,
    YXDNSResolverTypeZXBuildIn          =   5,
    YXDNSResolverTypeWJGlobalConfig     =   6,
    YXDNSResolverTypeWJBuildIn          =   7
};

@interface YXDNSResolver : NSObject

+ (instancetype)shareInstance;

- (void)resolveAllHost;

- (BOOL)hostStatusWithResolverType:(YXDNSResolverType)type;

- (nullable NSString *)httpDNSIpWith:(YXDNSResolverType)type;

/// DNS解析分析
/// @param hostname 待解析的hostName
- (BOOL)resolveHost:(NSString *)hostname resolverType:(YXDNSResolverType)type;

@end

NS_ASSUME_NONNULL_END
