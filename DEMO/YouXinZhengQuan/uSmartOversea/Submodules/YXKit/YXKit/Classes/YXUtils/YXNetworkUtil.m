//
//  YXNetworkUtil.m
//  YouXinZhengQuan
//
//  Created by 胡华翔 on 2019/1/3.
//  Copyright © 2019 RenRenDai. All rights reserved.
//

#import "YXNetworkUtil.h"
#import "HLNetWorkReachability.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@implementation YXNetworkUtil
static YXNetworkUtil *_singleTon = nil;

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _singleTon = [[super allocWithZone:NULL] init];
    });
    
    return _singleTon;
}

+ (id)allocWithZone:(NSZone *)zone
{
    return [YXNetworkUtil sharedInstance];
}

- (id)copyWithZone:(NSZone *)zone
{
    return [YXNetworkUtil sharedInstance];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _reachability = [HLNetWorkReachability reachabilityWithHostName:@"www.baidu.com"];
    }
    return self;
}

- (void)startReachabilityNotifier {
    [self.reachability startNotifier];
}

- (void)stopReachabilityNotifier {
    [self.reachability stopNotifier];
}

- (NSString *)networkType {
    HLNetWorkStatus netStatus = [self.reachability currentReachabilityStatus];
    switch (netStatus) {
        case HLNetWorkStatusNotReachable:
            return @"unavailable";
        case HLNetWorkStatusUnknown:
            return @"unknow";
        case HLNetWorkStatusWWAN2G:
            return @"n2";
        case HLNetWorkStatusWWAN3G:
            return @"n3";
        case HLNetWorkStatusWWAN4G:
            return @"n4";
        case HLNetWorkStatusWWAN5G:
            return @"n5";
        case HLNetWorkStatusWiFi:
            return @"n1";
        default:
            break;
    }
    return @"unknow";
}

+ (NSString *)operatorInfomation {
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = [info subscriberCellularProvider];
    if (carrier == nil) {
        return @"unknow";
    }
    NSString *code = [carrier mobileNetworkCode];
    if (code == nil) {
        return @"unknow";
    }
    if ([code isEqualToString:@"00"] || [code isEqualToString:@"02"] || [code isEqualToString:@"07"]) {
        return @"CMCC";
    } else if ([code isEqualToString:@"01"] || [code isEqualToString:@"06"]) {
        return @"CUCC";
    } else if ([code isEqualToString:@"03"] || [code isEqualToString:@"05"]) {
        return @"CTCC";
    } else if ([code isEqualToString:@"20"]) {
        return @"CRC";
    }
    return @"unknow";
}
@end
