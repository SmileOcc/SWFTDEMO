//
//  ZFVKontakteApi.m
//  ZZZZZ
//
//  Created by YW on 2019/11/29.
//  Copyright © 2019 ZZZZZ. All rights reserved.
//

#import "ZFVKontakteApi.h"
#import "NSStringUtils.h"
#import "ZFAnalytics.h"
#import "YWCFunctionTool.h"
#import "Constants.h"

@implementation ZFVKontakteApi

{
    NSMutableDictionary *_dict;
}

- (instancetype)initWithDict:(NSMutableDictionary *)dict{
    self = [super init];
    if (self) {
        _dict = dict;
    }
    return self;
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
             @"action"       : @"user/vk_login",
             @"sess_id"      : SESSIONID,
             @"vk_userId"    : NullFilter(_dict[@"vk_userId"]),
             @"email"        : NullFilter(_dict[@"email"]),
             @"sex"          : NullFilter(_dict[@"sex"]),
             @"access_token" : NullFilter(_dict[@"access_token"]),
             @"nickname"     : NullFilter(_dict[@"nickname"]),
             @"wj_linkid"    : [NSStringUtils getLkid],
             @"is_enc"       :  @"0",
             @"af_uid"       : ZFToString([AppsFlyerTracker sharedTracker].getAppsFlyerUID),
             @"birthday"     : _dict[@"birthday"],
             @"source"       : ZFToString(_dict[@"source"]),
             };
}

- (SYRequestMethod)requestMethod {
    return SYRequestMethodPOST;
}


- (SYRequestSerializerType)requestSerializerType {
    return SYRequestSerializerTypeJSON;
}

@end
