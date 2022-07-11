//
//  YXDNSResolver.m
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2020/5/27.
//  Copyright © 2020 RenRenDai. All rights reserved.
//

#import "YXDNSResolver.h"
#include <arpa/inet.h>
#import "YXNetworkUtil.h"
#import <MSDKDns_C11/MSDKDns.h>
#import <YXKit/YXKit-Swift.h>

NSString *const YXHZGlobalConfigKey = @"YXHZGlobalConfigKey";
NSString *const YXHZBuildInKey = @"YXHZBuildInKey";
NSString *const YXJYGlobalConfigKey = @"YXJYGlobalConfigKey";
NSString *const YXJYBuildInKey = @"YXJYBuildInKey";
NSString *const YXWJGlobalConfigKey = @"YXWJGlobalConfigKey";
NSString *const YXWJBuildInKey = @"YXWJBuildInKey";
NSString *const YXZXGlobalConfigKey = @"YXZXGlobalConfigKey";
NSString *const YXZXBuildInKey = @"YXZXBuildInKey";

NSString *const YXHTTPDNSHZIPKey = @"YXHTTPDNSHZIPKey";
NSString *const YXHTTPDNSJYIPKey = @"YXHTTPDNSJYIPKey";
NSString *const YXHTTPDNSWJIPKey = @"YXHTTPDNSWJIPKey";
NSString *const YXHTTPDNSZXIPKey = @"YXHTTPDNSZXIPKey";


NSString *const YXHttpDNSAppKey = @"0IOS0H1NF94J45PC";
int const YXHttpDNSId = 1650;
NSString *const YXHttpDNSKey = @"evfcRXWk";

@interface YXDNSResolver ()
@property (nonatomic, assign) HLNetWorkStatus netWorkStatus;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSNumber *> *hostStatus;
@property (nonatomic, strong) NSMutableDictionary<NSString *, NSString *> *httpDnsIps;
@end

@implementation YXDNSResolver
+ (instancetype)shareInstance {
    static YXDNSResolver *_shareInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInstance = [[self alloc] init];
    });
    return _shareInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
        _hostStatus = [NSMutableDictionary dictionary];
        _httpDnsIps = [NSMutableDictionary dictionary];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleNetWorkChangeNotification:) name:kNetWorkReachabilityChangedNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)handleNetWorkChangeNotification:(NSNotification *)ntf{
    HLNetWorkReachability *reachability = (HLNetWorkReachability *)ntf.object;
    HLNetWorkStatus netWorkStatus = [reachability currentReachabilityStatus];
    
    if (netWorkStatus != HLNetWorkStatusNotReachable) {
        // 有网络变化时，就更新一下IP地址
        [self.hostStatus removeAllObjects];
        [self resolveAllHost];
    }
}

- (BOOL)hostStatusWithResolverType:(YXDNSResolverType)type {
    switch (type) {
        case YXDNSResolverTypeHZGlobalConfig:
            return [[self.hostStatus valueForKey:YXHZGlobalConfigKey] boolValue];
        case YXDNSResolverTypeHZBuildIn:
            return [[self.hostStatus valueForKey:YXHZBuildInKey] boolValue];
        case YXDNSResolverTypeJYGlobalConfig:
            return [[self.hostStatus valueForKey:YXJYGlobalConfigKey] boolValue];
        case YXDNSResolverTypeJYBuildIn:
            return [[self.hostStatus valueForKey:YXJYBuildInKey] boolValue];
        case YXDNSResolverTypeWJGlobalConfig:
            return [[self.hostStatus valueForKey:YXWJGlobalConfigKey] boolValue];
        case YXDNSResolverTypeWJBuildIn:
            return [[self.hostStatus valueForKey:YXWJBuildInKey] boolValue];
        case YXDNSResolverTypeZXGlobalConfig:
            return [[self.hostStatus valueForKey:YXZXGlobalConfigKey] boolValue];
        case YXDNSResolverTypeZXBuildIn:
            return [[self.hostStatus valueForKey:YXZXBuildInKey] boolValue];
        default:
            break;
    }
    return nil;
}

- (NSString *)httpDNSIpWith:(YXDNSResolverType)type {
    switch (type) {
        case YXDNSResolverTypeHZGlobalConfig:
            return [self.httpDnsIps valueForKey:YXHTTPDNSHZIPKey];
        case YXDNSResolverTypeJYGlobalConfig:
            return [self.httpDnsIps valueForKey:YXHTTPDNSJYIPKey];
        case YXDNSResolverTypeZXGlobalConfig:
            return [self.httpDnsIps valueForKey:YXHTTPDNSZXIPKey];
        case YXDNSResolverTypeWJGlobalConfig:
            return [self.httpDnsIps valueForKey:YXHTTPDNSWJIPKey];
        default:
            break;
    }
    return nil;
}

- (void)resolveHostWithType:(YXGlobalConfigURLType)type resolverType:(YXDNSResolverType)resolverType {
    NSString *globalConfigURLString = [YXGlobalConfigManager bizUrlWithType:type];
    NSURL *globalUrl = [NSURL URLWithString:globalConfigURLString];
    NSURL *buildInUrl;
    NSString *buildInKey;
    NSString *globalConfigKey;
    NSString *httpDnsIpKey;
    BOOL useLocalDNS = NO;
    YXDNSResolverType buildInResolverType;
    switch (type) {
        case YXGlobalConfigURLTypeHzCenter:
            buildInUrl = [NSURL URLWithString:[YXUrlRouterConstant hzBuildInBaseUrl]];
            buildInKey = YXHZBuildInKey;
            globalConfigKey = YXHZGlobalConfigKey;
            buildInResolverType = YXDNSResolverTypeHZBuildIn;
            httpDnsIpKey = YXHTTPDNSHZIPKey;
            break;
        case YXGlobalConfigURLTypeJyCenter:
            buildInUrl = [NSURL URLWithString:[YXUrlRouterConstant jyBuildInBaseUrl]];
            buildInKey = YXJYBuildInKey;
            globalConfigKey = YXJYGlobalConfigKey;
            buildInResolverType = YXDNSResolverTypeJYBuildIn;
            httpDnsIpKey = YXHTTPDNSJYIPKey;
            break;
        case YXGlobalConfigURLTypeWjCenter:
            buildInUrl = [NSURL URLWithString:[YXUrlRouterConstant wjBuildInBaseUrl]];
            buildInKey = YXWJBuildInKey;
            globalConfigKey = YXWJGlobalConfigKey;
            buildInResolverType = YXDNSResolverTypeWJBuildIn;
            httpDnsIpKey = YXHTTPDNSWJIPKey;
            break;
        case YXGlobalConfigURLTypeZxCenter:
            buildInUrl = [NSURL URLWithString:[YXUrlRouterConstant zxBuildInBaseUrl]];
            buildInKey = YXZXBuildInKey;
            globalConfigKey = YXZXGlobalConfigKey;
            buildInResolverType = YXDNSResolverTypeZXBuildIn;
            httpDnsIpKey = YXHTTPDNSZXIPKey;
            break;
        default:
            break;
    }
    
    if ([self httpDNSAllowed]) {
        __block NSArray *ips;
        NSString *ipv4;
        BOOL globalSuccess = NO;
        if (globalConfigURLString) {
            if (globalUrl && globalUrl.host) {
                ips = [[MSDKDns sharedInstance] WGGetHostByName:globalUrl.host];
            }
        }
        
        if (ips && [ips count] > 1) {
            ipv4 = ips[0];
            if (![ipv4 isEqualToString:@"0"]) {
                self.httpDnsIps[httpDnsIpKey] = ipv4;
                globalSuccess = YES;
            }
        } else if (!globalSuccess && buildInUrl && buildInUrl.host) {
            if (globalUrl.host && [buildInUrl.host isEqualToString:globalUrl.host]) {
                // Donothing
            } else {
                ips = [[MSDKDns sharedInstance] WGGetHostByName:buildInUrl.host];
            }
            if (ips && [ips count] > 1) {
                ipv4 = ips[0];
                if (![ipv4 isEqualToString:@"0"]) {
                    self.httpDnsIps[httpDnsIpKey] = ipv4;
                }
            }
        }
        
        if (ips && [ips count] > 1) {
            ipv4 = ips[0];
            if (![ipv4 isEqualToString:@"0"]) {
                useLocalDNS = NO;
            } else {
                useLocalDNS = YES;
            }
        } else {
            useLocalDNS = YES;
        }
    } else {
        useLocalDNS = YES;
    }
    
    if (useLocalDNS) {
        if ([[self.httpDnsIps allKeys] containsObject:httpDnsIpKey]) {
            [self.httpDnsIps removeObjectForKey:httpDnsIpKey];
        }
        if (globalConfigURLString) {
            if (globalUrl && globalUrl.host) {
                [self resolveHost:globalUrl.host resolverType:resolverType];
            }
        }

        if (buildInUrl && buildInUrl.host) {
            // 如果全局配置的域名和内置的域名一样，则直接使用全局配置的解析结果作为内置的解析结果
            if (globalUrl.host && [buildInUrl.host isEqualToString:globalUrl.host]) {
                self.hostStatus[buildInKey] = [self.hostStatus valueForKey:globalConfigKey];
            } else {
                [self resolveHost:buildInUrl.host resolverType:buildInResolverType];
            }
        }
    }
}

- (void)resolveAllHost {
    // 配置腾讯云HTTP DNS
    // 文档 https://cloud.tencent.com/document/product/379/17669
    DnsConfig config;
    config.dnsIp = @"119.29.29.98";
    config.dnsId = YXHttpDNSId;
    config.dnsKey = YXHttpDNSKey;
    config.encryptType = HttpDnsEncryptTypeDES;
    config.addressType = HttpDnsAddressTypeIPv4;
    config.debug = NO;
    config.timeout = 1000;
    
    if ([[MSDKDns sharedInstance] initConfig: &config]) {
        NSLog(@"WGSetDnsAppKey success");
    } else {
        [YXRealLogger.shareInstance realLogWithType:@"DNSError" name:@"DNSError" url:@"" code:@"-1" desc:[NSString stringWithFormat:@"腾讯云HTTP DNS解析设置错误"] extend_msg:nil];
    }
    
//    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    
    // DNS解析行情域名
    [self resolveHostWithType:YXGlobalConfigURLTypeHzCenter resolverType:YXDNSResolverTypeHZGlobalConfig];
    
    // DNS解析交易域名
    [self resolveHostWithType:YXGlobalConfigURLTypeJyCenter resolverType:YXDNSResolverTypeJYGlobalConfig];
    
    // DNS解析文件域名
    [self resolveHostWithType:YXGlobalConfigURLTypeWjCenter resolverType:YXDNSResolverTypeWJGlobalConfig];
    
    // DNS解析资讯域名
    [self resolveHostWithType:YXGlobalConfigURLTypeZxCenter resolverType:YXDNSResolverTypeZXGlobalConfig];

//    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
//
//    NSLog(@"[http dns] %@", [NSString stringWithFormat:@"DNS解析错误[解析耗时: %0.3fs]", end - start]);
}

- (BOOL)resolveHost:(NSString *)hostname resolverType:(YXDNSResolverType)type {
    HLNetWorkStatus netWorkStatus = [YXNetworkUtil.sharedInstance.reachability currentReachabilityStatus];
    if (netWorkStatus == HLNetWorkStatusNotReachable) {
        // 没有网络时, 不进行DNS日志的上报
        return NO;
    }
    
    __block NSString *ipAddress = nil;
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    NSOperationQueue * queue = [NSOperationQueue new];
    queue.maxConcurrentOperationCount = 1;
    [queue addOperationWithBlock: ^{
        Boolean result = FALSE;
        CFHostRef hostRef;
        CFArrayRef addresses;
        hostRef = CFHostCreateWithName(kCFAllocatorDefault, (__bridge CFStringRef)hostname);
        if (hostRef) {
            result = CFHostStartInfoResolution(hostRef, kCFHostAddresses, NULL); // pass an error instead of NULL here to find out why it failed
            if (result) {
                addresses = CFHostGetAddressing(hostRef, &result);
            }
        }
        if (result) {
            CFIndex index = 0;
            CFDataRef ref = (CFDataRef) CFArrayGetValueAtIndex(addresses, index);
            
            int port=0;
            struct sockaddr *addressGeneric;
            
            NSData *myData = (__bridge NSData *)ref;
            addressGeneric = (struct sockaddr *)[myData bytes];
            
            switch (addressGeneric->sa_family) {
                case AF_INET: {
                    struct sockaddr_in *ip4;
                    char dest[INET_ADDRSTRLEN];
                    ip4 = (struct sockaddr_in *)[myData bytes];
                    port = ntohs(ip4->sin_port);
                    ipAddress = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET, &ip4->sin_addr, dest, sizeof dest)];
                }
                    break;
                case AF_INET6: {
                    struct sockaddr_in6 *ip6;
                    char dest[INET6_ADDRSTRLEN];
                    ip6 = (struct sockaddr_in6 *)[myData bytes];
                    port = ntohs(ip6->sin6_port);
                    ipAddress = [NSString stringWithFormat:@"%s", inet_ntop(AF_INET6, &ip6->sin6_addr, dest, sizeof dest)];
                }
                    break;
                default:
                    ipAddress = nil;
                    break;
            }
        }
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC));
    [queue cancelAllOperations];
    CFAbsoluteTime end = CFAbsoluteTimeGetCurrent();
    
    switch (type) {
        case YXDNSResolverTypeHZGlobalConfig:
            self.hostStatus[YXHZGlobalConfigKey] = ipAddress ? @(YES) : @(NO);
            break;
        case YXDNSResolverTypeHZBuildIn:
            self.hostStatus[YXHZBuildInKey] = ipAddress ? @(YES) : @(NO);
            break;
        case YXDNSResolverTypeJYGlobalConfig:
            self.hostStatus[YXJYGlobalConfigKey] = ipAddress ? @(YES) : @(NO);
            break;
        case YXDNSResolverTypeJYBuildIn:
            self.hostStatus[YXJYBuildInKey] = ipAddress ? @(YES) : @(NO);
            break;
        case YXDNSResolverTypeWJGlobalConfig:
            self.hostStatus[YXWJGlobalConfigKey] = ipAddress ? @(YES) : @(NO);
            break;
        case YXDNSResolverTypeWJBuildIn:
            self.hostStatus[YXWJBuildInKey] = ipAddress ? @(YES) : @(NO);
            break;
        case YXDNSResolverTypeZXGlobalConfig:
            self.hostStatus[YXZXGlobalConfigKey] = ipAddress ? @(YES) : @(NO);
            break;
        case YXDNSResolverTypeZXBuildIn:
            self.hostStatus[YXZXBuildInKey] = ipAddress ? @(YES) : @(NO);
            break;
        default:
            break;
    }
    
    if (ipAddress) {
        return YES;
    } else {
        [YXRealLogger.shareInstance realLogWithType:@"DNSError" name:@"DNSError" url:hostname code:@"-1" desc:[NSString stringWithFormat:@"DNS解析错误[解析耗时: %0.3fs]", end - start] extend_msg:nil];
        return NO;
    }
}

- (BOOL)isUseHTTPProxy {
    CFDictionaryRef dicRef = CFNetworkCopySystemProxySettings();
    const CFStringRef proxyCFstr = (const CFStringRef)CFDictionaryGetValue(dicRef, (const void*)kCFNetworkProxiesHTTPProxy);
    NSString *proxy = (__bridge NSString *)proxyCFstr;
    if (proxy) {
       return YES;
    } else {
       return NO;
    }
}

- (BOOL)httpDNSAllowed {
    return ![self isUseHTTPProxy] && [YXConstant httpDnsEnable] && [YXGlobalConfigManager configFrequency:YXGlobalConfigParameterTypeHttpDNSEnable] == 1;
}
@end
