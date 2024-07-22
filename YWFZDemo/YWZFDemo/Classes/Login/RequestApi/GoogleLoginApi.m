//
//  GoogleLoginApi.m
//  ZZZZZ
//
//  Created by YW on 2/5/17.
//  Copyright © 2018年 YW. All rights reserved.
//

#import "GoogleLoginApi.h"
#import "NSStringUtils.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@implementation GoogleLoginApi
{
    NSMutableDictionary *_dict;
}

- (instancetype)initWithDict:(NSMutableDictionary *)dict {
    if (self = [super init]) {
        _dict = dict;
    }
    return self;
}

- (BOOL)enableCache {
    return YES;
}

-(BOOL)encryption {
    return NO;
}

- (NSURLRequestCachePolicy)requestCachePolicy {
    return NSURLRequestReloadIgnoringCacheData;
}

- (NSString *)requestPath {
    return [NSStringUtils buildRequestPath:@""];
}


- (id)requestParameters {
    return @{
             @"action"       : @"User/googleLogin",
             @"sess_id"      : SESSIONID,
             @"email"        : NullFilter(_dict[@"email"]),
             @"googleId"     : NullFilter(_dict[@"googleId"]),
             @"sex"          : NullFilter(_dict[@"sex"]),
             @"access_token" : NullFilter(_dict[@"access_token"]),
             @"nickname"     : NullFilter(_dict[@"nickname"]),
             @"wj_linkid"    : [NSStringUtils getLkid],
             @"is_enc"       : @"0",
             @"af_uid"       : ZFToString([AppsFlyerTracker sharedTracker].getAppsFlyerUID),
             @"source"       : ZFToString(_dict[@"source"]),
             @"device_id"    : ZFToString([AccountManager sharedManager].device_id)
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}



- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}


@end
